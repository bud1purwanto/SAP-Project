// Read-only: cek index fisik di DB via DB_EXISTS_INDEX (temp program RFC_ABAP_INSTALL_AND_RUN)
// Usage: node check_db_index.mjs <server> TAB~IDX ...
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';

const [server, ...pairs] = process.argv.slice(2);
const src = [
  'REPORT ZTMP_IDX.',
  'DATA: LV_RC TYPE SY-SUBRC,',
  '      LV_TXT(72) TYPE C.',
];
for (const p of pairs) {
  const [t, i] = p.split('~');
  src.push(
    `CALL FUNCTION 'DB_EXISTS_INDEX'`,
    `  EXPORTING TABNAME = '${t}' INDEXNAME = '${i}'`,
    `  IMPORTING SUBRC = LV_RC.`,
    `CONCATENATE '${p}' 'RC=' INTO LV_TXT SEPARATED BY SPACE.`,
    `WRITE: / LV_TXT, LV_RC.`,
  );
}
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const res = await HANDLERS.call_function({ function_name: "RFC_ABAP_INSTALL_AND_RUN", parameters: { PROGRAM: src.map(LINE => ({ LINE })) } });
const out = res.result?.WRITES || res.WRITES || res;
console.log(JSON.stringify(out, null, 1));
