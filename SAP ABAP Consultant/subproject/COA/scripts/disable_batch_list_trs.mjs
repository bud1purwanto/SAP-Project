import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const userProfile = process.env.USERPROFILE || 'C:\\Users\\User';
const registryPath = path.join(
  userProfile,
  'Documents',
  'Claude',
  'MCP SAP',
  'sap-leader-mcp',
  'src',
  'tool-registry.js'
);

const registry = await import(pathToFileURL(registryPath).href);
const setActiveServer = registry.HANDLERS['set_active_server'];
const callFunction = registry.HANDLERS['call_function'];

console.log('1. Setting active server to sandbox-new (TRS)...');
const srvRes = await setActiveServer({ server_ref: 'sandbox-new' });
console.log('Server response:', srvRes.mode, srvRes.active_server, srvRes.sid);

if (!srvRes.connected && !srvRes.success) {
  console.error('Failed to connect to sandbox-new');
  process.exit(1);
}

console.log('2. Reading live ZQMI_COA_F01 source from TRS...');
const readRes = await callFunction({
  function_name: 'RPY_PROGRAM_READ',
  parameters: {
    PROGRAM_NAME: 'ZQMI_COA_F01'
  }
});

let liveLines = [];
if (readRes && readRes.SOURCE_EXTENDED) {
  liveLines = readRes.SOURCE_EXTENDED.map(item => item.LINE);
} else if (readRes && readRes.SOURCE) {
  liveLines = readRes.SOURCE.map(item => item.LINE);
} else {
  console.log('RPY_PROGRAM_READ result keys:', Object.keys(readRes || {}));
  const localSrc = fs.readFileSync('subproject/COA/outputs/fetch_trs_latest/ZQMI_COA_F01.abap', 'utf8');
  liveLines = localSrc.split(/\r?\n/);
}

console.log(`Live lines read: ${liveLines.length}`);

// Backup current live source
fs.writeFileSync(
  'subproject/COA/outputs/backup_ZQMI_COA_F01_before_disable.abap',
  liveLines.join('\n'),
  'utf8'
);
console.log('Saved backup to subproject/COA/outputs/backup_ZQMI_COA_F01_before_disable.abap');

const fullSource = liveLines.join('\n');

// Block 1: Smartform module name lookup for batch list
const target1 = `  CLEAR LV_BATCH_FM.
  IF GV_BATCH_FORM IS NOT INITIAL AND GT_DYN_ROLL[] IS NOT INITIAL.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME           = GV_BATCH_FORM
      IMPORTING
        FM_NAME            = LV_BATCH_FM
      EXCEPTIONS
        NO_FORM            = 1
        NO_FUNCTION_MODULE = 2
        OTHERS             = 3.
    IF SY-SUBRC <> 0 OR LV_BATCH_FM IS INITIAL.
      MESSAGE 'Smartform Lampiran Batch List belum aktif' TYPE 'E'.
      EXIT.
    ENDIF.
  ENDIF.`;

const replacement1 = `  CLEAR LV_BATCH_FM.
*--------------------- DISABLED for BATCH LIST ------------------------*
* IF GV_BATCH_FORM IS NOT INITIAL AND GT_DYN_ROLL[] IS NOT INITIAL.
*   CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*     EXPORTING
*       FORMNAME           = GV_BATCH_FORM
*     IMPORTING
*       FM_NAME            = LV_BATCH_FM
*     EXCEPTIONS
*       NO_FORM            = 1
*       NO_FUNCTION_MODULE = 2
*       OTHERS             = 3.
*   IF SY-SUBRC <> 0 OR LV_BATCH_FM IS INITIAL.
*     MESSAGE 'Smartform Lampiran Batch List belum aktif' TYPE 'E'.
*     EXIT.
*   ENDIF.
* ENDIF.
*----------------------------------------------------------------------*`;

// Block 2: Calling batch list Smartform
const target2 = `  " 2. Cetak Halaman 2: Lampiran Batch List (ZQMF_COA_BATCH_POTRAIT / ZQMF_COA_BATCH_LANDSCAPE)
  IF LV_BATCH_FM IS NOT INITIAL AND GT_DYN_ROLL[] IS NOT INITIAL.
    CALL FUNCTION LV_BATCH_FM
      EXPORTING
        CONTROL_PARAMETERS = I_SSFCTRLOP
        OUTPUT_OPTIONS      = I_SSFCOMPOP
        USER_SETTINGS       = ' '
        CUSTOMER            = NAME1
        DELIVERY            = VBELN
        PRODUCT             = PRODUCT
        QUANTITY            = QUANTITY
        WIDTH               = WIDTH
        COMPANYTXT          = COMPANYTXT
        GS_DYN_HDR          = GS_DYN_HDR
      TABLES
        IT_QAMV             = IT_QAMV
        IT_ROLL             = IT_ROLL
        GT_DYN_ROLL         = GT_DYN_ROLL
      EXCEPTIONS
        FORMATTING_ERROR    = 1
        INTERNAL_ERROR      = 2
        SEND_ERROR          = 3
        USER_CANCELED       = 4
        OTHERS              = 5.
    IF SY-SUBRC <> 0.
      CALL FUNCTION 'SSF_CLOSE'.
      MESSAGE 'Gagal mencetak lampiran Batch List' TYPE 'E'.
      EXIT.
    ENDIF.
  ENDIF.`;

