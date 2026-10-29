import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_NOMURA.',
    'DATA: LT_ZMAP TYPE TABLE OF ZMAP_COA WITH HEADER LINE.',
    'SELECT * FROM ZMAP_COA INTO TABLE LT_ZMAP WHERE MATNR LIKE \'%LC03%\' OR KUNNR LIKE \'%NOMURA%\'.',
    'WRITE: / \'Lines found:\', LINES( LT_ZMAP ).',
    'LOOP AT LT_ZMAP.',
    '  WRITE: / LT_ZMAP-MATNR, LT_ZMAP-KUNNR, LT_ZMAP-MIC, LT_ZMAP-MIC_DESC, LT_ZMAP-UOM.',
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
