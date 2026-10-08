import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
import { writeFile } from 'node:fs/promises';

const source = [
  'REPORT ZTMP_COA_EXPORT_SMOKE.',
  'DATA: LV_FM TYPE RS38L_FNAM,',
  '      LS_CTRL TYPE SSFCTRLOP,',
  '      LS_OUT TYPE SSFCOMPOP,',
  '      LS_JOB TYPE SSFCRESCL,',
  '      LT_PDF_LINES TYPE STANDARD TABLE OF TLINE,',
  '      LT_QAMV TYPE STANDARD TABLE OF QAMV,',
  '      LS_QAMV TYPE QAMV,',
  '      LT_ROLL TYPE STANDARD TABLE OF ZQMSAP,',
  '      LT_DYN TYPE STANDARD TABLE OF ZQM_COA_DYN_ROLL,',
  '      LV_PDF TYPE XSTRING,',
  '      LV_B64 TYPE STRING,',
  '      LV_PART TYPE C LENGTH 70,',
  '      LV_OFFSET TYPE I,',
  '      LV_TOTAL TYPE I,',
  '      LV_LINES TYPE I,',
  '      LV_RC TYPE SY-SUBRC.',
  "CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'",
  '  EXPORTING FORMNAME = \'ZQMF_COA_EXPORT\'',
  '  IMPORTING FM_NAME = LV_FM',
  '  EXCEPTIONS OTHERS = 1.',
  "WRITE: / 'FM_NAME_RC', SY-SUBRC, LV_FM.",
  'IF SY-SUBRC <> 0. EXIT. ENDIF.',
  "LS_CTRL-NO_DIALOG = 'X'.",
  "LS_CTRL-GETOTF = 'X'.",
  "LS_OUT-TDDEST = 'LOCL'.",
  'DO 10 TIMES.',
  '  CLEAR LS_QAMV.',
  "  LS_QAMV-KURZTEXT = 'TEST PROPERTY'.",
  '  APPEND LS_QAMV TO LT_QAMV.',
  'ENDDO.',
  'CALL FUNCTION LV_FM',
  '  EXPORTING',
  '    CONTROL_PARAMETERS = LS_CTRL',
  '    OUTPUT_OPTIONS = LS_OUT',
  "    USER_SETTINGS = ' '",
  "    CUSTOMER = 'TEST EXPORT CUSTOMER'",
  "    DELIVERY = 'PO-TEST-001'",
  "    PRODUCT = 'PI-TEST-001'",
  "    QUANTITY = 'TEST PRODUCT'",
  "    WIDTH = '120 ROLLS'",
  "    COMPANYTXT = 'TEST COMPANY'",
  "    H_LABEL1 = 'CUSTOMER NAME'",
  "    H_LABEL2 = 'PO NUMBER'",
  "    H_LABEL3 = 'PI NUMBER'",
  "    H_LABEL4 = 'PRODUCT'",
  "    H_LABEL5 = 'QUANTITY'",
  "    EXTRA_LABEL1 = 'Container Number'",
  "    EXTRA_LABEL2 = 'LC Number'",
  "    EXTRA_LABEL3 = 'Delivery Date'",
  "    EXTRA_LABEL4 = 'Thickness'",
  "    EXTRA_LABEL5 = 'Grammage'",
  "    EXTRA_LABEL6 = 'Raw Material Code'",
  "    EXTRA_LABEL7 = 'Width'",
  "    EXTRA_LABEL8 = 'Date Goods Shipped'",
  "    EXTRA_LABEL9 = '#Part'",
  "    EXTRA_LABEL10 = 'Manufacturer'",
  "    EXTRA_LABEL11 = 'Shelf Life'",
  "    EXTRA_VALUE1 = 'ABCD1234567'",
  "    EXTRA_VALUE2 = 'LC-TEST-001'",
  "    EXTRA_VALUE3 = '01/01/2029'",
  "    EXTRA_VALUE4 = '20'",
  "    EXTRA_VALUE5 = '30'",
  "    EXTRA_VALUE6 = 'ABC123'",
  "    EXTRA_VALUE7 = '800'",
  "    EXTRA_VALUE8 = '01/01/2029'",
  "    EXTRA_VALUE9 = '1234'",
  "    EXTRA_VALUE10 = 'TEST'",
  "    EXTRA_VALUE11 = '12 Months'",
  '  IMPORTING JOB_OUTPUT_INFO = LS_JOB',
  '  TABLES',
  '    IT_QAMV = LT_QAMV',
  '    IT_ROLL = LT_ROLL',
  '    GT_DYN_ROLL = LT_DYN',
  '  EXCEPTIONS OTHERS = 1.',
  'LV_RC = SY-SUBRC.',
  'DESCRIBE TABLE LS_JOB-OTFDATA LINES LV_LINES.',
  "WRITE: / 'FORM_RC', LV_RC.",
  "WRITE: / 'OTF_LINES', LV_LINES.",
  'IF LV_RC <> 0 OR LV_LINES = 0. EXIT. ENDIF.',
  "CALL FUNCTION 'CONVERT_OTF'",
  "  EXPORTING FORMAT = 'PDF'",
  '  IMPORTING BIN_FILE = LV_PDF',
  '  TABLES OTF = LS_JOB-OTFDATA LINES = LT_PDF_LINES',
  '  EXCEPTIONS OTHERS = 1.',
  "WRITE: / 'PDF_RC', SY-SUBRC.",
  'IF SY-SUBRC <> 0. EXIT. ENDIF.',
  "CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'",
  '  EXPORTING INPUT = LV_PDF',
  '  IMPORTING OUTPUT = LV_B64.',
  'LV_TOTAL = STRLEN( LV_B64 ).',
  "WRITE: / 'PDF_BASE64_BEGIN'.",
  'WHILE LV_OFFSET < LV_TOTAL.',
  '  IF LV_OFFSET + 70 <= LV_TOTAL.',
  '    LV_PART = LV_B64+LV_OFFSET(70).',
  '  ELSE.',
  '    LV_PART = LV_B64+LV_OFFSET.',
  '  ENDIF.',
  '  WRITE: / LV_PART.',
  '  ADD 70 TO LV_OFFSET.',
  'ENDWHILE.',
  "WRITE: / 'PDF_BASE64_END'."
];

