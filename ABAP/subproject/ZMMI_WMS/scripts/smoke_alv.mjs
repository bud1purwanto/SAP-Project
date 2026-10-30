// Smoke run ZMMI_WMS (ALV) via SUBMIT + CL_SALV_BS_RUNTIME_INFO. Usage: node smoke_alv.mjs <server> <date_from|-> <date_to|-> [MAGRV,...] [EXIDV,...]
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';
const [server, d1, d2, mg = 'PLT,BOX', hu = ''] = process.argv.slice(2);
const src = [
  'REPORT ZTMP_SMK LINE-SIZE 255.',
  'DATA: LR_DATA TYPE REF TO DATA,',
  '      LR_DAT TYPE RANGE OF VEKP-ERDAT,',
  '      LS_DAT LIKE LINE OF LR_DAT,',
  '      LR_MG TYPE RANGE OF VEKP-MAGRV,',
  '      LS_MG LIKE LINE OF LR_MG,',
  '      LR_HU TYPE RANGE OF VEKP-EXIDV,',
  '      LS_HU LIKE LINE OF LR_HU,',
  '      LV_T1 TYPE I, LV_T2 TYPE I, LV_N TYPE I, LV_MS TYPE I.',
  'FIELD-SYMBOLS: <LT> TYPE STANDARD TABLE, <LS> TYPE ANY,',
  '               <LF> TYPE ANY.',
  ...(d1 === '-' ? [] : ["LS_DAT-SIGN = 'I'. LS_DAT-OPTION = 'BT'.",
  `LS_DAT-LOW = '${d1}'. LS_DAT-HIGH = '${d2}'.`,
  'APPEND LS_DAT TO LR_DAT.']),
  "LS_HU-SIGN = 'I'. LS_HU-OPTION = 'EQ'.",
  ...hu.split(',').filter(Boolean).map(h => `LS_HU-LOW = '${h.padStart(20, '0')}'. APPEND LS_HU TO LR_HU.`),
  "LS_MG-SIGN = 'I'. LS_MG-OPTION = 'EQ'.",
  ...mg.split(',').map(m => `LS_MG-LOW = '${m}'. APPEND LS_MG TO LR_MG.`),
  'CL_SALV_BS_RUNTIME_INFO=>SET( EXPORTING DISPLAY = SPACE',
  "  METADATA = SPACE DATA = 'X' ).",
  'GET RUN TIME FIELD LV_T1.',
  'SUBMIT ZMMI_WMS WITH S_ERDAT IN LR_DAT WITH S_MAGRV IN LR_MG',
  '  WITH S_EXIDV IN LR_HU',
  "  WITH P_ALV = 'X' WITH P_WMS = ' ' AND RETURN.",
  'GET RUN TIME FIELD LV_T2.',
  'LV_MS = ( LV_T2 - LV_T1 ) / 1000.',
  'TRY.',
  '  CL_SALV_BS_RUNTIME_INFO=>GET_DATA_REF( IMPORTING R_DATA = LR_DATA ).',
  '  CATCH CX_SALV_BS_SC_RUNTIME_INFO.',
  "    WRITE / 'NO ALV DATA'.",
  'ENDTRY.',
  'CL_SALV_BS_RUNTIME_INFO=>CLEAR_ALL( ).',
  "WRITE: / 'MS', LV_MS.",
  'IF LR_DATA IS BOUND.',
  '  ASSIGN LR_DATA->* TO <LT>.',
  '  LV_N = LINES( <LT> ).',
  "  WRITE: / 'ROWS', LV_N.",
  '  LOOP AT <LT> ASSIGNING <LS>.',
  '    IF SY-TABIX > 60. EXIT. ENDIF.',
  '    NEW-LINE.',
  '    DO 22 TIMES.',
  '      ASSIGN COMPONENT SY-INDEX OF STRUCTURE <LS> TO <LF>.',
  '      IF SY-SUBRC <> 0. EXIT. ENDIF.',
  "      WRITE: <LF> NO-GAP, '|' NO-GAP.",
  '    ENDDO.',
  '  ENDLOOP.',
  'ENDIF.',
];
const bad = src.filter(l => l.length > 72); if (bad.length) { console.log('LINE>72', bad); process.exit(1); }
await serverManager.loadConfig(); await serverManager.setActiveServer(server);
const res = await HANDLERS.call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: src.map(LINE => ({ LINE })) } });
for (const w of (res.result?.WRITES || [])) console.log(w.ZEILE.replace(/\s+\|/g,'|').trimEnd());
if (res.result?.ERRORMESSAGE) console.log('ERR', res.result.ERRORMESSAGE);
