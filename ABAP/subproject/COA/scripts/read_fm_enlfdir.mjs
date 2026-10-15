import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZREAD_FM_ENLFDIR.',
  'TABLES: ENLFDIR, TFDIR.',
  'DATA: LV_PNAME TYPE TFDIR-PNAME.',
  'SELECT SINGLE PNAME INTO LV_PNAME FROM TFDIR',
  '  WHERE FUNCNAME = \'ZQM_GET_BATCH_JR_BY_SR\'.',
  'WRITE: / \'PNAME:\', LV_PNAME.',
  'IF LV_PNAME IS NOT INITIAL.',
  '  DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
  '  READ REPORT LV_PNAME INTO LT_SRC.',
  '  WRITE: / \'Lines:\', sy-subrc.',
  '  LOOP AT LT_SRC.',
  '    WRITE: / LT_SRC-LINE.',
  '  ENDLOOP.',
  'ENDIF.'
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
