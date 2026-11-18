// Order sumber slitting (PPA2) lewat COR1 BDC, meniru ZPPC_UPLOAD_SLITROLL (ZPP003P).
// usage: node slit_order.mjs '<json: aufnr, matnr, werks, auart, verid, qty, lgort, width, length>'
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const a = JSON.parse(process.argv[2]);
const d = new Date(); const pad = n => String(n).padStart(2, '0');
const dt = `${pad(d.getDate())}.${pad(d.getMonth() + 1)}.${d.getFullYear()}`;
const S = (p, n) => ({ PROGRAM: p, DYNPRO: n, DYNBEGIN: 'X' });
const F = (f, v) => ({ FNAM: f, FVAL: v });
const t = [
  S('SAPLCOKO', '5100'), F('BDC_CURSOR', 'CAUFVD-AUFNR'), F('BDC_OKCODE', '=ENTK'),
  F('CAUFVD-MATNR', a.matnr), F('CAUFVD-WERKS', a.werks), F('AFPOD-PWERK', a.werks),
  F('AUFPAR-PI_AUFART', a.auart), F('CAUFVD-AUFNR', a.aufnr),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=KOWE'), F('BDC_CURSOR', 'CAUFVD-GSTRP'),
  F('CAUFVD-GAMNG', String(a.qty)), F('CAUFVD-GMEIN', 'ROL'), F('CAUFVD-BMENGE', String(a.qty)),
  F('CAUFVD-GLTRP', dt), F('CAUFVD-GLUZP', '16:00:00'), F('CAUFVD-GSTRP', dt), F('CAUFVD-GSUZP', '08:00:00'),
  S('SAPLCOSD', '5132'), F('BDC_CURSOR', 'MDFQ-VERID(01)'), F('BDC_OKCODE', '=AUSW'),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=SLAP'), F('BDC_CURSOR', 'AFPOD-LGORT'), F('AFPOD-UEBTK', 'X'), F('AFPOD-LGORT', a.lgort),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=STAK'), F('BDC_CURSOR', 'CAUFVD-PLNNR'),
  S('SAPLCOKO', '5131'), F('BDC_OKCODE', '=ENT1'), F('BDC_CURSOR', 'RC62F-PROD_VERS'), F('RC62F-PROD_VERS', a.verid),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=+COI'), F('BDC_CURSOR', 'CAUFVD-PLNNR'),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=BU'), F('BDC_CURSOR', 'ZFILM-ZWIDTH'),
  F('ZFILM-ZWIDTH', a.width), F('ZFILM-ZLENGTH', a.length),
];
await serverManager.loadConfig(); await serverManager.setActiveServer('Development AIX');
const r = await call_function({ function_name: 'ABAP4_CALL_TRANSACTION', parameters: { TCODE: 'COR1', MODE_VAL: 'N', UPDATE_VAL: 'S', USING_TAB: t } });
const res = r.result ?? r;
console.log('SUBRC', res.SUBRC);
for (const m of res.MESS_TAB || []) console.log(m.MSGTYP, m.MSGID, m.MSGNR, [m.MSGV1, m.MSGV2, m.MSGV3, m.MSGV4].join('|'), m.DYNAME, m.DYNUMB);
process.exit(0);
