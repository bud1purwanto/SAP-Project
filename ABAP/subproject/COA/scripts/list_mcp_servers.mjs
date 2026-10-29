import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';

async function main() {
  await serverManager.loadConfig();
  console.log('Servers:', Object.keys(serverManager.servers));
  for (const [k, v] of Object.entries(serverManager.servers)) {
    console.log(k, v.ashost, v.sysnr, v.client);
  }
}
main().catch(console.error);
