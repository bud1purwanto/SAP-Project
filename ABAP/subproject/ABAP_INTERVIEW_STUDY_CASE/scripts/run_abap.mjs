// Run temp ABAP (read-only diagnostic) via RFC_ABAP_INSTALL_AND_RUN.
// node scripts/mt_run_abap.mjs file.abap [server]
import { readFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const file = process.argv[2];
const server = process.argv[3] || 'sandbox-new';
const lines = readFileSync(file, 'utf8').split('\n').map(l => l.replace(/\s+$/, ''));
for (const [i, l] of lines.entries()) if (l.length > 72) throw new Error(`line ${i + 1} > 72: ${l}`);
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
let r; try { r = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: lines.map(LINE => ({ LINE })), WRITES: [] } }); } catch (e) { console.error("EXC", e.message || JSON.stringify(e)); process.exit(1); }
if (r.result?.ERRORMESSAGE) console.error('ERR:', r.result.ERRORMESSAGE);
console.log((r.result?.WRITES || []).map(w => w.ZEILE).join('\n'));
if (!r.result) console.log(JSON.stringify(r).slice(0, 2000));
process.exit(0);
