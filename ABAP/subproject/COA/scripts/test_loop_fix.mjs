import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZTEST_LOOP_FIX.',
  'TABLES: MSEG, MCH1, QALS.',
  'TYPES: BEGIN OF TY_LOT,',
  '         STAGE TYPE C LENGTH 2, CAT TYPE C LENGTH 4,',
  '         CHARG TYPE MCH1-CHARG, LOT TYPE QALS-PRUEFLOS,',
  '       END OF TY_LOT.',
  'DATA: GT_LOTS TYPE TABLE OF TY_LOT,',
  '      GS_LOT  TYPE TY_LOT.',
  'DATA: LV_CURR_CHARG TYPE MCH1-CHARG, LV_MATNR TYPE MCH1-MATNR,',
  '      LV_AUFNR TYPE MSEG-AUFNR, LV_COMP TYPE MSEG-CHARG,',
  '      LV_LICHA TYPE MCH1-LICHA, LV_JR TYPE MCH1-CHARG,',
  '      LV_LOT TYPE QALS-PRUEFLOS, LV_ITER TYPE I.',
  '',
  'LV_CURR_CHARG = \'0000405583\'.',
  'DO 10 TIMES.',
  '  LV_ITER = SY-INDEX.',
  '  SELECT SINGLE MATNR LICHA INTO (LV_MATNR, LV_LICHA) FROM MCH1',
  '    WHERE CHARG = LV_CURR_CHARG.',
  '  IF SY-SUBRC <> 0. EXIT. ENDIF.',
  '  IF LV_LICHA IS NOT INITIAL. LV_CURR_CHARG = LV_LICHA. ENDIF.',
  '  SELECT SINGLE MATNR INTO LV_MATNR FROM MCH1 WHERE CHARG = LV_CURR_CHARG.',
  '  IF LV_MATNR(2) = \'SR\'.',
  '    SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS',
  '      WHERE CHARG = LV_CURR_CHARG AND ART = \'Z04\'.',
  '    IF LV_LOT IS NOT INITIAL.',
  '      GS_LOT-STAGE = \'SR\'. GS_LOT-CAT = \'CONV\'.',
  '      GS_LOT-CHARG = LV_CURR_CHARG. GS_LOT-LOT = LV_LOT.',
  '      APPEND GS_LOT TO GT_LOTS.',
  '    ENDIF.',
  '    CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\'',
  '      EXPORTING CHARG_S = LV_CURR_CHARG IMPORTING CHARG_J = LV_JR.',
  '    IF LV_JR IS NOT INITIAL.',
  '      SELECT SINGLE MATNR INTO LV_MATNR FROM MCH1 WHERE CHARG = LV_JR.',
  '      SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS',
  '        WHERE CHARG = LV_JR AND ( ART = \'Z02\' OR ART = \'Z03\' ).',
  '      IF LV_LOT IS NOT INITIAL.',
  '        GS_LOT-STAGE = \'JR\'.',
  '        IF LV_MATNR CS \'AH\' OR LV_MATNR CS \'AS\'.',
  '          GS_LOT-CAT = \'BASE\'.',
  '        ELSE.',
  '          GS_LOT-CAT = \'CONV\'.',
  '        ENDIF.',
  '        GS_LOT-CHARG = LV_JR. GS_LOT-LOT = LV_LOT.',
  '        APPEND GS_LOT TO GT_LOTS.',
  '      ENDIF.',
  '      CLEAR LV_AUFNR.',
  '      SELECT SINGLE AUFNR INTO LV_AUFNR FROM MSEG',
  '        WHERE BWART = \'101\' AND CHARG = LV_JR.',
  '      IF LV_AUFNR IS NOT INITIAL.',
  '        SELECT SINGLE CHARG INTO LV_COMP FROM MSEG',
  '          WHERE BWART = \'261\' AND AUFNR = LV_AUFNR AND CHARG <> space.',
  '        IF LV_COMP IS NOT INITIAL.',
  '          LV_CURR_CHARG = LV_COMP.',
  '        ELSE.',
  '          EXIT.',
  '        ENDIF.',
  '      ELSE.',
  '        EXIT.',
  '      ENDIF.',
  '    ELSE.',
  '      EXIT.',
  '    ENDIF.',
  '  ELSE.',
  '    EXIT.',
  '  ENDIF.',
  'ENDDO.',
  'WRITE: / \'TC: QM03\'.',
  'LOOP AT GT_LOTS INTO GS_LOT.',
  '  WRITE: / \'  ->\', GS_LOT-STAGE, GS_LOT-CAT, GS_LOT-CHARG, GS_LOT-LOT.',
  'ENDLOOP.'
];

const formatted = [];
for (const l of rawLines) {
  if (l.length > 72) {
    const idx = l.lastIndexOf(' ', 70);
    formatted.push(l.slice(0, idx));
    formatted.push('  ' + l.slice(idx + 1));
  } else {
    formatted.push(l);
  }
}

const resp = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: formatted.map(LINE => ({ LINE })),
    WRITES: []
  }
});
if (resp.result?.ERRORMESSAGE) console.error(resp.result.ERRORMESSAGE);
else console.log(resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
