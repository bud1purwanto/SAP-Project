import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_DEV_0200_EXEC_DATA.',
    'DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
    'READ REPORT \'ZQMI_COA_F02\' INTO LT_SRC.',
    'DATA: LV_IDX TYPE I.',
    'LOOP AT LT_SRC WHERE LINE CS \'WHEN \'\'EXEC\'\'\'.',
    '  LV_IDX = SY-TABIX.',
    '  EXIT.',
    'ENDLOOP.',
    'WRITE: / \'EXEC line:\', LV_IDX.',
    'LOOP AT LT_SRC FROM LV_IDX TO LV_IDX + 30.',
    '  WRITE: / LT_SRC-LINE.',
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
