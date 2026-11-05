// Usage: node sap_tool.mjs <server> <tool> '<json args>'
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';

const [server, tool, raw] = process.argv.slice(2);
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const res = await HANDLERS[tool](JSON.parse(raw || '{}'));
process.stdout.write(typeof res === 'string' ? res : JSON.stringify(res, null, 2));
