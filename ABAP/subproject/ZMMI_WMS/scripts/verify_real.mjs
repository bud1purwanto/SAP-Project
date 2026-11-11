// Read-only: SUBMIT program asli (ZMMI_WMS Screen by HU / ZBMBC by batch), tangkap ALV via
// CL_SALV_BS_RUNTIME_INFO, tulis kolom kunci. Usage: node verify_real.mjs <server> ZMMI|ZBMBC
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';
const [server, which] = process.argv.slice(2);
const sub = which === 'ZMMI' ? [
  "LS_E-SIGN = 'I'. LS_E-OPTION = 'EQ'.",
  "LS_E-LOW = '00000000006000036526'. APPEND LS_E TO LR_E.",
  "LS_E-LOW = '00000000006000036527'. APPEND LS_E TO LR_E.",
  "LS_M-SIGN = 'I'. LS_M-OPTION = 'EQ'. LS_M-LOW = 'BOX'.",
  'APPEND LS_M TO LR_M. LS_M-LOW = \'PLT\'. APPEND LS_M TO LR_M.',
  'SUBMIT ZMMI_WMS WITH S_ERDAT IN LR_D WITH S_EXIDV IN LR_E',
  " WITH S_MAGRV IN LR_M WITH P_ALV = 'X' WITH P_WMS = ' '",
  ' AND RETURN.'] : [
  "LS_A-SIGN = 'I'. LS_A-OPTION = 'EQ'. LS_A-LOW = 'SRA9JI'.",
  "APPEND LS_A TO LR_A. LS_A-LOW = 'SRWCNI'. APPEND LS_A TO LR_A.",
  "LS_W-SIGN = 'I'. LS_W-OPTION = 'EQ'. LS_W-LOW = '2000'.",
  'APPEND LS_W TO LR_W.',
  "LS_C-SIGN = 'I'. LS_C-OPTION = 'EQ'. LS_C-LOW = '0003860400'.",
  "APPEND LS_C TO LR_C. LS_C-LOW = '0003879068'.",
  'APPEND LS_C TO LR_C.',
  'SUBMIT ZBAP_STOCK_BY_CHAR1 WITH S_MATNR IN LR_A',
  " WITH S_WERKS IN LR_W WITH S_CHARG IN LR_C WITH P_ZERO = 'X'",
  ' AND RETURN.'];
const src = [
  'REPORT ZTMP_VREAL LINE-SIZE 255.',
  'DATA: LR_DATA TYPE REF TO DATA, LV_V TYPE STRING, LV_O TYPE STRING.',
  'DATA: LR_D TYPE RANGE OF VEKP-ERDAT,',
  ' LR_E TYPE RANGE OF VEKP-EXIDV, LS_E LIKE LINE OF LR_E,',
  ' LR_M TYPE RANGE OF VEKP-MAGRV, LS_M LIKE LINE OF LR_M,',
  ' LR_A TYPE RANGE OF MATNR, LS_A LIKE LINE OF LR_A,',
  ' LR_W TYPE RANGE OF WERKS_D, LS_W LIKE LINE OF LR_W,',
  ' LR_C TYPE RANGE OF CHARG_D, LS_C LIKE LINE OF LR_C,',
  ' LT_N TYPE STANDARD TABLE OF STRING, LV_N TYPE STRING.',
  'FIELD-SYMBOLS: <LT> TYPE STANDARD TABLE, <LS> TYPE ANY,',
  ' <LF> TYPE ANY.',
  "SPLIT 'WERKS MATNR CHARG LGORT VBELN KDAUF POSNR KDPOS'",
  " AT ' ' INTO TABLE LT_N.",
  "APPEND 'SOBKZ' TO LT_N.",
  "APPEND 'HUBOX' TO LT_N. APPEND 'HUPLT' TO LT_N.",
  "APPEND 'LABST' TO LT_N. APPEND 'CLABS' TO LT_N.",
  'CL_SALV_BS_RUNTIME_INFO=>SET( DISPLAY = ABAP_FALSE',
  ' METADATA = ABAP_FALSE DATA = ABAP_TRUE ).',
  ...sub,
  'TRY.',
  ' CL_SALV_BS_RUNTIME_INFO=>GET_DATA_REF(',
  '  IMPORTING R_DATA = LR_DATA ).',
  ' CATCH CX_SALV_BS_SC_RUNTIME_INFO.',
  "  WRITE / 'NODATA'.",
  'ENDTRY.',
  'CL_SALV_BS_RUNTIME_INFO=>CLEAR_ALL( ).',
  'CHECK LR_DATA IS BOUND.',
  'ASSIGN LR_DATA->* TO <LT>.',
  'LOOP AT <LT> ASSIGNING <LS>.',
  " LV_O = 'O'.",
  ' LOOP AT LT_N INTO LV_N.',
  '  ASSIGN COMPONENT LV_N OF STRUCTURE <LS> TO <LF>.',
  '  IF SY-SUBRC = 0. LV_V = <LF>. CONDENSE LV_V.',
  "   CONCATENATE LV_O LV_N '=' LV_V INTO LV_O SEPARATED BY ' '.",
  '  ENDIF.',
  ' ENDLOOP.',
  ' WRITE / LV_O.',
  'ENDLOOP.'];
const bad = src.filter(l => l.length > 72);
if (bad.length) { console.log('TOO LONG', bad); process.exit(1); }
await serverManager.loadConfig(); await serverManager.setActiveServer(server);
const res = await HANDLERS.call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: src.map(LINE => ({ LINE })) } });
const r = res.result || res;
if (r.ERRORMESSAGE) console.log('ERR:', r.ERRORMESSAGE);
for (const w of r.WRITES || []) if (w.ZEILE.trim()) console.log(w.ZEILE.trim());
