// Read-only test: jalankan source ZMMI_WMS (file lokal) sebagai SUBROUTINE POOL di memori server,
// TANPA menyimpan / mengubah program di server dan TANPA insert SQL (INSERT_SQL_WMS diganti dump).
// Usage: node pool_test.mjs <server> <source.abap> <SCREEN|WMS> <MAGRV,..> <EXIDV,..> [ERDAT_FROM ERDAT_TO]
// Output: baris "O|WERKS|MATNR|CHARG|LGORT|VBELN|POSNR|SOBKZ|HUBOX|HUPLT|LABST"
import { readFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';

const [server, file, mode, magrv, exidv, d1, d2] = process.argv.slice(2);
let L = readFileSync(file, 'utf8').replace(/\r/g, '').split('\n');

// ---- transformasi report -> subroutine pool
const out = [];
let skip = false, inStart = false, closed = false;
for (const line of L) {
  const u = line.trim().toUpperCase();
  if (/^REPORT\s/.test(u)) { out.push('PROGRAM ZTMP_WMS_POOL.'); continue; }
  if (/^(SELECTION-SCREEN|SELECT-OPTIONS|PARAMETERS?)[\s:]/.test(u)) continue;
  if (u === 'INITIALIZATION.' || u === 'AT SELECTION-SCREEN OUTPUT.') { skip = true; continue; }
  if (u === 'START-OF-SELECTION.') {
    skip = false; inStart = true;
    out.push('RANGES: S_ERDAT FOR VEKP-ERDAT, S_EXIDV FOR VEKP-EXIDV,');
    out.push('        S_MAGRV FOR VEKP-MAGRV, S_WERKS FOR VEKP-WERKS.');
    out.push("DATA: P_ALV(1) TYPE C, P_WMS(1) TYPE C,");
    out.push('      P_CONN TYPE DBCON-CON_NAME.');
    out.push('FORM ENTRY USING UV_MODE TYPE C UV_MAGRV TYPE STRING');
    out.push('                 UV_EXIDV TYPE STRING UV_D1 TYPE D UV_D2 TYPE D.');
    out.push('  DATA: LT_V TYPE STANDARD TABLE OF STRING, LV_V TYPE STRING.');
    out.push("  IF UV_MODE = 'W'. P_WMS = 'X'. P_CONN = 'DUMMY'.");
    out.push("  ELSE. P_ALV = 'X'. ENDIF.");
    out.push("  SPLIT UV_MAGRV AT ',' INTO TABLE LT_V.");
    out.push("  LOOP AT LT_V INTO LV_V. S_MAGRV-SIGN = 'I'.");
    out.push("    S_MAGRV-OPTION = 'EQ'. S_MAGRV-LOW = LV_V.");
    out.push('    APPEND S_MAGRV. ENDLOOP.');
    out.push("  SPLIT UV_EXIDV AT ',' INTO TABLE LT_V.");
    out.push("  LOOP AT LT_V INTO LV_V. CHECK LV_V IS NOT INITIAL.");
    out.push("    S_EXIDV-SIGN = 'I'. S_EXIDV-OPTION = 'EQ'.");
    out.push('    S_EXIDV-LOW = LV_V. APPEND S_EXIDV. ENDLOOP.');
    out.push('  IF UV_D1 IS NOT INITIAL.');
    out.push("    S_ERDAT-SIGN = 'I'. S_ERDAT-OPTION = 'BT'.");
    out.push('    S_ERDAT-LOW = UV_D1. S_ERDAT-HIGH = UV_D2.');
    out.push('    APPEND S_ERDAT. ENDIF.');
    continue;
  }
  if (skip) continue;
  if (inStart && !closed && /^FORM\s/.test(u)) {
    out.push('ENDFORM.');
    out.push('FORM DUMP_OUT.');
    out.push('  LOOP AT GT_OUT INTO GS_OUT.');
    out.push("    WRITE: / 'O', GS_OUT-WERKS, GS_OUT-MATNR, GS_OUT-CHARG,");
    out.push('      GS_OUT-LGORT, GS_OUT-VBELN, GS_OUT-POSNR, GS_OUT-SOBKZ,');
    out.push('      GS_OUT-HUBOX, GS_OUT-HUPLT, GS_OUT-LABST.');
    out.push('  ENDLOOP.');
    out.push('ENDFORM.');
    closed = true;
  }
  if (inStart && !closed) {
    if (u === 'PERFORM SET_ALV.' || u === 'PERFORM INSERT_SQL_WMS.') { out.push('    PERFORM DUMP_OUT.'); continue; }
  }
  out.push(line);
}
if (!closed) { console.log('transform gagal'); process.exit(1); }

// ---- carrier program (baris <= 72)
const esc = s => s.replace(/'/g, "''");
const car = [
  'REPORT ZTMP_POOLRUN LINE-SIZE 255.',
  'DATA: LT_SRC TYPE STANDARD TABLE OF STRING, LV_L TYPE STRING,',
  '      LV_PROG TYPE PROGRAM, LV_MSG TYPE STRING, LV_LIN TYPE I,',
  '      LV_M TYPE STRING, LV_E TYPE STRING, LV_D1 TYPE D, LV_D2 TYPE D.',
];
for (const line of out) {
  car.push('CLEAR LV_L.');
  for (let i = 0; i < line.length; i += 40) {
    car.push(`CONCATENATE LV_L '${esc(line.slice(i, i + 40))}'`);
    car.push(' INTO LV_L RESPECTING BLANKS.');
  }
  car.push('APPEND LV_L TO LT_SRC.');
}
car.push('GENERATE SUBROUTINE POOL LT_SRC NAME LV_PROG');
car.push('  MESSAGE LV_MSG LINE LV_LIN.');
car.push("IF SY-SUBRC <> 0. WRITE: / 'GENERR', LV_LIN, LV_MSG(200).");
car.push('  RETURN. ENDIF.');
car.push(`LV_M = '${magrv}'. LV_E = '${exidv || ''}'.`);
car.push(`LV_D1 = '${d1 || '00000000'}'. LV_D2 = '${d2 || '00000000'}'.`);
car.push(`PERFORM ENTRY IN PROGRAM (LV_PROG) USING '${mode === 'WMS' ? 'W' : 'S'}'`);
car.push('  LV_M LV_E LV_D1 LV_D2.');
car.push("WRITE: / 'END'.");
const bad = car.filter(l => l.length > 72);
if (bad.length) { console.log('TOO LONG', bad.slice(0, 3)); process.exit(1); }

await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const res = await HANDLERS.call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: car.map(LINE => ({ LINE })) } });
const r = res.result || res;
if (r.ERRORMESSAGE) console.log('ERR:', r.ERRORMESSAGE);
for (const w of r.WRITES || []) {
  const z = w.ZEILE.replace(/\s+$/, '');
  if (z.trim()) console.log(z);
}
