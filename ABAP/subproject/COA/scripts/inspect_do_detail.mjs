import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_DO_DETAIL.',
    'DATA: LV_V TYPE LIKP-VBELN VALUE \'0085006272\'.',
    'DATA: WA_LIKP TYPE LIKP, LT_LIPS TYPE TABLE OF LIPS WITH HEADER LINE.',
    'SELECT SINGLE * FROM LIKP INTO WA_LIKP WHERE VBELN = LV_V.',
    'WRITE: / \'LIKP:\', WA_LIKP-VBELN, WA_LIKP-KUNNR, WA_LIKP-LFART.',
    'SELECT * FROM LIPS INTO TABLE LT_LIPS WHERE VBELN = LV_V.',
    'LOOP AT LT_LIPS.',
    '  WRITE: / LT_LIPS-POSNR, LT_LIPS-MATNR, LT_LIPS-CHARG.',
    'ENDLOOP.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: prog.map(l => ({ LINE: l }))
    }
  });
  console.log(JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
