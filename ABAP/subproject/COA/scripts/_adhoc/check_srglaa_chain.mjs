import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_SRGLAA_CHAIN.',
  'TABLES: MSEG, MCH1, QALS.',
  'DATA: LV_CHARG TYPE MCH1-CHARG VALUE \'0000406788\',',
  '      LV_LICHA TYPE MCH1-LICHA,',
  '      LV_AUFNR TYPE MSEG-AUFNR,',
  '      LV_COMP  TYPE MSEG-CHARG,',
  '      LV_MATNR TYPE MCH1-MATNR.',
  '',
  'SELECT SINGLE LICHA MATNR INTO (LV_LICHA, LV_MATNR) FROM MCH1',
  '  WHERE CHARG = LV_CHARG.',
  'WRITE: / \'0000406788 MATNR:\', LV_MATNR, \'LICHA:\', LV_LICHA.',
  'SELECT SINGLE AUFNR INTO LV_AUFNR FROM MSEG',
  '  WHERE ( BWART = \'101\' OR BWART = \'531\' ) AND CHARG = LV_CHARG.',
  'WRITE: / \'Order for 0000406788:\', LV_AUFNR.',
  'IF LV_AUFNR IS NOT INITIAL.',
  '  SELECT SINGLE CHARG MATNR INTO (LV_COMP, LV_MATNR) FROM MSEG',
  '    WHERE BWART = \'261\' AND AUFNR = LV_AUFNR AND CHARG <> space.',
  '  WRITE: / \'Component 261:\', LV_COMP, LV_MATNR.',
  'ENDIF.'
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
