import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_LIVE_MICDES.',
    'DATA: BEGIN OF IT_DATA OCCURS 0,',
    '        CHK TYPE C,',
    '        MIC LIKE QAMV-VERWMERKM,',
    '        MICDES LIKE QPMT-KURZTEXT,',
    '      END OF IT_DATA.',
    'DATA: BEGIN OF IT_ZMAP OCCURS 0,',
    '        MIC LIKE ZMAP_COA-MIC,',
    '        MIC_DESC LIKE ZMAP_COA-MIC_DESC,',
    '      END OF IT_ZMAP.',
    'SELECT MIC MIC_DESC FROM ZMAP_COA INTO TABLE IT_ZMAP',
    '  WHERE MATNR = \'SRIA5I\' AND DELETION NE \'X\'.',
    'LOOP AT IT_ZMAP.',
    '  DATA: LV_QAMV_KT LIKE QAMV-KURZTEXT.',
    '  SELECT SINGLE KURZTEXT INTO LV_QAMV_KT FROM QAMV',
    '    WHERE VERWMERKM = IT_ZMAP-MIC.',
    '  WRITE: / IT_ZMAP-MIC, \'ZMAP:\', IT_ZMAP-MIC_DESC,',
    '         \'QAMV:\', LV_QAMV_KT.',
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
