// Read-only: tarik source ZMMR_LABELROL_DOCX + include + ZCL_LABEL_DOCX ke ../src
// Pakai: cd "/var/www/MCP/MCP SAP/sap-leader-mcp" && node <path>/fetch_src.mjs [server=dev]
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
import { read_program } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/abap-tools.js';
import fs from 'fs'; import path from 'path'; import { fileURLToPath } from 'url';
const out = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'src');
await serverManager.loadConfig(); await serverManager.setActiveServer(process.argv[2] || 'dev');
for (const n of ['ZMMR_LABELROL_DOCX', 'ZMMR_LABELROL_DOCX_INCL']) {
  const p = await read_program({ program_name: n });
  fs.writeFileSync(path.join(out, n + '.abap'), p.source || ''); console.log(n, (p.source || '').length);
}
const r = await call_function({ function_name: 'RFC_READ_TABLE', parameters: { QUERY_TABLE: 'TRDIR', DELIMITER: '|', ROWCOUNT: 100, OPTIONS: [{ TEXT: "NAME LIKE 'ZCL_LABEL_DOCX%'" }], FIELDS: [{ FIELDNAME: 'NAME' }] } });
let all = '';
for (const n of (r.result?.DATA || []).map(d => d.WA.trim())) { const p = await read_program({ program_name: n }); all += '\n*==== ' + n + '\n' + (p.source || ''); }
fs.writeFileSync(path.join(out, 'ZCL_LABEL_DOCX.abap'), all); console.log('ZCL_LABEL_DOCX', all.length);
process.exit(0);
