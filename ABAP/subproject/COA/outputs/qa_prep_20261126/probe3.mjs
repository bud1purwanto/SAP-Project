import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const rt=async(t,f,w,n=50)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
await serverManager.loadConfig(); await serverManager.setActiveServer('QA');
const cnt=(a,f)=>{const m={};if(!Array.isArray(a))return a;for(const x of a){const k=f(x);m[k]=(m[k]||0)+1;}return m;};
const lk=await rt('LIKP',['VBELN','LFART','ERDAT'],["ERDAT >= '20240101'"],20000);
console.log('LIKP>=2024',Array.isArray(lk)?lk.length:lk, cnt(lk,x=>x.ERDAT.slice(0,6)+' '+x.LFART));
const ql=await rt('QALS',['PRUEFLOS','ART','ENSTEHDAT','WERK'],["ENSTEHDAT >= '20240101'"],50000);
console.log('QALS>=2024',Array.isArray(ql)?ql.length:ql, cnt(ql,x=>x.ENSTEHDAT.slice(0,4)+' '+x.ART+' '+x.WERK));
const lkmax=await rt('LIKP',['VBELN','ERDAT','LFART'],["VBELN LIKE '00850%'"],100000);
if(Array.isArray(lkmax)){lkmax.sort((a,b)=>a.VBELN<b.VBELN?1:-1);console.log('max 0085', lkmax.slice(0,3));}
const mch=await rt('MCH1',['MATNR','CHARG','ERSDA'],["MATNR = 'SRAABI' AND ERSDA >= '20240101'"],5000);
console.log('MCH1 SRAABI>=2024', Array.isArray(mch)?mch.length:mch, Array.isArray(mch)?cnt(mch,x=>x.ERSDA.slice(0,6)):'');
const mx=await rt('MCH1',['MATNR','CHARG','ERSDA'],["MATNR = 'SRAABI' AND ERSDA >= '20120101'"],100000);
if(Array.isArray(mx)) console.log('MCH1 SRAABI per year', cnt(mx,x=>x.ERSDA.slice(0,4)));
