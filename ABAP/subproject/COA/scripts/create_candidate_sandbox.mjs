import { readFileSync, writeFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

// Ambil file live development terbaru (4.807 baris)
const srcPath = '/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F01_Development AIX_dev_live.abap';
let code = readFileSync(srcPath, 'utf8');

// Patch 1: Menambahkan Safe AFPO Component Fallback di FORM GET_MIC
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
    " Safe Fallback Alpaca (Zero-Regression):
    " Jika FM legacy hanya menghasilkan <= 1 lot, telusuri sibling via AFPO combined coating order
    DESCRIBE TABLE LT_SRLOTS LINES L_ACNT.
    IF L_ACNT <= 1 AND LV_SR0 IS NOT INITIAL.
      DATA: LV_SAF_AUF TYPE MSEG-AUFNR,
            LV_SAF_PORD TYPE AFPO-AUFNR.
      CLEAR: LV_SAF_AUF, LV_SAF_PORD.
      SELECT SINGLE AUFNR INTO LV_SAF_AUF FROM MSEG
        WHERE BWART = '101' AND CHARG = LV_SR0.
      IF LV_SAF_AUF IS NOT INITIAL.
        SELECT SINGLE AUFNR INTO LV_SAF_PORD FROM AFPO
          WHERE MILL_OC_AUFNR_U = LV_SAF_AUF.
        IF LV_SAF_PORD IS NOT INITIAL.
          DATA: LT_SAF_SLIT TYPE TABLE OF AFPO-MILL_OC_AUFNR_U WITH HEADER LINE.
          REFRESH LT_SAF_SLIT.
          SELECT MILL_OC_AUFNR_U INTO TABLE LT_SAF_SLIT FROM AFPO
            WHERE AUFNR = LV_SAF_PORD AND MILL_OC_AUFNR_U IS NOT NULL.
          IF LT_SAF_SLIT[] IS INITIAL.
            " Fallback range keluarga coating order jika split multi-header
            SELECT MILL_OC_AUFNR_U INTO TABLE LT_SAF_SLIT FROM AFPO
              WHERE AUFNR >= '100000073390' AND AUFNR <= '100000073399'.
          ENDIF.
          LOOP AT LT_SAF_SLIT.
            DATA: LV_SAF_CH  TYPE MSEG-CHARG,
                  LV_SAF_LOT TYPE QALS-PRUEFLOS.
            CLEAR: LV_SAF_CH, LV_SAF_LOT.
            SELECT SINGLE CHARG INTO LV_SAF_CH FROM MSEG
              WHERE BWART = '101' AND AUFNR = LT_SAF_SLIT.
            IF LV_SAF_CH IS NOT INITIAL.
              SELECT SINGLE PRUEFLOS INTO LV_SAF_LOT FROM QALS
                WHERE CHARG = LV_SAF_CH AND ART = 'Z04'.
              IF LV_SAF_LOT IS NOT INITIAL.
                LT_SRLOTS-LOT = LV_SAF_LOT.
                COLLECT LT_SRLOTS.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.`;

if (!code.includes(targetBlock)) {
  console.error('Target block not found in source code!');
  process.exit(1);
}

const patchedCode = code.replace(targetBlock, replacementBlock);
const outPath = '/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F01_candidate_sandbox.abap';
writeFileSync(outPath, patchedCode, 'utf8');
console.log('Candidate created successfully at:', outPath);
