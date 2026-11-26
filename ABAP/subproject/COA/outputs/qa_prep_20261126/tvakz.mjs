import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const rt=async(t,f,w,n=100)=>{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.rows||r;};
await serverManager.loadConfig(); await serverManager.setActiveServer('QA');
console.log('TVAKZ 1000/00',JSON.stringify(await rt('TVAKZ',['VKORG','VTWEG','SPART','AUART'],["VKORG = '1000'","AND VTWEG = '00'"])).slice(0,800));
for(const a of ['ZDOR','ZEOR']){console.log(a,'TVAK',JSON.stringify(await rt('TVAK',['AUART','LFARV','VBTYP'],[`AUART = '${a}'`])),'TVAKZ',JSON.stringify(await rt('TVAKZ',['VKORG','VTWEG','SPART'],[`AUART = '${a}'`])));}
console.log('VBAK 1000/00 types',JSON.stringify(await rt('VBAK',['AUART'],["VKORG = '1000'","AND VTWEG = '00'","AND ERDAT >= '20260101'"],300).then(r=>[...new Set(r.map(x=>x.AUART))])));
console.log('TVKOV 1000',JSON.stringify(await rt('TVKOV',['VKORG','VTWEG'],["VKORG = '1000'"])));
