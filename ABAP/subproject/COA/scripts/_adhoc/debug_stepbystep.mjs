import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZDEBUG_STEPBYSTEP.',
  'TABLES: MSEG, MCH1, QALS.',
  'DATA: LV_CHARG TYPE MCH1-CHARG, LV_MATNR TYPE MCH1-MATNR,',
  '      LV_LICHA TYPE MCH1-LICHA, LV_SUBRC TYPE SY-SUBRC.',
  'LV_CHARG = \'0000405583\'.',
  'SELECT SINGLE MATNR LICHA INTO (LV_MATNR, LV_LICHA) FROM MCH1',
  '  WHERE CHARG = LV_CHARG.',
  'LV_SUBRC = SY-SUBRC.',
  'WRITE: / \'SUBRC:\', LV_SUBRC, \'MATNR:\', LV_MATNR, \'LICHA:\', LV_LICHA.'
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
