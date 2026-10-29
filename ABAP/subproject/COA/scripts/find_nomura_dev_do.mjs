import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZFIND_NOMURA_DEV.',
    'DATA: LT_LIKP TYPE TABLE OF LIKP WITH HEADER LINE.',
    'SELECT * FROM LIKP INTO TABLE LT_LIKP UP TO 10 ROWS',
    '  WHERE KUNNR = \'1141100181\' OR KUNNR = \'1800000007\'.',
    'LOOP AT LT_LIKP.',
    '  WRITE: / LT_LIKP-VBELN, LT_LIKP-KUNNR, LT_LIKP-WADAT_IST, LT_LIKP-LFART.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('DEV NOMURA DO:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
