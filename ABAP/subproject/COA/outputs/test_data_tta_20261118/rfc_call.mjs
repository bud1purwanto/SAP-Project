// Panggil FM langsung lewat RFC (tanpa RFC_ABAP_INSTALL_AND_RUN).
// usage: node rfc_call.mjs <FM> '<json parameters>' [server]
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const [fm, pj, server = 'Development AIX'] = process.argv.slice(2);
await serverManager.loadConfig(); await serverManager.setActiveServer(server);
const r = await call_function({ function_name: fm, parameters: JSON.parse(pj) });
console.log(JSON.stringify(r.result ?? r, null, 1));
process.exit(0);
