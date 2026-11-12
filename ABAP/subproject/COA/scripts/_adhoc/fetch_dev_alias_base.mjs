// Ambil include ZQMI_COA terbaru dari Development AIX (read-only) untuk live test alias.
import { writeFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const TAG = process.argv[2] || 'alias20261112';
await serverManager.loadConfig(); await serverManager.setActiveServer('Development AIX');
for (const p of ['ZQMI_COA', 'ZQMI_COA_TOP', 'ZQMI_COA_F01', 'ZQMI_COA_F02', 'ZQMI_COA_ALV']) {
  const r = await call_function({ function_name: 'RPY_PROGRAM_READ', parameters: { PROGRAM_NAME: p, WITH_LOWERCASE: 'X' } });
  const src = r.result?.SOURCE_EXTENDED || r.result?.SOURCE || [];
  const lines = src.map(x => typeof x === 'string' ? x : x.LINE);
  writeFileSync(new URL(`../../outputs/${p}_Development AIX_${TAG}.abap`, import.meta.url).pathname, lines.join('\n'));
  console.log(p, lines.length);
}
