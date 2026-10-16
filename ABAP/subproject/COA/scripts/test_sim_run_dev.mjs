import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZSIM_RUN_COA_DEV.',
  'TABLES: LIKP, LIPS, MSEG, MCH1, QALS, QAMV, QAMR, ZMAP_COA, AFPO.',
  'DATA: BEGIN OF IT_DATA OCCURS 0,',
  '        VBELN LIKE LIKP-VBELN, POSNR LIKE LIPS-POSNR, CHARG LIKE LIPS-CHARG,',
  '        MATNR LIKE LIPS-MATNR, WERKS LIKE LIPS-WERKS, NOMSR TYPE C LENGTH 50,',
  '        UECHA LIKE LIPS-UECHA, CHK TYPE C LENGTH 1,',
  '      END OF IT_DATA.',
  'DATA: BEGIN OF IT_LOT OCCURS 0,',
  '        VBELN LIKE LIKP-VBELN, POSNR LIKE LIPS-POSNR, CHARG LIKE LIPS-CHARG,',
  '        MATNR LIKE LIPS-MATNR, WERKS LIKE LIPS-WERKS, NOMSR TYPE C LENGTH 50,',
  '        UECHA LIKE LIPS-UECHA, CHK TYPE C LENGTH 1,',
  '      END OF IT_LOT.',
  'DATA: BEGIN OF IT_MIC1 OCCURS 0,',
  '        VBELN LIKE LIKP-VBELN, POSNR LIKE LIPS-POSNR, CHARG LIKE LIPS-CHARG,',
  '        MIC LIKE ZMAP_COA-MIC, MICDES TYPE C LENGTH 40, UOM TYPE C LENGTH 10,',
  '        CMICMIT TYPE C LENGTH 20, INSLOT LIKE QALS-PRUEFLOS, MERKNR LIKE QAMV-MERKNR,',
  '        MICMIT TYPE QAMR-MITTELWERT, VORGLFNR LIKE QAMR-VORGLFNR,',
  '        METHOD LIKE ZMAP_COA-METHOD,',
  '      END OF IT_MIC1.',
  'START-OF-SELECTION.',
  '  \" Ambil 10 roll dari DO 85006278',
  '  SELECT VBELN POSNR CHARG MATNR WERKS FROM LIPS',
  '    INTO CORRESPONDING FIELDS OF TABLE IT_DATA',
  '    WHERE VBELN = \'0085006278\' AND CHARG <> space.',
  '  WRITE: / \'Lines in LIPS:\', SY-DBCNT.',
  '  LOOP AT IT_DATA.',
  '    SELECT SINGLE LICHA INTO IT_DATA-NOMSR FROM MCH1 WHERE CHARG = IT_DATA-CHARG.',
  '    MODIFY IT_DATA.',
  '  ENDLOOP.',
  '  WRITE: / \'Setup completed, testing live ZQMI_COA components...\'.'
];

function wrapLines(lines) {
  const out = [];
  for (const raw of lines) {
    if (raw.length <= 70) {
      out.push(raw);
    } else {
      let cur = raw;
      while (cur.length > 70) {
        let idx = cur.lastIndexOf(' ', 70);
        if (idx === -1) idx = 70;
        out.push(cur.slice(0, idx));
        cur = '  ' + cur.slice(idx).trimStart();
      }
      if (cur.length > 0) out.push(cur);
    }
  }
  return out.map(LINE => ({ LINE }));
}

const resp = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: wrapLines(rawLines),
    WRITES: []
  }
});

console.log(resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
