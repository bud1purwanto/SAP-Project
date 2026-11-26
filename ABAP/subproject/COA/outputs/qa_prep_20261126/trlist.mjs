import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const rt=async(t,f,w,n=500)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
await serverManager.loadConfig(); await serverManager.setActiveServer('Development AIX');
for(const t of ['TRDK924626','TRDK924627']){console.log(t,JSON.stringify(await rt('E070',['TRFUNCTION','TRSTATUS','AS4USER','AS4DATE','TARSYSTEM'],[`TRKORR = '${t}'`])));
 const r=await rt('E071',['PGMID','OBJECT','OBJ_NAME'],[`TRKORR = '${t}'`]); console.log(r.map(x=>x.PGMID+' '+x.OBJECT+' '+x.OBJ_NAME.trim()).join('\n'));
 const k=await rt('E071K',['OBJNAME','TABKEY'],[`TRKORR = '${t}'`]); console.log('keys',Array.isArray(k)?k.length:k, JSON.stringify(k).slice(0,300));}
for(const n of ['ZQM_COA_DYN_ROLL','ZQM_COA_DYN_HDR','ZQM_COA_CUST_COL','ZMAP_COA','ZMAP_COA_GRP_COL','ZMAP_COA_GRP_CST','ZLOG_COA']) console.log(n,JSON.stringify(await rt('DD02L',['TABCLASS','CONTFLAG','AS4DATE'],[`TABNAME = '${n}' AND AS4LOCAL = 'A'`])));
for(const n of ['ZMAP_COA','ZMAP_COA_GRP_COL','ZMAP_COA_GRP_CST']){const r=await rt(n,['MANDT'],[],100000);console.log('rows',n,Array.isArray(r)?r.length:r);}
