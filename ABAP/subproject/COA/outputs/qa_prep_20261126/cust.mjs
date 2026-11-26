import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const rt=async(t,f,w,n=50)=>{try{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.data||r.rows||r;}catch(e){return 'ERR '+e.message}};
await serverManager.loadConfig(); await serverManager.setActiveServer('QA');
for(const p of ['%CANOPUS%','%KT&G%','%TUTUN%','%ATLANTIC%']){const r=await rt('KNA1',['KUNNR','NAME1','LAND1','KTOKD'],[`NAME1 LIKE '${p}'`]);console.log(p,JSON.stringify(r));}
for(const k of ['1141000512','1141000514','1141100304']){const r=await rt('KNVV',['KUNNR','VKORG','VTWEG','SPART'],[`KUNNR = '${k}'`]);console.log('KNVV',k,JSON.stringify(r));}
