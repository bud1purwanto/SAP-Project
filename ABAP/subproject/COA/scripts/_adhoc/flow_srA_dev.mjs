import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const prog = `REPORT ZFLOWSA.
DATA: LT_M TYPE TABLE OF MSEG WITH HEADER LINE, LV_T TYPE MKPF-BKTXT.
DATA: LV_LIC TYPE MCH1-LICHA, LV_MAT TYPE MCH1-MATNR.
SELECT * FROM MSEG INTO TABLE LT_M WHERE CHARG IN
 ('0000406742','0000406719','0000406788','0000406820').
SORT LT_M BY CHARG MBLNR.
LOOP AT LT_M.
 SELECT SINGLE BKTXT INTO LV_T FROM MKPF WHERE MBLNR = LT_M-MBLNR
  AND MJAHR = LT_M-MJAHR.
 WRITE: / LT_M-CHARG, LT_M-MATNR(8), LT_M-BWART, LT_M-SHKZG,
  LT_M-AUFNR, LT_M-UMMAT(8), LT_M-UMCHA, LV_T(20).
ENDLOOP.
SELECT SINGLE MATNR LICHA INTO (LV_MAT, LV_LIC) FROM MCH1
 WHERE CHARG = '0000406742'.
WRITE: / 'MCH1 742', LV_MAT, LV_LIC.`.split('\n');
for (const l of prog) if (l.length > 72) throw new Error('long: '+l);
await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');
const res = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: { PROGRAM: prog.map(l => ({ LINE: l })) } });
console.log(JSON.stringify(res.result?.ERRORMESSAGE||''));
for (const w of res.result?.WRITES||[]) console.log(w.ZEILE);
process.exit(0);
