// Read-only: jalankan ZMMI_WMS (ALV) via SUBMIT + CL_SALV_BS_RUNTIME_INFO, tangkap semua kolom.
// Usage: node capture_alv.mjs <server> <date_from> <date_to> <MAGRV,...> <out.json>
import { writeFileSync } from 'fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';
const [server, d1, d2, mg, out] = process.argv.slice(2);
const src = `REPORT ZTMP_WMSCAP LINE-SIZE 255.
DATA: LR_DATA TYPE REF TO DATA,
 LO_TD TYPE REF TO CL_ABAP_TABLEDESCR,
 LO_SD TYPE REF TO CL_ABAP_STRUCTDESCR,
 LT_COMP TYPE ABAP_COMPDESCR_TAB, LS_COMP TYPE ABAP_COMPDESCR,
 LV_ROW TYPE STRING, LV_VAL TYPE STRING, LV_LEN TYPE I,
 LV_OFF TYPE I, LV_PRE(1) TYPE C, LV_OUT(256) TYPE C,
 LV_N TYPE I, T0 TYPE I, T1 TYPE I, LV_TXT TYPE STRING.
DATA: LR_DAT TYPE RANGE OF VEKP-ERDAT, LS_DAT LIKE LINE OF LR_DAT,
 LR_MG TYPE RANGE OF VEKP-MAGRV, LS_MG LIKE LINE OF LR_MG.
FIELD-SYMBOLS: <LT> TYPE STANDARD TABLE, <LS> TYPE ANY,
 <LF> TYPE ANY.
LS_DAT-SIGN = 'I'. LS_DAT-OPTION = 'BT'.
LS_DAT-LOW = '${d1}'. LS_DAT-HIGH = '${d2}'.
APPEND LS_DAT TO LR_DAT.
LS_MG-SIGN = 'I'. LS_MG-OPTION = 'EQ'.
${mg.split(',').map(m => `LS_MG-LOW = '${m}'. APPEND LS_MG TO LR_MG.`).join('\n')}
CL_SALV_BS_RUNTIME_INFO=>SET( DISPLAY = ABAP_FALSE
 METADATA = ABAP_FALSE DATA = ABAP_TRUE ).
GET RUN TIME FIELD T0.
SUBMIT ZMMI_WMS WITH S_ERDAT IN LR_DAT WITH S_MAGRV IN LR_MG
 WITH P_ALV = 'X' WITH P_WMS = ' ' AND RETURN.
GET RUN TIME FIELD T1.
T1 = ( T1 - T0 ) / 1000000.
LV_TXT = T1. CONCATENATE 'T|' LV_TXT INTO LV_OUT. WRITE: / LV_OUT.
TRY.
 CL_SALV_BS_RUNTIME_INFO=>GET_DATA_REF( IMPORTING R_DATA = LR_DATA ).
 CATCH CX_SALV_BS_SC_RUNTIME_INFO.
 WRITE: / 'E|NO ALV DATA'.
 RETURN.
ENDTRY.
CL_SALV_BS_RUNTIME_INFO=>CLEAR_ALL( ).
ASSIGN LR_DATA->* TO <LT>.
LO_TD ?= CL_ABAP_TYPEDESCR=>DESCRIBE_BY_DATA( <LT> ).
LO_SD ?= LO_TD->GET_TABLE_LINE_TYPE( ).
LT_COMP = LO_SD->COMPONENTS.
LOOP AT LT_COMP INTO LS_COMP.
 CONCATENATE 'H|' LS_COMP-NAME INTO LV_OUT.
 WRITE: / LV_OUT.
ENDLOOP.
LOOP AT <LT> ASSIGNING <LS>.
 CLEAR LV_ROW.
 LOOP AT LT_COMP INTO LS_COMP.
  ASSIGN COMPONENT LS_COMP-NAME OF STRUCTURE <LS> TO <LF>.
  IF SY-SUBRC = 0. LV_VAL = <LF>. ELSE. CLEAR LV_VAL. ENDIF.
  CONDENSE LV_VAL.
  REPLACE ALL OCCURRENCES OF '|' IN LV_VAL WITH '/'.
  CONCATENATE LV_ROW LV_VAL '|' INTO LV_ROW.
 ENDLOOP.
 LV_LEN = STRLEN( LV_ROW ). LV_OFF = 0. LV_PRE = 'R'.
 WHILE LV_OFF < LV_LEN.
  LV_N = LV_LEN - LV_OFF.
  IF LV_N > 250. LV_N = 250. ENDIF.
  CONCATENATE LV_PRE '|' LV_ROW+LV_OFF(LV_N) INTO LV_OUT
   RESPECTING BLANKS.
  WRITE: / LV_OUT.
  LV_OFF = LV_OFF + LV_N. LV_PRE = 'C'.
 ENDWHILE.
ENDLOOP.
LV_N = LINES( <LT> ). LV_TXT = LV_N.
CONCATENATE 'N|' LV_TXT INTO LV_OUT. WRITE: / LV_OUT.
`;
const lines = src.split('\n').filter(l => l.trim());
const bad = lines.filter(l => l.length > 72);
if (bad.length) { console.log('TOO LONG:', bad); process.exit(1); }
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const res = await HANDLERS.call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: lines.map(LINE => ({ LINE })) } });
const r = res.result || res;
writeFileSync(out, JSON.stringify({ err: r.ERRORMESSAGE || res.error || '', writes: (r.WRITES || []).map(w => w.ZEILE) }));
console.log('ERR:', r.ERRORMESSAGE || res.error || '-', 'LINES:', (r.WRITES || []).length);
