import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const abapCode = [
  'REPORT ZCHECK_ZMAP_SRGLBI.',
  'TABLES: ZMAP_COA.',
  'DATA: BEGIN OF LT_MAP OCCURS 0,',
  '        MIC TYPE ZMAP_COA-MIC,',
  '        MAPPING TYPE ZMAP_COA-MAPPING,',
  '        MIC_DESC TYPE ZMAP_COA-MIC_DESC,',
  '      END OF LT_MAP.',
  'SELECT MIC MAPPING MIC_DESC FROM ZMAP_COA INTO TABLE LT_MAP',
  '  WHERE MATNR = \'SRGLBI\'.',
  'LOOP AT LT_MAP.',
  '  WRITE: / LT_MAP-MIC, LT_MAP-MAPPING, LT_MAP-MIC_DESC.',
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
else console.log('ZMAP_COA for SRGLBI:\n' + resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
