import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_TRDIR.',
    'DATA: WA_TRDIR TYPE TRDIR.',
    'DATA: LT_PROG TYPE TABLE OF PROGRAM WITH HEADER LINE.',
    'APPEND \'ZQMI_COA\' TO LT_PROG.',
    'APPEND \'ZQMI_COA_TOP\' TO LT_PROG.',
    'APPEND \'ZQMI_COA_F01\' TO LT_PROG.',
    'APPEND \'ZQMI_COA_F02\' TO LT_PROG.',
    'LOOP AT LT_PROG.',
    '  SELECT SINGLE * FROM TRDIR INTO WA_TRDIR WHERE NAME = LT_PROG.',
    '  WRITE: / WA_TRDIR-NAME, WA_TRDIR-UDAT, WA_TRDIR-UTIME, WA_TRDIR-UNAM.',
    'ENDLOOP.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log(JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
