import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const ords = process.argv.slice(2);
let prog = `REPORT ZFLOWOR.
DATA: LT_M TYPE TABLE OF MSEG WITH HEADER LINE, LV_C TYPE AUFNR.
DATA: R_A TYPE RANGE OF MSEG-AUFNR WITH HEADER LINE.
DATA: LV_T TYPE MKPF-BKTXT.`.split('\n');
for (const o of ords) prog.push(`R_A-SIGN = 'I'. R_A-OPTION = 'EQ'. R_A-LOW = '${o}'.`, 'APPEND R_A.');
prog.push(...`LOOP AT R_A.
 CLEAR LV_C. SELECT SINGLE AUFNR INTO LV_C FROM AFPO
  WHERE MILL_OC_AUFNR_U = R_A-LOW.
 WRITE: / '### ORDER', R_A-LOW, 'COLL->', LV_C.
 IF LV_C IS NOT INITIAL. R_A-LOW = LV_C. ENDIF.
 REFRESH LT_M.
 SELECT * FROM MSEG INTO TABLE LT_M WHERE AUFNR = R_A-LOW.
 SORT LT_M BY BWART CHARG.
 LOOP AT LT_M.
  CLEAR LV_T. SELECT SINGLE BKTXT INTO LV_T FROM MKPF
   WHERE MBLNR = LT_M-MBLNR AND MJAHR = LT_M-MJAHR.
  WRITE: / LT_M-BWART, LT_M-CHARG, LT_M-MATNR, LT_M-SMBLN, LV_T(25).
 ENDLOOP.
ENDLOOP.`.split('\n'));
for (const l of prog) if (l.length > 72) throw new Error('long: '+l);
await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');
const res = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: { PROGRAM: prog.map(l => ({ LINE: l })) } });
console.log(JSON.stringify(res.result?.ERRORMESSAGE||''));
for (const w of res.result?.WRITES||[]) console.log(w.ZEILE);
process.exit(0);
