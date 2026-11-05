import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_QAMV_CASE2.',
    'DATA: LT_QAMV TYPE TABLE OF QAMV WITH HEADER LINE.',
    'SELECT * FROM QAMV INTO TABLE LT_QAMV UP TO 20 ROWS WHERE VERWMERKM = \'PAABELMD\'.',
    'LOOP AT LT_QAMV.',
    '  WRITE: / LT_QAMV-PRUEFLOS, LT_QAMV-VERWMERKM, LT_QAMV-KURZTEXT.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: prog.map(l => ({ LINE: l }))
    }
  });
  for (const row of res.result?.WRITES || []) {
    console.log(row.ZEILE);
  }
}
main().catch(console.error);
