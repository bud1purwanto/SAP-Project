// Read-only: tampilkan interface FM. Usage: node fm_iface.mjs <server> FM1 [FM2...]
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const [server, ...fms] = process.argv.slice(2);
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
for (const fm of fms) {
  const r = await call_function({ function_name: 'RFC_GET_FUNCTION_INTERFACE', parameters: { FUNCNAME: fm } });
  const p = r.result?.PARAMS || [];
  console.log('==', fm, r.error || '', 'remote:', r.result?.REMOTE_CALL);
  for (const x of p) console.log(x.PARAMCLASS, x.PARAMETER, x.TABNAME, x.FIELDNAME, x.OPTIONAL);
}
