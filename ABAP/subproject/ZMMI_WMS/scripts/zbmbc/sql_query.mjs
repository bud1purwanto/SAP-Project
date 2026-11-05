// Read-only: jalankan 1 query SELECT ke DBCO via ADBC, hasil kolom pertama per baris (NVARCHAR <= 250).
// Usage: node sql_query.mjs <server> <dbco> "<select returning 1 nvarchar column>"
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';
const [server, dbco, sql] = process.argv.slice(2);
if (!/^\s*(select|with)\b/i.test(sql)) { console.log('hanya SELECT'); process.exit(1); }
const parts = [];
for (let i = 0; i < sql.length; i += 40) parts.push(sql.slice(i, i + 40).replace(/'/g, "''"));
const src = [
  'REPORT ZTMP_SQLQ LINE-SIZE 255.',
  'DATA: LO_CON TYPE REF TO CL_SQL_CONNECTION,',
  ' LO_ST TYPE REF TO CL_SQL_STATEMENT,',
  ' LO_RS TYPE REF TO CL_SQL_RESULT_SET,',
  ' LX TYPE REF TO CX_SQL_EXCEPTION, LR TYPE REF TO DATA,',
  ' LV_SQL TYPE STRING, LV_OUT(250) TYPE C, LV_MSG TYPE STRING.',
  ...parts.flatMap(p => ['CONCATENATE LV_SQL', ` '${p}'`, ' INTO LV_SQL RESPECTING BLANKS.']),
  'TRY.',
  ` LO_CON = CL_SQL_CONNECTION=>GET_CONNECTION( '${dbco}' ).`,
  ' LO_ST = LO_CON->CREATE_STATEMENT( ).',
  ' LO_RS = LO_ST->EXECUTE_QUERY( LV_SQL ).',
  ' GET REFERENCE OF LV_OUT INTO LR.',
  ' LO_RS->SET_PARAM( LR ).',
  ' WHILE LO_RS->NEXT( ) > 0.',
  '  WRITE: / LV_OUT. CLEAR LV_OUT.',
  ' ENDWHILE.',
  ' LO_RS->CLOSE( ). LO_CON->CLOSE( ).',
  ' CATCH CX_SQL_EXCEPTION INTO LX.',
  '  LV_MSG = LX->GET_TEXT( ). LV_OUT = LV_MSG.',
  "  WRITE: / 'SQLERR', LV_OUT.",
  'ENDTRY.'];
const bad = src.filter(l => l.length > 72);
if (bad.length) { console.log('TOO LONG:', bad); process.exit(1); }
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const res = await HANDLERS.call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: src.map(LINE => ({ LINE })) } });
const r = res.result || res;
if (r.ERRORMESSAGE) console.log('ERR:', r.ERRORMESSAGE);
console.log((r.WRITES || []).map(w => w.ZEILE).join('\n') || JSON.stringify(res).slice(0, 800));
