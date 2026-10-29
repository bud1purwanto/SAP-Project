import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
import * as fs from 'fs';
import * as path from 'path';

async function fetchProgram(serverName, progName, outPath) {
  const readRes = await call_function({
    function_name: 'RPY_PROGRAM_READ',
    parameters: {
      PROGRAM_NAME: progName
    }
  });

  const lines = readRes.result?.SOURCE_EXTENDED_LINES?.map(s => s.LINE) || 
                readRes.result?.SOURCE_EXTENDED?.map(s => s.LINE) || 
                readRes.result?.SOURCE_LINES?.map(s => s.LINE) ||
                readRes.result?.SOURCE?.map(s => s.LINE) || [];

  if (lines.length === 0) {
    throw new Error(`Gagal fetch ${progName} dari ${serverName}`);
  }

  fs.writeFileSync(outPath, lines.join('\n'));
  console.log(`[${serverName}] Fetched ${progName} -> ${lines.length} lines saved to ${outPath}`);
  return lines.length;
}

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');

  const outDir = '/data/Projects/SAP/ABAP/subproject/COA/outputs';
  const progs = ['ZQMI_COA_ALV', 'Z_PROG_INFO'];

  for (const p of progs) {
    try {
      const outPath = path.join(outDir, `${p}_sandbox_live_latest.abap`);
      await fetchProgram('sandbox-new', p, outPath);
    } catch (err) {
      console.error(`Error fetching ${p}:`, err.message);
    }
  }
}

main().catch(console.error);
