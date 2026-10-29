import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_DEV_QPMK.',
    'DATA: LT_QPMK TYPE TABLE OF QPMK WITH HEADER LINE.',
    'SELECT * FROM QPMK INTO TABLE LT_QPMK UP TO 10 ROWS.',
    'LOOP AT LT_QPMK.',
    '  WRITE: / LT_QPMK-WERKS, LT_QPMK-MKMNR, LT_QPMK-VERSION, LT_QPMK-KURZTEXT.',
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
