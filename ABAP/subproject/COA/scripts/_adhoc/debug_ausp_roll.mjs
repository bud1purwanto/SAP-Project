import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZDEBUG_AUSP_ROLL.',
  'TABLES: AUSP, MCH1.',
  'DATA: LV_CUOBJ_BM TYPE MCH1-CUOBJ_BM,',
  '      LV_OBJEK TYPE AUSP-OBJEK,',
  '      LV_ROLL_STR TYPE AUSP-ATWRT,',
  '      ATINN_ROLL TYPE AUSP-ATINN.',
  'CALL FUNCTION \'CONVERSION_EXIT_ATINN_INPUT\'',
  '  EXPORTING INPUT = \'ROLL_NO\' IMPORTING OUTPUT = ATINN_ROLL.',
  'SELECT SINGLE CUOBJ_BM INTO LV_CUOBJ_BM FROM MCH1',
  '  WHERE CHARG = \'0000406781\'.',
  'WRITE: / \'CUOBJ_BM:\', LV_CUOBJ_BM, \'ATINN:\', ATINN_ROLL.',
  'SELECT SINGLE ATWRT INTO LV_ROLL_STR FROM AUSP',
  '  WHERE OBJEK = LV_CUOBJ_BM AND ATINN = ATINN_ROLL.',
  'WRITE: / \'ATWRT (no klart):\', LV_ROLL_STR.',
  'SELECT SINGLE ATWRT INTO LV_ROLL_STR FROM AUSP',
  '  WHERE OBJEK = LV_CUOBJ_BM AND ATINN = ATINN_ROLL AND KLART = \'023\'.',
  'WRITE: / \'ATWRT (klart 023):\', LV_ROLL_STR.'
];

const resp = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: rawLines.map(LINE => ({ LINE })),
    WRITES: []
  }
});
if (resp.result?.ERRORMESSAGE) console.error(resp.result.ERRORMESSAGE);
else console.log(resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
