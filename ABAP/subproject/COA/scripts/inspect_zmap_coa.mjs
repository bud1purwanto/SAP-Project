import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_ZMAP.',
    'DATA: LT_ZMAP TYPE TABLE OF ZMAP_COA WITH HEADER LINE.',
    'SELECT * FROM ZMAP_COA INTO TABLE LT_ZMAP UP TO 10 ROWS.',
    'LOOP AT LT_ZMAP.',
    '  WRITE: / LT_ZMAP-MIC, LT_ZMAP-MIC_DESC.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('DEV ZMAP_COA:', JSON.stringify(res.result?.WRITES));

  await serverManager.setActiveServer('sandbox-new');
  const res2 = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('SANDBOX ZMAP_COA:', JSON.stringify(res2.result?.WRITES));
}
main().catch(console.error);
