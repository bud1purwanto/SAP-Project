import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_DEV_F02_MODIFY.',
    'DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
    'READ REPORT \'ZQMI_COA_F02\' INTO LT_SRC.',
    'LOOP AT LT_SRC.',
    '  IF LT_SRC-LINE CS \'MODULE TCTIMB_MODIFY\' OR',
    '     LT_SRC-LINE CS \'MODULE TDETAIL_MODIFY\'.',
    '    DATA: LV_IDX TYPE I.',
    '    LV_IDX = SY-TABIX.',
    '    LOOP AT LT_SRC FROM LV_IDX TO LV_IDX + 15.',
    '      WRITE: / LT_SRC-LINE.',
    '      IF LT_SRC-LINE CS \'ENDMODULE\'. EXIT. ENDIF.',
    '    ENDLOOP.',
    '  ENDIF.',
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
