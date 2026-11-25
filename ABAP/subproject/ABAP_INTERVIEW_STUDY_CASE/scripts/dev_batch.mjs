import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import * as A from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/abap-tools.js';
import * as Q from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/query-tools.js';
import fs from 'fs';
// input: JSON file berisi array {tool,args,out?}
const jobs = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
await serverManager.loadConfig();
await serverManager.setActiveServer(process.env.SRV || 'dev');
for (const j of jobs) {
  if (j.tool === 'call_function') continue;
  const fn = A[j.tool] || Q[j.tool];
  let r; try { r = await fn(j.args); } catch (e) { r = { error: (e && (e.message || JSON.stringify(e))) }; }
  if (j.out && r && r.source) { fs.writeFileSync(j.out, r.source.replace(/[ ]+$/gm, '') + '\n'); console.log('##', j.tool, JSON.stringify(j.args), '-> saved', j.out, r.line_count); continue; }
  console.log('##', j.tool, JSON.stringify(j.args));
  if (r && r.rows) console.log(r.rows.map(x => Object.values(x).map(v => String(v).trim()).join(' | ')).join('\n') || '(kosong)');
  else console.log(JSON.stringify(r).slice(0, 3000));
}
process.exit(0);
