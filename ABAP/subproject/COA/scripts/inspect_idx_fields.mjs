import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('Development AIX');
  
  const prog = [
    'REPORT ZDYNPRO_INSPECT.',
    'DATA: D020S_REC TYPE D020S,',
    '      D021S_TAB TYPE TABLE OF D021S WITH HEADER LINE,',
    '      D022S_TAB TYPE TABLE OF D022S WITH HEADER LINE.',
    'CALL FUNCTION \'RS_IMPORT_DYNPRO\'',
    '  EXPORTING',
    '    DYNAME = \'ZQMI_COA\'',
    '    DYNUMB = \'0100\'',
    '  IMPORTING',
    '    HEADER = D020S_REC',
    '  TABLES',
    '    FTAB   = D021S_TAB',
    '    PLTAB  = D022S_TAB',
    '  EXCEPTIONS',
    '    OTHERS = 1.',
    'READ TABLE D021S_TAB INDEX 20.',
    'IF SY-SUBRC = 0.',
    '  WRITE: / \'IDX 20 FNAM:\', D021S_TAB-FNAM.',
    '  WRITE: / \'IDX 20 LENG:\', D021S_TAB-LENG.',
    '  WRITE: / \'IDX 20 DIDX:\', D021S_TAB-DIDX.',
    '  WRITE: / \'IDX 20 FLG1:\', D021S_TAB-FLG1.',
    '  WRITE: / \'IDX 20 FLG2:\', D021S_TAB-FLG2.',
    '  WRITE: / \'IDX 20 FLG3:\', D021S_TAB-FLG3.',
    'ENDIF.',
    'READ TABLE D021S_TAB INDEX 22.',
    'IF SY-SUBRC = 0.',
    '  WRITE: / \'IDX 22 FNAM:\', D021S_TAB-FNAM.',
    '  WRITE: / \'IDX 22 LENG:\', D021S_TAB-LENG.',
    '  WRITE: / \'IDX 22 DIDX:\', D021S_TAB-DIDX.',
    '  WRITE: / \'IDX 22 FLG1:\', D021S_TAB-FLG1.',
    '  WRITE: / \'IDX 22 FLG2:\', D021S_TAB-FLG2.',
    '  WRITE: / \'IDX 22 FLG3:\', D021S_TAB-FLG3.',
    'ENDIF.'
  ];

  for (const l of prog) {
    if (l.length > 72) throw new Error('Line > 72: ' + l);
  }

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: prog.map(l => ({ LINE: l }))
    }
  });
  console.log('Result:', JSON.stringify(res.result?.WRITES || res));
}
main().catch(console.error);
