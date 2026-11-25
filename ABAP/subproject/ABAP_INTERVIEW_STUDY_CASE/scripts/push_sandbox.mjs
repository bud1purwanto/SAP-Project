// Push program latihan ke sandbox-new ($TMP) via Z_RFC_PROGRAM_UPDATE, lalu pull ulang & bandingkan.
// Usage: node push_sandbox.mjs ../src/ZTRAIN_X.abap ...
import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/query-tools.js';
import { read_program } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tools/abap-tools.js';
import fs from 'fs'; import path from 'path';
await serverManager.loadConfig();
await serverManager.setActiveServer('sandbox-new');
for (const f of process.argv.slice(2)) {
  const name = path.basename(f, '.abap');
  const lines = fs.readFileSync(f, 'utf8').replace(/\n$/, '').split('\n').map(l => l.replace(/\s+$/, ''));
  let r;
  try {
    r = await call_function({ function_name: 'Z_RFC_PROGRAM_UPDATE', parameters: {
      IV_PROGRAM_NAME: name, IV_PACKAGE: '$TMP', IV_CORRNUMBER: ' ', IT_SOURCE: lines.map(LINE => ({ LINE })) } });
  } catch (e) { console.log(name, 'EXC', e.message || JSON.stringify(e)); continue; }
  const res = r.result || r;
  const back = await read_program({ program_name: name });
  const got = (back.source || '').split('\n').map(l => l.replace(/\s+$/, '')).filter((l, i, a) => !(i === a.length - 1 && l === ''));
  const same = got.join('\n').toUpperCase() === lines.join('\n').toUpperCase();
  console.log(name, '| EV_SUCCESS=', res.EV_SUCCESS, '|', (res.EV_MESSAGE || '').trim(), '| pull ulang:', got.length, 'baris, sama =', same);
}
process.exit(0);
