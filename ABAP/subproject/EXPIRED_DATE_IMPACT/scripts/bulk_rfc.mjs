import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { read_program } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/abap-tools.js';
import fs from 'fs';
const [list, outdir, srv] = process.argv.slice(2);
await serverManager.loadConfig();
await serverManager.setActiveServer(srv || 'dev');
const names = fs.readFileSync(list,'utf8').split('\n').filter(Boolean);
let n=0, ok=0, bad=0; const t0=Date.now();
for (const p of names) {
  n++;
  const fn = `${outdir}/${p.replace(/\//g,'#')}.abap`;
  if (fs.existsSync(fn)) { ok++; continue; }
  try {
    const r = await read_program({ program_name: p });
    if (r && r.source !== undefined) { fs.writeFileSync(fn, r.source); ok++; }
    else { fs.writeFileSync(fn+'.err', JSON.stringify(r).slice(0,300)); bad++; }
  } catch (e) { fs.writeFileSync(fn+'.err', String(e).slice(0,300)); bad++; }
  if (n%100===0) console.log(n, ok, bad, Math.round((Date.now()-t0)/1000)+'s');
}
console.log('DONE', n, ok, bad);
process.exit(0);
