import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
import fs from 'fs';
const [,,sys,file]=process.argv;
await serverManager.loadConfig(); await serverManager.setActiveServer(sys);
const src=fs.readFileSync(file,'utf8').split('\n');
const res=await call_function({function_name:'RFC_ABAP_INSTALL_AND_RUN',parameters:{PROGRAM:src.map(l=>({LINE:l}))}});
const r=res.result||res; if(r.ERRORMESSAGE) console.log('ERR',r.ERRORMESSAGE);
for(const w of (r.WRITES||[])) console.log(w.ZEILE);
