import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';

async function main() {
  await serverManager.loadConfig();
  console.log(serverManager);
}
main().catch(console.error);
