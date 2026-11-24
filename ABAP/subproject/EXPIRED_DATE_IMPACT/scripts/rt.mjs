import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/query-tools.js';
const [srv, json] = process.argv.slice(2);
await serverManager.loadConfig(); await serverManager.setActiveServer(srv);
const r = await read_table(JSON.parse(json));
console.log(JSON.stringify(r)); process.exit(0);
