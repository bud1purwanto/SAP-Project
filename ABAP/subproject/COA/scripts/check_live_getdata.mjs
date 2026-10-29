import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_LIVE_GETDATA.',
    'DATA: IT_DATA TYPE TABLE OF ZQMI_COA_DATA WITH HEADER LINE.',
    'DATA: P_VBELN LIKE LIKP-VBELN VALUE \'0085006273\'.',
    'DATA: P_KUNNR LIKE LIKP-KUNNR,',
    '      P_CHARG LIKE LIPS-CHARG,',
    '      P_ATWRT TYPE ATWRT,',
    '      S_ERDAT LIKE LIKP-ERDAT.',
    'DATA: LV_CNT TYPE I.',
    'CALL FUNCTION \'ZQMI_COA_GET_DATA\'',
    '  EXPORTING P_VBELN = P_VBELN',
    '  TABLES IT_DATA = IT_DATA EXCEPTIONS OTHERS = 1.',
    'WRITE: / \'SY-SUBRC:\', SY-SUBRC.'
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
