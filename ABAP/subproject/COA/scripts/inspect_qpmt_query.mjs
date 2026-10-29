import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_QPMT_QUERY.',
    'DATA: LV_TEXT TYPE QPMT-KURZTEXT.',
    'SELECT SINGLE KURZTEXT INTO LV_TEXT FROM QPMT WHERE MKMNR = \'AAAADTTR\' AND SPRACHE = \'E\'.',
    'WRITE: / \'With E:\', SY-SUBRC, LV_TEXT.',
    'SELECT SINGLE KURZTEXT INTO LV_TEXT FROM QPMT WHERE MKMNR = \'AAAADTTR\' AND SPRACHE = SY-LANGU.',
    'WRITE: / \'With SY-LANGU:\', SY-SUBRC, LV_TEXT.',
    'SELECT SINGLE KURZTEXT INTO LV_TEXT FROM QPMT WHERE MKMNR = \'AAAADTTR\'.',
    'WRITE: / \'Without SPRACHE:\', SY-SUBRC, LV_TEXT.'
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
