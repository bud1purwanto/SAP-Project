import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_LIKP_DEV.',
    'DATA: LT_LIKP TYPE TABLE OF LIKP WITH HEADER LINE.',
    'SELECT * FROM LIKP INTO TABLE LT_LIKP UP TO 5 ROWS WHERE VBELN LIKE \'%8500627%\'.',
    'WRITE: / \'LIKP Lines:\', LINES( LT_LIKP ).',
    'LOOP AT LT_LIKP.',
    '  WRITE: / LT_LIKP-VBELN, LT_LIKP-KUNNR, LT_LIKP-LFART.',
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
