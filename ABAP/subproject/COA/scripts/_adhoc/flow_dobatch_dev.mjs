import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const prog = `REPORT ZFLOWDB.
DATA: LT_L TYPE TABLE OF LIPS WITH HEADER LINE, LV_J TYPE CHARG_D,
 LV_CU TYPE MCH1-CUOBJ_BM, LV_AL TYPE AUSP-ATWRT,
 LV_LOT TYPE QALS-PRUEFLOS.
SELECT * FROM LIPS INTO TABLE LT_L WHERE VBELN IN
 ('0085006276','0085006277','0085006278','0085006279') AND CHARG <> ''.
SORT LT_L BY VBELN CHARG.
LOOP AT LT_L.
 CLEAR: LV_J, LV_CU, LV_AL, LV_LOT.
 CALL FUNCTION 'ZQM_GET_BATCH_JR_BY_SR'
  EXPORTING CHARG_S = LT_L-CHARG IMPORTING CHARG_J = LV_J.
 SELECT SINGLE CUOBJ_BM INTO LV_CU FROM MCH1 WHERE CHARG = LT_L-CHARG
  AND MATNR = LT_L-MATNR.
 SELECT SINGLE A~ATWRT INTO LV_AL FROM AUSP AS A INNER JOIN CABN AS C
  ON C~ATINN = A~ATINN WHERE A~OBJEK = LV_CU AND C~ATNAM = 'ZZALIAS'.
 SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS WHERE CHARG = LT_L-CHARG.
 WRITE: / LT_L-VBELN, LT_L-POSNR, LT_L-CHARG, LT_L-MATNR(8), 'JR', LV_J,
  'AL', LV_AL(12), 'LOT', LV_LOT.
ENDLOOP.`.split('\n');
for (const l of prog) if (l.length > 72) throw new Error('long: '+l);
await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');
const res = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: { PROGRAM: prog.map(l => ({ LINE: l })) } });
console.log(JSON.stringify(res.result?.ERRORMESSAGE||''));
for (const w of res.result?.WRITES||[]) console.log(w.ZEILE);
process.exit(0);
