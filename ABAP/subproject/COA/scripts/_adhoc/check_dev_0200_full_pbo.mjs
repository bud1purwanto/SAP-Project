import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_DEV_0200_FULL_PBO.',
    'DATA: D020S_REC TYPE D020S,',
    '      D021S_TAB TYPE TABLE OF D021S WITH HEADER LINE,',
    '      D022S_TAB TYPE TABLE OF D022S WITH HEADER LINE.',
    'CALL FUNCTION \'RS_IMPORT_DYNPRO\'',
    '  EXPORTING DYNAME = \'ZQMI_COA\' DYNUMB = \'0200\'',
    '  IMPORTING HEADER = D020S_REC',
    '  TABLES FTAB = D021S_TAB PLTAB = D022S_TAB EXCEPTIONS OTHERS = 1.',
    'DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
    'READ REPORT \'ZQMI_COA_F02\' INTO LT_SRC.',
    'LOOP AT LT_SRC WHERE LINE CS \'TDETAIL_GET_LINES\'.',
    '  DATA: LV_IDX TYPE I.',
    '  LV_IDX = SY-TABIX.',
    '  LOOP AT LT_SRC FROM LV_IDX - 2 TO LV_IDX + 10.',
    '    WRITE: / LT_SRC-LINE.',
    '  ENDLOOP.',
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
