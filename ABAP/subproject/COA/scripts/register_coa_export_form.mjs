import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

const source = [
  'REPORT ZTMP_COA_EXPORT_REGISTER.',
  "CALL FUNCTION 'TR_TADIR_INTERFACE'",
  '  EXPORTING',
  "    WI_TEST_MODUS = ' '",
  "    WI_TADIR_PGMID = 'R3TR'",
  "    WI_TADIR_OBJECT = 'SSFO'",
  "    WI_TADIR_OBJ_NAME = 'ZQMF_COA_EXPORT'",
  "    WI_TADIR_DEVCLASS = '$TMP'",
  "    WI_TADIR_MASTERLANG = 'E'",
  "    IV_NO_PAK_CHECK = 'X'",
  '  EXCEPTIONS OTHERS = 1.',
  "WRITE: / 'TADIR_RC', SY-SUBRC, SY-MSGID, SY-MSGNO.",
  'IF SY-SUBRC = 0. COMMIT WORK AND WAIT. ENDIF.'
];
if (source.some(line => line.length > 72)) throw new Error('Line > 72 chars');
await serverManager.loadConfig();
const server = await serverManager.setActiveServer('sandbox-new');
if (!server.connected) throw new Error(server.connect_error || 'SAP not connected');
const response = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: { PROGRAM: source.map(LINE => ({ LINE })), WRITES: [] }
});
console.log(JSON.stringify({
  errorMessage: response.result?.ERRORMESSAGE,
  writes: response.result?.WRITES
}));
