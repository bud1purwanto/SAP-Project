// Copy isi ZMAP_COA_GRP_COL / ZMAP_COA_GRP_CST dari server sumber ke target (bukan PRD).
// Usage: node copy_coa_grp_data.mjs <source> <target> [--apply]
import { writeFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const [src, tgt] = process.argv.slice(2);
const apply = process.argv.includes('--apply');
if (!src || !tgt || /prod/i.test(tgt)) throw new Error('Usage: <source> <target> [--apply]; target bukan PRD');
const T = { ZMAP_COA_GRP_COL: ['COA_GRP','FIELD_NAME','FIELD_LABEL','SEQ_NO','COL_SIZE','ACTIVE','AENAM','AEDAT','AEZET'],
            ZMAP_COA_GRP_CST: ['KUNNR','COA_GRP','AENAM','AEDAT','AEZET'] };
await serverManager.loadConfig();
const read = async (srv) => { await serverManager.setActiveServer(srv); const o = {};
  for (const [t, f] of Object.entries(T)) o[t] = ((await call_function({ function_name: 'RFC_READ_TABLE', parameters: { QUERY_TABLE: t, DELIMITER: '|', FIELDS: f.map(x => ({ FIELDNAME: x })) } })).result?.DATA || []).map(d => d.WA.split('|').map(v => v.trim()));
  return o; };
const S = await read(src), D = await read(tgt);
for (const t in T) console.log(t, `${src}=${S[t].length}`, `${tgt}=${D[t].length}`);
const stamp = new Date().toISOString().slice(0, 10).replace(/-/g, '');
writeFileSync(`outputs/coa_grp_data_${tgt.replace(/ /g, '_')}_before_copy_${stamp}.json`, JSON.stringify(D, null, 1));
if (!apply) process.exit(0);
const esc = s => s.replace(/'/g, "''");
const L = ['REPORT ZTMP_COA_GRP_COPY.',
  'DATA: LT_C TYPE TABLE OF ZMAP_COA_GRP_COL,', '      LS_C TYPE ZMAP_COA_GRP_COL,',
  '      LT_K TYPE TABLE OF ZMAP_COA_GRP_CST,', '      LS_K TYPE ZMAP_COA_GRP_CST.'];
for (const r of S.ZMAP_COA_GRP_COL) { L.push('CLEAR LS_C.'); T.ZMAP_COA_GRP_COL.forEach((f, i) => L.push(`LS_C-${f} = '${esc(r[i])}'.`)); L.push('APPEND LS_C TO LT_C.'); }
for (const r of S.ZMAP_COA_GRP_CST) { L.push('CLEAR LS_K.'); T.ZMAP_COA_GRP_CST.forEach((f, i) => L.push(`LS_K-${f} = '${esc(r[i])}'.`)); L.push('APPEND LS_K TO LT_K.'); }
L.push('DELETE FROM ZMAP_COA_GRP_COL WHERE COA_GRP <> SPACE.', 'DELETE FROM ZMAP_COA_GRP_CST WHERE KUNNR <> SPACE.',
  'INSERT ZMAP_COA_GRP_COL FROM TABLE LT_C.', 'IF SY-SUBRC <> 0. ROLLBACK WORK. WRITE: / \'ERR COL\'. RETURN. ENDIF.',
  "WRITE: / 'COL', SY-DBCNT.",
  'INSERT ZMAP_COA_GRP_CST FROM TABLE LT_K.', 'IF SY-SUBRC <> 0. ROLLBACK WORK. WRITE: / \'ERR CST\'. RETURN. ENDIF.',
  "WRITE: / 'CST', SY-DBCNT.", 'COMMIT WORK.');
for (const l of L) if (l.length > 72) throw new Error('Line too long: ' + l);
await serverManager.setActiveServer(tgt);
const r = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: L.map(LINE => ({ LINE })) } });
console.log((r.result?.WRITES || []).map(w => w.ZEILE.replace(/ +/g, ' ')).join(' | '), r.result?.ERRORMESSAGE || '');
const D2 = await read(tgt);
for (const t in T) { const a = JSON.stringify(S[t].map(x => x.join('|')).sort()), b = JSON.stringify(D2[t].map(x => x.join('|')).sort());
  console.log(t, 'identical:', a === b, D2[t].length); }
process.exit(0);
