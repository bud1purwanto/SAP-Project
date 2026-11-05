import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_TRACE_LOT.',
    'DATA: LT_LIPS TYPE TABLE OF LIPS WITH HEADER LINE.',
    'SELECT * FROM LIPS INTO TABLE LT_LIPS WHERE VBELN = \'0085006273\'.',
    'READ TABLE LT_LIPS INDEX 1.',
    'WRITE: / \'DO MATNR:\', LT_LIPS-MATNR, \'CHARG:\', LT_LIPS-CHARG.',
    'DATA: LT_ZMAP TYPE TABLE OF ZMAP_COA WITH HEADER LINE.',
    'SELECT * FROM ZMAP_COA INTO TABLE LT_ZMAP',
    '  WHERE MATNR = LT_LIPS-MATNR AND DELETION NE \'X\'.',
    'LOOP AT LT_ZMAP.',
    '  WRITE: / LT_ZMAP-MIC, LT_ZMAP-MAPPING, LT_ZMAP-MIC_DESC.',
    'ENDLOOP.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line too long: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
  });
  console.log(JSON.stringify(res.result?.WRITES));
}
main().catch(console.error);
