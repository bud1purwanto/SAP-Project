import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZTEST_DEBUG_COA_SIM.',
  'TABLES: MSEG, MCH1, QALS, QAMV, QAMR, ZMAP_COA, AFPO.',
  'DATA: LV_CHARG TYPE MCH1-CHARG VALUE \'0000406850\'.',
  'DATA: LOT_SR_CONV TYPE QALS-PRUEFLOS.',
  'DATA: LV_SR0 TYPE CHARG_D, LV_JRC TYPE CHARG_D.',
  'DATA: BEGIN OF LT_SRLOTS OCCURS 0, LOT TYPE QALS-PRUEFLOS, END OF LT_SRLOTS.',
  'DATA: LT_SRX TYPE TABLE OF ZQM_GET_BATCH_SR WITH HEADER LINE.',
  'DATA: L_ACNT TYPE I, LV_TLOT TYPE QALS-PRUEFLOS.',
  'DATA: BEGIN OF GT_LOT_AVG OCCURS 0,',
  '        INSLOT TYPE QALS-PRUEFLOS,',
  '        MERKNR TYPE QAMV-MERKNR,',
  '        MITTELWERT TYPE QAMR-MITTELWERT,',
  '        ANZWERTG TYPE QAMR-ANZWERTG,',
  '      END OF GT_LOT_AVG.',
  'DATA: GS_LOT_AVG LIKE LINE OF GT_LOT_AVG.',
  'START-OF-SELECTION.',
  '  \" 1. Cek apa yang menjadi LOT_SR_CONV saat runtime DO 85006278',
  '  SELECT SINGLE PRUEFLOS INTO LOT_SR_CONV FROM QALS WHERE CHARG = LV_CHARG AND ART = \'Z04\'.',
  '  WRITE: / \'Step 1: LOT_SR_CONV untuk roll pengiriman =\', LOT_SR_CONV.',
  '  \" 2. Cek apakah ada penelusuran intermediate SR di GT_STAGE_LOTS:',
  '  DATA: LV_INT_SR TYPE MCH1-CHARG VALUE \'0000406810\'.',
  '  SELECT SINGLE PRUEFLOS INTO LV_TLOT FROM QALS WHERE CHARG = LV_INT_SR AND ART = \'Z04\'.',
  '  WRITE: / \'Step 2: Lot Intermediate SRGLAI =\', LV_TLOT.',
  '  \" 3. Cek di ZMAP_COA: SGLASTCD (Surface Tension Coated) dimapping ke mana?',
  '  DATA: LV_MAPPING TYPE ZMAP_COA-MAPPING.',
  '  SELECT SINGLE MAPPING INTO LV_MAPPING FROM ZMAP_COA WHERE MATNR = \'SRGLBI\' AND MIC = \'SGLASTCD\'.',
  '  WRITE: / \'Step 3: Mapping ZMAP_COA untuk SGLASTCD =\', LV_MAPPING.'
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
