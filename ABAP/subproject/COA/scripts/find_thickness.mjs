import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZFIND_TEXT.',
    'DATA: LT_QPMT TYPE TABLE OF QPMT WITH HEADER LINE.',
    'SELECT * FROM QPMT INTO TABLE LT_QPMT UP TO 10 ROWS',
    '  WHERE KURZTEXT LIKE \'%Thickness%\' OR KURZTEXT LIKE \'%THICKNESS%\'.',
    'LOOP AT LT_QPMT.',
    '  WRITE: / \'QPMT:\', LT_QPMT-MKMNR, LT_QPMT-SPRACHE, LT_QPMT-KURZTEXT.',
    'ENDLOOP.',
    'DATA: LT_QAMV TYPE TABLE OF QAMV WITH HEADER LINE.',
    'SELECT * FROM QAMV INTO TABLE LT_QAMV UP TO 10 ROWS',
    '  WHERE KURZTEXT LIKE \'%Thickness%\' OR KURZTEXT LIKE \'%THICKNESS%\'.',
    'LOOP AT LT_QAMV.',
    '  WRITE: / \'QAMV:\', LT_QAMV-PRUEFLOS, LT_QAMV-VERWMERKM, LT_QAMV-KURZTEXT.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('SANDBOX:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
