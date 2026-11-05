import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_LOT_406686.',
  'TABLES: QALS, QAMV, QAMR.',
  'DATA: BEGIN OF LT_LOTS OCCURS 0,',
  '        PRUEFLOS TYPE QALS-PRUEFLOS,',
  '        ART TYPE QALS-ART,',
  '        MATNR TYPE QALS-MATNR,',
  '        CHARG TYPE QALS-CHARG,',
  '      END OF LT_LOTS.',
  'SELECT PRUEFLOS ART MATNR CHARG FROM QALS INTO TABLE LT_LOTS',
  '  WHERE CHARG = \'0000406686\' OR CHARG = \'0000406687\'.',
  'LOOP AT LT_LOTS.',
  '  WRITE: / LT_LOTS-PRUEFLOS, LT_LOTS-ART, LT_LOTS-MATNR, LT_LOTS-CHARG.',
  'ENDLOOP.',
  'DATA: BEGIN OF LT_MIC OCCURS 0,',
  '        PRUEFLOS TYPE QAMV-PRUEFLOS,',
  '        VERWMERKM TYPE QAMV-VERWMERKM,',
  '      END OF LT_MIC.',
  'SELECT PRUEFLOS VERWMERKM FROM QAMV INTO TABLE LT_MIC',
  '  WHERE PRUEFLOS = \'040000021012\'.',
  'LOOP AT LT_MIC.',
  '  WRITE: / \'MIC 21012:\', LT_MIC-VERWMERKM.',
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
