import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const rt=async(t,f,w,n=50)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
const cnt=(a,f)=>{const m={};if(!Array.isArray(a))return a;for(const x of a){const k=f(x);m[k]=(m[k]||0)+1;}return m;};
await serverManager.loadConfig(); await serverManager.setActiveServer('QA');
const ql=await rt('QALS',['PRUEFLOS','ART','MATNR','CHARG','ENSTEHDAT','AUFNR'],["ENSTEHDAT >= '20260101' AND WERK = '2000'"],5000);
console.log('QA lots 2026 by art/mat', cnt(ql,x=>x.ART+' '+x.MATNR.trim()));
const z02=ql.filter(x=>x.ART==='Z02').slice(0,40); let wr=0;
for(const l of z02){const r=await rt('QAMR',['PRUEFLOS'],[`PRUEFLOS = '${l.PRUEFLOS}'`],1); if(Array.isArray(r)&&r.length) wr++;}
console.log('Z02 sample 40 with QAMR:',wr);
for(const m of ['PCADELMD','PACBTH00','PAABTH00','PEYASTNT','PCADSTNT']){const r=await rt('QPMK',['MKMNR','WERKS','VERSION'],[`MKMNR = '${m}'`],3);console.log('QPMK',m,JSON.stringify(r));}
for(const p of ['ZEQM015','ZQMI_PROP_SELECT','ZQMI_CERTIFICATE','ZPPC_UPLOAD_SLITROLL']){const r=await rt('TRDIR',['NAME','UDAT'],[`NAME = '${p}'`]);console.log('PROG',p,JSON.stringify(r));}
const lp=await rt('LIPS',['VBELN','MATNR','CHARG','ERDAT'],["ERDAT >= '20260101' AND WERKS = '2000' AND PSTYV = 'ZB'"],5000);
console.log('QA DO items ZB 2026 by mat', cnt(lp,x=>x.MATNR.trim()));
const d=await rt('LIPS',['VBELN','MATNR','CHARG','ERDAT'],["ERDAT >= '20261101' AND WERKS = '2000'"],30);console.log(JSON.stringify(d).slice(0,800));
