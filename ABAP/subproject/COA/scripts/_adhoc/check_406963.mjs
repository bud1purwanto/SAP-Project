import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_406963.',
  'TABLES: MCH1, MSEG, QALS.',
  'DATA: LV_MATNR TYPE MCH1-MATNR, LV_LICHA TYPE MCH1-LICHA,',
  '      LV_AUFNR TYPE MSEG-AUFNR.',
  'SELECT SINGLE MATNR LICHA INTO (LV_MATNR, LV_LICHA) FROM MCH1',
  '  WHERE CHARG = \'0000406963\'.',
  'WRITE: / \'406963 MATNR:\', LV_MATNR, \'LICHA:\', LV_LICHA.',
  'SELECT SINGLE AUFNR INTO LV_AUFNR FROM MSEG',
  '  WHERE BWART = \'101\' AND CHARG = \'0000406963\'.',
  'WRITE: / \'406963 AUFNR 101:\', LV_AUFNR.',
  'SELECT SINGLE AUFNR INTO LV_AUFNR FROM MSEG',
  '  WHERE BWART = \'531\' AND CHARG = \'0000406963\'.',
  'WRITE: / \'406963 AUFNR 531:\', LV_AUFNR.'
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
