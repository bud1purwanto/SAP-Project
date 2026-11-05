// Push source ke sandbox-new via Z_RFC_PROGRAM_UPDATE. Usage: node push_program.mjs PROG [PROG ...]
import { readFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('sandbox-new');
for (const p of process.argv.slice(2)) {
  const lines = readFileSync(`/data/Projects/SAP/ABAP/subproject/ZMMI_WMS/src/${p}.abap`, 'utf8').split('\n');
  const res = await HANDLERS.call_function({ function_name: 'Z_RFC_PROGRAM_UPDATE', parameters: {
    IV_PROGRAM_NAME: p, IV_PACKAGE: '$TMP', IV_CORRNUMBER: ' ',
    IT_SOURCE: lines.map(LINE => ({ LINE })) } });
  const r = res.result || res;
  console.log(p, lines.length, 'lines ->', r.EV_SUCCESS, r.EV_MESSAGE || JSON.stringify(r).slice(0, 300));
}
