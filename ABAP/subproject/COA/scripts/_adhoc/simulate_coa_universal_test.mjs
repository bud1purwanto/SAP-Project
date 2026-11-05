import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZSIM_COA_UNIVERSAL_TEST.',
  'TABLES: MSEG, MCH1, QALS, QAMV, QAMR, ZMAP_COA.',
  'TYPES: BEGIN OF TY_LOT,',
  '         STAGE TYPE C LENGTH 2, CAT TYPE C LENGTH 4,',
  '         CHARG TYPE MCH1-CHARG, LOT TYPE QALS-PRUEFLOS,',
  '       END OF TY_LOT.',
  'DATA: GT_LOTS TYPE TABLE OF TY_LOT,',
  '      GS_LOT  TYPE TY_LOT,',
  '      LT_VISITED TYPE TABLE OF MCH1-CHARG WITH HEADER LINE.',
  'DATA: LV_CURR_CHARG TYPE MCH1-CHARG, LV_MATNR TYPE MCH1-MATNR,',
  '      LV_AUFNR TYPE MSEG-AUFNR, LV_COMP TYPE MSEG-CHARG,',
  '      LV_LICHA TYPE MCH1-LICHA, LV_JR TYPE MCH1-CHARG,',
  '      LV_LOT TYPE QALS-PRUEFLOS, LV_ITER TYPE I,',
  '      LV_LEN TYPE I, LV_TEMP TYPE I.',
  'DATA: BEGIN OF LT_ZMAP OCCURS 0,',
  '        MIC TYPE ZMAP_COA-MIC,',
  '        MAPPING TYPE ZMAP_COA-MAPPING,',
  '        MIC_DESC TYPE ZMAP_COA-MIC_DESC,',
  '      END OF LT_ZMAP.',
  'DATA: LV_MK TYPE QAMV-MERKNR, LV_MW TYPE QAMR-MITTELWERT,',
  '      LV_AZ TYPE QAMR-ANZWERTG, LV_T_STAGE TYPE C LENGTH 2,',
  '      LV_T_CAT TYPE C LENGTH 4, LV_FOUND_LOT TYPE QALS-PRUEFLOS.',
  '',
  'LV_CURR_CHARG = \'0000406850\'.',
  'DO 10 TIMES.',
  '  LV_ITER = SY-INDEX.',
  '  READ TABLE LT_VISITED WITH KEY TABLE_LINE = LV_CURR_CHARG.',
  '  IF SY-SUBRC = 0. EXIT. ENDIF.',
  '  LT_VISITED = LV_CURR_CHARG. APPEND LT_VISITED.',
  '  SELECT SINGLE MATNR LICHA INTO (LV_MATNR, LV_LICHA) FROM MCH1',
  '    WHERE CHARG = LV_CURR_CHARG.',
  '  IF SY-SUBRC <> 0. EXIT. ENDIF.',
  '  LV_LEN = STRLEN( LV_MATNR ). LV_TEMP = LV_LEN - 1.',
  '  IF LV_MATNR(2) = \'SR\' AND ( LV_MATNR+LV_TEMP(1) = \'A\' OR LV_MATNR+LV_TEMP(1) = \'O\' ).',
  '    IF LV_LICHA IS NOT INITIAL. LV_CURR_CHARG = LV_LICHA. ENDIF.',
  '  ENDIF.',
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
  '        WHERE CHARG = LV_JR AND ( ART = \'Z01\' OR ART = \'Z02\' OR ART = \'Z03\' ).',
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
  '        IF LV_COMP IS NOT INITIAL. LV_CURR_CHARG = LV_COMP.',
  '        ELSE. EXIT. ENDIF.',
  '      ELSE. EXIT. ENDIF.',
  '    ELSE. EXIT. ENDIF.',
  '  ELSE. EXIT. ENDIF.',
  'ENDDO.',
  '',
  'WRITE: / \'=== REKAP LENGKAP PENARIKAN COA DENGAN UNIVERSAL LOOP ===\'.',
  'SELECT MIC MAPPING MIC_DESC FROM ZMAP_COA INTO TABLE LT_ZMAP',
  '  WHERE MATNR = \'SRGLBI\'.',
  'SORT LT_ZMAP BY MIC.',
  'DELETE ADJACENT DUPLICATES FROM LT_ZMAP COMPARING MIC.',
  'LOOP AT LT_ZMAP.',
  '  CLEAR: LV_T_STAGE, LV_T_CAT, LV_FOUND_LOT, LV_MK, LV_MW.',
  '  IF LT_ZMAP-MAPPING CS \'JR\'. LV_T_STAGE = \'JR\'.',
  '  ELSEIF LT_ZMAP-MAPPING CS \'SR\'. LV_T_STAGE = \'SR\'. ENDIF.',
  '  IF LT_ZMAP-MAPPING CS \'Base\'. LV_T_CAT = \'BASE\'.',
  '  ELSEIF LT_ZMAP-MAPPING CS \'Converting\'. LV_T_CAT = \'CONV\'. ENDIF.',
  '  LOOP AT GT_LOTS INTO GS_LOT WHERE STAGE = LV_T_STAGE',
  '                                AND CAT   = LV_T_CAT.',
  '    SELECT SINGLE MERKNR INTO LV_MK FROM QAMV',
  '      WHERE PRUEFLOS = GS_LOT-LOT AND VERWMERKM = LT_ZMAP-MIC.',
  '    IF SY-SUBRC = 0.',
  '      SELECT SINGLE MITTELWERT ANZWERTG INTO (LV_MW, LV_AZ) FROM QAMR',
  '        WHERE PRUEFLOS = GS_LOT-LOT AND MERKNR = LV_MK.',
  '      IF LV_AZ > 0 OR LV_MW IS NOT INITIAL.',
  '        LV_FOUND_LOT = GS_LOT-LOT.',
  '        EXIT.',
  '      ENDIF.',
  '    ENDIF.',
  '  ENDLOOP.',
  '  WRITE: / LT_ZMAP-MIC, \'|\', LT_ZMAP-MAPPING, \'|\',',
  '           LT_ZMAP-MIC_DESC, \'|\',',
  '           \'Lot:\', LV_FOUND_LOT, \'|\', \'Val:\', LV_MW.',
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
