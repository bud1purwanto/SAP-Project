import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const DOS=['0085006234','0085006235','0085006240','0085006241','0085006242','0085006243','0085006244','0085006245','0085006270','0085006271','0085006272','0085006276','0085006277','0085006278','0085006279','0085006280','0085006281','0085006282','0085006284','0085006285','0085006286'];
const rt=async(t,f,w,n=200)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
await serverManager.loadConfig();
const out={};
for (const sys of ['Development AIX','QA']){
  await serverManager.setActiveServer(sys); out[sys]={};
  for(const d of DOS){
    const h=await rt('LIKP',['VBELN','KUNNR','LFART','ERDAT','WADAT_IST'],[`VBELN = '${d}'`]);
    const p=await rt('LIPS',['POSNR','MATNR','CHARG','WERKS','LGORT','PSTYV','VGBEL','LFIMG'],[`VBELN = '${d}'`]);
    out[sys][d]={h,p};
  }
  out[sys].progs=await rt('TRDIR',['NAME','UDAT','UNAM'],["NAME LIKE 'ZQMI_COA%' OR NAME LIKE 'ZEQM015%'"]);
  out[sys].tabs=await rt('DD02L',['TABNAME','AS4DATE'],["TABNAME LIKE 'ZMAP_COA%' OR TABNAME LIKE 'ZLOG_COA%' OR TABNAME LIKE 'ZQM_LOG%'"]);
  out[sys].tcodes=await rt('TSTC',['TCODE','PGMNA'],["TCODE LIKE 'ZQM00%'"]);
}
console.log(JSON.stringify(out,null,1));
