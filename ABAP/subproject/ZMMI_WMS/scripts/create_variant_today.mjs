// WRITE (hanya sandbox-new): buat variant TODAY untuk ZMMI_WMS.
// Isi: S_ERDAT = tanggal hari ini (dinamis RS_VARI_V_TODAY), S_MAGRV = PLT & BOX,
//      Execution Type WMS (P_WMS = X), DBCO P_CONN = WMS.
// Usage: node create_variant_today.mjs sandbox-new
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';

const server = process.argv[2];
if (server !== 'sandbox-new') { console.log('Write hanya boleh ke sandbox-new'); process.exit(1); }

const src = [
  'REPORT ZTMP_VARIANT LINE-SIZE 200.',
  'DATA: LS_DESC TYPE VARID,',
  '      LT_CONT TYPE STANDARD TABLE OF RSPARAMS,',
  '      LS_CONT TYPE RSPARAMS,',
  '      LT_TEXT TYPE STANDARD TABLE OF VARIT,',
  '      LS_TEXT TYPE VARIT,',
  '      LT_VAL  TYPE STANDARD TABLE OF RSPARAMS,',
  '      LT_OBJ  TYPE STANDARD TABLE OF VANZ,',
  '      LV_RC   TYPE SY-SUBRC.',
  'FIELD-SYMBOLS: <LS_OBJ> TYPE VANZ.',
  "LS_DESC-REPORT     = 'ZMMI_WMS'.",
  "LS_DESC-VARIANT    = 'TODAY'.",
  "LS_DESC-ENVIRONMNT = 'A'.",
  "LS_DESC-MLANGU     = 'E'.",
  "CLEAR LS_CONT. LS_CONT-SELNAME = 'S_ERDAT'. LS_CONT-KIND = 'S'.",
  "LS_CONT-SIGN = 'I'. LS_CONT-OPTION = 'EQ'. LS_CONT-LOW = SY-DATUM.",
  'APPEND LS_CONT TO LT_CONT.',
  "CLEAR LS_CONT. LS_CONT-SELNAME = 'S_MAGRV'. LS_CONT-KIND = 'S'.",
  "LS_CONT-SIGN = 'I'. LS_CONT-OPTION = 'EQ'. LS_CONT-LOW = 'PLT'.",
  'APPEND LS_CONT TO LT_CONT.',
  "LS_CONT-LOW = 'BOX'. APPEND LS_CONT TO LT_CONT.",
  "CLEAR LS_CONT. LS_CONT-SELNAME = 'P_ALV'. LS_CONT-KIND = 'P'.",
  'APPEND LS_CONT TO LT_CONT.',
  "CLEAR LS_CONT. LS_CONT-SELNAME = 'P_WMS'. LS_CONT-KIND = 'P'.",
  "LS_CONT-LOW = 'X'. APPEND LS_CONT TO LT_CONT.",
  "CLEAR LS_CONT. LS_CONT-SELNAME = 'P_CONN'. LS_CONT-KIND = 'P'.",
  "LS_CONT-LOW = 'WMS'. APPEND LS_CONT TO LT_CONT.",
  "LS_TEXT-LANGU = 'E'. LS_TEXT-REPORT = 'ZMMI_WMS'.",
  "LS_TEXT-VARIANT = 'TODAY'.",
  "LS_TEXT-VTEXT = 'Today - PLT/BOX - WMS'.",
  'APPEND LS_TEXT TO LT_TEXT.',
  "CALL FUNCTION 'RS_CREATE_VARIANT'",
  "  EXPORTING CURR_REPORT = 'ZMMI_WMS' CURR_VARIANT = 'TODAY'",
  '            VARI_DESC = LS_DESC',
  '  TABLES    VARI_CONTENTS = LT_CONT VARI_TEXT = LT_TEXT',
  '  EXCEPTIONS ILLEGAL_REPORT_OR_VARIANT = 1 ILLEGAL_VARIANTNAME = 2',
  '    NOT_AUTHORIZED = 3 NOT_EXECUTED = 4 REPORT_NOT_EXISTENT = 5',
  '    REPORT_NOT_SUPPLIED = 6 VARIANT_EXISTS = 7 VARIANT_LOCKED = 8',
  '    OTHERS = 9.',
  "WRITE: / 'CREATE RC', SY-SUBRC.",
  'CHECK SY-SUBRC = 0.',
  'COMMIT WORK AND WAIT.',
  "CALL FUNCTION 'RS_VARIANT_CONTENTS'",
  "  EXPORTING REPORT = 'ZMMI_WMS' VARIANT = 'TODAY'",
  '  TABLES VALUTAB = LT_VAL OBJECTS = LT_OBJ',
  '  EXCEPTIONS VARIANT_NON_EXISTENT = 1 VARIANT_OBSOLETE = 2',
  '    OTHERS = 3.',
  "WRITE: / 'READ RC', SY-SUBRC.",
  'CHECK SY-SUBRC = 0.',
  "LOOP AT LT_OBJ ASSIGNING <LS_OBJ> WHERE NAME = 'S_ERDAT'.",
  "  <LS_OBJ>-VTYPE = 'F'.",
  "  <LS_OBJ>-VNAME = 'IEQRS_VARI_V_TODAY'.",
  'ENDLOOP.',
  "CALL FUNCTION 'RS_CHANGE_CREATED_VARIANT'",
  "  EXPORTING CURR_REPORT = 'ZMMI_WMS' CURR_VARIANT = 'TODAY'",
  '            VARI_DESC = LS_DESC',
  '  TABLES VARI_CONTENTS = LT_VAL VARI_TEXT = LT_TEXT',
  '         OBJECTS = LT_OBJ',
  '  EXCEPTIONS ILLEGAL_REPORT_OR_VARIANT = 1 ILLEGAL_VARIANTNAME = 2',
  '    NOT_AUTHORIZED = 3 NOT_EXECUTED = 4 REPORT_NOT_EXISTENT = 5',
  '    REPORT_NOT_SUPPLIED = 6 VARIANT_DOESNT_EXIST = 7',
  '    VARIANT_LOCKED = 8 SELECTIONS_NO_MATCH = 9 OTHERS = 10.',
  'LV_RC = SY-SUBRC.',
  "WRITE: / 'CHANGE RC', LV_RC.",
  'IF LV_RC = 0. COMMIT WORK AND WAIT. ENDIF.',
];
const bad = src.filter(l => l.length > 72);
if (bad.length) { console.log('TOO LONG:', bad); process.exit(1); }
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const res = await HANDLERS.call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: src.map(LINE => ({ LINE })) } });
const r = res.result || res;
if (r.ERRORMESSAGE) console.log('ERR:', r.ERRORMESSAGE);
console.log((r.WRITES || []).map(w => w.ZEILE).join('\n') || JSON.stringify(res).slice(0, 800));
