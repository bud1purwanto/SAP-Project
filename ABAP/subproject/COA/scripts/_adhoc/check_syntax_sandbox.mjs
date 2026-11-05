import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_SYNTAX_COA.',
    'DATA: LV_MSG TYPE STRING,',
    '      LV_LINE TYPE I,',
    '      LV_WORD TYPE STRING.',
    'SYNTAX-CHECK FOR PROGRAM \'ZQMI_COA\'',
    '  MESSAGE LV_MSG LINE LV_LINE WORD LV_WORD.',
    'IF SY-SUBRC = 0.',
    '  WRITE: / \'SYNTAX_CHECK_SUCCESS\'.',
    'ELSE.',
    '  WRITE: / \'SYNTAX_ERROR:\', LV_MSG, \'LINE:\', LV_LINE, \'WORD:\', LV_WORD.',
    'ENDIF.'
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
