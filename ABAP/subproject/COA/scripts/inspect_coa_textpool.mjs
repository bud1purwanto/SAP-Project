import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
import { writeFile } from 'node:fs/promises';

const source = [
  'REPORT ZTMP_COA_TEXTPOOL_READ.',
  'DATA: LT_TP TYPE STANDARD TABLE OF TEXTPOOL,',
  '      LS_TP TYPE TEXTPOOL,',
  '      LV_LANG TYPE SY-LANGU,',
  '      LV_LINE TYPE STRING,',
  '      LV_LENGTH TYPE C LENGTH 3.',
  "LV_LANG = 'E'.",
  'PERFORM READ_POOL.',
  "LV_LANG = 'I'.",
  'PERFORM READ_POOL.',
  'FORM READ_POOL.',
  '  REFRESH LT_TP.',
  "  READ TEXTPOOL 'ZQMI_COA' INTO LT_TP LANGUAGE LV_LANG.",
  "  WRITE: / 'LANG', LV_LANG, 'RC', SY-SUBRC.",
  '  LOOP AT LT_TP INTO LS_TP.',
  '    WRITE LS_TP-LENGTH TO LV_LENGTH LEFT-JUSTIFIED.',
  '    CONCATENATE LS_TP-ID LS_TP-KEY LV_LENGTH',
  "      LS_TP-ENTRY INTO LV_LINE SEPARATED BY '|'.",
  '    WRITE: / LV_LINE.',
  '  ENDLOOP.',
  'ENDFORM.'
];
if (source.some(line => line.length > 72)) throw new Error('Line > 72');
await serverManager.loadConfig();
const server = await serverManager.setActiveServer('sandbox-new');
if (!server.connected) throw new Error(server.connect_error || 'SAP not connected');
const response = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: { PROGRAM: source.map(LINE => ({ LINE })), WRITES: [] }
});
const result = {
  errorMessage: response.result?.ERRORMESSAGE,
  writes: response.result?.WRITES
};
const tag = process.argv[2] || 'before_selection_texts';
if (!/^[a-z0-9_]+$/i.test(tag)) throw new Error('Invalid output tag');
const backup = new URL(`../outputs/ZQMI_COA_textpool_${tag}.json`, import.meta.url);
await writeFile(backup, JSON.stringify(result, null, 2));
console.log(JSON.stringify({ ...result, backup: backup.pathname }));
