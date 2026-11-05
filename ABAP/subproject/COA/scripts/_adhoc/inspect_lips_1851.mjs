import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_85001851.',
    'DATA: LT_LIPS TYPE TABLE OF LIPS WITH HEADER LINE.',
    'SELECT * FROM LIPS INTO TABLE LT_LIPS WHERE VBELN = \'0085001851\'.',
    'LOOP AT LT_LIPS.',
    '  WRITE: / LT_LIPS-POSNR, LT_LIPS-MATNR, LT_LIPS-CHARG.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('LIPS 85001851:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
