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

console.log('2. Reading local ABAP source code...');
const abapPath = path.resolve('subproject/BARRIER/src/ZQMI_PENDING_BARRIER.abap');
const code = fs.readFileSync(abapPath, 'utf8');
const lines = code.split(/\r?\n/).map((line) => ({ LINE: line }));

console.log(`Read ${lines.length} lines. Calling Z_RFC_PROGRAM_UPDATE...`);
const res = await callFunction({
  function_name: 'Z_RFC_PROGRAM_UPDATE',
  parameters: {
    IV_PROGRAM_NAME: 'ZQMI_PENDING_BARRIER',
    IV_PACKAGE: '$TMP',
    IV_CORRNUMBER: ' ',
    IT_SOURCE: lines
  }
});

console.log('Update result:', JSON.stringify(res, null, 2));

console.log('3. Performing Syntax Check on TRS...');
const syntaxRes = await callFunction({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    MODE: 'F',
    PROGRAM: [
      { LINE: 'REPORT ZTMP_SYNTAX_CHECK.' },
      { LINE: 'DATA: mess TYPE string, lin TYPE i, wrd TYPE string.' },
      { LINE: "SYNTAX-CHECK FOR PROGRAM 'ZQMI_PENDING_BARRIER'" },
      { LINE: '  MESSAGE mess LINE lin WORD wrd.' },
      { LINE: 'IF mess IS INITIAL.' },
      { LINE: "  WRITE: / 'SYNTAX_STATUS: OK'." },
      { LINE: 'ELSE.' },
      { LINE: "  WRITE: / 'SYNTAX_STATUS: ERROR', mess, 'LINE:', lin." },
      { LINE: 'ENDIF.' }
    ]
  }
});

console.log('Syntax Check Output:', JSON.stringify(syntaxRes.result?.WRITES, null, 2));
