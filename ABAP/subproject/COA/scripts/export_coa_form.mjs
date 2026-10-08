import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
import { writeFileSync } from 'node:fs';

const formName = process.argv[2] || 'ZQMF_COA';
const serverRef = process.argv[3] || 'sandbox-new';
const outputTag = process.argv[4] || 'baseline';

const source = [
  'REPORT ZTMP_COA_XML_EXPORT.',
  'DATA: LV_XML TYPE XSTRING,',
  '      LV_B64 TYPE STRING,',
  '      LV_LEN TYPE I,',
  '      LV_OFF TYPE I,',
  '      LV_CHUNK TYPE I,',
  '      LV_PART TYPE STRING.',
  `CALL FUNCTION 'FB_CONVERT_FORM_TO_XML'`,
  `  EXPORTING I_FORMNAME = '${formName}'`,
  '  IMPORTING E_XML = LV_XML',
  '  EXCEPTIONS OTHERS = 6.',
  'IF SY-SUBRC <> 0.',
  "  WRITE: / 'ERROR_EXPORT', SY-SUBRC.",
  '  EXIT.',
  'ENDIF.',
  "CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'",
  '  EXPORTING INPUT = LV_XML',
  '  IMPORTING OUTPUT = LV_B64.',
  'LV_LEN = STRLEN( LV_B64 ).',
  'LV_OFF = 0.',
  'WHILE LV_OFF < LV_LEN.',
  '  LV_CHUNK = LV_LEN - LV_OFF.',
  '  IF LV_CHUNK > 84. LV_CHUNK = 84. ENDIF.',
  '  LV_PART = LV_B64+LV_OFF(LV_CHUNK).',
  '  WRITE: / LV_PART.',
  '  LV_OFF = LV_OFF + LV_CHUNK.',
  'ENDWHILE.'
];

if (source.some(line => line.length > 72)) {
  throw new Error('RFC_ABAP_INSTALL_AND_RUN line exceeds 72 chars');
}

await serverManager.loadConfig();
const server = await serverManager.setActiveServer(serverRef);
if (!server.connected) throw new Error(server.connect_error || 'SAP not connected');
const response = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: source.map(LINE => ({ LINE })),
    WRITES: []
  }
});
const result = response.result || {};
if (result.ERRORMESSAGE) throw new Error(result.ERRORMESSAGE);
const chunks = (result.WRITES || []).map(row => row.ZEILE?.trim() || '');
if (chunks.some(chunk => chunk.startsWith('ERROR_EXPORT'))) {
  throw new Error(chunks.find(chunk => chunk.startsWith('ERROR_EXPORT')));
}
const xml = Buffer.from(chunks.join(''), 'base64').toString('utf8');
if (!xml.includes('<sf:SMARTFORM') || !xml.includes('</sf:SMARTFORM>')) {
  throw new Error('Export XML incomplete');
}
const target = new URL(`../outputs/${formName}_${serverRef}_${outputTag}.xml`, import.meta.url);
writeFileSync(target, xml);
console.log(JSON.stringify({
  formName,
  serverRef,
  writesLength: result.WRITES?.length,
  bytes: Buffer.byteLength(xml),
  target: target.pathname
}));
