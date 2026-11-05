import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_MANDT_ANY.',
    'DATA: LT_LIKP TYPE TABLE OF LIKP WITH HEADER LINE.',
    'SELECT * FROM LIKP CLIENT SPECIFIED INTO TABLE LT_LIKP UP TO 5 ROWS.',
    'LOOP AT LT_LIKP.',
    '  WRITE: / LT_LIKP-MANDT, LT_LIKP-VBELN.',
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
