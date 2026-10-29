import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZLIST_SCREENS.',
    'DATA: LT_D020S TYPE TABLE OF D020S WITH HEADER LINE.',
    'SELECT * FROM D020S INTO TABLE LT_D020S WHERE PROG = \'ZQMI_COA\'.',
    'LOOP AT LT_D020S.',
    '  WRITE: / LT_D020S-DNUM, LT_D020S-TYPE.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('SCREENS:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
