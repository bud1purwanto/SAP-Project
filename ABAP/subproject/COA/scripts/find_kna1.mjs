import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZFIND_KNA1.',
    'DATA: LT_KNA1 TYPE TABLE OF KNA1 WITH HEADER LINE.',
    'SELECT * FROM KNA1 INTO TABLE LT_KNA1 UP TO 10 ROWS',
    '  WHERE NAME1 LIKE \'%NOMURA%\' OR NAME1 LIKE \'%SARIGUNA%\'.',
    'LOOP AT LT_KNA1.',
    '  WRITE: / LT_KNA1-KUNNR, LT_KNA1-NAME1.',
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
