import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_LIVE_F01_SEL.',
    'DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
    'READ REPORT \'ZQMI_COA_F01\' INTO LT_SRC.',
    'LOOP AT LT_SRC.',
    '  IF LT_SRC-LINE CS \'FORM SELALL\' OR',
    '     LT_SRC-LINE CS \'FORM DESALL\' OR',
    '     LT_SRC-LINE CS \'FORM SELMAPPING\'.',
    '    DATA: LV_IDX TYPE I.',
    '    LV_IDX = SY-TABIX.',
    '    LOOP AT LT_SRC FROM LV_IDX TO LV_IDX + 20.',
    '      WRITE: / LT_SRC-LINE.',
    '      IF LT_SRC-LINE CS \'ENDFORM\'. EXIT. ENDIF.',
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
