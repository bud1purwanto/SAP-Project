import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
await serverManager.loadConfig(); await serverManager.setActiveServer('QA');
for(const f of process.argv.slice(2)){const r=await read_table({table:'FUPARAREF',fields:['PARAMETER','PARAMTYPE','STRUCTURE','OPTIONAL'],where:[`FUNCNAME = '${f}'`],rowcount:80});
console.log(f,'\n ',r.rows.map(x=>x.PARAMTYPE+':'+x.PARAMETER.trim()+'('+x.STRUCTURE.trim()+')').join(' '));}
