import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZTEST_DO_GETDATA.',
    'INCLUDE ZQMI_COA_TOP.',
    'INCLUDE ZQMI_COA_F01.',
    'INCLUDE ZQMI_COA_F02.',
    'START-OF-SELECTION.',
    '  P_VBELN = \'0085006273\'.',
    '  PERFORM GET_DATA.',
    '  LOOP AT IT_DATA.',
    '    WRITE: / IT_DATA-MIC, \'DES:\', IT_DATA-MICDES.',
    '  ENDLOOP.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('RESULT OF GET_DATA:');
  for (const r of res.result?.WRITES || []) {
    console.log(r.ZEILE);
  }
}
main().catch(console.error);
