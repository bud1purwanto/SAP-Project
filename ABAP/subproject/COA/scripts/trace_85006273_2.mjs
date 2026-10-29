import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZTRACE_DO_85006273.',
    'DATA: LV_V TYPE LIKP-VBELN VALUE \'0085006273\'.',
    'DATA: LT_LIPS TYPE TABLE OF LIPS WITH HEADER LINE.',
    'DATA: LV_CNT TYPE I.',
    'SELECT * FROM LIPS INTO TABLE LT_LIPS WHERE VBELN = LV_V.',
    'DESCRIBE TABLE LT_LIPS LINES LV_CNT.',
    'WRITE: / \'Lines in LIPS:\', LV_CNT.',
    'LOOP AT LT_LIPS.',
    '  WRITE: / LT_LIPS-POSNR, LT_LIPS-MATNR, LT_LIPS-CHARG.',
    'ENDLOOP.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('DEV 85006273:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
