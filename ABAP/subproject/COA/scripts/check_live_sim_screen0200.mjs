import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZCHECK_LIVE_SCREEN0200.',
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
    'DATA: BEGIN OF IT_DETAIL OCCURS 0,',
    '        CHK TYPE C,',
    '        MIC LIKE QAMV-VERWMERKM,',
    '        NUM(5),',
    '        NUMMIC TYPE I,',
    '        MICDES TYPE C LENGTH 60,',
    '        RANGE_FLAG TYPE C LENGTH 1,',
    '        UOM TYPE C LENGTH 30,',
    '        METHOD TYPE C LENGTH 52,',
    '        MICMIN TYPE C LENGTH 17,',
    '        MICMAX TYPE C LENGTH 17,',
    '        RAW_MICMIN TYPE F,',
    '        RAW_MICMAX TYPE F,',
    '        CMICMIT TYPE C LENGTH 17,',
    '        TYPE TYPE C,',
    '        PROBENR LIKE QASE-PROBENR,',
    '        VORGLFNR LIKE QAMV-VORGLFNR,',
    '        MESSWERT LIKE QASE-MESSWERT,',
    '      END OF IT_DETAIL.',
    'WRITE: / \'Ready\'.'
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