const replacement2 = `*--------------------- DISABLED for BATCH LIST ------------------------*
* " 2. Cetak Halaman 2: Lampiran Batch List (ZQMF_COA_BATCH_POTRAIT / ZQMF_COA_BATCH_LANDSCAPE)
* IF LV_BATCH_FM IS NOT INITIAL AND GT_DYN_ROLL[] IS NOT INITIAL.
*   CALL FUNCTION LV_BATCH_FM
*     EXPORTING
*       CONTROL_PARAMETERS = I_SSFCTRLOP
*       OUTPUT_OPTIONS      = I_SSFCOMPOP
*       USER_SETTINGS       = ' '
*       CUSTOMER            = NAME1
*       DELIVERY            = VBELN
*       PRODUCT             = PRODUCT
*       QUANTITY            = QUANTITY
*       WIDTH               = WIDTH
*       COMPANYTXT          = COMPANYTXT
*       GS_DYN_HDR          = GS_DYN_HDR
*     TABLES
*       IT_QAMV             = IT_QAMV
*       IT_ROLL             = IT_ROLL
*       GT_DYN_ROLL         = GT_DYN_ROLL
*     EXCEPTIONS
*       FORMATTING_ERROR    = 1
*       INTERNAL_ERROR      = 2
*       SEND_ERROR          = 3
*       USER_CANCELED       = 4
*       OTHERS              = 5.
*   IF SY-SUBRC <> 0.
*     CALL FUNCTION 'SSF_CLOSE'.
*     MESSAGE 'Gagal mencetak lampiran Batch List' TYPE 'E'.
*     EXIT.
*   ENDIF.
* ENDIF.
*----------------------------------------------------------------------*`;

// Normalize \r\n to \n for matching
const normSource = fullSource.replace(/\r\n/g, '\n');
const normTarget1 = target1.replace(/\r\n/g, '\n');
const normTarget2 = target2.replace(/\r\n/g, '\n');

if (!normSource.includes(normTarget1)) {
  console.error('Target 1 not found in live source!');
  process.exit(1);
}
console.log('Target 1 found successfully.');

if (!normSource.includes(normTarget2)) {
  console.error('Target 2 not found in live source!');
  process.exit(1);
}
console.log('Target 2 found successfully.');

const patchedSource = normSource
  .replace(normTarget1, replacement1)
  .replace(normTarget2, replacement2);

fs.writeFileSync(
  'subproject/COA/outputs/patched_ZQMI_COA_F01_TRS.abap',
  patchedSource,
  'utf8'
);
console.log('Patched source saved to subproject/COA/outputs/patched_ZQMI_COA_F01_TRS.abap');

const patchedLines = patchedSource.split('\n').map(line => ({ LINE: line }));

console.log(`3. Updating ZQMI_COA_F01 on TRS via Z_RFC_PROGRAM_UPDATE (${patchedLines.length} lines)...`);
const updateRes = await callFunction({
  function_name: 'Z_RFC_PROGRAM_UPDATE',
  parameters: {
    IV_PROGRAM_NAME: 'ZQMI_COA_F01',
    IV_PACKAGE: '$TMP',
    IV_CORRNUMBER: ' ',
    IT_SOURCE: patchedLines
  }
});

console.log('Update result:', JSON.stringify(updateRes, null, 2));

console.log('4. Performing Syntax Check on main program ZQMI_COA...');
const syntaxRes = await callFunction({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    MODE: 'F',
    PROGRAM: [
      { LINE: 'REPORT ZTMP_SYNTAX_CHECK.' },
      { LINE: 'DATA: mess TYPE string, lin TYPE i, wrd TYPE string.' },
      { LINE: "SYNTAX-CHECK FOR PROGRAM 'ZQMI_COA'" },
      { LINE: '  MESSAGE mess LINE lin WORD wrd.' },
      { LINE: 'IF mess IS INITIAL.' },
      { LINE: "  WRITE: / 'SYNTAX_STATUS: OK'." },
      { LINE: 'ELSE.' },
      { LINE: "  WRITE: / 'SYNTAX_STATUS: ERROR', mess, 'LINE:', lin." },
      { LINE: 'ENDIF.' }
    ]
  }
});

console.log('Syntax check response:');
if (syntaxRes && syntaxRes.P_OUTPUT) {
  syntaxRes.P_OUTPUT.forEach(o => console.log('  ', o.LINE));
} else {
  console.log(JSON.stringify(syntaxRes, null, 2));
}
