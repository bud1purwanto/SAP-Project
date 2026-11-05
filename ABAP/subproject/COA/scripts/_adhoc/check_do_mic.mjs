import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_DO_MIC.',
    'DATA: LT_LIPS TYPE TABLE OF LIPS WITH HEADER LINE,',
    '      LT_QAMV TYPE TABLE OF QAMV WITH HEADER LINE.',
    'SELECT * FROM LIPS INTO TABLE LT_LIPS WHERE VBELN = \'0085006272\'.',
    'WRITE: / \'Lines in LIPS:\', LINES( LT_LIPS ).',
    'SELECT * FROM QAMV INTO TABLE LT_QAMV UP TO 10 ROWS WHERE KURZTEXT CS \'Elongation\' OR KURZTEXT CS \'ELONGATION\'.',
    'LOOP AT LT_QAMV.',
    '  WRITE: / LT_QAMV-VERWMERKM, LT_QAMV-KURZTEXT.',
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
