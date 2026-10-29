import { writeFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function fetchAll(server = 'Development AIX') {
  await serverManager.loadConfig();
  await serverManager.setActiveServer(server);

  const progs = ['ZQMI_COA', 'ZQMI_COA_TOP', 'ZQMI_COA_F01', 'ZQMI_COA_F02', 'ZQMI_COA_SCR', 'ZQMI_COA_PBO', 'ZQMI_COA_PAI'];
  for (const p of progs) {
    try {
      const res = await call_function({
        function_name: 'RPY_PROGRAM_READ',
        parameters: { PROGRAM_NAME: p, WITH_LOWERCASE: 'X' }
      });
      const sourceExtended = res.result?.SOURCE_EXTENDED || res.result?.SOURCE || [];
      const lines = sourceExtended.map(row => (typeof row === 'string' ? row : row.LINE));
      const outPath = `/data/Projects/SAP/ABAP/subproject/COA/outputs/${p}_${server}_current.abap`;
      writeFileSync(outPath, lines.join('\n'), 'utf8');
      console.log(`[SUCCESS] ${p} fetched from ${server}: ${lines.length} lines -> ${outPath}`);
    } catch (e) {
      console.log(`[WARN] Failed to fetch ${p}: ${e.message}`);
    }
  }
}

fetchAll('Development AIX').catch(console.error);
