import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_LIVE_GETDATA_ALL.',
    'DATA: BEGIN OF IT_DATA OCCURS 0,',
    '        CHK TYPE C,',
    '        VBELN LIKE LIPS-VBELN,',
    '        POSNR LIKE LIPS-POSNR,',
    '        CHARG LIKE LIPS-CHARG,',
    '        MATNR LIKE LIPS-MATNR,',
    '        WERKS LIKE LIPS-WERKS,',
    '        UECHA LIKE LIPS-UECHA,',
    '        NOMSR TYPE C LENGTH 30,',
    '        ZZTYPE TYPE C LENGTH 30,',
    '        ZZWIDTH TYPE ZQMSAP-ZZWIDTH,',
    '        ZZLENGTH TYPE ZQMSAP-ZZLENGTH,',
    '        MIC LIKE QAMV-VERWMERKM,',
    '        MICDES LIKE QPMT-KURZTEXT,',
    '        RANGE_FLAG TYPE C LENGTH 1,',
    '        UOM TYPE C LENGTH 30,',
    '        METHOD TYPE C LENGTH 43,',
    '        MICMIN TYPE C LENGTH 17,',
    '        MICMAX TYPE C LENGTH 17,',
    '        RAW_MICMIN TYPE F,',
    '        RAW_MICMAX TYPE F,',
    '        MICMIT LIKE QAMR-MITTELWERT,',
    '        CMICMIT TYPE C LENGTH 17,',
    '        STELLEN TYPE QAMV-STELLEN,',
    '        NUMMIC TYPE I,',
    '        NUM(5),',
    '        TYPE TYPE C,',
    '        INSLOT LIKE QALS-PRUEFLOS,',
    '        BARRIER_TYPE TYPE C LENGTH 4,',
    '        PROBENR LIKE QASE-PROBENR,',
    '        VORGLFNR LIKE QAMV-VORGLFNR,',
    '        MESSWERT LIKE QASE-MESSWERT,',
    '        SAVED_CMICMIT TYPE C LENGTH 17,',
    '        ORIG_CMICMIT TYPE C LENGTH 17,',
    '      END OF IT_DATA.',
    'DATA: BEGIN OF IT_MIC OCCURS 0,',
    '        VBELN LIKE LIPS-VBELN,',
    '        POSNR LIKE LIPS-POSNR,',
    '        CHARG LIKE LIPS-CHARG,',
    '        NOMSR TYPE C LENGTH 30,',
    '        NOREF(10),',
    '        ZZTYPE(10),',
    '        MATNR LIKE LIPS-MATNR,',
    '        UECHA LIKE LIPS-UECHA,',
    '        WERKS LIKE LIPS-WERKS,',
    '        MIC LIKE QPMK-MKMNR,',
    '        MICDES LIKE QPMT-KURZTEXT,',
    '        UOM LIKE ZMAP_COA-UOM,',
    '        METHOD(40),',
    '        MICMIN LIKE QPMK-TOLERANZUN,',
    '        MICMAX LIKE QPMK-TOLERANZOB,',
    '        CMICMIT(20),',
    '        MICMIT LIKE QAMR-MITTELWERT,',
    '        STELLEN TYPE QAMV-STELLEN,',
    '        INSLOT LIKE QALS-PRUEFLOS,',
    '        MERKNR LIKE QAMV-MERKNR,',
    '        SEQ(1),',
    '        BARRIER_TYPE TYPE C LENGTH 4,',
    '        PROBENR LIKE QASE-PROBENR,',
    '        VORGLFNR LIKE QAMV-VORGLFNR,',
    '      END OF IT_MIC.',
    'DATA: LT_ZMAP TYPE TABLE OF ZMAP_COA WITH HEADER LINE.',
    'SELECT * FROM ZMAP_COA INTO TABLE LT_ZMAP',
    '  WHERE MATNR = \'SRIA5I\' AND DELETION NE \'X\'.',
    'LOOP AT LT_ZMAP.',
    '  WRITE: / LT_ZMAP-MIC, \'MIC_DESC:\', LT_ZMAP-MIC_DESC.',
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
