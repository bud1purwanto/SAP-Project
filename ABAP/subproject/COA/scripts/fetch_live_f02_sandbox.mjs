import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZCHECK_LIVE_F02_FETCH.',
    'DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
    'READ REPORT \'ZQMI_COA_F02\' INTO LT_SRC.',
    'LOOP AT LT_SRC.',
    '  WRITE: / LT_SRC-LINE.',
    'ENDLOOP.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  
  if (res.result?.WRITES) {
    const lines = res.result.WRITES.map(w => w.ZEILE);
    console.log('Total lines live ZQMI_COA_F02 in sandbox:', lines.length);
    import('fs').then(fs => {
      fs.writeFileSync('/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F02_sandbox_current_before_patch.abap', lines.join('\n'));
      console.log('Saved to /data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F02_sandbox_current_before_patch.abap');
    });
  }
}
main().catch(console.error);
