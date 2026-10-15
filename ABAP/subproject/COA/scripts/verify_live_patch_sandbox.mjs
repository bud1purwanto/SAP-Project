import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_program } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/abap-tools.js';

await serverManager.loadConfig();
const server = await serverManager.setActiveServer('sandbox-new');
if (!server.connected) throw new Error('Cannot connect to sandbox-new');

const resp = await read_program({ program_name: 'ZQMI_COA_F01' });
if (resp.mode !== 'LIVE' || !resp.source) throw new Error('Live source unavailable');

const src = resp.source;
const checks = [
  { name: 'Tabel Koleksi GT_STAGE_LOTS', pattern: 'DATA: GT_STAGE_LOTS TYPE TABLE OF TY_STAGE_LOT WITH HEADER LINE.' },
  { name: 'Traversal Genealogi Dinamis di GET_TRACED_LOTS', pattern: 'DO 10 TIMES.' },
  { name: 'Order-Based Sibling Lookup Call', pattern: 'PERFORM GET_JR_SIBLING_BY_ORDER USING LV_TREE_JR CHANGING LV_TREE_LOT.' },
  { name: 'Pencocokan Dinamis di GET_MIC', pattern: 'LOOP AT GT_STAGE_LOTS WHERE STAGE_TYPE = LV_DYN_STAGE' },
  { name: 'Subrutin FORM GET_JR_SIBLING_BY_ORDER', pattern: 'FORM GET_JR_SIBLING_BY_ORDER USING P_CHARG TYPE CHARG_D' }
];

console.log('=== VERIFIKASI SOURCE CODE LIVE DARI SERVER SANDBOX-NEW ===');
console.log('Total baris live:', resp.line_count);
for (const c of checks) {
  const found = src.includes(c.pattern);
  console.log(`[${found ? 'PASS' : 'FAIL'}] ${c.name}`);
}