if (process.argv.includes('--sparse')) {
  for (let number = 3; number <= 11; number++) {
    const index = source.findIndex(line => line.startsWith(`    EXTRA_LABEL${number} =`));
    if (index < 0) throw new Error(`Missing label ${number}`);
    source[index] = `    EXTRA_LABEL${number} = ' '`;
  }
}
if (source.some(line => line.length > 72)) throw new Error('Line > 72');
await serverManager.loadConfig();
const server = await serverManager.setActiveServer('sandbox-new');
if (!server.connected) throw new Error(server.connect_error || 'SAP not connected');
const response = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: { PROGRAM: source.map(LINE => ({ LINE })), WRITES: [] }
});
const writes = response.result?.WRITES?.map(row => row.ZEILE?.trimEnd() ?? '') ?? [];
const start = writes.indexOf('PDF_BASE64_BEGIN');
const end = writes.indexOf('PDF_BASE64_END');
if (start >= 0 && end > start) {
  const bytes = Buffer.from(writes.slice(start + 1, end).join(''), 'base64');
  const variant = process.argv.includes('--sparse') ? 'sparse' : 'full';
  const output = new URL(`../outputs/ZQMF_COA_EXPORT_${variant}_smoke.pdf`, import.meta.url);
  await writeFile(output, bytes);
  console.log(JSON.stringify({ status: writes.slice(0, start), pdfBytes: bytes.length, output: output.pathname }));
} else {
  console.log(JSON.stringify({ errorMessage: response.result?.ERRORMESSAGE, writes }));
}
