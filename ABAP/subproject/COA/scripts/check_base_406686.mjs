import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_BASE_406686.',
  'TABLES: MSEG, MCH1, QALS.',
  'DATA: LV_CHARG TYPE MCH1-CHARG VALUE \'0000406686\',',
  '      LV_LOT TYPE QALS-PRUEFLOS.',
  'SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS WHERE CHARG = LV_CHARG.',
  'WRITE: / \'Lot for 0000406686:\', LV_LOT.',
  'DATA: BEGIN OF LT_USERS OCCURS 0,',
  '        MBLNR TYPE MSEG-MBLNR,',
  '        AUFNR TYPE MSEG-AUFNR,',
  '        MATNR TYPE MSEG-MATNR,',
  '        CHARG TYPE MSEG-CHARG,',
  '      END OF LT_USERS.',
  'SELECT MBLNR AUFNR MATNR CHARG FROM MSEG INTO TABLE LT_USERS',
  '  WHERE BWART = \'261\' AND CHARG = \'0000406715\'.',
  'LOOP AT LT_USERS.',
  '  WRITE: / \'Used by:\', LT_USERS-AUFNR, LT_USERS-MATNR, LT_USERS-CHARG.',
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
