import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZSIM_COA_EXEC.',
  'TABLES: QALS, QAMR, QAMV, MSEG, MCH1, ZMAP_COA.',
  'DATA: BEGIN OF IT_DATA OCCURS 0,',
  '        VBELN LIKE LIKP-VBELN, POSNR LIKE LIPS-POSNR, CHARG LIKE LIPS-CHARG,',
  '        MATNR LIKE LIPS-MATNR, WERKS LIKE LIPS-WERKS, NOMSR TYPE C LENGTH 50,',
  '      END OF IT_DATA.',
  'DATA: BEGIN OF IT_MIC1 OCCURS 0,',
  '        VBELN LIKE LIKP-VBELN, POSNR LIKE LIPS-POSNR, CHARG LIKE LIPS-CHARG,',
  '        MIC LIKE ZMAP_COA-MIC, MICDES TYPE C LENGTH 40, UOM TYPE C LENGTH 10,',
  '        CMICMIT TYPE C LENGTH 20, INSLOT LIKE QALS-PRUEFLOS, MERKNR LIKE QAMV-MERKNR,',
  '      END OF IT_MIC1.',
  'DATA: BEGIN OF IT_ZMAP OCCURS 0,',
  '        MIC LIKE ZMAP_COA-MIC, MAPPING LIKE ZMAP_COA-MAPPING, MIC_DESC LIKE ZMAP_COA-MIC_DESC,',
  '        UOM LIKE ZMAP_COA-UOM,',
  '      END OF IT_ZMAP.',
  'DATA: LOT_SR_CONV TYPE QALS-PRUEFLOS, LOT_JR_CONV TYPE QALS-PRUEFLOS.',
  'DATA: LOT_SR_BASE TYPE QALS-PRUEFLOS, LOT_JR_BASE TYPE QALS-PRUEFLOS.',
  'START-OF-SELECTION.',
  '  SELECT * INTO CORRESPONDING FIELDS OF TABLE IT_ZMAP FROM ZMAP_COA WHERE MATNR = \'SRGLBI\'.',
  '  WRITE: / \'ZMAP_COA lines:\', SY-DBCNT.',
  '  \" Cek apa saja lot yang terdeteksi untuk 0000406850',
  '  SELECT SINGLE PRUEFLOS INTO LOT_SR_CONV FROM QALS WHERE CHARG = \'0000406850\' AND ART = \'Z04\'.',
  '  WRITE: / \'LOT_SR_CONV:\', LOT_SR_CONV.',
  '  LOOP AT IT_ZMAP.',
  '    WRITE: / IT_ZMAP-MIC, IT_ZMAP-MAPPING, IT_ZMAP-MIC_DESC.',
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
