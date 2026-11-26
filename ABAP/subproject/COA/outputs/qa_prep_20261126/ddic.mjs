import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const rt=async(t,f,w,n=500)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
await serverManager.loadConfig(); await serverManager.setActiveServer('Development AIX');
const tabs=['ZMAP_COA','ZMAP_COA_GRP_COL','ZMAP_COA_GRP_CST','ZLOG_COA','ZQM_COA_DYN_ROLL','ZQM_COA_DYN_HDR','ZQM_COA_CUST_COL'];
const z=new Set();
for(const t of tabs){const r=await rt('DD03L',['ROLLNAME','PRECFIELD'],[`TABNAME = '${t}' AND AS4LOCAL = 'A'`]); for(const x of r){for(const v of [x.ROLLNAME,x.PRECFIELD]) if(v&&v.trim().startsWith('Z')) z.add(v.trim());}}
const doms=new Set(); for(const d of z){const r=await rt('DD04L',['DOMNAME'],[`ROLLNAME = '${d}'`]); if(r[0]&&r[0].DOMNAME.trim().startsWith('Z')) doms.add(r[0].DOMNAME.trim());}
console.log('DTEL/INCL',[...z].join(' ')); console.log('DOMA',[...doms].join(' '));
const r=await rt('ZMAP_COA',['MATNR'],[],100000); console.log('ZMAP_COA rows',Array.isArray(r)?r.length:r);
await serverManager.setActiveServer('QA');
for(const d of z){const a=await rt('DD04L',['ROLLNAME'],[`ROLLNAME = '${d}'`]);const b=await rt('DD02L',['TABNAME'],[`TABNAME = '${d}'`]); if(!(a.length||b.length)) console.log('QA missing',d);}
for(const d of doms){const a=await rt('DD01L',['DOMNAME'],[`DOMNAME = '${d}'`]); if(!a.length) console.log('QA missing DOMA',d);}
for(const s of ['ZQMF_COA_EXPORT','ZQMI_PENDING_BARRIER','ZMAP_GLOBAL']) {const a=await rt('TADIR',['OBJECT'],[`OBJ_NAME = '${s}'`]);const b=await rt('STXFADM',['FORMNAME'],[`FORMNAME = '${s}'`]); console.log('QA',s,JSON.stringify(a),JSON.stringify(b));}
