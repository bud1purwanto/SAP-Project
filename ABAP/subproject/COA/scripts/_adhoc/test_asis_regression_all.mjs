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
    'REPORT ZTEST_ASIS_TRACE.',
    'TABLES: MSEG, MCH1, QALS.',
    'DATA: L_JR_CONV_BATCH LIKE MCH1-CHARG,',
    '      LOT_JR_CONV     LIKE QALS-PRUEFLOS,',
    '      LOT_SR_CONV     LIKE QALS-PRUEFLOS,',
    '      L_SR_BASE_BATCH LIKE MCH1-CHARG,',
    '      LOT_SR_BASE     LIKE QALS-PRUEFLOS,',
    '      L_JR_BASE_BATCH LIKE MCH1-CHARG,',
    '      LOT_JR_BASE     LIKE QALS-PRUEFLOS,',
    '      LV_SEARCH_SR    LIKE MCH1-CHARG,',
    '      L_AUFNR         LIKE AFPO-AUFNR,',
    '      L_CHARG         LIKE MSEG-CHARG,',
    '      L_MATNR         LIKE MSEG-MATNR,',
    '      L_LICHA         LIKE MCH1-LICHA,',
    '      L_LEN TYPE I, L_TEMP TYPE I.',
    '',
    `LV_SEARCH_SR = '${tc.batch}'.`,
    'SELECT SINGLE PRUEFLOS INTO LOT_SR_CONV FROM QALS',
    '  WHERE CHARG = LV_SEARCH_SR AND ART = \'Z04\'.',
    'CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\'',
    '  EXPORTING CHARG_S = LV_SEARCH_SR IMPORTING CHARG_J = L_JR_CONV_BATCH.',
    'IF L_JR_CONV_BATCH IS NOT INITIAL.',
    '  SELECT SINGLE PRUEFLOS INTO LOT_JR_CONV FROM QALS',
    '    WHERE CHARG = L_JR_CONV_BATCH AND ( ART = \'Z02\' OR ART = \'Z03\' ).',
    '  SELECT SINGLE AUFNR INTO L_AUFNR FROM MSEG',
    '    WHERE BWART = \'101\' AND CHARG = L_JR_CONV_BATCH.',
    '  IF L_AUFNR IS NOT INITIAL.',
    '    SELECT SINGLE CHARG INTO L_CHARG FROM MSEG',
    '      WHERE BWART = \'261\' AND AUFNR = L_AUFNR AND CHARG <> space.',
    '    IF L_CHARG IS NOT INITIAL.',
    '      SELECT SINGLE MATNR INTO L_MATNR FROM MCH1 WHERE CHARG = L_CHARG.',
    '      L_LEN = STRLEN( L_MATNR ). L_TEMP = L_LEN - 1.',
    '      IF L_MATNR(2) = \'SR\' AND ( L_MATNR+L_TEMP(1) = \'A\' OR L_MATNR+L_TEMP(1) = \'O\' ).',
    '        SELECT SINGLE LICHA INTO L_LICHA FROM MCH1 WHERE MATNR = L_MATNR AND CHARG = L_CHARG.',
    '        IF L_LICHA IS NOT INITIAL. L_SR_BASE_BATCH = L_LICHA.',
    '        ELSE. L_SR_BASE_BATCH = L_CHARG. ENDIF.',
    '      ELSE. L_SR_BASE_BATCH = L_CHARG. ENDIF.',
    '    ENDIF.',
    '  ENDIF.',
    'ELSE. L_SR_BASE_BATCH = LV_SEARCH_SR. ENDIF.',
    'IF L_JR_CONV_BATCH IS NOT INITIAL AND L_SR_BASE_BATCH IS INITIAL.',
    '  L_JR_BASE_BATCH = L_JR_CONV_BATCH. LOT_JR_BASE = LOT_JR_CONV.',
    '  L_SR_BASE_BATCH = LV_SEARCH_SR. LOT_SR_BASE = LOT_SR_CONV.',
    '  CLEAR: L_JR_CONV_BATCH, LOT_JR_CONV, LOT_SR_CONV.',
    'ENDIF.',
    'IF L_SR_BASE_BATCH IS NOT INITIAL AND LOT_SR_BASE IS INITIAL.',
    '  SELECT SINGLE PRUEFLOS INTO LOT_SR_BASE FROM QALS',
    '    WHERE CHARG = L_SR_BASE_BATCH AND ART = \'Z04\'.',
    '  CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\'',
    '    EXPORTING CHARG_S = L_SR_BASE_BATCH IMPORTING CHARG_J = L_JR_BASE_BATCH.',
    '  IF L_JR_BASE_BATCH IS NOT INITIAL.',
    '    SELECT SINGLE PRUEFLOS INTO LOT_JR_BASE FROM QALS',
    '      WHERE CHARG = L_JR_BASE_BATCH AND ( ART = \'Z02\' OR ART = \'Z03\' ).',
    '  ENDIF.',
    'ENDIF.',
    'WRITE: / \'TC:\', \'' + tc.sc + '\', \'SR_CONV:\', LOT_SR_CONV, \'JR_CONV:\', LOT_JR_CONV,',
    '         \'SR_BASE:\', LOT_SR_BASE, \'JR_BASE:\', LOT_JR_BASE.'
  ];

  const formatted = [];
  for (const l of rawLines) {
    if (l.length > 72) {
      // simple break
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
