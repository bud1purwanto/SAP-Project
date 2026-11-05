import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZDEBUG_QM03_STEP2.',
  'TABLES: MSEG, MCH1, QALS.',
  'DATA: LV_JR TYPE MCH1-CHARG, LV_LOT TYPE QALS-PRUEFLOS,',
  '      LV_AUFNR TYPE MSEG-AUFNR, LV_COMP TYPE MSEG-CHARG,',
  '      LV_MATNR TYPE MCH1-MATNR.',
  'LV_JR = \'0000405468\'.',
  'SELECT SINGLE MATNR INTO LV_MATNR FROM MCH1 WHERE CHARG = LV_JR.',
  'SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS WHERE CHARG = LV_JR',
  '  AND ( ART = \'Z02\' OR ART = \'Z03\' ).',
  'WRITE: / \'JR MATNR:\', LV_MATNR, \'LOT:\', LV_LOT.',
  'SELECT SINGLE AUFNR INTO LV_AUFNR FROM MSEG',
  '  WHERE BWART = \'101\' AND CHARG = LV_JR.',
  'WRITE: / \'AUFNR:\', LV_AUFNR.',
  'SELECT SINGLE CHARG INTO LV_COMP FROM MSEG',
  '  WHERE BWART = \'261\' AND AUFNR = LV_AUFNR AND CHARG <> space.',
  'WRITE: / \'COMP:\', LV_COMP.'
];

const resp = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: rawLines.map(LINE => ({ LINE })),
    WRITES: []
  }
});
if (resp.result?.ERRORMESSAGE) console.error(resp.result.ERRORMESSAGE);
else console.log(resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
