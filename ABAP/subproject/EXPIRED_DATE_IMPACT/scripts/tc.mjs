import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/query-tools.js';
await serverManager.loadConfig(); await serverManager.setActiveServer('dev');
for (const n of process.argv.slice(2)) {
  let m=[n];
  try { const inc=(await read_table({table:'D010INC',where:[`INCLUDE = '${n}'`],fields:['MASTER'],rowcount:0})).rows||[]; if(inc.length) m=[...new Set(inc.map(r=>r.MASTER))]; } catch(e){}
  const out=[];
  for (const p of m) { const t=(await read_table({table:'TSTC',where:[`PGMNA = '${p}'`],fields:['TCODE'],rowcount:0})).rows||[]; out.push(p+':'+t.map(r=>r.TCODE).join('/')); }
  console.log(n,'->',out.join(' '));
}
process.exit(0);
