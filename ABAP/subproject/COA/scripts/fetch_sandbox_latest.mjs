import { writeFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function fetchProgram(progName, server = 'sandbox-new') {
  await serverManager.loadConfig();
  await serverManager.setActiveServer(server);

  const res = await call_function({
    function_name: 'RPY_PROGRAM_READ',
    parameters: {
      PROGRAM_NAME: progName,
      WITH_LOWERCASE: 'X'
    }
  });

  const sourceExtended = res.result?.SOURCE_EXTENDED || res.result?.SOURCE || [];
  const lines = sourceExtended.map(row => (typeof row === 'string' ? row : row.LINE));
  console.log(`Fetched ${progName} from ${server}: ${lines.length} lines`);

  const outPath = `/data/Projects/SAP/ABAP/subproject/COA/outputs/${progName}_sandbox_latest_rollback.abap`;
  writeFileSync(outPath, lines.join('\n'), 'utf8');
  console.log(`Saved to ${outPath}`);
  return { lines, outPath };
}

async function main() {
  await fetchProgram('ZQMI_COA_F01', 'sandbox-new');
  await fetchProgram('ZQMI_COA_F02', 'sandbox-new');
  await fetchProgram('ZQMI_COA_TOP', 'sandbox-new');
  await fetchProgram('ZQMI_COA', 'sandbox-new');
}

main().catch(console.error);
