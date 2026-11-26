import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
import fs from 'fs';
const rt=async(t,f,w,n=50)=>{const r=await read_table({table:t,fields:f,where:w,rowcount:n});return r.rows||[];};
await serverManager.loadConfig(); await serverManager.setActiveServer('QA');
const S={
 1:{c:'1141000584',r:[['SRAABI','0003885659'],['SRAABI','0003885660'],['SRAABI','0003885661']]},
 2:{c:'1800000002',r:[['SRAABI','0003883662'],['SRAABI','0003883663'],['SRAABI','0003885662'],['SRAABI','0003885663']]},
 3:{c:'1800000002',r:[['SRGIDI','0003885098'],['SRGIDI','0003885099'],['SRGIDI','0003885100']]},
 4:{c:'1800000002',r:[['SREWEI','0003885126'],['SREWEI','0003885127'],['SREWEI','0003885122'],['SREWEI','0003885123']]},
 6:{c:'1141000004',r:['0003885210','0003885211','0003885212','0003885213','0003885214'].map(b=>['SREASI',b])},
 12:{c:'1141100239',r:['0003885794','0003885795','0003885796','0003885797','0003885798','0003885799'].map(b=>['SRACBI',b])},
 13:{c:'1141100081',r:['0003885818','0003885819','0003885820','0003885821','0003885822','0003885823'].map(b=>['SRACBI',b])},
 16:{c:'1141000584',r:[['SRAABI','0003883666'],['SRAABI','0003883667'],['SRAAAI','0003632666'],['SRAAAI','0003632667']]},
 17:{c:'1141000585',r:[['SRAABI','0003883679'],['SRAABI','0003883680']]},
 18:{c:'1141000584',r:[['SRAABI','0003883682'],['SRAABI','0003885664'],['SRAABI','0003884166']]},
 19:{c:'1141000584',r:[['SRAABI','0003885665'],['SRAC2I','0003884267']]}};
for(const [k,s] of Object.entries(S)){
 s.rolls=[]; for(const [m,b] of s.r){let x=await rt('MCHB',['LGORT','CLABS'],[`MATNR = '${m}'`,`AND WERKS = '2000'`,`AND CHARG = '${b}'`]); x=x.filter(y=>parseFloat(y.CLABS)>0); s.rolls.push({m,b,lgort:x[0]?.LGORT?.trim(),q:parseFloat(x[0]?.CLABS)}); if(!x[0])console.log('NOSTOCK',m,b);}
 delete s.r;
 const v=await rt('KNVV',['VKORG','VTWEG','VKBUR','ZTERM','VSBED','WAERS'],[`KUNNR = '${s.c}'`,`AND VKORG = '1000'`,`AND VTWEG = '00'`]); s.knvv=v[0];
}
fs.writeFileSync('scen.json',JSON.stringify(S,null,1));
console.log(JSON.stringify(Object.fromEntries(Object.entries(S).map(([k,s])=>[k,s.rolls.map(r=>r.b.slice(-4)+'@'+r.lgort+':'+r.q).join(' ')+' | '+JSON.stringify(s.knvv)])),null,1));
console.log('BAPE_VBAP',JSON.stringify((await rt('DD03L',['FIELDNAME'],["TABNAME = 'BAPE_VBAP'"],30)).map(x=>x.FIELDNAME.trim())));
console.log('ZD00',JSON.stringify(await rt('T685',['KSCHL','KVEWE'],["KSCHL = 'ZD00'"])));
