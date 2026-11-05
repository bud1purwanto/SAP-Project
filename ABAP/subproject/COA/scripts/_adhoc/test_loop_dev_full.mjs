import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZTEST_LOOP_DEV.',
  'TABLES: MSEG, MCH1, QALS.',
  'DATA: LV_TREE_CHARG TYPE MCH1-CHARG VALUE \'0000406850\'.',
  'DATA: LV_TREE_MATNR TYPE MCH1-MATNR, LV_TREE_LICHA TYPE MCH1-LICHA.',
  'DATA: LV_TREE_LOT TYPE QALS-PRUEFLOS, LV_TREE_JR TYPE MCH1-CHARG.',
  'DATA: LV_TREE_AUFNR TYPE MSEG-AUFNR, LV_TREE_COMP TYPE MSEG-CHARG.',
  'START-OF-SELECTION.',
  'DO 5 TIMES.',
  '  SELECT SINGLE MATNR LICHA INTO (LV_TREE_MATNR, LV_TREE_LICHA)',
  '    FROM MCH1 WHERE CHARG = LV_TREE_CHARG.',
  '  WRITE: / \'Loop:\', SY-INDEX, \'Batch:\', LV_TREE_CHARG, \'Mat:\', LV_TREE_MATNR.',
  '  IF LV_TREE_MATNR(2) = \'SR\'.',
  '    CLEAR LV_TREE_JR.',
  '    CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\'',
  '      EXPORTING CHARG_S = LV_TREE_CHARG',
  '      IMPORTING CHARG_J = LV_TREE_JR.',
  '    WRITE: / \'  Found JR:\', LV_TREE_JR.',
  '    IF LV_TREE_JR IS NOT INITIAL.',
  '      CLEAR LV_TREE_AUFNR.',
  '      SELECT SINGLE AUFNR INTO LV_TREE_AUFNR',
  '        FROM MSEG WHERE BWART = \'101\' AND CHARG = LV_TREE_JR.',
  '      WRITE: / \'  JR Aufnr:\', LV_TREE_AUFNR.',
  '      IF LV_TREE_AUFNR IS NOT INITIAL.',
  '        CLEAR LV_TREE_COMP.',
  '        SELECT SINGLE CHARG INTO LV_TREE_COMP',
  '          FROM MSEG WHERE BWART = \'261\' AND AUFNR = LV_TREE_AUFNR AND CHARG <> SPACE.',
  '        WRITE: / \'  JR Consumed Comp:\', LV_TREE_COMP.',
  '        IF LV_TREE_COMP IS NOT INITIAL.',
  '          LV_TREE_CHARG = LV_TREE_COMP.',
  '        ELSE.',
  '          EXIT.',
  '        ENDIF.',
  '      ELSE.',
  '        EXIT.',
  '      ENDIF.',
  '    ELSE.',
  '      EXIT.',
  '    ENDIF.',
  '  ELSE.',
  '    EXIT.',
  '  ENDIF.',
  'ENDDO.'
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
