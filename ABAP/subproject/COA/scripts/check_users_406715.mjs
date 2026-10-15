import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_USERS_406715.',
  'TABLES: MSEG.',
  'DATA: BEGIN OF LT_USERS OCCURS 0,',
  '        BWART TYPE MSEG-BWART,',
  '        AUFNR TYPE MSEG-AUFNR,',
  '        MATNR TYPE MSEG-MATNR,',
  '        CHARG TYPE MSEG-CHARG,',
  '      END OF LT_USERS.',
  'SELECT BWART AUFNR MATNR CHARG FROM MSEG INTO TABLE LT_USERS',
  '  WHERE CHARG = \'0000406715\'.',
  'LOOP AT LT_USERS.',
  '  WRITE: / LT_USERS-BWART, LT_USERS-AUFNR, LT_USERS-MATNR.',
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
