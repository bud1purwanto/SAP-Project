import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZDEBUG_AUSP_ALL.',
  'TABLES: AUSP, CABN.',
  'DATA: BEGIN OF LT_AUSP OCCURS 0,',
  '        ATINN TYPE AUSP-ATINN,',
  '        ATNAM TYPE CABN-ATNAM,',
  '        ATWRT TYPE AUSP-ATWRT,',
  '        ATFLV TYPE AUSP-ATFLV,',
  '      END OF LT_AUSP.',
  'SELECT A~ATINN C~ATNAM A~ATWRT A~ATFLV',
  '  INTO (LT_AUSP-ATINN, LT_AUSP-ATNAM, LT_AUSP-ATWRT, LT_AUSP-ATFLV)',
  '  FROM AUSP AS A INNER JOIN CABN AS C ON C~ATINN = A~ATINN',
  '  WHERE A~OBJEK = \'000000000000634995\'.',
  '  APPEND LT_AUSP.',
  'ENDSELECT.',
  'LOOP AT LT_AUSP.',
  '  WRITE: / LT_AUSP-ATNAM, LT_AUSP-ATWRT.',
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
