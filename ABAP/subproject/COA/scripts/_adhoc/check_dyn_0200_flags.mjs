import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_LIVE_D021S_DYN.',
    'DATA: D020S_REC TYPE D020S,',
    '      D021S_TAB TYPE TABLE OF D021S WITH HEADER LINE,',
    '      D022S_TAB TYPE TABLE OF D022S WITH HEADER LINE.',
    'CALL FUNCTION \'RS_IMPORT_DYNPRO\'',
    '  EXPORTING DYNAME = \'ZQMI_COA\' DYNUMB = \'0200\'',
    '  IMPORTING HEADER = D020S_REC',
    '  TABLES FTAB = D021S_TAB PLTAB = D022S_TAB EXCEPTIONS OTHERS = 1.',
    'LOOP AT D021S_TAB WHERE FNAM CS \'MICDES\'.',
    '  WRITE: / D021S_TAB-FNAM, D021S_TAB-FLG1, D021S_TAB-FLG2,',
    '         D021S_TAB-FLG3, D021S_TAB-GRP1, D021S_TAB-GRP2.',
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
