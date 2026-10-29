import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_COUNT.',
    'DATA: LV_CNT TYPE I.',
    'SELECT COUNT(*) INTO LV_CNT FROM QPMT.',
    'WRITE: / \'Count QPMT:\', LV_CNT.',
    'SELECT COUNT(*) INTO LV_CNT FROM QAMV.',
    'WRITE: / \'Count QAMV:\', LV_CNT.',
    'SELECT COUNT(*) INTO LV_CNT FROM ZMAP_COA.',
    'WRITE: / \'Count ZMAP_COA:\', LV_CNT.'
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
