import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_QPMT_EN.',
    'DATA: LT_QPMT TYPE TABLE OF QPMT WITH HEADER LINE.',
    'SELECT * FROM QPMT INTO TABLE LT_QPMT WHERE SPRACHE = \'E\' UP TO 10 ROWS.',
    'WRITE: / \'Lines found E:\', LINES( LT_QPMT ).',
    'SELECT * FROM QPMT INTO TABLE LT_QPMT WHERE SPRACHE = \'EN\' UP TO 10 ROWS.',
    'WRITE: / \'Lines found EN:\', LINES( LT_QPMT ).',
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
  for (const row of res.result?.WRITES || []) {
    console.log(row.ZEILE);
  }
}
main().catch(console.error);
