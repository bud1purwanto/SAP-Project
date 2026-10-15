import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('sandbox-new');

// Cek apakah ada data di sandbox-new atau Development AIX
// Kita tes koneksi dan cari DO / Batch
const abapCode = [
  'REPORT ZTEST_FIND_SAMPLES.',
  'TABLES: LIKP, LIPS, MSEG, MCH1, QALS.',
  'DATA: BEGIN OF LT_DO OCCURS 0,',
  '        VBELN TYPE LIPS-VBELN,',
  '        CHARG TYPE LIPS-CHARG,',
  '        MATNR TYPE LIPS-MATNR,',
  '      END OF LT_DO.',
  'SELECT VBELN CHARG MATNR FROM LIPS INTO TABLE LT_DO UP TO 5 ROWS',
  '  WHERE CHARG <> space AND MATNR LIKE \'SR%\'.',
  'LOOP AT LT_DO.',
  '  WRITE: / LT_DO-VBELN, LT_DO-CHARG, LT_DO-MATNR.',
  'ENDLOOP.'
];

const resp = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: abapCode.map(LINE => ({ LINE })),
    WRITES: []
  }
});
if (resp.result?.ERRORMESSAGE) console.error(resp.result.ERRORMESSAGE);
else console.log('Result in sandbox-new:\n' + resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
