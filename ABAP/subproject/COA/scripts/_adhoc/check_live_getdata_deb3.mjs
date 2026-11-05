import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_LIVE_GETDATA_DEB3.',
    'DATA: BEGIN OF IT_DATA OCCURS 0,',
    '        CHK TYPE C,',
    '        MIC LIKE QAMV-VERWMERKM,',
    '        MICDES LIKE QPMT-KURZTEXT,',
    '      END OF IT_DATA.',
    'DATA: BEGIN OF IT_DETAIL OCCURS 0,',
    '        CHK TYPE C,',
    '        MIC LIKE QAMV-VERWMERKM,',
    '        MICDES TYPE C LENGTH 60,',
    '      END OF IT_DETAIL.',
    'DATA: BEGIN OF IT_MIC1 OCCURS 0,',
    '        MIC LIKE QPMK-MKMNR,',
    '        MICDES LIKE QPMT-KURZTEXT,',
    '      END OF IT_MIC1.',
    'DATA: WA_DATA LIKE IT_DATA.',
    'DATA: LT_ZMAP TYPE TABLE OF ZMAP_COA WITH HEADER LINE.',
    'SELECT * FROM ZMAP_COA INTO TABLE LT_ZMAP',
    '  WHERE MATNR = \'SRIA5I\' AND DELETION NE \'X\'.',
    'DATA: LT_QALS TYPE TABLE OF QALS WITH HEADER LINE.',
    'SELECT * FROM QALS INTO TABLE LT_QALS UP TO 1 ROWS',
    '  WHERE MATNR = \'SRIA5I\'.',
    'READ TABLE LT_QALS INDEX 1.',
    'WRITE: / \'Sample QALS:\', LT_QALS-PRUEFLOS, LT_QALS-ART.',
    'DATA: LT_QAMV TYPE TABLE OF QAMV WITH HEADER LINE.',
    'SELECT * FROM QAMV INTO TABLE LT_QAMV',
    '  WHERE PRUEFLOS = LT_QALS-PRUEFLOS.',
    'LOOP AT LT_QAMV.',
    '  WRITE: / \'QAMV-VERWMERKM:\', LT_QAMV-VERWMERKM,',
    '         \'KURZTEXT:\', LT_QAMV-KURZTEXT.',
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
