import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_TRACE_SRIA5I.',
    'DATA: LT_QALS TYPE TABLE OF QALS WITH HEADER LINE,',
    '      LT_QAMV TYPE TABLE OF QAMV WITH HEADER LINE.',
    'SELECT * FROM QALS INTO TABLE LT_QALS WHERE CHARG = \'0000406256\'.',
    'LOOP AT LT_QALS.',
    '  WRITE: / \'LOT:\', LT_QALS-PRUEFLOS, LT_QALS-ART.',
    '  SELECT * FROM QAMV INTO TABLE LT_QAMV',
    '    WHERE PRUEFLOS = LT_QALS-PRUEFLOS.',
    '  LOOP AT LT_QAMV.',
    '    WRITE: / \'  QAMV:\', LT_QAMV-VERWMERKM, LT_QAMV-KURZTEXT.',
    '  ENDLOOP.',
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
