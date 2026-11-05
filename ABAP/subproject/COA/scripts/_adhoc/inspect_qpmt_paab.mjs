import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_QPMT_PAAB.',
    'DATA: LT_QPMT TYPE TABLE OF QPMT WITH HEADER LINE.',
    'SELECT * FROM QPMT INTO TABLE LT_QPMT UP TO 10 ROWS',
    '  WHERE MKMNR LIKE \'PAAB%\'.',
    'LOOP AT LT_QPMT.',
    '  WRITE: / LT_QPMT-MKMNR, LT_QPMT-SPRACHE, LT_QPMT-KURZTEXT.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('SANDBOX QPMT PAAB:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
