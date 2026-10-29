import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZFIND_DO_DATE_DEV.',
    'DATA: LT_LIKP TYPE TABLE OF LIKP WITH HEADER LINE.',
    'SELECT * FROM LIKP INTO TABLE LT_LIKP UP TO 20 ROWS',
    '  WHERE LFDAT = \'20260911\' OR WADAT_IST = \'20260911\'.',
    'LOOP AT LT_LIKP.',
    '  WRITE: / LT_LIKP-VBELN, LT_LIKP-KUNNR, LT_LIKP-LFART, LT_LIKP-LFDAT.',
    'ENDLOOP.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('DEV DOs:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
