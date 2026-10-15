import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_P29_3305.',
  'TABLES: MSEG, MCH1, AFPO.',
  'DATA: LV_AUFNR TYPE MSEG-AUFNR,',
  '      LT_COMP TYPE TABLE OF MSEG-CHARG WITH HEADER LINE,',
  '      LV_MATNR TYPE MCH1-MATNR.',
  'SELECT SINGLE MATNR INTO LV_MATNR FROM MCH1 WHERE CHARG = \'0000406958\'.',
  'WRITE: / \'406958 MATNR:\', LV_MATNR.',
  'SELECT CHARG INTO TABLE LT_COMP FROM MSEG',
  '  WHERE BWART = \'261\' AND AUFNR = \'P29000003305\'.',
  'LOOP AT LT_COMP.',
  '  WRITE: / \'Comp of P29000003305:\', LT_COMP.',
  'ENDLOOP.',
  'SELECT MILL_OC_AUFNR_U INTO LV_AUFNR FROM AFPO',
  '  WHERE AUFNR = \'P29000003305\'.',
  'WRITE: / \'Combined aufnr:\', LV_AUFNR.'
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
