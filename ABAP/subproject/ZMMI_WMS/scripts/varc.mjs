// Read-only: isi variant. Usage: node varc.mjs <server> REPORT VARIANT
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const [server, rep, vari] = process.argv.slice(2);
await serverManager.loadConfig(); await serverManager.setActiveServer(server);
const r = await call_function({ function_name: 'RS_VARIANT_CONTENTS_RFC', parameters: { REPORT: rep, VARIANT: vari } });
if (r.error) console.log('ERR', r.error);
console.log('RETURN', JSON.stringify(r.result?.RETURN));
console.log('VALUTAB'); for (const v of r.result?.VALUTAB || []) console.log(v.SELNAME, v.KIND, v.SIGN, v.OPTION, v.LOW, v.HIGH);
console.log('OBJECTS'); for (const v of r.result?.OBJECTS || []) console.log(JSON.stringify(v));
