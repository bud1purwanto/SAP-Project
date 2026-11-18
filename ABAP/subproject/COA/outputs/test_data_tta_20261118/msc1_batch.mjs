// Buat batch SR converting lewat MSC1 BDC, meniru ZPPC_UPLOAD_SLITROLL (ZPP003P).
// usage: node msc1_batch.mjs '<json: matnr, werks, licha, code, treat, core, width, grade, dms, dss, packing, label, pcode, exlen, prodline, posms, posss, length, alias>'
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const a = JSON.parse(process.argv[2]);
const S = (p, n) => ({ PROGRAM: p, DYNPRO: n, DYNBEGIN: 'X' });
const F = (f, v) => ({ FNAM: f, FVAL: v ?? '' });
const t = [
  S('SAPMM03S', '0105'), F('BDC_OKCODE', '/00'), F('BDC_CURSOR', 'RM03S-CHARG'),
  F('RM03S-MATNR', a.matnr), F('RM03S-CHARG', ''), F('RM03S-WERKS', a.werks), F('RM03S-LGORT', ''),
  S('SAPMM03S', '0200'), F('BDC_CURSOR', 'MCHA-LICHA'), F('BDC_OKCODE', '=CLAS'),
  F('RM03S-FZUST', 'X'), F('MCHA-LICHA', a.licha), F('RM03S-CHKLJ', 'X'), F('RM03S-SPRAS', 'EN'),
  S('SAPLCTMS', '0109'), F('BDC_CURSOR', 'RCTMS-MWERT(10)'), F('BDC_OKCODE', '/00'),
  F('RCTMS-MNAME(01)', 'ZZCODE'), F('RCTMS-MNAME(02)', 'ZZTREATMENT'), F('RCTMS-MNAME(03)', 'ZZCORE'),
  F('RCTMS-MNAME(04)', 'ZZWIDTH'), F('RCTMS-MNAME(05)', 'ZZGRADE'), F('RCTMS-MNAME(06)', 'ZZDERIVATIVEMS'),
  F('RCTMS-MNAME(07)', 'ZZDERIVATIVESS'), F('RCTMS-MNAME(08)', 'ZZPACKING'), F('RCTMS-MNAME(09)', 'ZZLABEL'),
  F('RCTMS-MNAME(10)', 'ZZPACKINGCODE'),
  F('RCTMS-MWERT(01)', a.code), F('RCTMS-MWERT(02)', a.treat), F('RCTMS-MWERT(03)', a.core),
  F('RCTMS-MWERT(04)', a.width), F('RCTMS-MWERT(05)', a.grade), F('RCTMS-MWERT(06)', a.dms),
  F('RCTMS-MWERT(07)', a.dss), F('RCTMS-MWERT(08)', a.packing), F('RCTMS-MWERT(09)', a.label),
  F('RCTMS-MWERT(10)', a.pcode),
  S('SAPLCTMS', '0109'), F('BDC_CURSOR', 'RCTMS-MWERT(06)'), F('BDC_OKCODE', '=BACK'),
  F('RCTMS-MNAME(01)', 'ZZEXLENGTH'), F('RCTMS-MNAME(02)', 'ZZPRODLINE'), F('RCTMS-MNAME(03)', 'ZZNOLOTTOYOBO'),
  F('RCTMS-MNAME(04)', 'ZZNOROLLTOYOBO'), F('RCTMS-MNAME(05)', 'ZZPOSITIONMS'), F('RCTMS-MNAME(06)', 'ZZPOSITIONSS'),
  F('RCTMS-MNAME(07)', 'ZZLENGTH'),
  F('RCTMS-MWERT(01)', a.exlen), F('RCTMS-MWERT(02)', a.prodline), F('RCTMS-MWERT(03)', ''),
  F('RCTMS-MWERT(04)', ''), F('RCTMS-MWERT(05)', a.posms), F('RCTMS-MWERT(06)', a.posss),
  F('RCTMS-MWERT(07)', a.length),
  F('RCTMS-MNAME(08)', 'ZZALIAS'), F('RCTMS-MWERT(08)', a.alias || ''),
  F('RCTMS-MNAME(09)', 'ZZTYBCOMBINATIONNO'), F('RCTMS-MWERT(09)', ''),
  S('SAPMM03S', '0200'), F('BDC_CURSOR', 'RM03S-CHARG'), F('BDC_OKCODE', '=BU'),
  F('RM03S-FZUST', 'X'), F('RM03S-CHKLJ', 'X'),
];
await serverManager.loadConfig(); await serverManager.setActiveServer('Development AIX');
const r = await call_function({ function_name: 'ABAP4_CALL_TRANSACTION', parameters: { TCODE: 'MSC1', MODE_VAL: 'N', UPDATE_VAL: 'S', USING_TAB: t, SPAGPA_TAB: [] } });
const res = r.result ?? r;
console.log('SUBRC', res.SUBRC);
for (const m of res.MESS_TAB || []) console.log(m.MSGTYP, m.MSGID, m.MSGNR, [m.MSGV1, m.MSGV2, m.MSGV3, m.MSGV4].join('|'), m.DYNAME, m.DYNUMB);
process.exit(0);
