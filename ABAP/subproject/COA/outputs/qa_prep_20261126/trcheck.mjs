import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const rt=async(t,f,w,n=500)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
await serverManager.loadConfig(); await serverManager.setActiveServer('Development AIX');
const objs=['ZQMI_COA','ZQMI_COA_TOP','ZQMI_COA_F01','ZQMI_COA_F02','ZQMI_COA_ALV','ZMAP_COA','ZMAP_COA_GRP_COL','ZMAP_COA_GRP_CST','ZLOG_COA','ZQM_COA_CUST_COL','ZQM_COA_DYN_ROLL','ZQM_COA_DYN_HDR','ZQMF_COA','ZQMF_COA_BATCH','ZMAP_COA_BATCH','ZMAP_COA_MIC','ZQM001','ZQM002','ZQM003'];
const trs={};
for(const o of objs){const r=await rt('E071',['TRKORR','OBJECT','OBJ_NAME'],[`OBJ_NAME = '${o}'`]); if(Array.isArray(r)) for(const x of r){(trs[x.TRKORR]=trs[x.TRKORR]||new Set()).add(x.OBJECT+':'+o);}}
for(const [t,s] of Object.entries(trs)){const h=await rt('E070',['TRKORR','TRFUNCTION','TRSTATUS','AS4USER','AS4DATE','STRKORR'],[`TRKORR = '${t}'`]);const tx=await rt('E07T',['AS4TEXT'],[`TRKORR = '${t}'`]);
 const e=h[0]||{}; console.log(t,e.TRFUNCTION,e.TRSTATUS,e.AS4DATE,e.STRKORR,(tx[0]||{}).AS4TEXT,'|',[...s].join(' '));}
