import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZDEBUG_AUSP_406838.',
  'TABLES: AUSP, CABN, MCH1.',
  'DATA: LV_CUOBJ_BM TYPE MCH1-CUOBJ_BM.',
  'DATA: BEGIN OF LT_AUSP OCCURS 0,',
  '        ATNAM TYPE CABN-ATNAM,',
  '        ATWRT TYPE AUSP-ATWRT,',
  '      END OF LT_AUSP.',
  'SELECT SINGLE CUOBJ_BM INTO LV_CUOBJ_BM FROM MCH1 WHERE CHARG = \'0000406838\'.',
  'WRITE: / \'CUOBJ_BM 406838:\', LV_CUOBJ_BM.',
  'IF LV_CUOBJ_BM IS NOT INITIAL.',
  '  SELECT C~ATNAM A~ATWRT INTO (LT_AUSP-ATNAM, LT_AUSP-ATWRT)',
  '    FROM AUSP AS A INNER JOIN CABN AS C ON C~ATINN = A~ATINN',
  '    WHERE A~OBJEK = LV_CUOBJ_BM.',
  '    APPEND LT_AUSP.',
  '  ENDSELECT.',
  '  LOOP AT LT_AUSP.',
  '    WRITE: / LT_AUSP-ATNAM, LT_AUSP-ATWRT.',
  '  ENDLOOP.',
  'ENDIF.'
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
