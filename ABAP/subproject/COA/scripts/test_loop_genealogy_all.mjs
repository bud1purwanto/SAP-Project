import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const testCases = [
  { sc: 'QM01', doNum: '0085006234', batch: '0000405751' },
  { sc: 'QM02', doNum: '0085006235', batch: '0000405546' },
  { sc: 'QM03', doNum: '0085006240', batch: '0000405583' },
  { sc: 'QM04', doNum: '0085006241', batch: '0000405609' },
  { sc: 'QM05', doNum: '0085006242', batch: '0000405831' },
  { sc: 'QM07', doNum: '0085006243', batch: '0000405629' },
  { sc: 'QM09', doNum: '0085006244', batch: '0000405828' },
  { sc: 'QM10', doNum: '0085006245', batch: '0000405699' }
];

for (const tc of testCases) {
  const rawLines = [
    'REPORT ZTEST_LOOP_TRACE.',
    'TABLES: MSEG, MCH1, QALS.',
    'TYPES: BEGIN OF TY_LOT,',
    '         STAGE TYPE C LENGTH 2, CAT TYPE C LENGTH 4,',
    '         CHARG TYPE MCH1-CHARG, LOT TYPE QALS-PRUEFLOS,',
    '       END OF TY_LOT.',
    'DATA: GT_LOTS TYPE TABLE OF TY_LOT WITH HEADER LINE,',
    '      LV_CURR_CHARG TYPE MCH1-CHARG, LV_MATNR TYPE MCH1-MATNR,',
    '      LV_AUFNR TYPE MSEG-AUFNR, LV_COMP TYPE MSEG-CHARG,',
    '      LV_LICHA TYPE MCH1-LICHA, LV_JR TYPE MCH1-CHARG,',
    '      LV_LOT TYPE QALS-PRUEFLOS, LV_ITER TYPE I.',
    '',
    `LV_CURR_CHARG = '${tc.batch}'.`,
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
    '      GT_LOTS-STAGE = \'SR\'. GT_LOTS-CAT = \'CONV\'.',
    '      GT_LOTS-CHARG = LV_CURR_CHARG. GT_LOTS-LOT = LV_LOT.',
    '      APPEND GT_LOTS.',
    '    ENDIF.',
    '    CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\'',
    '      EXPORTING CHARG_S = LV_CURR_CHARG IMPORTING CHARG_J = LV_JR.',
    '    IF LV_JR IS NOT INITIAL.',
    '      SELECT SINGLE MATNR INTO LV_MATNR FROM MCH1 WHERE CHARG = LV_JR.',
    '      SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS',
    '        WHERE CHARG = LV_JR AND ( ART = \'Z02\' OR ART = \'Z03\' ).',
    '      IF LV_LOT IS NOT INITIAL.',
    '        GT_LOTS-STAGE = \'JR\'.',
    '        IF LV_MATNR CS \'AH\' OR LV_MATNR CS \'AS\'.',
    '          GT_LOTS-CAT = \'BASE\'.',
    '        ELSE.',
    '          GT_LOTS-CAT = \'CONV\'.',
    '        ENDIF.',
    '        GT_LOTS-CHARG = LV_JR. GT_LOTS-LOT = LV_LOT.',
    '        APPEND GT_LOTS.',
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
    'WRITE: / \'TC:\', \'' + tc.sc + '\'.',
    'LOOP AT GT_LOTS.',
    '  WRITE: / \'  ->\', GT_LOTS-STAGE, GT_LOTS-CAT, GT_LOTS-CHARG, GT_LOTS-LOT.',
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
}
