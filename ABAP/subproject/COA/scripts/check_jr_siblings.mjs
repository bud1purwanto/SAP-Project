import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_JR_SIBLINGS.',
  'TABLES: MSEG, QALS, QAMR.',
  'DATA: LV_AUFNR TYPE MSEG-AUFNR,',
  '      LT_BCH TYPE TABLE OF MSEG-CHARG WITH HEADER LINE,',
  '      LV_L TYPE QALS-PRUEFLOS, LV_CNT TYPE I.',
  'SELECT SINGLE AUFNR INTO LV_AUFNR FROM MSEG',
  '  WHERE BWART = \'101\' AND CHARG = \'0000406781\'.',
  'WRITE: / \'AUFNR of 406781:\', LV_AUFNR.',
  'SELECT CHARG INTO TABLE LT_BCH FROM MSEG',
  '  WHERE BWART = \'101\' AND AUFNR = LV_AUFNR.',
  'SORT LT_BCH. DELETE ADJACENT DUPLICATES FROM LT_BCH.',
  'LOOP AT LT_BCH.',
  '  CLEAR: LV_L, LV_CNT.',
  '  SELECT SINGLE PRUEFLOS INTO LV_L FROM QALS',
  '    WHERE CHARG = LT_BCH AND ( ART = \'Z02\' OR ART = \'Z03\' ).',
  '  IF LV_L IS NOT INITIAL.',
  '    SELECT COUNT(*) INTO LV_CNT FROM QAMR WHERE PRUEFLOS = LV_L',
  '      AND ANZWERTG > 0.',
  '  ENDIF.',
  '  WRITE: / LT_BCH, \'LOT:\', LV_L, \'QAMR count:\', LV_CNT.',
  'ENDLOOP.'
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
