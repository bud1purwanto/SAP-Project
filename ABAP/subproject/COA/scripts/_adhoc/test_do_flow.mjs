import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZTEST_DO_FLOW.',
    'TABLES: LIKP, LIPS, ZMAP_COA.',
    'DATA: LV_V TYPE LIKP-VBELN VALUE \'0085006273\'.',
    'DATA: LT_DATA TYPE TABLE OF ZQMI_COA_DATA WITH HEADER LINE.',
    'SELECT * FROM ZMAP_COA WHERE MATNR = \'SRIA5I\'.',
    '  WRITE: / ZMAP_COA-MIC, ZMAP_COA-MIC_DESC.',
    'ENDSELECT.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log(JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
