// Buat process order lewat COR1 (BDC) via ABAP4_CALL_TRANSACTION, urutan layar
// mengikuti Solusi_COR1_via_RFC.md (ZPP002). Format: tanggal DD.MM.YYYY, desimal koma.
// usage: node cor1_bdc.mjs <json: matnr, werks, auart, verid, bmenge, zcode, zwidth, zlength, ztreat, zline, zmonth, [zcustm], [zno], [dry]>
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const a = JSON.parse(process.argv[2]);
const d = new Date(); const pad = n => String(n).padStart(2, '0');
const dt = `${pad(d.getDate())}.${pad(d.getMonth() + 1)}.${d.getFullYear()}`;
const S = (p, n) => ({ PROGRAM: p, DYNPRO: n, DYNBEGIN: 'X' });
const F = (f, v) => ({ FNAM: f, FVAL: v });
const t = [
  S('SAPLCOKO', '5100'), F('BDC_OKCODE', '=ENTK'), F('CAUFVD-MATNR', a.matnr), F('CAUFVD-WERKS', a.werks), F('AUFPAR-PI_AUFART', a.auart),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=SLAP'), F('CAUFVD-GAMNG', '1'), F('CAUFVD-GMEIN', 'ROL'),
  F('CAUFVD-GSTRS', dt), F('CAUFVD-GSUZS', '08:00:00'), F('CAUFVD-GLTRS', dt), F('CAUFVD-GLUZS', '16:00:00'),
  S('SAPLCOSD', '5132'), F('BDC_CURSOR', 'MDFQ-VERID(01)'), F('BDC_OKCODE', '=AUSW'),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=STAK'),
  S('SAPLCOKO', '5131'), F('BDC_OKCODE', '=ENT1'), F('RC62F-VER_SEL', 'X'), F('RC62F-PROD_VERS', a.verid), F('RC62F-NEW_ROUT', 'X'), F('RC62F-NEW_BOM', 'X'),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=+COI'),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=FREI'),
  F('ZFILM-ZCODE', a.zcode), F('ZFILM-ZWIDTH', a.zwidth), F('ZFILM-ZLENGTH', a.zlength), F('ZFILM-ZTREAT', a.ztreat), F('ZFILM-ZLINE', a.zline), F('ZFILM-ZMONTH', a.zmonth),
  F('ZFILM-ZCUSTM', a.zcustm || ''), F('ZFILM-ZNOSHEET', a.zno || ''),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=KOSD'),
  S('SAPLCOKO', '5115'), F('BDC_CURSOR', 'CAUFVD-AUTERM'), F('CAUFVD-AUTERM', ''),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=KOMG'),
  S('SAPLCOKO', '0133'), F('BDC_CURSOR', 'CAUFVD-BMENGE'), F('BDC_OKCODE', '=ENT1'), F('CAUFVD-BMENGE', a.bmenge),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=BU'),
];
await serverManager.loadConfig(); await serverManager.setActiveServer('Development AIX');
const r = await call_function({ function_name: 'ABAP4_CALL_TRANSACTION', parameters: { TCODE: 'COR1', MODE_VAL: 'N', UPDATE_VAL: 'S', USING_TAB: t } });
const res = r.result ?? r;
console.log('SUBRC', res.SUBRC);
for (const m of res.MESS_TAB || []) console.log(m.MSGTYP, m.MSGID, m.MSGNR, [m.MSGV1, m.MSGV2, m.MSGV3, m.MSGV4].join('|'), m.DYNAME, m.DYNUMB);
const ok = (res.MESS_TAB || []).find(m => m.MSGID === '40' && m.MSGNR === '582' && m.MSGTYP === 'S');
console.log('ORDER', ok ? ok.MSGV1 : '(tidak ada)');
process.exit(0);
