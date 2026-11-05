import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZTEST_M261_CHECK.',
  'TABLES: MSEG, MKPF.',
  'DATA: LT_MSEG TYPE TABLE OF MSEG WITH HEADER LINE,',
  '      LT_MKPF TYPE TABLE OF MKPF WITH HEADER LINE.',
  'DATA: GV_TRACE_BKTXT LIKE MKPF-BKTXT.',
  'START-OF-SELECTION.',
  '  SELECT SINGLE BKTXT INTO GV_TRACE_BKTXT FROM MKPF WHERE MBLNR = \'5000077472\'.',
  '  WRITE: / \'BKTXT for 5000077472:\', GV_TRACE_BKTXT.',
  '  SELECT * INTO TABLE LT_MSEG FROM MSEG WHERE AUFNR = \'100000073400\' AND BWART IN (\'261\', \'262\').',
  '  WRITE: / \'Lines in 100000073400:\', SY-DBCNT.',
  '  LOOP AT LT_MSEG.',
  '    SELECT SINGLE BKTXT INTO LT_MKPF-BKTXT FROM MKPF WHERE MBLNR = LT_MSEG-MBLNR AND MJAHR = LT_MSEG-MJAHR.',
  '    WRITE: / LT_MSEG-MBLNR, LT_MSEG-BWART, LT_MSEG-MATNR, LT_MSEG-CHARG, \'BKTXT:\', LT_MKPF-BKTXT.',
  '  ENDLOOP.'
];

function wrapLines(lines) {
  const out = [];
  for (const raw of lines) {
    if (raw.length <= 70) {
      out.push(raw);
    } else {
      let cur = raw;
      while (cur.length > 70) {
        let idx = cur.lastIndexOf(' ', 70);
        if (idx === -1) idx = 70;
        out.push(cur.slice(0, idx));
        cur = '  ' + cur.slice(idx).trimStart();
      }
      if (cur.length > 0) out.push(cur);
    }
  }
  return out.map(LINE => ({ LINE }));
}

const resp = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: wrapLines(rawLines),
    WRITES: []
  }
});

console.log(resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
