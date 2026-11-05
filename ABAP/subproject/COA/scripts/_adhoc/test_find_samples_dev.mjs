import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const abapCode = [
  'REPORT ZTEST_FIND_SAMPLES_DEV.',
  'TABLES: LIPS.',
  'DATA: BEGIN OF LT_DO OCCURS 0,',
  '        VBELN TYPE LIPS-VBELN,',
  '        CHARG TYPE LIPS-CHARG,',
  '        MATNR TYPE LIPS-MATNR,',
  '      END OF LT_DO.',
  'SELECT VBELN CHARG MATNR FROM LIPS INTO TABLE LT_DO',
  '  WHERE VBELN = \'0085006278\' AND CHARG <> space.',
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
else console.log('Result in DEV AIX:\n' + resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
