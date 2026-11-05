import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_QPMT_FIELD.',
    'DATA: WA_QPMT TYPE QPMT.',
    'DATA: LV_RAW TYPE X, LV_HEX(4) TYPE C.',
    'SELECT SINGLE * FROM QPMT INTO WA_QPMT.',
    'LV_RAW = WA_QPMT-SPRACHE. LV_HEX = LV_RAW.',
    'WRITE: / \'SPRACHE:\', WA_QPMT-SPRACHE, \'HEX:\', LV_HEX,',
    '         \'MKMNR:\', WA_QPMT-MKMNR, \'TEXT:\', WA_QPMT-KURZTEXT.'
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
