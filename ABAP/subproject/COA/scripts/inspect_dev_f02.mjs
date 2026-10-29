import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_DEV_F02.',
    'DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
    'READ REPORT \'ZQMI_COA_F02\' INTO LT_SRC.',
    'LOOP AT LT_SRC WHERE LINE CS \'MODULE TDETAIL_MODIFY\'.',
    '  DATA: LV_IDX TYPE I.',
    '  LV_IDX = SY-TABIX.',
    '  DO 15 TIMES.',
    '    READ TABLE LT_SRC INDEX LV_IDX.',
    '    WRITE: / LT_SRC-LINE.',
    '    LV_IDX = LV_IDX + 1.',
    '  ENDDO.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('DEV F02:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
