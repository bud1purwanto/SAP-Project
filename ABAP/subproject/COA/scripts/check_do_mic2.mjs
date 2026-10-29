import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_DO_MIC2.',
    'DATA: LT_LIPS TYPE TABLE OF LIPS WITH HEADER LINE.',
    'SELECT * FROM LIPS INTO TABLE LT_LIPS WHERE VBELN = \'0085006272\'.',
    'WRITE: / \'Lines in LIPS:\', LINES( LT_LIPS ).',
    'LOOP AT LT_LIPS.',
    '  WRITE: / LT_LIPS-POSNR, LT_LIPS-MATNR, LT_LIPS-CHARG.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: prog.map(l => ({ LINE: l }))
    }
  });
  for (const row of res.result?.WRITES || []) {
    console.log(row.ZEILE);
  }
}
main().catch(console.error);
