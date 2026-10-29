import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  // Let's call the program ZQMI_COA or inspect IT_DATA
  const prog = [
    'REPORT ZTEST_MICDES.',
    'TABLES: ZMAP_COA, QPMT, QAMV.',
    'DATA: LV_DESC TYPE QPMT-KURZTEXT.',
    'SELECT SINGLE KURZTEXT INTO LV_DESC FROM QPMT',
    '  WHERE MKMNR = \'PAABELMD\' AND SPRACHE = \'E\'.',
    'WRITE: / \'PAABELMD with E:\', SY-SUBRC, LV_DESC.',
    'SELECT SINGLE KURZTEXT INTO LV_DESC FROM QPMT',
    '  WHERE MKMNR = \'PAABELMD\' AND SPRACHE = \'EN\'.',
    'WRITE: / \'PAABELMD with EN:\', SY-SUBRC, LV_DESC.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log(JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
