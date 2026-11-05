import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_DEV_SELMAPPING.',
    'DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
    'READ REPORT \'ZQMI_COA_F01\' INTO LT_SRC.',
    'LOOP AT LT_SRC WHERE LINE CS \'FORM SELMAPPING\'.',
    '  DATA: LV_IDX TYPE I.',
    '  LV_IDX = SY-TABIX.',
    '  DO 15 TIMES.',
    '    READ TABLE LT_SRC INDEX LV_IDX.',
    '    WRITE: / LT_SRC-LINE.',
    '    LV_IDX = LV_IDX + 1.',
    '  ENDDO.',
    'ENDLOOP.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('DEV SELMAPPING:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
