import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const rt=async(t,f,w,n=50)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
const names=['ZQMI_COA','ZQMI_COA_TOP','ZQMI_COA_F01','ZQMI_COA_F02','ZQMI_COA_ALV','ZMAP_COA','ZMAP_COA_GRP_COL','ZMAP_COA_GRP_CST','ZLOG_COA','ZQM_GET_BATCH_JR_BY_SR','ZQM_GET_BATCH_SR_BY_JR','ZQM_GET_BATCH_SR','ZQM_COA_CUST_COL','ZQM_COA_DYN_ROLL','ZQM_COA_DYN_HDR','ZQMF_COA','ZQMF_COA_BATCH','Z_GET_PRODUCTION_DATE','ZBATCHISTORY','ZEQM015','ZPROGINFO','ZBC_DOWNLOAD_TEMPLATE','ZQMI_BARRIER_PASS_FAIL','ZSDC_DJP_CONV','ZHUR_LABELPACK','ZMAP_LABEL','ZQM_LOG_GS','ZMAP_COA_BATCH','ZMAP_COA_MIC','ZQM001','ZQM002','ZQM003','ZMAP_TYPE','ZDJP_CONV','ZQMI_CERTIFICATE'];
await serverManager.loadConfig(); const res={};
for(const sys of ['Development AIX','QA']){await serverManager.setActiveServer(sys);
 for(const n of names){const r=await rt('TADIR',['PGMID','OBJECT','OBJ_NAME','DEVCLASS'],[`OBJ_NAME = '${n}'`]);
  res[n]=res[n]||{}; res[n][sys]=Array.isArray(r)?r.map(x=>x.OBJECT+':'+x.DEVCLASS).join(' '):r;}
 // FM existence via TFDIR
 for(const n of names){const r=await rt('TFDIR',['FUNCNAME','PNAME'],[`FUNCNAME = '${n}'`]); if(Array.isArray(r)&&r.length){res[n][sys]+=' FUNC:'+r[0].PNAME.trim();}}
 for(const f of ['ZZALIAS']){for(const t of ['VBAP','LIPS','MCH1','VBAK']){const r=await rt('DD03L',['TABNAME','FIELDNAME'],[`TABNAME = '${t}' AND FIELDNAME = '${f}'`]);res[t+'-'+f]=res[t+'-'+f]||{};res[t+'-'+f][sys]=Array.isArray(r)?r.length:r;}}
 for(const c of ['ZZALIAS','ZZNOMORROLL','ZZPRODLINE','ZZTYPE']){const r=await rt('CABN',['ATNAM','ATINN'],[`ATNAM = '${c}'`]);res['CABN '+c]=res['CABN '+c]||{};res['CABN '+c][sys]=Array.isArray(r)?r.length:r;}
}
for(const [k,v] of Object.entries(res)) console.log(k.padEnd(26),'| DEV:',(v['Development AIX']||'-').toString().padEnd(40),'| QA:',v['QA']||'-');
