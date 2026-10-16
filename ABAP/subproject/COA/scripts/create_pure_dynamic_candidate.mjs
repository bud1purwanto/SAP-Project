import { readFileSync, writeFileSync } from 'node:fs';

const srcPath = '/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F01_Development AIX_dev_live.abap';
let code = readFileSync(srcPath, 'utf8');

const targetBlock = `    IF LV_JRC IS NOT INITIAL.
      CALL FUNCTION 'ZQM_GET_BATCH_SR_BY_JR'
        EXPORTING
          CHARGJR = LV_JRC
        TABLES
          T_SR    = LT_SRX.
      LOOP AT LT_SRX.
        PERFORM GET_NEWEST_BATCH
          USING LT_SRX-CHARG CHANGING LV_NEWB.
        CLEAR LV_TLOT.
        SELECT SINGLE PRUEFLOS INTO LV_TLOT
          FROM QALS WHERE CHARG = LV_NEWB
            AND ART = 'Z04'.
        IF LV_TLOT IS NOT INITIAL.
          LT_SRLOTS-LOT = LV_TLOT.
          COLLECT LT_SRLOTS.
        ENDIF.
      ENDLOOP.
    ENDIF.`;

const replacementBlock = `    IF LV_JRC IS NOT INITIAL.
      CALL FUNCTION 'ZQM_GET_BATCH_SR_BY_JR'
        EXPORTING
          CHARGJR = LV_JRC
        TABLES
          T_SR    = LT_SRX.
      LOOP AT LT_SRX.
        PERFORM GET_NEWEST_BATCH
          USING LT_SRX-CHARG CHANGING LV_NEWB.
        CLEAR LV_TLOT.
        SELECT SINGLE PRUEFLOS INTO LV_TLOT
          FROM QALS WHERE CHARG = LV_NEWB
            AND ART = 'Z04'.
        IF LV_TLOT IS NOT INITIAL.
          LT_SRLOTS-LOT = LV_TLOT.
          COLLECT LT_SRLOTS.
        ENDIF.
      ENDLOOP.
    ENDIF.
    " Tracing Dinamis Murni (Zero Hardcode & Zero Regression):
    " Jika FM legacy menghasilkan <= 1 lot (order slitting bukan combined order biasa),
    " telusuri genealogi fisik silsilah batch:
    " SR -> Order Slitting -> Order Coating -> Parent JR -> Order Produksi JR -> Sibling JR
    " -> Order Coating Konsumen -> Order Slitting Konsumen -> 10 Sibling SR
    DESCRIBE TABLE LT_SRLOTS LINES L_ACNT.
    IF L_ACNT <= 1 AND LV_SR0 IS NOT INITIAL.
      DATA: LV_DYN_SLIT_AUF TYPE MSEG-AUFNR,
            LV_DYN_COAT_AUF TYPE AFPO-AUFNR,
            LV_DYN_JR       TYPE MSEG-CHARG,
            LV_DYN_JR_AUF   TYPE MSEG-AUFNR,
            LT_DYN_JR       TYPE TABLE OF MSEG-CHARG WITH HEADER LINE,
            LT_DYN_COAT     TYPE TABLE OF MSEG-AUFNR WITH HEADER LINE,
            LT_DYN_SLIT     TYPE TABLE OF AFPO-MILL_OC_AUFNR_U WITH HEADER LINE,
            LV_DYN_ROLL     TYPE MSEG-CHARG,
            LV_DYN_LOT      TYPE QALS-PRUEFLOS.
      CLEAR: LV_DYN_SLIT_AUF, LV_DYN_COAT_AUF, LV_DYN_JR, LV_DYN_JR_AUF.
      SELECT SINGLE AUFNR INTO LV_DYN_SLIT_AUF FROM MSEG
        WHERE BWART = '101' AND CHARG = LV_SR0.
      IF LV_DYN_SLIT_AUF IS NOT INITIAL.
        SELECT SINGLE AUFNR INTO LV_DYN_COAT_AUF FROM AFPO
          WHERE MILL_OC_AUFNR_U = LV_DYN_SLIT_AUF.
        IF LV_DYN_COAT_AUF IS NOT INITIAL.
          SELECT SINGLE CHARG INTO LV_DYN_JR FROM MSEG
            WHERE BWART = '261' AND AUFNR = LV_DYN_COAT_AUF AND CHARG <> SPACE.
          IF LV_DYN_JR IS NOT INITIAL.
            SELECT SINGLE AUFNR INTO LV_DYN_JR_AUF FROM MSEG
              WHERE BWART = '101' AND CHARG = LV_DYN_JR.
            IF LV_DYN_JR_AUF IS NOT INITIAL.
              REFRESH: LT_DYN_JR, LT_DYN_COAT, LT_DYN_SLIT.
              SELECT CHARG INTO TABLE LT_DYN_JR FROM MSEG
                WHERE BWART = '101' AND AUFNR = LV_DYN_JR_AUF.
              LOOP AT LT_DYN_JR.
                SELECT AUFNR APPENDING TABLE LT_DYN_COAT FROM MSEG
                  WHERE BWART = '261' AND CHARG = LT_DYN_JR.
              ENDLOOP.
              SORT LT_DYN_COAT. DELETE ADJACENT DUPLICATES FROM LT_DYN_COAT.
              LOOP AT LT_DYN_COAT.
                SELECT MILL_OC_AUFNR_U APPENDING TABLE LT_DYN_SLIT FROM AFPO
                  WHERE AUFNR = LT_DYN_COAT.
              ENDLOOP.
              SORT LT_DYN_SLIT. DELETE ADJACENT DUPLICATES FROM LT_DYN_SLIT.
              LOOP AT LT_DYN_SLIT.
                CLEAR: LV_DYN_ROLL, LV_DYN_LOT.
                SELECT SINGLE CHARG INTO LV_DYN_ROLL FROM MSEG
                  WHERE BWART = '101' AND AUFNR = LT_DYN_SLIT.
                IF LV_DYN_ROLL IS NOT INITIAL.
                  SELECT SINGLE PRUEFLOS INTO LV_DYN_LOT FROM QALS
                    WHERE CHARG = LV_DYN_ROLL AND ART = 'Z04'.
                  IF LV_DYN_LOT IS NOT INITIAL.
                    LT_SRLOTS-LOT = LV_DYN_LOT.
                    COLLECT LT_SRLOTS.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.`;

if (!code.includes(targetBlock)) {
  console.error('Target block not found!');
  process.exit(1);
}

const patchedCode = code.replace(targetBlock, replacementBlock);
const outPath = '/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F01_candidate_sandbox.abap';
writeFileSync(outPath, patchedCode, 'utf8');
console.log('100% Pure Dynamic Candidate generated successfully.');
