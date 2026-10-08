import { readFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

const formName = process.argv[2];
const candidatePath = process.argv[3];
const mode = process.argv[4] === '--existing' ? 'MODIFY' : 'INSERT';
if (formName !== 'ZQMF_COA_EXPORT' || !candidatePath) {
  throw new Error('Only ZQMF_COA_EXPORT candidate upload is allowed');
}
const xml = readFileSync(candidatePath, 'utf8');
if (!xml.includes(`<FORMNAME>${formName}</FORMNAME>`)) {
  throw new Error('Candidate XML form name mismatch');
}
const base64 = Buffer.from(xml, 'utf8').toString('base64');
const source = [
  'REPORT ZTMP_COA_XML_UPLOAD.',
  'DATA: LT_B64 TYPE STANDARD TABLE OF STRING,',
  '      LV_PART TYPE STRING,',
  '      LV_B64 TYPE STRING,',
  '      LV_XML TYPE XSTRING,',
  '      LV_RC TYPE I,',
  '      LV_GEN_RC TYPE I,',
  '      LV_ERROR_TEXT TYPE STRING,',
  '      LV_FM TYPE RS38L_FNAM,',
  '      LO_IXML TYPE REF TO IF_IXML,',
  '      LO_FACTORY TYPE REF TO IF_IXML_STREAM_FACTORY,',
  '      LO_STREAM TYPE REF TO IF_IXML_ISTREAM,',
  '      LO_PARSER TYPE REF TO IF_IXML_PARSER,',
  '      LO_DOC TYPE REF TO IF_IXML_DOCUMENT,',
  '      LO_CURRENT TYPE REF TO CL_SSF_FB_SMART_FORM,',
  '      LO_UPLOAD TYPE REF TO CL_SSF_FB_SMART_FORM,',
  '      LO_ERROR TYPE REF TO CX_ROOT.'
];
for (let offset = 0; offset < base64.length; offset += 50) {
  source.push(`APPEND '${base64.slice(offset, offset + 50)}' TO LT_B64.`);
}
source.push(
  'LOOP AT LT_B64 INTO LV_PART.',
  '  CONCATENATE LV_B64 LV_PART INTO LV_B64.',
  'ENDLOOP.',
  "CALL FUNCTION 'SCMS_BASE64_DECODE_STR'",
  '  EXPORTING INPUT = LV_B64',
  '  IMPORTING OUTPUT = LV_XML.',
  'LO_IXML = CL_IXML=>CREATE( ).',
  'LO_FACTORY = LO_IXML->CREATE_STREAM_FACTORY( ).',
  'LO_STREAM = LO_FACTORY->CREATE_ISTREAM_XSTRING( LV_XML ).',
  'LO_DOC = LO_IXML->CREATE_DOCUMENT( ).',
  'LO_PARSER = LO_IXML->CREATE_PARSER(',
  '  STREAM_FACTORY = LO_FACTORY',
  '  ISTREAM = LO_STREAM DOCUMENT = LO_DOC ).',
  'LV_RC = LO_PARSER->PARSE( ).',
  'IF LV_RC <> 0.',
  "  WRITE: / 'XML_PARSE_ERROR', LV_RC.",
  '  EXIT.',
  'ENDIF.',
  'CREATE OBJECT LO_CURRENT.',
  'CREATE OBJECT LO_UPLOAD.',
  'TRY.',
  '  CALL METHOD LO_CURRENT->ENQUEUE',
  '    EXPORTING',
  "      AUTHORITY_CHECK = 'X'",
  "      SUPPRESS_CORR_CHECK = 'X'",
  "      SUPPRESS_LANGUAGE_CHECK = 'X'",
  "      LANGUAGE_UPD_EXIT = ' '",
  `      MODE = '${mode}'`,
  `      FORMNAME = '${formName}'.`,
  '  CALL METHOD LO_CURRENT->LOAD',
  '    EXPORTING',
  "      IM_ACTIVE = 'X'",
  "      IM_FORMNAME = 'ZQMF_COA'",
  '      IM_LANGUAGE = SY-LANGU.',
  '  CALL METHOD LO_UPLOAD->XML_UPLOAD',
  '    EXPORTING',
  '      DOM = LO_DOC->GET_ROOT_ELEMENT( )',
  `      FORMNAME = '${formName}'`,
  '      LANGUAGE = SY-LANGU',
  '    CHANGING SFORM = LO_CURRENT.',
  '  CALL METHOD LO_UPLOAD->STORE',
  '    EXPORTING',
  "      IM_ACTIVE = 'X'",
  `      IM_FORMNAME = '${formName}'`,
  '      IM_LANGUAGE = SY-LANGU.',
  '  COMMIT WORK AND WAIT.',
  "  WRITE: / 'STORE_OK'.",
  '  CALL METHOD LO_CURRENT->DEQUEUE',
  `    EXPORTING FORMNAME = '${formName}'.`,
  'CATCH CX_ROOT INTO LO_ERROR.',
  '  LV_ERROR_TEXT = LO_ERROR->GET_TEXT( ).',
  "  WRITE: / 'UPLOAD_ERROR', LV_ERROR_TEXT.",
  '  EXIT.',
  'ENDTRY.',
  "CALL FUNCTION 'FB_GENERATE_FORM'",
  `  EXPORTING I_FORMNAME = '${formName}'`,
  '  EXCEPTIONS OTHERS = 5.',
  'LV_GEN_RC = SY-SUBRC.',
  "WRITE: / 'GENERATE_RC', LV_GEN_RC.",
  "CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'",
  `  EXPORTING FORMNAME = '${formName}'`,
  '  IMPORTING FM_NAME = LV_FM',
  '  EXCEPTIONS OTHERS = 3.',
  "WRITE: / 'FM_RC', SY-SUBRC, LV_FM."
);
if (process.argv[4] === '--dry-xml') {
  const storeIndex = source.indexOf('  CALL METHOD LO_UPLOAD->STORE');
  source.splice(storeIndex, 0,
    "  WRITE: / 'XML_UPLOAD_OK'.",
    '  CALL METHOD LO_CURRENT->DEQUEUE',
    `    EXPORTING FORMNAME = '${formName}'.`,
    '  EXIT.'
  );
}
if (source.some(line => line.length > 72)) {
  throw new Error('RFC_ABAP_INSTALL_AND_RUN line exceeds 72 chars');
}
await serverManager.loadConfig();
const server = await serverManager.setActiveServer('sandbox-new');
if (!server.connected) throw new Error(server.connect_error || 'SAP not connected');
const response = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: { PROGRAM: source.map(LINE => ({ LINE })), WRITES: [] }
});
const result = response.result || {};
console.log(JSON.stringify({
  formName,
  sourceLines: source.length,
  errorMessage: result.ERRORMESSAGE,
  writes: result.WRITES?.slice(0, 20)
}));
