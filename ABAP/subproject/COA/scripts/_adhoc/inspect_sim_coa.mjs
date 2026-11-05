import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  // Let's inspect the first delivery with material and trace IT_DATA and IT_DETAIL
  const prog = [
    'REPORT ZSIM_COA.',
    'DATA: LT_DATA TYPE TABLE OF ZQMI_COA_DATA WITH HEADER LINE.',
    'SELECT * FROM LIKP UP TO 5 ROWS.',
    '  WRITE: / LIKP-VBELN, LIKP-KUNNR.',
    'ENDSELECT.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('LIKP in Sandbox:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
