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
    " Tracing Dinamis Murni (Zero Hardcode & Full Cancellation-Aware):
    " Jika FM legacy menghasilkan <= 1 lot, telusuri genealogi fisik silsilah batch
    " dengan validasi pembatalan transaksi (Cancellation check: 102/262, SMBLN).
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
      DATA: LT_DYN_M101 TYPE TABLE OF MSEG WITH HEADER LINE,
            LT_DYN_M261 TYPE TABLE OF MSEG WITH HEADER LINE,
            LT_DYN_CANC TYPE TABLE OF MSEG WITH HEADER LINE.
      CLEAR: LV_DYN_SLIT_AUF, LV_DYN_COAT_AUF, LV_DYN_JR, LV_DYN_JR_AUF.

      " 1. Cari Order Slitting dari SR GR (101/102) dengan cek cancellation
      REFRESH: LT_DYN_M101, LT_DYN_CANC.
      SELECT * INTO TABLE LT_DYN_M101 FROM MSEG
        WHERE CHARG = LV_SR0 AND ( BWART = '101' OR BWART = '102' ).
      IF LT_DYN_M101[] IS NOT INITIAL.
        LT_DYN_CANC[] = LT_DYN_M101[].
        DELETE LT_DYN_CANC WHERE SMBLN IS INITIAL.
        LOOP AT LT_DYN_CANC.
          DELETE LT_DYN_M101 WHERE MBLNR = LT_DYN_CANC-SMBLN AND MJAHR = LT_DYN_CANC-SJAHR AND ZEILE = LT_DYN_CANC-SMBLP.
        ENDLOOP.
        DELETE LT_DYN_M101 WHERE SMBLN IS NOT INITIAL OR BWART = '102'.
        SORT LT_DYN_M101 BY MBLNR DESCENDING ZEILE DESCENDING.
        READ TABLE LT_DYN_M101 INDEX 1.
        IF SY-SUBRC = 0.
          LV_DYN_SLIT_AUF = LT_DYN_M101-AUFNR.
        ENDIF.
      ENDIF.

      IF LV_DYN_SLIT_AUF IS NOT INITIAL.
        SELECT SINGLE AUFNR INTO LV_DYN_COAT_AUF FROM AFPO
          WHERE MILL_OC_AUFNR_U = LV_DYN_SLIT_AUF.
        IF LV_DYN_COAT_AUF IS NOT INITIAL.
          " 2. Cari Parent JR yang dikonsumsi (261/262) dengan cek cancellation
          REFRESH: LT_DYN_M261, LT_DYN_CANC.
          SELECT * INTO TABLE LT_DYN_M261 FROM MSEG
            WHERE AUFNR = LV_DYN_COAT_AUF AND ( BWART = '261' OR BWART = '262' ) AND CHARG <> SPACE.
          IF LT_DYN_M261[] IS NOT INITIAL.
            LT_DYN_CANC[] = LT_DYN_M261[].
            DELETE LT_DYN_CANC WHERE SMBLN IS INITIAL.
            LOOP AT LT_DYN_CANC.
              DELETE LT_DYN_M261 WHERE MBLNR = LT_DYN_CANC-SMBLN AND MJAHR = LT_DYN_CANC-SJAHR AND ZEILE = LT_DYN_CANC-SMBLP.
            ENDLOOP.
            DELETE LT_DYN_M261 WHERE SMBLN IS NOT INITIAL OR BWART = '262'.
            SORT LT_DYN_M261 BY MBLNR DESCENDING ZEILE DESCENDING.
            READ TABLE LT_DYN_M261 INDEX 1.
            IF SY-SUBRC = 0.
              LV_DYN_JR = LT_DYN_M261-CHARG.
            ENDIF.
          ENDIF.

          IF LV_DYN_JR IS NOT INITIAL.
            " 3. Cari Order Produksi JR asal (101/102) dengan cek cancellation
            REFRESH: LT_DYN_M101, LT_DYN_CANC.
            SELECT * INTO TABLE LT_DYN_M101 FROM MSEG
              WHERE CHARG = LV_DYN_JR AND ( BWART = '101' OR BWART = '102' ).
            IF LT_DYN_M101[] IS NOT INITIAL.
              LT_DYN_CANC[] = LT_DYN_M101[].
              DELETE LT_DYN_CANC WHERE SMBLN IS INITIAL.
              LOOP AT LT_DYN_CANC.
                DELETE LT_DYN_M101 WHERE MBLNR = LT_DYN_CANC-SMBLN AND MJAHR = LT_DYN_CANC-SJAHR AND ZEILE = LT_DYN_CANC-SMBLP.
              ENDLOOP.
              DELETE LT_DYN_M101 WHERE SMBLN IS NOT INITIAL OR BWART = '102'.
              SORT LT_DYN_M101 BY MBLNR DESCENDING ZEILE DESCENDING.
              READ TABLE LT_DYN_M101 INDEX 1.
              IF SY-SUBRC = 0.
                LV_DYN_JR_AUF = LT_DYN_M101-AUFNR.
              ENDIF.
            ENDIF.

            IF LV_DYN_JR_AUF IS NOT INITIAL.
              " 4. Kumpulkan seluruh Roll JR Sibling yang valid (tidak dicancel)
              REFRESH: LT_DYN_JR, LT_DYN_COAT, LT_DYN_SLIT, LT_DYN_M101, LT_DYN_CANC.
              SELECT * INTO TABLE LT_DYN_M101 FROM MSEG
                WHERE AUFNR = LV_DYN_JR_AUF AND ( BWART = '101' OR BWART = '102' ).
              IF LT_DYN_M101[] IS NOT INITIAL.
                LT_DYN_CANC[] = LT_DYN_M101[].
                DELETE LT_DYN_CANC WHERE SMBLN IS INITIAL.
                LOOP AT LT_DYN_CANC.
                  DELETE LT_DYN_M101 WHERE MBLNR = LT_DYN_CANC-SMBLN AND MJAHR = LT_DYN_CANC-SJAHR AND ZEILE = LT_DYN_CANC-SMBLP.
                ENDLOOP.
                DELETE LT_DYN_M101 WHERE SMBLN IS NOT INITIAL OR BWART = '102'.
                LOOP AT LT_DYN_M101.
                  IF LT_DYN_M101-CHARG IS NOT INITIAL.
                    LT_DYN_JR = LT_DYN_M101-CHARG.
                    COLLECT LT_DYN_JR.
                  ENDIF.
                ENDLOOP.
              ENDIF.

              " 5. Telusuri Order Coating Konsumen untuk tiap JR (valid 261 non-cancelled)
              LOOP AT LT_DYN_JR.
                REFRESH: LT_DYN_M261, LT_DYN_CANC.
                SELECT * INTO TABLE LT_DYN_M261 FROM MSEG
                  WHERE CHARG = LT_DYN_JR AND ( BWART = '261' OR BWART = '262' ).
                IF LT_DYN_M261[] IS NOT INITIAL.
                  LT_DYN_CANC[] = LT_DYN_M261[].
                  DELETE LT_DYN_CANC WHERE SMBLN IS INITIAL.
                  LOOP AT LT_DYN_CANC.
                    DELETE LT_DYN_M261 WHERE MBLNR = LT_DYN_CANC-SMBLN AND MJAHR = LT_DYN_CANC-SJAHR AND ZEILE = LT_DYN_CANC-SMBLP.
                  ENDLOOP.
                  DELETE LT_DYN_M261 WHERE SMBLN IS NOT INITIAL OR BWART = '262'.
                  LOOP AT LT_DYN_M261.
                    IF LT_DYN_M261-AUFNR IS NOT INITIAL.
                      LT_DYN_COAT = LT_DYN_M261-AUFNR.
                      COLLECT LT_DYN_COAT.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
              ENDLOOP.

              " 6. Telusuri Order Slitting Konsumen via AFPO
              LOOP AT LT_DYN_COAT.
                SELECT MILL_OC_AUFNR_U APPENDING TABLE LT_DYN_SLIT FROM AFPO
                  WHERE AUFNR = LT_DYN_COAT.
              ENDLOOP.
              SORT LT_DYN_SLIT. DELETE ADJACENT DUPLICATES FROM LT_DYN_SLIT.

              " 7. Kumpulkan Lot Inspeksi SR yang valid (tidak dicancel GR 101-nya)
              LOOP AT LT_DYN_SLIT.
                CLEAR: LV_DYN_ROLL, LV_DYN_LOT.
                REFRESH: LT_DYN_M101, LT_DYN_CANC.
                SELECT * INTO TABLE LT_DYN_M101 FROM MSEG
                  WHERE AUFNR = LT_DYN_SLIT AND ( BWART = '101' OR BWART = '102' ).
                IF LT_DYN_M101[] IS NOT INITIAL.
                  LT_DYN_CANC[] = LT_DYN_M101[].
                  DELETE LT_DYN_CANC WHERE SMBLN IS INITIAL.
                  LOOP AT LT_DYN_CANC.
                    DELETE LT_DYN_M101 WHERE MBLNR = LT_DYN_CANC-SMBLN AND MJAHR = LT_DYN_CANC-SJAHR AND ZEILE = LT_DYN_CANC-SMBLP.
                  ENDLOOP.
                  DELETE LT_DYN_M101 WHERE SMBLN IS NOT INITIAL OR BWART = '102'.
                  SORT LT_DYN_M101 BY MBLNR DESCENDING ZEILE DESCENDING.
                  READ TABLE LT_DYN_M101 INDEX 1.
                  IF SY-SUBRC = 0.
                    LV_DYN_ROLL = LT_DYN_M101-CHARG.
                  ENDIF.
                ENDIF.

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
console.log('Candidate with cancellation awareness created successfully.');
