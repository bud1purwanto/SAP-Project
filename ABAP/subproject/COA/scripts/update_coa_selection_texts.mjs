import { readFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

const texts = [
  ['P_XCUS', 'Print Customer Name'], ['P_VCUS', 'Customer Name'],
  ['P_XPO', 'Print PO Number'], ['P_VPO', 'PO Number'],
  ['P_XPI', 'Print PI Number'], ['P_VPI', 'PI Number'],
  ['P_XPRD', 'Print Product'], ['P_VPRD', 'Product'],
  ['P_XQTY', 'Print Quantity'], ['P_VQTY', 'Quantity'],
  ['P_XCONT', 'Print Container Number'], ['P_VCONT', 'Container Number'],
  ['P_XDDAT', 'Print Delivery Date'], ['P_VDDAT', 'Delivery Date'],
  ['P_XTHK', 'Print Thickness'], ['P_VTHK', 'Thickness'],
  ['P_XGRM', 'Print Grammage'], ['P_VGRM', 'Grammage'],
  ['P_XRAW', 'Print Raw Material Code'], ['P_VRAW', 'Raw Material Code'],
  ['P_XLC', 'Print LC Number'], ['P_VLC', 'LC Number'],
  ['P_XWID', 'Print Width'], ['P_VWID', 'Width'],
  ['P_XSHP', 'Print Date Goods Shipped'],
  ['P_VSHP', 'Date Goods Shipped'],
  ['P_XPRT', 'Print #Part'], ['P_VPRT', '#Part'],
  ['P_XMFR', 'Print Manufacturer'], ['P_VMFR', 'Manufacturer'],
  ['P_XLIF', 'Print Shelf Life'], ['P_VLIF', 'Shelf Life']
];

const top = readFileSync(new URL('../src/ZQMI_COA_TOP_export_candidate.abap', import.meta.url), 'utf8');
if (texts.length !== 32 || new Set(texts.map(([key]) => key)).size !== 32) {
  throw new Error('Expected 32 unique popup parameter labels');
}
for (const [key, label] of texts) {
  if (!new RegExp(`\\bPARAMETERS ${key}\\b`).test(top)) throw new Error(`Missing ${key}`);
  if (label.length > 30) throw new Error(`Selection text too long: ${key}`);
}

const source = [
  'REPORT ZTMP_COA_SELECTION_TEXTS.',
  'TYPES: BEGIN OF TY_MAP,',
  '         SELKEY TYPE C LENGTH 8,',
  '         LABEL TYPE C LENGTH 30,',
  '       END OF TY_MAP.',
  'DATA: LT_TP TYPE STANDARD TABLE OF TEXTPOOL,',
  '      LT_CHECK TYPE STANDARD TABLE OF TEXTPOOL,',
  '      LT_MAP TYPE STANDARD TABLE OF TY_MAP,',
  '      LS_TP TYPE TEXTPOOL,',
  '      LS_MAP TYPE TY_MAP,',
  '      LV_INDEX TYPE SY-TABIX,',
  '      LV_BEFORE TYPE I,',
  '      LV_AFTER TYPE I,',
  '      LV_RC TYPE SY-SUBRC.'
];
for (const [key, label] of texts) {
  source.push(`LS_MAP-SELKEY = '${key}'.`);
  source.push(`LS_MAP-LABEL = '${label}'.`);
  source.push('APPEND LS_MAP TO LT_MAP.');
}
source.push(
  "READ TEXTPOOL 'ZQMI_COA' INTO LT_TP LANGUAGE 'E'.",
  'IF SY-SUBRC <> 0.',
  "  WRITE: / 'READ_FAILED', SY-SUBRC.",
  '  EXIT.',
  'ENDIF.',
  'READ TABLE LT_TP TRANSPORTING NO FIELDS',
  "  WITH KEY ID = 'S' KEY = 'P_ATWRT'.",
  'IF SY-SUBRC <> 0.',
  "  WRITE: / 'BASELINE_GUARD_FAILED'.",
  '  EXIT.',
  'ENDIF.',
  'DESCRIBE TABLE LT_TP LINES LV_BEFORE.',
  'LOOP AT LT_MAP INTO LS_MAP.',
  '  CLEAR LS_TP.',
  '  READ TABLE LT_TP INTO LS_TP',
  "    WITH KEY ID = 'S' KEY = LS_MAP-SELKEY.",
  '  IF SY-SUBRC = 0.',
  '    LV_INDEX = SY-TABIX.',
  '  ELSE.',
  '    CLEAR LS_TP.',
  '    LV_INDEX = 0.',
  '  ENDIF.',
  "  LS_TP-ID = 'S'.",
  '  LS_TP-KEY = LS_MAP-SELKEY.',
  '  CLEAR LS_TP-ENTRY.',
  '  LS_TP-ENTRY+8(30) = LS_MAP-LABEL.',
  '  LS_TP-LENGTH = 8 + STRLEN( LS_MAP-LABEL ).',
  '  IF LV_INDEX > 0.',
  '    MODIFY LT_TP FROM LS_TP INDEX LV_INDEX.',
  '  ELSE.',
  '    APPEND LS_TP TO LT_TP.',
  '  ENDIF.',
  'ENDLOOP.',
  'SORT LT_TP BY ID KEY.',
  "INSERT TEXTPOOL 'ZQMI_COA' FROM LT_TP LANGUAGE 'E'.",
  'LV_RC = SY-SUBRC.',
  'COMMIT WORK AND WAIT.',
  "WRITE: / 'INSERT_RC', LV_RC.",
  'IF LV_RC <> 0. EXIT. ENDIF.',
  "READ TEXTPOOL 'ZQMI_COA' INTO LT_CHECK LANGUAGE 'E'.",
  "WRITE: / 'READBACK_RC', SY-SUBRC.",
  'DESCRIBE TABLE LT_CHECK LINES LV_AFTER.',
  "WRITE: / 'COUNTS', LV_BEFORE, LV_AFTER.",
  'LOOP AT LT_MAP INTO LS_MAP.',
  '  READ TABLE LT_CHECK INTO LS_TP',
  "    WITH KEY ID = 'S' KEY = LS_MAP-SELKEY.",
  '  IF SY-SUBRC <> 0 OR',
  '     LS_TP-ENTRY+8(30) <> LS_MAP-LABEL.',
  "    WRITE: / 'VERIFY_FAILED', LS_MAP-SELKEY.",
  '  ENDIF.',
  'ENDLOOP.',
  "WRITE: / 'VERIFY_DONE'."
);
if (source.some(line => line.length > 72)) throw new Error('ABAP line exceeds 72 characters');

await serverManager.loadConfig();
const server = await serverManager.setActiveServer('sandbox-new');
if (!server.connected) throw new Error(server.connect_error || 'SAP not connected');
const response = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: { PROGRAM: source.map(LINE => ({ LINE })), WRITES: [] }
});
console.log(JSON.stringify({
  errorMessage: response.result?.ERRORMESSAGE,
  writes: response.result?.WRITES
}));
