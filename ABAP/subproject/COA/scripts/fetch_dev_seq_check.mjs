import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
import * as fs from 'fs';
const srv = process.argv[2] || 'dev';
const out = '/data/Projects/SAP/ABAP/subproject/COA/outputs/seq_check_20261103';
await serverManager.loadConfig();
await serverManager.setActiveServer(srv);
for (const p of ['ZQMI_COA','ZQMI_COA_TOP','ZQMI_COA_F01','ZQMI_COA_F02','ZQMI_COA_ALV']) {
  try {
    const r = await call_function({ function_name: 'RPY_PROGRAM_READ', parameters: { PROGRAM_NAME: p } });
    const lines = (r.result?.SOURCE_EXTENDED || r.result?.SOURCE || []).map(s => s.LINE);
    fs.writeFileSync(`${out}/${p}_${srv}.abap`, lines.join('\n'));
    console.log(p, lines.length);
  } catch (e) { console.log(p, 'ERR', e.message); }
}
process.exit(0);
