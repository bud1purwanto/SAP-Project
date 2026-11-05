import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { read_program } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/abap-tools.js';
import fs from 'fs';
const [prog, out] = process.argv.slice(2);
await serverManager.loadConfig();
await serverManager.setActiveServer('sandbox-new');
const r = await read_program({ program_name: prog });
if (!r.source) { console.error(JSON.stringify(r).slice(0, 800)); process.exit(1); }
fs.writeFileSync(out, r.source.replace(/[ ]+$/gm, '') + '\n');
console.log('mode', r.mode, 'lines', r.line_count, '->', out);
process.exit(0);
