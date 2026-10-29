// Jalankan ZBAP_STOCK_BY_CHAR1 mode WMS (LRB3, DBCO), lalu baca balik Y_ZBMBCSR via DBCO yang sama (read-only).
// Usage: node capture_wms.mjs <server> <dbco> <out.json> [run|readonly]
import { writeFileSync } from 'fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';
const [server, dbco, out, mode = 'run'] = process.argv.slice(2);
const cols = ['Plant', 'Material No', 'Type', 'Thick', 'Batch', 'Width', 'Length', 'TipeAlias',
  'CriteriaGrade', 'Sloc', 'Storage Bin', 'SO No', 'SO Item', 'Sales Doc Type', 'HU Box', 'HU Pallet', 'Customer Name'];
const vars = cols.map((_, i) => `V${i + 1}`);
const sel = [];
cols.forEach((c, i) => sel.push(` [${c}]${i < cols.length - 1 ? ',' : ''}`));
let src = `REPORT ZTMP_WMSCAP LINE-SIZE 255.
DATA: LV_CON TYPE DBCON-CON_NAME VALUE '${dbco}',
 LV_ROW TYPE STRING, LV_LEN TYPE I, LV_OFF TYPE I, LV_N TYPE I,
 LV_PRE(1) TYPE C, LV_OUT(256) TYPE C, LV_TXT TYPE STRING,
 LV_CNT TYPE I, T0 TYPE I, T1 TYPE I.
DATA: ${vars.map(v => `${v}(200) TYPE C`).join(', ')}.
DATA: R_MATNR TYPE RANGE OF MATNR, RS_MATNR LIKE LINE OF R_MATNR,
 R_WERKS TYPE RANGE OF WERKS_D, RS_WERKS LIKE LINE OF R_WERKS.
RS_MATNR-SIGN = 'I'. RS_MATNR-OPTION = 'CP'.
RS_MATNR-LOW = 'SR*'. APPEND RS_MATNR TO R_MATNR.
RS_WERKS-SIGN = 'I'. RS_WERKS-OPTION = 'CP'.
RS_WERKS-LOW = '*'. APPEND RS_WERKS TO R_WERKS.
`;
if (mode === 'run') src += `GET RUN TIME FIELD T0.
SUBMIT ZBAP_STOCK_BY_CHAR1 WITH S_MATNR IN R_MATNR
 WITH S_WERKS IN R_WERKS WITH P_ZERO = 'X'
 WITH LRB1 = ' ' WITH LRB2 = ' ' WITH LRB3 = 'X'
 WITH S_CONN = LV_CON AND RETURN.
GET RUN TIME FIELD T1.
T1 = ( T1 - T0 ) / 1000000.
LV_TXT = T1. CONCATENATE 'T|' LV_TXT INTO LV_OUT. WRITE: / LV_OUT.
`;
src += `EXEC SQL. CONNECT TO :LV_CON ENDEXEC.
IF SY-SUBRC <> 0. WRITE: / 'E|CONNECT FAIL'. RETURN. ENDIF.
EXEC SQL. SET CONNECTION :LV_CON ENDEXEC.
TRY.
EXEC SQL.
 SELECT COUNT(*) INTO :LV_CNT FROM ZBMBCSR_WMS
ENDEXEC.
LV_TXT = LV_CNT. CONCATENATE 'W|' LV_TXT INTO LV_OUT. WRITE: / LV_OUT.
CATCH CX_SY_NATIVE_SQL_ERROR.
WRITE: / 'W|ERR'.
ENDTRY.
EXEC SQL.
 OPEN C1 FOR SELECT
${sel.join('\n')}
 FROM Y_ZBMBCSR
ENDEXEC.
DO.
 EXEC SQL.
  FETCH NEXT C1 INTO ${vars.map(v => ':' + v).join(', ')}
 ENDEXEC.
 IF SY-SUBRC <> 0. EXIT. ENDIF.
 LV_CNT = SY-INDEX.
 CONCATENATE ${vars.join(" '|' ")} '|' INTO LV_ROW.
 LV_LEN = STRLEN( LV_ROW ). LV_OFF = 0. LV_PRE = 'R'.
 WHILE LV_OFF < LV_LEN.
  LV_N = LV_LEN - LV_OFF.
  IF LV_N > 250. LV_N = 250. ENDIF.
  CONCATENATE LV_PRE '|' LV_ROW+LV_OFF(LV_N) INTO LV_OUT
   RESPECTING BLANKS.
  WRITE: / LV_OUT.
  LV_OFF = LV_OFF + LV_N. LV_PRE = 'C'.
 ENDWHILE.
ENDDO.
EXEC SQL. CLOSE C1 ENDEXEC.
EXEC SQL. DISCONNECT :LV_CON ENDEXEC.
LV_TXT = LV_CNT. CONCATENATE 'N|' LV_TXT INTO LV_OUT. WRITE: / LV_OUT.
`;
// wrap long lines (>72) at spaces
const lines = [];
for (const l of src.split('\n').filter(x => x.trim())) {
  if (l.length <= 72) { lines.push(l); continue; }
  let cur = '';
  for (const tok of l.split(' ')) {
    if ((cur + ' ' + tok).length > 70 && cur.trim()) { lines.push(cur); cur = ' ' + tok; }
    else cur = cur ? cur + ' ' + tok : tok;
  }
  lines.push(cur);
}
const bad = lines.filter(l => l.length > 72);
if (bad.length) { console.log('TOO LONG:', bad); process.exit(1); }
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const res = await HANDLERS.call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: lines.map(LINE => ({ LINE })) } });
const r = res.result || res;
writeFileSync(out, JSON.stringify({ err: r.ERRORMESSAGE || res.error || '', writes: (r.WRITES || []).map(w => w.ZEILE) }));
console.log('ERR:', r.ERRORMESSAGE || res.error || '-', 'LINES:', (r.WRITES || []).length);
console.log((r.WRITES || []).filter(w => /^[TWNE]\|/.test(w.ZEILE)).map(w => w.ZEILE).join('\n'));
