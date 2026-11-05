import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZTEST_THICK.',
    'DATA: LV_DESC TYPE QPMT-KURZTEXT.',
    'SELECT SINGLE KURZTEXT INTO LV_DESC FROM QPMT',
    '  WHERE MKMNR = \'PAABTH00\' AND SPRACHE = \'E\'.',
    'WRITE: / \'PAABTH00 with E:\', SY-SUBRC, LV_DESC.',
    'SELECT SINGLE KURZTEXT INTO LV_DESC FROM QPMT',
    '  WHERE MKMNR = \'SAGCTH00\' AND SPRACHE = \'E\'.',
    'WRITE: / \'SAGCTH00 with E:\', SY-SUBRC, LV_DESC.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log(JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
