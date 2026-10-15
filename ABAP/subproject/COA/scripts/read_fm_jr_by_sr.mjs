import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZREAD_FM_JR_BY_SR.',
  'TABLES: TRDIR.',
  'DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
  'READ REPORT \'SAPLZQM001\' INTO LT_SRC.',
  'WRITE: / \'Lines in SAPLZQM001:\', sy-subrc.',
  'LOOP AT LT_SRC FROM 1 TO 40.',
  '  WRITE: / LT_SRC-LINE.',
  'ENDLOOP.'
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
