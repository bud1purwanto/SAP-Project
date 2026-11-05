import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_ORDER_10073355.',
  'TABLES: MSEG.',
  'DATA: BEGIN OF LT_OUT OCCURS 0,',
  '        BWART TYPE MSEG-BWART,',
  '        AUFNR TYPE MSEG-AUFNR,',
  '        MATNR TYPE MSEG-MATNR,',
  '        CHARG TYPE MSEG-CHARG,',
  '      END OF LT_OUT.',
  'SELECT BWART AUFNR MATNR CHARG FROM MSEG INTO TABLE LT_OUT',
  '  WHERE AUFNR = \'100000073355\' AND BWART = \'261\'.',
  'LOOP AT LT_OUT.',
  '  WRITE: / LT_OUT-BWART, LT_OUT-MATNR, LT_OUT-CHARG.',
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
