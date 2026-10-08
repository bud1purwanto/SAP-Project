import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

const source = [
  'REPORT ZTMP_COA_SYNTAX_CHECK.',
  'DATA: LT_SOURCE TYPE STANDARD TABLE OF ABAPTXT255,',
  '      LV_MSG TYPE STRING,',
  '      LV_INC TYPE SYREPID,',
  '      LV_LINE TYPE SY-TABIX,',
  '      LV_SUBRC TYPE SY-SUBRC.',
  "READ REPORT 'ZQMI_COA' INTO LT_SOURCE.",
  "CALL FUNCTION 'RS_SYNTAX_CHECK'",
  '  EXPORTING',
  "    I_PROGRAM = 'ZQMI_COA'",
  "    I_GLOBAL_PROGRAM = 'ZQMI_COA'",
  "    I_GLOBAL_CHECK = 'X'",
  "    I_WITH_DIALOG = ' '",
  '  IMPORTING',
  '    O_ERROR_INCLUDE = LV_INC',
  '    O_ERROR_LINE = LV_LINE',
  '    O_ERROR_MESSAGE = LV_MSG',
  '    O_ERROR_SUBRC = LV_SUBRC',
  '  TABLES I_SOURCE = LT_SOURCE',
  '  EXCEPTIONS OTHERS = 1.',
  "WRITE: / 'FM_RC', SY-SUBRC.",
  "WRITE: / 'SYNTAX_RC', LV_SUBRC, LV_INC, LV_LINE.",
  'WRITE: / LV_MSG.'
];
if (source.some(line => line.length > 72)) throw new Error('Line > 72');
await serverManager.loadConfig();
const server = await serverManager.setActiveServer('sandbox-new');
if (!server.connected) throw new Error(server.connect_error || 'SAP not connected');
const response = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: { PROGRAM: source.map(LINE => ({ LINE })), WRITES: [] }
});
console.log(JSON.stringify({ errorMessage: response.result?.ERRORMESSAGE, writes: response.result?.WRITES }));
