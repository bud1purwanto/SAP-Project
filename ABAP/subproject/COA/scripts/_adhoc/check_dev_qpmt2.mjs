import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_DEV_QPMT2.',
    'DATA: LT_QPMT TYPE TABLE OF QPMT WITH HEADER LINE.',
    'SELECT * FROM QPMT INTO TABLE LT_QPMT WHERE MKMNR = \'PAABELMD\'.',
    'WRITE: / \'Lines found:\', LINES( LT_QPMT ).',
    'LOOP AT LT_QPMT.',
    '  WRITE: / LT_QPMT-SPRACHE, LT_QPMT-MKMNR, LT_QPMT-KURZTEXT.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: prog.map(l => ({ LINE: l }))
    }
  });
  console.log('Result:', JSON.stringify(res.result?.WRITES || res));
}
main().catch(console.error);
