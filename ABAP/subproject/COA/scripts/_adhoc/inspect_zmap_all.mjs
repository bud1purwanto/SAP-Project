import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_ZMAP_ALL.',
    'DATA: LT_ZMAP TYPE TABLE OF ZMAP_COA WITH HEADER LINE.',
    'SELECT * FROM ZMAP_COA INTO TABLE LT_ZMAP UP TO 30 ROWS.',
    'LOOP AT LT_ZMAP.',
    '  WRITE: / LT_ZMAP-MATNR, LT_ZMAP-MIC, LT_ZMAP-MIC_DESC.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('SANDBOX ZMAP:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
