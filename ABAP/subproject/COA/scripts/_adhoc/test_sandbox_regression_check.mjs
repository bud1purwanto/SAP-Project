import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('sandbox-new');

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
    'REPORT ZTEST_SANDBOX_REG.',
    'TABLES: MSEG, MCH1, QALS.',
    'DATA: L_JR_CONV_BATCH LIKE MCH1-CHARG,',
    '      LOT_JR_CONV     LIKE QALS-PRUEFLOS,',
    '      LOT_SR_CONV     LIKE QALS-PRUEFLOS,',
    '      LV_SEARCH_SR    LIKE MCH1-CHARG.',
    'START-OF-SELECTION.',
    "LV_SEARCH_SR = '" + tc.batch + "'.",
    'SELECT SINGLE PRUEFLOS INTO LOT_SR_CONV FROM QALS',
    "  WHERE CHARG = LV_SEARCH_SR AND ART = 'Z04'.",
    "CALL FUNCTION 'ZQM_GET_BATCH_JR_BY_SR'",
    '  EXPORTING CHARG_S = LV_SEARCH_SR IMPORTING CHARG_J = L_JR_CONV_BATCH.',
    'IF L_JR_CONV_BATCH IS NOT INITIAL.',
    '  SELECT SINGLE PRUEFLOS INTO LOT_JR_CONV FROM QALS',
    "    WHERE CHARG = L_JR_CONV_BATCH AND ( ART = 'Z02' OR ART = 'Z03' ).",
    'ENDIF.',
    "WRITE: / 'TC:', '" + tc.sc + "', 'SR:', LOT_SR_CONV, 'JR:', LOT_JR_CONV."
  ];
  const resp = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: rawLines.map(LINE => ({ LINE })),
      WRITES: []
    }
  });
  console.log(resp.result?.WRITES?.map(w => w.ZEILE).join(' '));
}
