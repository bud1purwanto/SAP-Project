import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZFIND_DYN_FM.',
    'DATA: LT_TFDIR TYPE TABLE OF TFDIR WITH HEADER LINE.',
    'SELECT * FROM TFDIR INTO TABLE LT_TFDIR WHERE FUNCNAME LIKE \'%DYNPRO%\' AND FUNCNAME LIKE \'RS%\'.',
    'LOOP AT LT_TFDIR.',
    '  WRITE: / LT_TFDIR-FUNCNAME.',
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
