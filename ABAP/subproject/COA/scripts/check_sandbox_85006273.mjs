import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_SANDBOX_85006273.',
    'DATA: WA_LIKP TYPE LIKP.',
    'SELECT SINGLE * FROM LIKP INTO WA_LIKP WHERE VBELN = \'0085006273\'.',
    'WRITE: / \'SY-SUBRC:\', SY-SUBRC, \'VBELN:\', WA_LIKP-VBELN.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('SANDBOX:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
