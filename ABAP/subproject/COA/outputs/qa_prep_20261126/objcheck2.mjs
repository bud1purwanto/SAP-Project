import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const rt=async(t,f,w,n=50)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
await serverManager.loadConfig();
for(const sys of ['Development AIX','QA']){await serverManager.setActiveServer(sys); console.log('==',sys);
 const t=await rt('TSTC',['TCODE','PGMNA'],["TCODE = 'ZEQM015'"]); console.log(JSON.stringify(t));
 if(Array.isArray(t)&&t[0]){const p=t[0].PGMNA.trim(); console.log(JSON.stringify(await rt('TRDIR',['NAME','UDAT','UNAM'],[`NAME LIKE '${p}%'`])));}
 console.log('SSF',JSON.stringify(await rt('STXFADM',['FORMNAME','LASTDATE','LASTUSER'],["FORMNAME = 'ZQMF_COA' OR FORMNAME = 'ZQMF_COA_BATCH'"])));
 for(const f of ['ZQM_GET_BATCH_JR_BY_SR','ZQM_GET_BATCH_SR_BY_JR','Z_GET_PRODUCTION_DATE']){const r=await rt('TFDIR',['FUNCNAME','PNAME','INCLUDE'],[`FUNCNAME = '${f}'`]);
   if(Array.isArray(r)&&r[0]){const inc='L'+r[0].PNAME.trim().slice(4)+'U'+r[0].INCLUDE.trim(); console.log(f,inc,JSON.stringify(await rt('TRDIR',['UDAT'],[`NAME = '${inc}'`])));}}
 console.log('ZQM001 tab fields',JSON.stringify((await rt('DD03L',['FIELDNAME'],["TABNAME = 'ZQM001'"])).map?.(x=>x.FIELDNAME.trim())));
}
