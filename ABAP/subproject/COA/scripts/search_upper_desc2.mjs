import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZSEARCH_UPPER_DESC2.',
    'DATA: LT_ZMAP TYPE TABLE OF ZMAP_COA WITH HEADER LINE.',
    'DATA: LV_C1 TYPE I, LV_C2 TYPE I.',
    'SELECT * FROM ZMAP_COA INTO TABLE LT_ZMAP',
    '  WHERE MIC_DESC LIKE \'%THICKNESS%\'.',
    'DESCRIBE TABLE LT_ZMAP LINES LV_C1.',
    'WRITE: / \'ZMAP_COA UPPER:\', LV_C1.',
    'DATA: LT_QPMT TYPE TABLE OF QPMT WITH HEADER LINE.',
    'SELECT * FROM QPMT INTO TABLE LT_QPMT UP TO 5 ROWS',
    '  WHERE KURZTEXT LIKE \'%THICKNESS%\'.',
    'DESCRIBE TABLE LT_QPMT LINES LV_C2.',
    'WRITE: / \'QPMT UPPER:\', LV_C2.'
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
