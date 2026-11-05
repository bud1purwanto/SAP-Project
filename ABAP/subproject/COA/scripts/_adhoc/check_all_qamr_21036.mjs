import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_ALL_QAMR_21036.',
  'TABLES: QAMR, QAMV.',
  'DATA: BEGIN OF LT_ROW OCCURS 0,',
  '        MERKNR TYPE QAMR-MERKNR,',
  '        VERWMERKM TYPE QAMV-VERWMERKM,',
  '        MITTELWERT TYPE QAMR-MITTELWERT,',
  '        ANZWERTG TYPE QAMR-ANZWERTG,',
  '      END OF LT_ROW.',
  'SELECT R~MERKNR V~VERWMERKM R~MITTELWERT R~ANZWERTG',
  '  INTO (LT_ROW-MERKNR, LT_ROW-VERWMERKM, LT_ROW-MITTELWERT,',
  '        LT_ROW-ANZWERTG)',
  '  FROM QAMR AS R INNER JOIN QAMV AS V',
  '    ON V~PRUEFLOS = R~PRUEFLOS AND V~MERKNR = R~MERKNR',
  '  WHERE R~PRUEFLOS = \'040000021036\'.',
  '  APPEND LT_ROW.',
  'ENDSELECT.',
  'LOOP AT LT_ROW.',
  '  WRITE: / LT_ROW-MERKNR, LT_ROW-VERWMERKM, LT_ROW-MITTELWERT.',
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
