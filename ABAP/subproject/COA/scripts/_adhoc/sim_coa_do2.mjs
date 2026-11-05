import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZSIM_COA_DO.',
    'DATA: LT_ZMAP TYPE TABLE OF ZMAP_COA WITH HEADER LINE.',
    'DATA: LT_DATA TYPE TABLE OF ZQMI_COA_DATA WITH HEADER LINE.',
    'DATA: WA_DATA TYPE ZQMI_COA_DATA.',
    'DATA: LV_C TYPE I.',
    'SELECT * FROM ZMAP_COA INTO TABLE LT_ZMAP WHERE MATNR = \'SRIA5I\'.',
    'LOOP AT LT_ZMAP.',
    '  CLEAR WA_DATA.',
    '  WA_DATA-VBELN = \'0085006273\'.',
    '  WA_DATA-MATNR = LT_ZMAP-MATNR.',
    '  WA_DATA-MIC = LT_ZMAP-MIC.',
    '  WA_DATA-MICDES = LT_ZMAP-MIC_DESC.',
    '  WA_DATA-CHK = \'X\'.',
    '  APPEND WA_DATA TO LT_DATA.',
    'ENDLOOP.',
    'DESCRIBE TABLE LT_DATA LINES LV_C.',
    'WRITE: / \'Initial LT_DATA count:\', LV_C.',
    'LOOP AT LT_DATA.',
    '  WRITE: / LT_DATA-MIC, LT_DATA-MICDES.',
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
