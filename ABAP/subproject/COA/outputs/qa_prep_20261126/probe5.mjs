import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const rt=async(t,f,w,n=50)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
await serverManager.loadConfig(); await serverManager.setActiveServer('QA');
const ql=await rt('QALS',['PRUEFLOS','ART','MATNR','CHARG','ENSTEHDAT'],["ENSTEHDAT >= '20250101' AND WERK = '2000'"],5000);
const res={};
for(const l of ql.filter(x=>['Z02','Z04','Z05','Z06'].includes(x.ART))){
  const r=await rt('QAMR',['PRUEFLOS'],[`PRUEFLOS = '${l.PRUEFLOS}'`],1);
  const k=l.ART+' '+l.MATNR.trim(); res[k]=res[k]||[0,0,[]]; res[k][0]++;
  if(Array.isArray(r)&&r.length){res[k][1]++; if(res[k][2].length<3)res[k][2].push(l.PRUEFLOS+'/'+l.CHARG+'/'+l.ENSTEHDAT);}
}
for(const [k,v] of Object.entries(res).sort()) if(v[1]) console.log(k,'lots',v[0],'withQAMR',v[1],v[2].join(' '));
console.log('TOTAL', Object.values(res).reduce((a,v)=>[a[0]+v[0],a[1]+v[1]],[0,0]));
