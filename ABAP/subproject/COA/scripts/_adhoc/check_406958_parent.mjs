import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_406958_PARENT.',
  'TABLES: MSEG, MCH1, AFPO.',
  'DATA: LV_CHARG TYPE MCH1-CHARG, LV_AUFNR TYPE MSEG-AUFNR,',
  '      LT_COMP TYPE TABLE OF MSEG-CHARG WITH HEADER LINE.',
  'SELECT SINGLE AUFNR INTO LV_AUFNR FROM MSEG',
  '  WHERE BWART = \'101\' AND CHARG = \'0000406958\'.',
  'WRITE: / \'AUFNR 101 of 406958:\', LV_AUFNR.',
  'SELECT CHARG INTO TABLE LT_COMP FROM MSEG',
  '  WHERE BWART = \'261\' AND AUFNR = \'M10000000307\'.',
  'LOOP AT LT_COMP.',
  '  WRITE: / \'Comp of M10000000307:\', LT_COMP.',
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
