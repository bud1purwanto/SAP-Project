import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_QAMR_21033.',
  'TABLES: QAMR.',
  'DATA: BEGIN OF LT_QAMR OCCURS 0,',
  '        MERKNR TYPE QAMR-MERKNR,',
  '        MITTELWERT TYPE QAMR-MITTELWERT,',
  '        ANZWERTG TYPE QAMR-ANZWERTG,',
  '      END OF LT_QAMR.',
  'SELECT MERKNR MITTELWERT ANZWERTG FROM QAMR INTO TABLE LT_QAMR',
  '  WHERE PRUEFLOS = \'040000021033\'.',
  'LOOP AT LT_QAMR.',
  '  WRITE: / LT_QAMR-MERKNR, LT_QAMR-MITTELWERT, LT_QAMR-ANZWERTG.',
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
