import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZREAD_FM_INCLUDE.',
  'TABLES: TFDIR.',
  'DATA: LV_INCLUDE TYPE TFDIR-INCLUDE.',
  'SELECT SINGLE INCLUDE INTO LV_INCLUDE FROM TFDIR',
  '  WHERE FUNCNAME = \'ZQM_GET_BATCH_JR_BY_SR\'.',
  'WRITE: / \'INCLUDE num:\', LV_INCLUDE.',
  'IF LV_INCLUDE IS NOT INITIAL.',
  '  DATA: LV_PROG TYPE TRDIR-NAME.',
  '  CONCATENATE \'LZBARRIERU\' LV_INCLUDE INTO LV_PROG.',
  '  DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
  '  READ REPORT LV_PROG INTO LT_SRC.',
  '  WRITE: / \'Lines in\', LV_PROG, \':\', sy-subrc.',
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
