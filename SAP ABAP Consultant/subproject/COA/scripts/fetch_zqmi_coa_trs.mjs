import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const userProfile = process.env.USERPROFILE || 'C:\\Users\\User';
const registryPath = path.join(
  userProfile,
  'Documents',
  'Claude',
  'MCP SAP',
  'sap-leader-mcp',
  'src',
  'tool-registry.js'
);

const registry = await import(pathToFileURL(registryPath).href);
const setActiveServer = registry.HANDLERS['set_active_server'];
const readProgram = registry.HANDLERS['read_program'];

console.log('Connecting to sandbox-new (TRS)...');
await setActiveServer({ server_ref: 'sandbox-new' });

const progs = ['ZQMI_COA', 'ZQMI_COA_TOP', 'ZQMI_COA_F01', 'ZQMI_COA_F02', 'ZQMI_COA_ALV'];
const outDir = path.resolve('subproject/COA/outputs/fetch_trs_latest');
fs.mkdirSync(outDir, { recursive: true });

for (const p of progs) {
  console.log(`Fetching ${p} from TRS...`);
  const res = await readProgram({ program_name: p });
  if (res.source) {
    const filePath = path.join(outDir, `${p}.abap`);
    fs.writeFileSync(filePath, res.source, 'utf8');
    console.log(`Saved ${p} (${res.source.split('\n').length} lines)`);
  } else {
    console.error(`Error fetching ${p}:`, res.error || 'No source');
  }
}
console.log('Done fetching TRS programs.');
