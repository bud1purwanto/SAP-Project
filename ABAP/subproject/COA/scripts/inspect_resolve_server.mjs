import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';

async function main() {
  await serverManager.loadConfig();
  console.log('Resolving sandbox-new:');
  const s1 = await serverManager.setActiveServer('sandbox-new');
  console.log('s1 name:', s1.name, 'client:', s1.client);
  const s2 = await serverManager.setActiveServer('Development AIX');
  console.log('s2 name:', s2.name, 'client:', s2.client);
}
main().catch(console.error);
