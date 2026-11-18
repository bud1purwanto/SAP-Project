// Mill order combination (tcode MILL_OC) lewat ABAP4_CALL_TRANSACTION, meniru ZPPC_UPLOAD_SLITROLL.
// usage: node mill_oc.mjs '<json: werks, auart, aufnr1, aufnr2, ablad>'
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const a = JSON.parse(process.argv[2]);
const S = (p, n) => ({ PROGRAM: p, DYNPRO: n, DYNBEGIN: 'X' });
const F = (f, v) => ({ FNAM: f, FVAL: v });
const t = [
  S('SAPLMILL_OC', '0010'), F('BDC_CURSOR', 'MILL_OC_PRESELECT-WERKS'), F('BDC_OKCODE', '=AUSF'),
  F('MILL_OC_PRESELECT-WERKS', a.werks), F('MILL_OC_PRESELECT-SELID', a.auart),
  F('MILL_OC_PRESELECT-AUFNR1', a.aufnr1), F('MILL_OC_PRESELECT-AUFNR2', a.aufnr2),
  S('SAPLMILL_OC', '0100'), F('BDC_CURSOR', 'MILL_OC_ORDER_COMB_STRUC-DELBZ(01)'), F('BDC_OKCODE', '=SELE'),
  S('SAPLMILL_OC', '0100'), F('BDC_CURSOR', 'MILL_OC_ORDER_COMB_STRUC-VORLAGEAUFTR(01)'), F('BDC_OKCODE', '=AUSF'),
  F('MILL_OC_ORDER_COMB_STRUC-VORLAGEAUFTR(01)', 'X'),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=KOWE'), F('BDC_CURSOR', 'CAUFVD-GAMNG'),
  S('SAPLCOKO', '5115'), F('BDC_OKCODE', '=BACK'), F('BDC_CURSOR', 'AFPOD-ABLAD'), F('AFPOD-ABLAD', a.ablad),
  S('SAPLSPO1', '0300'), F('BDC_OKCODE', '=YES'),
];
await serverManager.loadConfig(); await serverManager.setActiveServer('Development AIX');
const r = await call_function({ function_name: 'ABAP4_CALL_TRANSACTION', parameters: { TCODE: 'MILL_OC', MODE_VAL: 'N', UPDATE_VAL: 'S', USING_TAB: t } });
const res = r.result ?? r;
console.log('SUBRC', res.SUBRC);
for (const m of res.MESS_TAB || []) console.log(m.MSGTYP, m.MSGID, m.MSGNR, [m.MSGV1, m.MSGV2, m.MSGV3, m.MSGV4].join('|'), m.DYNAME, m.DYNUMB);
process.exit(0);
