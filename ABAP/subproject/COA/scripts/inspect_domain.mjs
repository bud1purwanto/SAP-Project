import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_DD.',
    'DATA: WA_DD04L TYPE DD04L, WA_DD01L TYPE DD01L.',
    'SELECT SINGLE * FROM DD04L INTO WA_DD04L WHERE ROLLNAME = \'QKURZTEXT\'.',
    'SELECT SINGLE * FROM DD01L INTO WA_DD01L WHERE DOMNAME = WA_DD04L-DOMNAME.',
    'WRITE: / \'DOMNAME:\', WA_DD04L-DOMNAME, \'LOWERCASE:\', WA_DD01L-LOWERCASE.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('QKURZTEXT DOMAIN:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
