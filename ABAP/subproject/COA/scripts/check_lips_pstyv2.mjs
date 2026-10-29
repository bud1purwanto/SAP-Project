import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_LIPS_PSTYV2.',
    'DATA: WA_LIPS TYPE LIPS.',
    'SELECT SINGLE * FROM LIPS INTO WA_LIPS WHERE VBELN = \'0085006273\'.',
    'WRITE: / \'SY-SUBRC:\', SY-SUBRC, \'MATNR:\', WA_LIPS-MATNR,',
    '         \'PSTYV:\', WA_LIPS-PSTYV.'
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
