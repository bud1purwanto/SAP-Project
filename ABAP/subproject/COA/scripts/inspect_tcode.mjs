import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZDYNPRO_INSPECT.',
    'DATA: LV_PROG TYPE TSTC-PGMNA,',
    '      LV_DYNNR TYPE TSTC-DYPNO.',
    'SELECT SINGLE PGMNA DYPNO FROM TSTC INTO (LV_PROG, LV_DYNNR)',
    '  WHERE TCODE = \'ZQM002\'.',
    'WRITE: / \'ZQM002:\', LV_PROG, LV_DYNNR.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line > 72: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: prog.map(l => ({ LINE: l }))
    }
  });
  console.log('Result:', JSON.stringify(res.result?.WRITES || res));
}
main().catch(console.error);
