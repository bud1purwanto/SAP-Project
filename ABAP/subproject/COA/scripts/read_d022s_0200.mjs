import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZREAD_D022S.',
    'DATA: LT_D022S TYPE TABLE OF D022S WITH HEADER LINE.',
    'SELECT * FROM D022S INTO TABLE LT_D022S',
    '  WHERE PROG = \'ZQMI_COA\' AND DNUM = \'0200\'.',
    'LOOP AT LT_D022S.',
    '  WRITE: / LT_D022S-LINE.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('D022S 0200:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
