import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_QAMV_21033.',
  'TABLES: QAMV.',
  'DATA: BEGIN OF LT_QAMV OCCURS 0,',
  '        MERKNR TYPE QAMV-MERKNR,',
  '        VERWMERKM TYPE QAMV-VERWMERKM,',
  '        KURZTEXT TYPE QAMV-KURZTEXT,',
  '      END OF LT_QAMV.',
  'SELECT MERKNR VERWMERKM KURZTEXT FROM QAMV INTO TABLE LT_QAMV',
  '  WHERE PRUEFLOS = \'040000021033\'.',
  'LOOP AT LT_QAMV.',
  '  WRITE: / LT_QAMV-MERKNR, LT_QAMV-VERWMERKM, LT_QAMV-KURZTEXT.',
  'ENDLOOP.'
];

for (const l of rawLines) {
  if (l.length > 72) throw new Error('Line > 72: ' + l);
}

const resp = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: rawLines.map(LINE => ({ LINE })),
    WRITES: []
  }
});
if (resp.result?.ERRORMESSAGE) console.error(resp.result.ERRORMESSAGE);
else console.log(resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
