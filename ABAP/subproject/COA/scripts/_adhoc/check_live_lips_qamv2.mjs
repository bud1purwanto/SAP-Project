import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_LIVE_LIPS_QAMV.',
    'DATA: LT_LIPS TYPE TABLE OF LIPS WITH HEADER LINE,',
    '      LT_QALS TYPE TABLE OF QALS WITH HEADER LINE.',
    'SELECT * FROM LIPS INTO TABLE LT_LIPS WHERE VBELN = \'0085006273\'.',
    'READ TABLE LT_LIPS INDEX 1.',
    'WRITE: / \'LIPS:\', LT_LIPS-VBELN, LT_LIPS-CHARG, LT_LIPS-MATNR.',
    'SELECT * FROM QALS INTO TABLE LT_QALS WHERE CHARG = LT_LIPS-CHARG.',
    'LOOP AT LT_QALS.',
    '  WRITE: / \'QALS:\', LT_QALS-PRUEFLOS, LT_QALS-WERK, LT_QALS-ART.',
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
