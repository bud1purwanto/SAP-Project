import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  const prog = [
    'REPORT ZDYNPRO_EXPORT_TEST.',
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
    'WRITE: / \'IMPORT RC:\', SY-SUBRC.',
    'LOOP AT D021S_TAB WHERE FNAM = \'IT_DATA-MICDES\'.',
    '  WRITE: / \'BEFORE:\', D021S_TAB-FNAM, D021S_TAB-FLG1.',
    '  \" D021S_TAB-FLG1: bit 0 is lower case (0x01)',
    '  \" Current FLG1 is 0x80. If lower case set, it becomes 0x81.',
    '  D021S_TAB-FLG1 = \'81\'.',
    '  MODIFY D021S_TAB.',
    'ENDLOOP.',
    'CALL FUNCTION \'RS_EXPORT_DYNPRO\'',
    '  EXPORTING',
    '    HEADER = D020S_REC',
    '  TABLES',
    '    FTAB   = D021S_TAB',
    '    PLTAB  = D022S_TAB',
    '  EXCEPTIONS',
    '    OTHERS = 1.',
    'WRITE: / \'EXPORT RC:\', SY-SUBRC.',
    'CALL FUNCTION \'RS_GENERATE_DYNPRO\'',
    '  EXPORTING',
    '    DYNAME = \'ZQMI_COA\'',
    '    DYNUMB = \'0100\'',
    '  EXCEPTIONS',
    '    OTHERS = 1.',
    'WRITE: / \'GENERATE RC:\', SY-SUBRC.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: prog.map(l => ({ LINE: l }))
    }
  });
  for (const row of res.result?.WRITES || []) {
    console.log(row.ZEILE);
  }
}
main().catch(console.error);
