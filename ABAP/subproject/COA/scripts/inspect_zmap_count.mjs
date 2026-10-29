import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_ZMAP_SANDBOX.',
    'DATA: LT_ZMAP TYPE TABLE OF ZMAP_COA WITH HEADER LINE.',
    'DATA: LV_CNT TYPE I, LV_EMPTY TYPE I.',
    'SELECT COUNT(*) INTO LV_CNT FROM ZMAP_COA.',
    'SELECT COUNT(*) INTO LV_EMPTY FROM ZMAP_COA WHERE MIC_DESC = \'\'.',
    'WRITE: / \'Total ZMAP_COA in Sandbox:\', LV_CNT, \'Empty DESC:\', LV_EMPTY.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('SANDBOX:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
