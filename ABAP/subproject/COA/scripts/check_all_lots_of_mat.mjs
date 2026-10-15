import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_ALL_LOTS_OF_MAT.',
  'TABLES: QALS, QAMR.',
  'DATA: BEGIN OF LT_LOT OCCURS 0,',
  '        PRUEFLOS TYPE QALS-PRUEFLOS,',
  '        CHARG TYPE QALS-CHARG,',
  '        MATNR TYPE QALS-MATNR,',
  '        ART TYPE QALS-ART,',
  '      END OF LT_LOT.',
  'SELECT PRUEFLOS CHARG MATNR ART FROM QALS INTO TABLE LT_LOT',
  '  WHERE MATNR = \'JRAH8I\'.',
  'LOOP AT LT_LOT.',
  '  DATA: LV_CNT TYPE I.',
  '  SELECT COUNT(*) INTO LV_CNT FROM QAMR WHERE PRUEFLOS = LT_LOT-PRUEFLOS',
  '    AND ANZWERTG > 0.',
  '  WRITE: / LT_LOT-PRUEFLOS, LT_LOT-CHARG, LT_LOT-ART.',
  '  WRITE: / \'   QAMR count:\', LV_CNT.',
  'ENDLOOP.'
];

for (const l of rawLines) {
  if (l.length > 72) throw new Error('Line > 72: ' + l);
}

const resp = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: rawLines.map(LINE => ({ LINE })),
    WRITES: []
  }
});
if (resp.result?.ERRORMESSAGE) console.error(resp.result.ERRORMESSAGE);
else console.log(resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
