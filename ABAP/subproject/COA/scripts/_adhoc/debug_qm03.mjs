import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZDEBUG_QM03.',
  'TABLES: MSEG, MCH1, QALS.',
  'DATA: LV_CHARG TYPE MCH1-CHARG, LV_MATNR TYPE MCH1-MATNR,',
  '      LV_JR TYPE MCH1-CHARG, LV_LOT TYPE QALS-PRUEFLOS.',
  'LV_CHARG = \'0000405583\'.',
  'SELECT SINGLE MATNR FROM MCH1 INTO LV_MATNR WHERE CHARG = LV_CHARG.',
  'WRITE: / \'MATNR:\', LV_MATNR.',
  'SELECT SINGLE PRUEFLOS FROM QALS INTO LV_LOT WHERE CHARG = LV_CHARG.',
  'WRITE: / \'LOT:\', LV_LOT.',
  'CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\'',
  '  EXPORTING CHARG_S = LV_CHARG IMPORTING CHARG_J = LV_JR.',
  'WRITE: / \'JR:\', LV_JR.'
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
