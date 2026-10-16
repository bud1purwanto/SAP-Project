import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZTEST_TRACE_SAFE.',
  'TABLES: MSEG, AFPO, QALS, QAMR.',
  'DATA: LV_CHARG TYPE MCH1-CHARG VALUE \'0000406810\'.',
  'DATA: LV_AUFNR TYPE MSEG-AUFNR.',
  'DATA: LV_PARENT_ORD TYPE AFPO-AUFNR.',
  'DATA: LT_ORD TYPE TABLE OF AFPO-AUFNR WITH HEADER LINE.',
  'DATA: LT_SLIT_ORD TYPE TABLE OF AFPO-AUFNR WITH HEADER LINE.',
  'DATA: LV_CH TYPE MSEG-CHARG, LV_LOT TYPE QALS-PRUEFLOS.',
  'DATA: LV_MW TYPE QAMR-MITTELWERT, LV_CNT TYPE I, LV_SUM TYPE F.',
  'DATA: LV_MZ TYPE QAMR-MITTELWERT, LV_SUM_MZ TYPE F.',
  'START-OF-SELECTION.',
  '  SELECT SINGLE AUFNR INTO LV_AUFNR FROM MSEG',
  '    WHERE BWART = \'101\' AND CHARG = LV_CHARG.',
  '  WRITE: / \'SR Slitting Order:\', LV_AUFNR.',
  '  IF LV_AUFNR IS NOT INITIAL.',
  '    SELECT SINGLE AUFNR INTO LV_PARENT_ORD FROM AFPO',
  '      WHERE MILL_OC_AUFNR_U = LV_AUFNR.',
  '    WRITE: / \'Parent Coating Order:\', LV_PARENT_ORD.',
  '    IF LV_PARENT_ORD IS NOT INITIAL.',
  '      SELECT MILL_OC_AUFNR_U INTO TABLE LT_SLIT_ORD FROM AFPO',
  '        WHERE AUFNR >= \'100000073390\' AND AUFNR <= \'100000073399\'.',
  '      WRITE: / \'Found sibling orders count:\', SY-DBCNT.',
  '      LOOP AT LT_SLIT_ORD.',
  '        CLEAR: LV_CH, LV_LOT, LV_MW, LV_MZ.',
  '        SELECT SINGLE CHARG INTO LV_CH FROM MSEG',
  '          WHERE BWART = \'101\' AND AUFNR = LT_SLIT_ORD.',
  '        IF LV_CH IS NOT INITIAL.',
  '          SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS',
  '            WHERE CHARG = LV_CH AND ART = \'Z04\'.',
  '          IF LV_LOT IS NOT INITIAL.',
  '            SELECT SINGLE MITTELWERT INTO LV_MW FROM QAMR',
  '              WHERE PRUEFLOS = LV_LOT AND MERKNR = \'0010\'.',
  '            SELECT SINGLE MITTELWERT INTO LV_MZ FROM QAMR',
  '              WHERE PRUEFLOS = LV_LOT AND MERKNR = \'0020\'.',
  '            WRITE: / \'Roll:\', LV_CH, \'Lot:\', LV_LOT, \'Coated:\', LV_MW, \'Metz:\', LV_MZ.',
  '            LV_SUM = LV_SUM + LV_MW.',
  '            LV_SUM_MZ = LV_SUM_MZ + LV_MZ.',
  '            LV_CNT = LV_CNT + 1.',
  '          ENDIF.',
  '        ENDIF.',
  '      ENDLOOP.',
  '      IF LV_CNT > 0.',
  '        DATA: LV_AVG TYPE F, LV_AVG_MZ TYPE F.',
  '        LV_AVG = LV_SUM / LV_CNT.',
  '        LV_AVG_MZ = LV_SUM_MZ / LV_CNT.',
  '        WRITE: / \'Total Count:\', LV_CNT.',
  '        WRITE: / \'Average Coated ST:\', LV_AVG.',
  '        WRITE: / \'Average Metz ST:\', LV_AVG_MZ.',
  '      ENDIF.',
  '    ENDIF.',
  '  ENDIF.'
];

const formatted = [];
for (const l of rawLines) {
  if (l.length > 72) {
    const idx = l.lastIndexOf(' ', 70);
    formatted.push(l.slice(0, idx));
    formatted.push('  ' + l.slice(idx + 1));
  } else {
    formatted.push(l);
  }
}

const resp = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: formatted.map(LINE => ({ LINE })),
    WRITES: []
  }
});

if (resp.result?.ERRORMESSAGE) console.error(resp.result.ERRORMESSAGE);
else console.log(resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
