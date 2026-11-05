import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_LIVE_DATA_SRIA5I.',
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
    'DATA: LT_LIPS TYPE TABLE OF LIPS WITH HEADER LINE.',
    'SELECT * FROM LIPS INTO TABLE LT_LIPS',
    '  WHERE VBELN = \'0085006273\' AND MATNR = \'SRIA5I\'.',
    'LOOP AT LT_LIPS.',
    '  WRITE: / \'POSNR:\', LT_LIPS-POSNR, \'CHARG:\', LT_LIPS-CHARG.',
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
