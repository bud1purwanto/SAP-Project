import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_LOT_21033_DETAIL.',
  'TABLES: QAMV, QAMR.',
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
  '  WHERE R~PRUEFLOS = \'040000021033\'.',
  '  APPEND LT_ROW.',
  'ENDSELECT.',
  'LOOP AT LT_ROW.',
  '  WRITE: / LT_ROW-MERKNR, LT_ROW-VERWMERKM, LT_ROW-MITTELWERT,',
  '           \'ANZ:\', LT_ROW-ANZWERTG.',
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
