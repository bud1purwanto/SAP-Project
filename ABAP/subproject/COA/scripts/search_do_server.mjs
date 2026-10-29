import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  for (const s of serverManager.config.servers) {
    if (s.name.includes('Production')) continue;
    try {
      await serverManager.setActiveServer(s.name);
      const prog = [
        'REPORT ZCHECK_DO.',
        'DATA: LV_CNT TYPE I.',
        'SELECT COUNT(*) INTO LV_CNT FROM LIKP WHERE VBELN LIKE \'%85006272%\'.',
        'WRITE: / SY-MANDT, SY-SYSID, LV_CNT.'
      ];
      const res = await call_function({
        function_name: 'RFC_ABAP_INSTALL_AND_RUN',
        parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
      });
      console.log(s.name, res.result?.WRITES);
    } catch (e) {
      console.log(s.name, 'Error:', e.message);
    }
  }
}
main().catch(console.error);
