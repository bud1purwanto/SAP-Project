import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_LOT_85006273.',
    'DATA: LT_LIPS TYPE TABLE OF LIPS WITH HEADER LINE.',
    'DATA: WA_QALS TYPE QALS.',
    'DATA: LT_QAMV TYPE TABLE OF QAMV WITH HEADER LINE.',
    'SELECT * FROM LIPS INTO TABLE LT_LIPS',
    '  WHERE VBELN = \'0085006273\' AND CHARG <> \'\'.',
    'LOOP AT LT_LIPS.',
    '  SELECT SINGLE * FROM QALS INTO WA_QALS',
    '    WHERE CHARG = LT_LIPS-CHARG.',
    '  IF SY-SUBRC = 0.',
    '    WRITE: / LT_LIPS-CHARG, \'LOT:\', WA_QALS-PRUEFLOS.',
    '    SELECT * FROM QAMV INTO TABLE LT_QAMV',
    '      WHERE PRUEFLOS = WA_QALS-PRUEFLOS.',
    '    LOOP AT LT_QAMV.',
    '      WRITE: / LT_QAMV-VERWMERKM, LT_QAMV-KURZTEXT.',
    '    ENDLOOP.',
    '    EXIT.',
    '  ENDIF.',
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
