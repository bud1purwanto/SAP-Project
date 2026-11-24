import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/query-tools.js';
import fs from 'fs';
await serverManager.loadConfig(); await serverManager.setActiveServer('dev');
const [table, fields, where, out] = process.argv.slice(2);
const r = await read_table({table, fields: fields.split(','), where: where? [where]:[], rowcount:0, batch_size:5000, timeout_ms:300000});
fs.writeFileSync(out, JSON.stringify(r.rows||r)); console.log(table, (r.rows||[]).length); process.exit(0);
