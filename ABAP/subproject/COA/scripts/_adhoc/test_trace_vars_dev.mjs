import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZTEST_TRACE_VARS.',
  'DATA: L_AUFNR LIKE AFPO-AUFNR,',
  '      L_MBLNR LIKE MSEG-MBLNR,',
  '      L_MATNR LIKE MSEG-MATNR,',
  '      L_CHARG LIKE MSEG-CHARG,',
  '      L_LICHA LIKE MCH1-LICHA,',
  '      L_LEN TYPE I,',
  '      L_TEMP TYPE I.',
  'DATA: L_JR_CONV_BATCH LIKE MCH1-CHARG,',
  '      L_SR_BASE_BATCH LIKE MCH1-CHARG,',
  '      L_JR_BASE_BATCH LIKE MCH1-CHARG,',
  '      LOT_SR_CONV LIKE QALS-PRUEFLOS,',
  '      LOT_JR_CONV LIKE QALS-PRUEFLOS,',
  '      LOT_SR_BASE LIKE QALS-PRUEFLOS,',
  '      LOT_JR_BASE LIKE QALS-PRUEFLOS.',
  'START-OF-SELECTION.',
  '  \" 1. SR Conv Lot',
  '  SELECT SINGLE PRUEFLOS INTO LOT_SR_CONV FROM QALS WHERE CHARG = \'0000406850\' AND ART = \'Z04\'.',
  '  CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\'',
  '    EXPORTING CHARG_S = \'0000406850\'',
  '    IMPORTING CHARG_J = L_JR_CONV_BATCH.',
  '  WRITE: / \'LOT_SR_CONV:\', LOT_SR_CONV, \'L_JR_CONV_BATCH:\', L_JR_CONV_BATCH.',
  '  IF L_JR_CONV_BATCH IS NOT INITIAL.',
  '    SELECT SINGLE PRUEFLOS INTO LOT_JR_CONV FROM QALS WHERE CHARG = L_JR_CONV_BATCH AND ( ART = \'Z02\' OR ART = \'Z03\' ).',
  '    WRITE: / \'LOT_JR_CONV:\', LOT_JR_CONV.',
  '    \" Cek Aufnr JR',
  '    SELECT SINGLE AUFNR INTO L_AUFNR FROM MSEG WHERE BWART = \'101\' AND CHARG = L_JR_CONV_BATCH.',
  '    WRITE: / \'JR Aufnr:\', L_AUFNR.',
  '    SELECT SINGLE CHARG INTO L_CHARG FROM MSEG WHERE AUFNR = L_AUFNR AND BWART = \'261\' AND CHARG <> SPACE.',
  '    WRITE: / \'JR Component (261):\', L_CHARG.',
  '    IF L_CHARG IS NOT INITIAL.',
  '      SELECT SINGLE MATNR INTO L_MATNR FROM MCH1 WHERE CHARG = L_CHARG.',
  '      L_LEN = STRLEN( L_MATNR ). L_TEMP = L_LEN - 1.',
  '      WRITE: / \'Mat:\', L_MATNR, \'Suffix:\', L_MATNR+L_TEMP(1).',
  '      IF L_MATNR(2) = \'SR\' AND ( L_MATNR+L_TEMP(1) = \'A\' OR L_MATNR+L_TEMP(1) = \'O\' ).',
  '        SELECT SINGLE LICHA INTO L_LICHA FROM MCH1 WHERE MATNR = L_MATNR AND CHARG = L_CHARG.',
  '        WRITE: / \'LICHA:\', L_LICHA.',
  '        IF L_LICHA IS NOT INITIAL.',
  '          L_SR_BASE_BATCH = L_LICHA.',
  '        ELSE.',
  '          L_SR_BASE_BATCH = L_CHARG.',
  '        ENDIF.',
  '      ELSE.',
  '        L_SR_BASE_BATCH = L_CHARG.',
  '      ENDIF.',
  '      WRITE: / \'L_SR_BASE_BATCH:\', L_SR_BASE_BATCH.',
  '      IF L_SR_BASE_BATCH IS NOT INITIAL.',
  '        SELECT SINGLE PRUEFLOS INTO LOT_SR_BASE FROM QALS WHERE CHARG = L_SR_BASE_BATCH AND ART = \'Z04\'.',
  '        WRITE: / \'LOT_SR_BASE:\', LOT_SR_BASE.',
  '        CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\'',
  '          EXPORTING CHARG_S = L_SR_BASE_BATCH',
  '          IMPORTING CHARG_J = L_JR_BASE_BATCH.',
  '        WRITE: / \'L_JR_BASE_BATCH:\', L_JR_BASE_BATCH.',
  '        IF L_JR_BASE_BATCH IS NOT INITIAL.',
  '          SELECT SINGLE PRUEFLOS INTO LOT_JR_BASE FROM QALS WHERE CHARG = L_JR_BASE_BATCH AND ( ART = \'Z01\' OR ART = \'Z02\' OR ART = \'Z03\' ).',
  '          WRITE: / \'LOT_JR_BASE:\', LOT_JR_BASE.',
  '        ENDIF.',
  '      ENDIF.',
  '    ENDIF.',
  '  ENDIF.'
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
