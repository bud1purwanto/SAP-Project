// Read-only helper ke DEV (TRD 130). Usage: node dev_q.mjs <tool> '<json args>'
import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import * as A from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/abap-tools.js';
import * as Q from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/query-tools.js';
const [tool, args] = process.argv.slice(2);
await serverManager.loadConfig();
await serverManager.setActiveServer(process.env.SRV || 'dev');
const fn = A[tool] || Q[tool];
if (tool === 'call_function') { console.error('call_function diblok di helper ini'); process.exit(1); }
const r = await fn(JSON.parse(args || '{}'));
console.log(typeof r === 'string' ? r : JSON.stringify(r, null, 1));
process.exit(0);
