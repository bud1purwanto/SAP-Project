import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_LIVE_GETDATA_DEB2.',
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
    'LOOP AT LT_ZMAP.',
    '  CLEAR IT_MIC1.',
    '  IT_MIC1-MIC = LT_ZMAP-MIC.',
    '  IT_MIC1-MICDES = LT_ZMAP-MIC_DESC.',
    '  APPEND IT_MIC1.',
    'ENDLOOP.',
    'LOOP AT IT_MIC1.',
    '  MOVE-CORRESPONDING IT_MIC1 TO WA_DATA.',
    '  APPEND WA_DATA TO IT_DATA.',
    'ENDLOOP.',
    'LOOP AT IT_DATA.',
    '  IT_DETAIL-MIC = IT_DATA-MIC.',
    '  IT_DETAIL-MICDES = IT_DATA-MICDES.',
    '  APPEND IT_DETAIL.',
    'ENDLOOP.',
    'DATA: LV_CNT TYPE I.',
    'DESCRIBE TABLE IT_DETAIL LINES LV_CNT.',
    'WRITE: / \'Lines IT_DETAIL:\', LV_CNT.',
    'LOOP AT IT_DETAIL.',
    '  WRITE: / IT_DETAIL-MIC, IT_DETAIL-MICDES.',
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
