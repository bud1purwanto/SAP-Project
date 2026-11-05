import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZTEST_INSLOT_MISMATCH.',
  'TABLES: QALS, QAMV, QAMR.',
  'DATA: LV_CHARG TYPE MCH1-CHARG VALUE \'0000406850\'.',
  'DATA: LOT_SR_CONV TYPE QALS-PRUEFLOS.',
  'DATA: LV_DYN_LOT TYPE QALS-PRUEFLOS.',
  'START-OF-SELECTION.',
  '  \" 1. Apa isi LOT_SR_CONV di DO 85006278 item 0000406850?',
  '  SELECT SINGLE PRUEFLOS INTO LOT_SR_CONV FROM QALS WHERE CHARG = LV_CHARG AND ART = \'Z04\'.',
  '  WRITE: / \'LOT_SR_CONV (Outer SR Coat 2): \', LOT_SR_CONV.',
  '  \" 2. Apa isi lot intermediate SRGLAI?',
  '  SELECT SINGLE PRUEFLOS INTO LV_DYN_LOT FROM QALS WHERE CHARG = \'0000406810\' AND ART = \'Z04\'.',
  '  WRITE: / \'Intermediate SRGLAI Lot: \', LV_DYN_LOT.',
  '  \" 3. Di ZMAP_COA untuk SGLASTCD (Surface Tension Coated), mapping-nya apa?',
  '  SELECT SINGLE PRUEFLOS INTO LV_DYN_LOT FROM QAMV WHERE PRUEFLOS = \'050000014288\' AND VERWMERKM = \'SGLASTCD\'.',
  '  WRITE: / \'QAMV for SGLASTCD is in lot:\', LV_DYN_LOT.'
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
