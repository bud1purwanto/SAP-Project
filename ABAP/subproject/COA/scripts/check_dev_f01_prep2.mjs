import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_DEV_F01_PREP2.',
    'DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
    'READ REPORT \'ZQMI_COA_F01\' INTO LT_SRC.',
    'DATA: LV_LINE TYPE I.',
    'LOOP AT LT_SRC.',
    '  IF LT_SRC-LINE CS \'FORM PREPARE_EXPORT_HEADER\'.',
    '    LV_LINE = SY-TABIX.',
    '    EXIT.',
    '  ENDIF.',
    'ENDLOOP.',
    'WRITE: / \'FORM line:\', LV_LINE.',
    'LOOP AT LT_SRC FROM LV_LINE TO LV_LINE + 30.',
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
