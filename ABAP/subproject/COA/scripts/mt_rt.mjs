// Read-only helper: node scripts/mt_rt.mjs TABLE "FIELD1,FIELD2" "WHERE line1" ["WHERE line2"...] [--server X] [--rows N]
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const args = process.argv.slice(2);
let server = 'Development AIX', rows = 200;
const pos = [];
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--server') server = args[++i];
  else if (args[i] === '--rows') rows = +args[++i];
  else pos.push(args[i]);
}
const [table, fields, ...where] = pos;
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const r = await read_table({ table, fields: fields ? fields.split(',') : [], where, rowcount: rows });
const data = r.rows || r.data || r;
if (Array.isArray(data)) { for (const d of data) console.log(Object.values(d).map(v => String(v).trim()).join(' | ')); console.log('#rows', data.length); }
else console.log(JSON.stringify(r).slice(0, 3000));
