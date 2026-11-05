import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZTEST_DO_GETDATA5.',
    'INCLUDE ZQMI_COA_TOP.',
    'INCLUDE ZQMI_COA_F01.',
    'INCLUDE ZQMI_COA_F02.',
    'DATA: LV_L TYPE I.',
    'START-OF-SELECTION.',
    '  WRITE: / \'START\'.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log(JSON.stringify(res));
}
main().catch(console.error);
