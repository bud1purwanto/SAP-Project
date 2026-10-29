import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';

async function main() {
  await serverManager.loadConfig();
  console.log(serverManager.config.servers.map(s => ({ name: s.name, ashost: s.ashost, sysnr: s.sysnr, client: s.client })));
}
main().catch(console.error);
