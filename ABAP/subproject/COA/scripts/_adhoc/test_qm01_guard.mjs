import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZTEST_ORIG_QM01.',
  'TABLES: MSEG, MCH1, QALS.',
  'DATA: L_JR_CONV_BATCH LIKE MCH1-CHARG,',
  '      LOT_SR_CONV     LIKE QALS-PRUEFLOS,',
  '      LV_SEARCH_SR    LIKE MCH1-CHARG.',
  'START-OF-SELECTION.',
  'LV_SEARCH_SR = \'0000405751\'.',
  'SELECT SINGLE PRUEFLOS INTO LOT_SR_CONV FROM QALS',
  '  WHERE CHARG = LV_SEARCH_SR AND ART = \'Z04\'.',
  'CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\'',
  '  EXPORTING CHARG_S = LV_SEARCH_SR IMPORTING CHARG_J = L_JR_CONV_BATCH.',
  'WRITE: / \'LOT_SR_CONV:\', LOT_SR_CONV.',
  'WRITE: / \'L_JR_CONV_BATCH:\', L_JR_CONV_BATCH.'
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
