import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_GET_DATA_TEXT.',
    'TABLES: LIKP, LIPS, ZMAP_COA, QPMT.',
    'DATA: LV_V TYPE LIKP-VBELN VALUE \'0085006273\'.',
    'DATA: LT_ZMAP TYPE TABLE OF ZMAP_COA WITH HEADER LINE.',
    'DATA: LT_DATA TYPE TABLE OF ZQMI_COA_DATA WITH HEADER LINE.',
    'SELECT * FROM ZMAP_COA INTO TABLE LT_ZMAP WHERE MATNR = \'SRIA5I\'.',
    'LOOP AT LT_ZMAP.',
    '  WRITE: / LT_ZMAP-MIC, \'DESC:\', LT_ZMAP-MIC_DESC.',
    'ENDLOOP.'
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
