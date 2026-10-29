import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZREAD_DYNPRO.',
    'DATA: WA_HEADER TYPE D020S,',
    '      LT_FLOW TYPE TABLE OF D022S WITH HEADER LINE,',
    '      LT_FIELDS TYPE TABLE OF D021S WITH HEADER LINE.',
    'CALL FUNCTION \'IMPORT_DYNPRO\'',
    '  EXPORTING',
    '    PROGRAM = \'ZQMI_COA\'',
    '    DYNPRO  = \'0200\'',
    '  IMPORTING',
    '    HEADER  = WA_HEADER',
    '  TABLES',
    '    FTAB    = LT_FIELDS',
    '    FLTXT   = LT_FLOW',
    '  EXCEPTIONS',
    '    OTHERS  = 1.',
    'LOOP AT LT_FLOW.',
    '  WRITE: / LT_FLOW-LINE.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log('FLOW 0200:', JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
