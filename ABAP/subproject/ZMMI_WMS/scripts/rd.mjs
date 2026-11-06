// Read-only helper: node rd.mjs <server> fields TAB | table TAB "WHERE" FIELDS,.. [rows]
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const [server, mode, tab, where, flds, rows] = process.argv.slice(2);
await serverManager.loadConfig(); await serverManager.setActiveServer(server);
if (mode === 'fields') {
  const r = await call_function({ function_name: 'DDIF_FIELDINFO_GET', parameters: { TABNAME: tab, LANGU: 'E' } });
  for (const f of r.result?.DFIES_TAB || []) console.log(f.FIELDNAME, f.DATATYPE, f.LENG, f.FIELDTEXT);
} else {
  const opts = []; for (let i = 0; i < (where||'').length; i += 72) opts.push({ TEXT: where.slice(i, i + 72) });
  const r = await call_function({ function_name: 'RFC_READ_TABLE', parameters: { QUERY_TABLE: tab, DELIMITER: '|', ROWCOUNT: Number(rows || 50), OPTIONS: opts, FIELDS: (flds||'').split(',').filter(Boolean).map(F => ({ FIELDNAME: F })) } });
  if (r.error) console.log(r.error);
  console.log((r.result?.FIELDS||[]).map(f=>f.FIELDNAME).join('|'));
  for (const d of r.result?.DATA || []) console.log(d.WA);
}
