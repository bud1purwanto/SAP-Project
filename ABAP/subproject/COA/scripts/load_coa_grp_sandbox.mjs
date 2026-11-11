// Isi ZMAP_COA_GRP_COL / ZMAP_COA_GRP_CST di sandbox-new dari ZQM_COA_CUST_COL (sumber sistem yang sama).
// Usage: node load_coa_grp_sandbox.mjs [--force]
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const force = process.argv.includes('--force');
await serverManager.loadConfig(); await serverManager.setActiveServer('sandbox-new');
const read = async (t, opt, f) => ((await call_function({ function_name: 'RFC_READ_TABLE', parameters: { QUERY_TABLE: t, DELIMITER: '|', OPTIONS: opt ? [{ TEXT: opt }] : [], FIELDS: f.map(x => ({ FIELDNAME: x })) } })).result?.DATA || []).map(d => d.WA.split('|').map(v => v.trim()));
for (const t of ['ZMAP_COA_GRP_COL', 'ZMAP_COA_GRP_CST']) {
  const n = (await read(t, '', ['MANDT'])).length;
  if (n && !force) throw new Error(`${t} sudah berisi ${n} baris (pakai --force)`);
}
// group -> sumber layout (KUNNR lama)
const src = { 'DOM-G': 'DOMESTIC', 'EXP-G': 'EXPORT', 'DOM-01': '1141000111', 'DOM-02': '1142000002', 'EXP-01': '1141100041' };
const cols = [];
for (const [grp, k] of Object.entries(src)) {
  const rows = await read('ZQM_COA_CUST_COL', `KUNNR = '${k}' AND ACTIVE = 'X'`, ['SEQ_NO', 'FIELD_NAME', 'FIELD_LABEL', 'COL_SIZE']);
  rows.sort((a, b) => a[0].localeCompare(b[0]));
  rows.forEach((r, i) => cols.push([grp, r[1], r[2], String(i + 1).padStart(2, '0'), r[3] || 'M']));
}
// customer -> group: layout aktif sama persis dengan sumber group
const act = await read('ZQM_COA_CUST_COL', `ACTIVE = 'X'`, ['KUNNR', 'SEQ_NO', 'FIELD_NAME']);
const fp = {}; for (const [k, s, f] of act) (fp[k] = fp[k] || []).push(s + f);
const sig = k => (fp[k] || []).sort().map(x => x.slice(2)).join(',');
const csts = new Map();
for (const grp of ['DOM-01', 'DOM-02', 'EXP-01']) {
  const want = sig(src[grp]);
  for (const k of Object.keys(fp)) if (/^\d+$/.test(k) && sig(k) === want) csts.set(k, grp);
}
// customer di gambar user yang mapping lamanya tidak aktif / layout GG lama
for (const k of ['1141000110', '1141000119', '1141000143', '1141000165', '1141000299']) csts.set(k, 'DOM-01');
for (const k of ['1142000000', '1142000001', '1142000002']) csts.set(k, 'DOM-02');

const esc = s => s.replace(/'/g, "''");
const L = ['REPORT ZTMP_COA_GRP_LOAD.',
  'DATA: LT_C TYPE TABLE OF ZMAP_COA_GRP_COL, LS_C TYPE ZMAP_COA_GRP_COL,',
  '      LT_K TYPE TABLE OF ZMAP_COA_GRP_CST, LS_K TYPE ZMAP_COA_GRP_CST.'];
for (const [g, f, l, s, z] of cols) {
  L.push('CLEAR LS_C.', `LS_C-COA_GRP = '${g}'.`, `LS_C-FIELD_NAME = '${f}'.`, `LS_C-FIELD_LABEL = '${esc(l)}'.`,
    `LS_C-SEQ_NO = '${s}'.`, `LS_C-COL_SIZE = '${z}'.`, "LS_C-ACTIVE = 'X'.",
    'LS_C-AENAM = SY-UNAME. LS_C-AEDAT = SY-DATUM.', 'LS_C-AEZET = SY-UZEIT.', 'APPEND LS_C TO LT_C.');
}
for (const [k, g] of csts) {
  L.push('CLEAR LS_K.', `LS_K-KUNNR = '${k}'.`, `LS_K-COA_GRP = '${g}'.`,
    'LS_K-AENAM = SY-UNAME. LS_K-AEDAT = SY-DATUM.', 'LS_K-AEZET = SY-UZEIT.', 'APPEND LS_K TO LT_K.');
}
L.push('DELETE FROM ZMAP_COA_GRP_COL WHERE COA_GRP <> SPACE.',
  'DELETE FROM ZMAP_COA_GRP_CST WHERE KUNNR <> SPACE.',
  'INSERT ZMAP_COA_GRP_COL FROM TABLE LT_C.', "WRITE: / 'COL', SY-SUBRC, SY-DBCNT.",
  'INSERT ZMAP_COA_GRP_CST FROM TABLE LT_K.', "WRITE: / 'CST', SY-SUBRC, SY-DBCNT.", 'COMMIT WORK.');
for (const l of L) if (l.length > 72) throw new Error('Line too long: ' + l);
const r = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: L.map(LINE => ({ LINE })) } });
console.log((r.result?.WRITES || []).map(w => w.ZEILE).join(' | '), r.result?.ERRORMESSAGE || '');
const byGrp = {}; for (const [k, g] of csts) (byGrp[g] = byGrp[g] || []).push(k);
for (const g of Object.keys(src)) console.log(g, 'kolom', cols.filter(c => c[0] === g).length, 'customer', (byGrp[g] || []).length);
process.exit(0);
