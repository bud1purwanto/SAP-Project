// Ganti judul program (text pool ID 'R', bahasa E) di server non-PRD.
// Usage: node set_coa_titles.mjs [server]
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const srv = process.argv[2] || 'sandbox-new';
if (/prod/i.test(srv)) throw new Error('Not for production');
const TITLES = {
  ZQMI_COA_TOP: 'Include ZQMI_COA_TOP',
  ZQMI_COA_F01: 'Include ZQMI_COA_F01',
  ZQMI_COA_F02: 'Include ZQMI_COA_F02',
  ZMAP_COA_BATCH: 'COA Batch List Mapping per Group',
};
await serverManager.loadConfig(); await serverManager.setActiveServer(srv);
const L = ['REPORT ZTMP_COA_TITLE.',
  'DATA: LT_TP TYPE TABLE OF TEXTPOOL, LS_TP TYPE TEXTPOOL,',
  '      LV_P TYPE SYREPID.',
  'FIELD-SYMBOLS <TP> TYPE TEXTPOOL.'];
for (const [p, t] of Object.entries(TITLES)) L.push(
  `LV_P = '${p}'.`,
  "READ TEXTPOOL LV_P INTO LT_TP LANGUAGE 'E'.",
  "READ TABLE LT_TP ASSIGNING <TP> WITH KEY ID = 'R'.",
  'IF SY-SUBRC = 0.',
  `  <TP>-ENTRY = '${t}'.`,
  `  <TP>-LENGTH = ${t.length}.`,
  'ELSE.',
  `  LS_TP-ID = 'R'. LS_TP-ENTRY = '${t}'.`,
  `  LS_TP-LENGTH = ${t.length}. APPEND LS_TP TO LT_TP.`,
  'ENDIF.',
  "INSERT TEXTPOOL LV_P FROM LT_TP LANGUAGE 'E'.",
  'WRITE: / LV_P, SY-SUBRC.');
L.push('COMMIT WORK.');
for (const l of L) if (l.length > 72) throw new Error('Line too long: ' + l);
const r = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: L.map(LINE => ({ LINE })) } });
console.log((r.result?.WRITES || []).map(w => w.ZEILE.replace(/ +/g, ' ')).join(' | '), r.result?.ERRORMESSAGE || '');
process.exit(0);
