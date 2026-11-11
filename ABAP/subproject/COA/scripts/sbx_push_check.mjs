// Push a COA program to sandbox-new and run RS_SYNTAX_CHECK.
// Usage: node sbx_push_check.mjs <PROGRAM> <source-file> [--check-only] [--main <MAINPROG>]
import { readFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const [prog, file, ...rest] = process.argv.slice(2);
const checkOnly = rest.includes('--check-only');
const main = rest.includes('--main') ? rest[rest.indexOf('--main') + 1] : prog;
if (!/^(ZMAP_COA_BATCH\w*|ZQMI_COA_(TOP|F01|F02)|ZTMP_COA_\w+)$/.test(prog)) throw new Error('Program not allowed: ' + prog);
await serverManager.loadConfig();
await serverManager.setActiveServer('sandbox-new');
if (!checkOnly) {
  const src = readFileSync(file, 'utf8').split(/\r?\n/);
  if (src[src.length - 1] === '') src.pop();
  if (src.some(l => l.length > 255)) throw new Error('line > 255');
  const r = await call_function({ function_name: 'Z_RFC_PROGRAM_UPDATE', parameters: {
    IV_PROGRAM_NAME: prog, IV_PACKAGE: '$TMP', IV_CORRNUMBER: ' ', IT_SOURCE: src.map(LINE => ({ LINE })) } });
  console.log('push', prog, src.length, r.result?.EV_SUCCESS, r.result?.EV_MESSAGE);
  if (r.result?.EV_SUCCESS !== 'X') process.exit(1);
}
const chk = [
  'REPORT ZTMP_COA_SYNCHK.',
  'DATA: LT_SRC TYPE STANDARD TABLE OF ABAPTXT255,',
  '      LV_MSG TYPE STRING, LV_INC TYPE SYREPID,',
  '      LV_LINE TYPE SY-TABIX, LV_RC TYPE SY-SUBRC, LV_WRD TYPE STRING.',
  `READ REPORT '${main}' INTO LT_SRC.`,
  "CALL FUNCTION 'RS_SYNTAX_CHECK'",
  `  EXPORTING I_PROGRAM = '${main}'`,
  `            I_GLOBAL_PROGRAM = '${main}'`,
  '  IMPORTING O_ERROR_INCLUDE = LV_INC O_ERROR_LINE = LV_LINE',
  '            O_ERROR_MESSAGE = LV_MSG O_ERROR_SUBRC = LV_RC',
  '  TABLES I_SOURCE = LT_SRC',
  '  EXCEPTIONS OTHERS = 1.',
  "WRITE: / 'RC', LV_RC, LV_INC, LV_LINE.",
  'WRITE: / LV_WRD.',
  'WRITE: / LV_MSG.'];
const c = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: chk.map(LINE => ({ LINE })) } });
console.log((c.result?.WRITES || []).map(w => w.ZEILE).join('\n'), c.result?.ERRORMESSAGE || '');
process.exit(0);
