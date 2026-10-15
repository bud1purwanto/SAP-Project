import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZCHECK_BASE_AUFNR.',
  'TABLES: MSEG, AFPO, MCH1, QALS.',
  'DATA: LV_JR0 TYPE MCH1-CHARG VALUE \'0000406781\',',
  '      LV_AUFNR TYPE MSEG-AUFNR,',
  '      LV_COMBINE TYPE AFPO-AUFNR,',
  '      LV_COMP TYPE MSEG-CHARG,',
  '      LV_MATNR TYPE MCH1-MATNR,',
  '      LV_JR_BASE TYPE MCH1-CHARG,',
  '      LV_LOT TYPE QALS-PRUEFLOS.',
  '',
  'SELECT SINGLE AUFNR INTO LV_AUFNR FROM MSEG',
  '  WHERE BWART = \'101\' AND CHARG = LV_JR0.',
  'WRITE: / \'Order of 0000406781:\', LV_AUFNR.',
  'SELECT SINGLE AUFNR INTO LV_COMBINE FROM AFPO',
  '  WHERE MILL_OC_AUFNR_U = LV_AUFNR.',
  'WRITE: / \'Combined Order:\', LV_COMBINE.',
  'IF LV_COMBINE IS NOT INITIAL. LV_AUFNR = LV_COMBINE. ENDIF.',
  '',
  'SELECT SINGLE CHARG MATNR INTO (LV_COMP, LV_MATNR) FROM MSEG',
  '  WHERE BWART = \'261\' AND AUFNR = LV_AUFNR AND CHARG <> space.',
  'WRITE: / \'Component 261:\', LV_COMP, LV_MATNR.',
  '',
  'CALL FUNCTION \'ZQM_GET_BATCH_JR_BY_SR\'',
  '  EXPORTING CHARG_S = LV_COMP IMPORTING CHARG_J = LV_JR_BASE.',
  'WRITE: / \'JR of Component:\', LV_JR_BASE.',
  'SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS',
  '  WHERE CHARG = LV_JR_BASE.',
  'WRITE: / \'Lot of JR Base:\', LV_LOT.'
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
