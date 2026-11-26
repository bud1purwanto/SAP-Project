import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
import fs from 'fs';
const k=JSON.parse(fs.readFileSync(process.argv[2]));
const rt=async(t,f,w,n=50)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
await serverManager.loadConfig();
const out={};
for (const sys of ['QA','Development AIX']){
 await serverManager.setActiveServer(sys); const o=out[sys]={};
 o.t000=await rt('T000',['MANDT','MTEXT','CCCATEGORY','CHANGEDATE'],[]);
 o.mara={}; for(const m of k.mats){const r=await rt('MARC',['MATNR','WERKS'],[`MATNR = '${m}'`]); o.mara[m]=Array.isArray(r)?r.map(x=>x.WERKS).join(','):r;}
 o.kna1={}; for(const c of k.cust){const r=await rt('KNA1',['KUNNR','NAME1'],[`KUNNR = '${c}'`]); o.kna1[c]=Array.isArray(r)&&r[0]?r[0].NAME1:'-';}
 o.tabs={}; for(const t of ['ZMAP_COA','ZMAP_COA_MIC','ZMAP_COA_BATCH','ZMAP_COA_GRP_COL','ZMAP_COA_GRP_CST','ZLOG_COA','ZQM_LOG_GS']){const r=await rt('DD02L',['TABNAME','AS4DATE'],[`TABNAME = '${t}'`]); o.tabs[t]=Array.isArray(r)&&r[0]?r[0].AS4DATE:'-';}
 let hit=0,miss=[]; for(const [m,b] of k.bats){const r=await rt('MCH1',['CHARG'],[`MATNR = '${m}' AND CHARG = '${b}'`],1); if(Array.isArray(r)&&r.length)hit++; else miss.push(b);} o.batch={hit,miss:miss.length,ex:miss.slice(0,5)};
 o.likp_last=await rt('LIKP',['VBELN','ERDAT'],["ERDAT >= '20260101'"],3);
 o.qals_2026=await rt('QALS',['PRUEFLOS','ENSTEHDAT','MATNR'],["ENSTEHDAT >= '20260101'"],3);
 o.qals_2025=await rt('QALS',['PRUEFLOS','ENSTEHDAT','MATNR'],["ENSTEHDAT >= '20250101'"],3);
}
console.log(JSON.stringify(out,null,1));
