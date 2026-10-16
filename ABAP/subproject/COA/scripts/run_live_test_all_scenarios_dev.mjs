import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const testCases = [
  { sc: 'QM01', doNum: '0085006234', batch: '0000405751' },
  { sc: 'QM02', doNum: '0085006235', batch: '0000405546' },
  { sc: 'QM03', doNum: '0085006240', batch: '0000405583' },
  { sc: 'QM04', doNum: '0085006241', batch: '0000405609' },
  { sc: 'QM05', doNum: '0085006242', batch: '0000405831' },
  { sc: 'QM07', doNum: '0085006243', batch: '0000405629' },
  { sc: 'QM09', doNum: '0085006244', batch: '0000405828' },
  { sc: 'QM10', doNum: '0085006245', batch: '0000405699' },
  { sc: 'Multi-Tier', doNum: '0085006278', batch: '0000406810' }
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

for (const tc of testCases) {
  const abapLines = [
    'REPORT ZTEST_SUITE_SAFE.',
    'TABLES: MSEG, MCH1, QALS, AFPO, QAMR.',
    'DATA: LV_SR TYPE MCH1-CHARG,',
    '      LOT_SR_CONV TYPE QALS-PRUEFLOS,',
    '      L_JR_CONV_BATCH TYPE MCH1-CHARG,',
    '      LOT_JR_CONV TYPE QALS-PRUEFLOS.',
    'DATA: BEGIN OF LT_SRLOTS OCCURS 0, LOT TYPE QALS-PRUEFLOS, END OF LT_SRLOTS.',
    'DATA: LT_SRX TYPE TABLE OF ZQM_GET_BATCH_SR WITH HEADER LINE.',
    'DATA: L_ACNT TYPE I, LV_TLOT TYPE QALS-PRUEFLOS.',
    'DATA: LV_DYN_SLIT_AUF TYPE MSEG-AUFNR,',
    '      LV_DYN_COAT_AUF TYPE AFPO-AUFNR,',
    '      LV_DYN_JR       TYPE MSEG-CHARG,',
    '      LV_DYN_JR_AUF   TYPE MSEG-AUFNR,',
    '      LT_DYN_JR       TYPE TABLE OF MSEG-CHARG WITH HEADER LINE,',
    '      LT_DYN_COAT     TYPE TABLE OF MSEG-AUFNR WITH HEADER LINE,',
    '      LT_DYN_SLIT     TYPE TABLE OF AFPO-MILL_OC_AUFNR_U WITH HEADER LINE,',
    '      LV_DYN_ROLL     TYPE MSEG-CHARG,',
    '      LV_DYN_LOT      TYPE QALS-PRUEFLOS,',
    '      LV_FALLBACK     TYPE C LENGTH 1.',
    'START-OF-SELECTION.',
    "LV_SR = '" + tc.batch + "'.",
    'SELECT SINGLE PRUEFLOS INTO LOT_SR_CONV FROM QALS WHERE CHARG = LV_SR AND ART = \'Z04\'.',
    'CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\' EXPORTING CHARG_S = LV_SR IMPORTING CHARG_J = L_JR_CONV_BATCH.',
    'IF L_JR_CONV_BATCH IS NOT INITIAL.',
    '  SELECT SINGLE PRUEFLOS INTO LOT_JR_CONV FROM QALS WHERE CHARG = L_JR_CONV_BATCH AND ( ART = \'Z02\' OR ART = \'Z03\' ).',
    '  CALL FUNCTION \'ZQM_GET_BATCH_SR_BY_JR\' EXPORTING CHARGJR = L_JR_CONV_BATCH TABLES T_SR = LT_SRX.',
    '  LOOP AT LT_SRX.',
    '    CLEAR LV_TLOT.',
    '    SELECT SINGLE PRUEFLOS INTO LV_TLOT FROM QALS WHERE CHARG = LT_SRX-CHARG AND ART = \'Z04\'.',
    '    IF LV_TLOT IS NOT INITIAL.',
    '      LT_SRLOTS-LOT = LV_TLOT. COLLECT LT_SRLOTS.',
    '    ENDIF.',
    '  ENDLOOP.',
    'ENDIF.',
    'DESCRIBE TABLE LT_SRLOTS LINES L_ACNT.',
    'LV_FALLBACK = \'N\'.',
    'IF L_ACNT <= 1 AND LV_SR IS NOT INITIAL.',
    '  SELECT SINGLE AUFNR INTO LV_DYN_SLIT_AUF FROM MSEG WHERE BWART = \'101\' AND CHARG = LV_SR.',
    '  IF LV_DYN_SLIT_AUF IS NOT INITIAL.',
    '    SELECT SINGLE AUFNR INTO LV_DYN_COAT_AUF FROM AFPO WHERE MILL_OC_AUFNR_U = LV_DYN_SLIT_AUF.',
    '    IF LV_DYN_COAT_AUF IS NOT INITIAL.',
    '      SELECT SINGLE CHARG INTO LV_DYN_JR FROM MSEG WHERE BWART = \'261\' AND AUFNR = LV_DYN_COAT_AUF AND CHARG <> SPACE.',
    '      IF LV_DYN_JR IS NOT INITIAL.',
    '        SELECT SINGLE AUFNR INTO LV_DYN_JR_AUF FROM MSEG WHERE BWART = \'101\' AND CHARG = LV_DYN_JR.',
    '        IF LV_DYN_JR_AUF IS NOT INITIAL.',
    '          LV_FALLBACK = \'Y\'.',
    '          REFRESH: LT_DYN_JR, LT_DYN_COAT, LT_DYN_SLIT.',
    '          SELECT CHARG INTO TABLE LT_DYN_JR FROM MSEG WHERE BWART = \'101\' AND AUFNR = LV_DYN_JR_AUF.',
    '          LOOP AT LT_DYN_JR.',
    '            SELECT AUFNR APPENDING TABLE LT_DYN_COAT FROM MSEG WHERE BWART = \'261\' AND CHARG = LT_DYN_JR.',
    '          ENDLOOP.',
    '          SORT LT_DYN_COAT. DELETE ADJACENT DUPLICATES FROM LT_DYN_COAT.',
    '          LOOP AT LT_DYN_COAT.',
    '            SELECT MILL_OC_AUFNR_U APPENDING TABLE LT_DYN_SLIT FROM AFPO WHERE AUFNR = LT_DYN_COAT.',
    '          ENDLOOP.',
    '          SORT LT_DYN_SLIT. DELETE ADJACENT DUPLICATES FROM LT_DYN_SLIT.',
    '          LOOP AT LT_DYN_SLIT.',
    '            CLEAR: LV_DYN_ROLL, LV_DYN_LOT.',
    '            SELECT SINGLE CHARG INTO LV_DYN_ROLL FROM MSEG WHERE BWART = \'101\' AND AUFNR = LT_DYN_SLIT.',
    '            IF LV_DYN_ROLL IS NOT INITIAL.',
    '              SELECT SINGLE PRUEFLOS INTO LV_DYN_LOT FROM QALS WHERE CHARG = LV_DYN_ROLL AND ART = \'Z04\'.',
    '              IF LV_DYN_LOT IS NOT INITIAL.',
    '                LT_SRLOTS-LOT = LV_DYN_LOT. COLLECT LT_SRLOTS.',
    '              ENDIF.',
    '            ENDIF.',
    '          ENDLOOP.',
    '        ENDIF.',
    '      ENDIF.',
    '    ENDIF.',
    '  ENDIF.',
    'ENDIF.',
    'DESCRIBE TABLE LT_SRLOTS LINES L_ACNT.',
    'WRITE: / \'TC:\', \'' + tc.sc + '\', \'SR_LOT:\', LOT_SR_CONV, \'JR_LOT:\', LOT_JR_CONV, \'FALLBACK:\', LV_FALLBACK, \'FINAL_SR_COUNT:\', L_ACNT.'
  ];

  const program = wrapLines(abapLines);
  const resp = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: program,
      WRITES: []
    }
  });

  if (resp.result?.ERRORMESSAGE) {
    console.error(`ERROR for ${tc.sc}:`, resp.result.ERRORMESSAGE);
  } else {
    console.log(resp.result?.WRITES?.map(w => w.ZEILE).join(' '));
  }
}
