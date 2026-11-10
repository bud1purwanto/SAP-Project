import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const prog = `REPORT ZFLOWM2.
DATA: LT_Y TYPE TABLE OF ZMAP_TYPE WITH HEADER LINE.
DATA: LT_L TYPE TABLE OF ZLOG_COA WITH HEADER LINE.
SELECT * FROM ZMAP_TYPE INTO TABLE LT_Y WHERE PROG LIKE '%COA%'.
LOOP AT LT_Y. WRITE: / 'Y', LT_Y-TCODE, LT_Y-PROG, LT_Y-TYPE,
 LT_Y-OPT, LT_Y-VALUE, LT_Y-TEXT1. ENDLOOP.
SELECT * FROM ZLOG_COA INTO TABLE LT_L UP TO 4 ROWS.
LOOP AT LT_L. WRITE: / 'L', LT_L-SEQ, LT_L-VBELN, LT_L-PRUEFLOS,
 LT_L-MIC, LT_L-KUNNR, LT_L-VALUE1 EXPONENT 0 DECIMALS 2,
 LT_L-VALUE2. ENDLOOP.`.split('\n');
for (const l of prog) if (l.length > 72) throw new Error('long: '+l);
await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');
const res = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: { PROGRAM: prog.map(l => ({ LINE: l })) } });
console.log(JSON.stringify(res.result?.ERRORMESSAGE||''));
for (const w of res.result?.WRITES||[]) console.log(w.ZEILE.replace(/\s+/g,' '));
process.exit(0);
