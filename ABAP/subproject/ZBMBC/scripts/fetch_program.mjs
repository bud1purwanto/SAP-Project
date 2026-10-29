// Usage: node fetch_program.mjs <server> <tag> PROG1 [PROG2 ...]
import { writeFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

const [server, tag, ...progs] = process.argv.slice(2);
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
for (const p of progs) {
  const res = await call_function({ function_name: 'RPY_PROGRAM_READ', parameters: { PROGRAM_NAME: p, WITH_LOWERCASE: 'X' } });
  const rows = res.result?.SOURCE_EXTENDED || res.result?.SOURCE || [];
  const lines = rows.map(r => (typeof r === 'string' ? r : r.LINE));
  const out = `/data/Projects/SAP/ABAP/subproject/ZBMBC/outputs/${p}_${tag}.abap`;
  writeFileSync(out, lines.join('\n'), 'utf8');
  console.log(`${p} @ ${server}: ${lines.length} lines -> ${out}`);
}
