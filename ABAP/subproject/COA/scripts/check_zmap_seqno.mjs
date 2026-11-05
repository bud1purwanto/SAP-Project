import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
await serverManager.loadConfig();
await serverManager.setActiveServer('dev');
const f = await call_function({ function_name: 'DDIF_FIELDINFO_GET', parameters: { TABNAME: 'ZMAP_COA', FIELDNAME: 'SEQ_NO' } });
const d = f.result?.DFIES_TAB?.[0] || {};
console.log('SEQ_NO', d.DATATYPE, d.INTTYPE, d.LENG, d.ROLLNAME);
const r = await call_function({ function_name: 'RFC_READ_TABLE', parameters: { QUERY_TABLE: 'ZMAP_COA', DELIMITER: '|', ROWCOUNT: 40,
  OPTIONS: [{ TEXT: "SEQ_NO NE ' ' AND SEQ_NO NE '000' AND DELETION NE 'X'" }],
  FIELDS: [{FIELDNAME:'MATNR'},{FIELDNAME:'KUNNR'},{FIELDNAME:'MIC'},{FIELDNAME:'SEQ_NO'}] } });
for (const x of r.result?.DATA || []) console.log(x.WA);
process.exit(0);
