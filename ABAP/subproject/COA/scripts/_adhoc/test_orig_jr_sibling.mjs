import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig();
await serverManager.setActiveServer('Development AIX');

const rawLines = [
  'REPORT ZTEST_ORIG_JR_SIBLING.',
  'TABLES: AUSP, MCH1, QALS.',
  'DATA: LV_LOT TYPE QALS-PRUEFLOS.',
  'PERFORM GET_JR_SIBLING_LOT USING \'0000406781\' CHANGING LV_LOT.',
  'WRITE: / \'Sibling of 406781:\', LV_LOT.',
  'PERFORM GET_JR_SIBLING_LOT USING \'0000406838\' CHANGING LV_LOT.',
  'WRITE: / \'Sibling of 406838:\', LV_LOT.',
  '',
  'FORM GET_JR_SIBLING_LOT USING P_BATCH TYPE CHARG_D',
  '                        CHANGING P_LOT TYPE QALS-PRUEFLOS.',
  '  DATA: LV_CUOBJ_BM TYPE MCH1-CUOBJ_BM,',
  '        LV_OBJEK TYPE AUSP-OBJEK,',
  '        LV_ROLL_STR TYPE AUSP-ATWRT,',
  '        ATINN_ROLL TYPE AUSP-ATINN.',
  '  DATA: BEGIN OF LT_PARTS OCCURS 0, PART(50) TYPE C, END OF LT_PARTS.',
  '  DATA: LV_PART(50) TYPE C, LV_PREFIX(50) TYPE C,',
  '        LV_SEQ_STR(10) TYPE C, LV_SEQ_NUM TYPE I, LV_LINES TYPE I,',
  '        LV_IDX TYPE I, LV_START TYPE I, LV_END TYPE I,',
  '        LV_SEQ_NEW_STR TYPE C LENGTH 3, LV_BATCH_NEW TYPE CHARG_D,',
  '        LV_ROLL_NEW TYPE AUSP-ATWRT.',
  '  DATA: BEGIN OF LT_LOTS OCCURS 0,',
  '          PRUEFLOS TYPE QALS-PRUEFLOS, CHARG TYPE QALS-CHARG,',
  '        END OF LT_LOTS.',
  '  CLEAR P_LOT.',
  '  IF P_BATCH IS INITIAL. RETURN. ENDIF.',
  '  CALL FUNCTION \'CONVERSION_EXIT_ATINN_INPUT\'',
  '    EXPORTING INPUT = \'ZZNOMORROLL\' IMPORTING OUTPUT = ATINN_ROLL.',
  '  SELECT SINGLE CUOBJ_BM INTO LV_CUOBJ_BM FROM MCH1 WHERE CHARG = P_BATCH.',
  '  IF SY-SUBRC <> 0 OR LV_CUOBJ_BM IS INITIAL. RETURN. ENDIF.',
  '  LV_OBJEK = LV_CUOBJ_BM.',
  '  SELECT SINGLE ATWRT INTO LV_ROLL_STR FROM AUSP',
  '    WHERE OBJEK = LV_OBJEK AND ATINN = ATINN_ROLL',
  '      AND KLART = \'023\' AND MAFID = \'O\'.',
  '  IF SY-SUBRC <> 0 OR LV_ROLL_STR IS INITIAL. RETURN. ENDIF.',
  '  SPLIT LV_ROLL_STR AT SPACE INTO TABLE LT_PARTS.',
  '  DESCRIBE TABLE LT_PARTS LINES LV_LINES.',
  '  IF LV_LINES >= 2.',
  '    READ TABLE LT_PARTS INDEX LV_LINES.',
  '    LV_SEQ_STR = LT_PARTS-PART.',
  '    LV_SEQ_NUM = LV_SEQ_STR.',
  '    LV_LINES = LV_LINES - 1.',
  '    CLEAR LV_PREFIX.',
  '    LOOP AT LT_PARTS TO LV_LINES.',
  '      IF LV_PREFIX IS INITIAL. LV_PREFIX = LT_PARTS-PART.',
  '      ELSE.',
  '        CONCATENATE LV_PREFIX LT_PARTS-PART INTO LV_PREFIX SEPARATED BY SPACE.',
  '      ENDIF.',
  '    ENDLOOP.',
  '    LV_START = 1. LV_END = 20.',
  '    LV_IDX = LV_START.',
  '    WHILE LV_IDX <= LV_END AND P_LOT IS INITIAL.',
  '      CLEAR: LV_ROLL_NEW, LV_SEQ_NEW_STR, LV_OBJEK, LV_CUOBJ_BM, LV_BATCH_NEW.',
  '      REFRESH LT_LOTS.',
  '      UNPACK LV_IDX TO LV_SEQ_NEW_STR.',
  '      CONCATENATE LV_PREFIX LV_SEQ_NEW_STR INTO LV_ROLL_NEW SEPARATED BY SPACE.',
  '      SELECT SINGLE OBJEK INTO LV_OBJEK FROM AUSP',
  '        WHERE ATINN = ATINN_ROLL AND ATWRT = LV_ROLL_NEW',
  '          AND KLART = \'023\' AND MAFID = \'O\'.',
  '      IF SY-SUBRC = 0 AND LV_OBJEK IS NOT INITIAL.',
  '        LV_CUOBJ_BM = LV_OBJEK.',
  '        SELECT SINGLE CHARG INTO LV_BATCH_NEW FROM MCH1',
  '          WHERE CUOBJ_BM = LV_CUOBJ_BM.',
  '        IF SY-SUBRC = 0 AND LV_BATCH_NEW IS NOT INITIAL.',
  '          SELECT PRUEFLOS CHARG INTO TABLE LT_LOTS FROM QALS',
  '            WHERE CHARG = LV_BATCH_NEW AND ( ART = \'Z02\' OR ART = \'Z03\' ).',
  '          IF SY-SUBRC = 0.',
  '            SORT LT_LOTS BY PRUEFLOS DESCENDING.',
  '            READ TABLE LT_LOTS INDEX 1.',
  '            IF SY-SUBRC = 0. P_LOT = LT_LOTS-PRUEFLOS. ENDIF.',
  '          ENDIF.',
  '        ENDIF.',
  '      ENDIF.',
  '      LV_IDX = LV_IDX + 1.',
  '    ENDWHILE.',
  '  ENDIF.',
  'ENDFORM.'
];

const formatted = [];
for (const l of rawLines) {
  if (l.length > 72) {
    const idx = l.lastIndexOf(' ', 70);
    formatted.push(l.slice(0, idx));
    formatted.push('  ' + l.slice(idx + 1));
  } else {
    formatted.push(l);
  }
}

const resp = await call_function({
  function_name: 'RFC_ABAP_INSTALL_AND_RUN',
  parameters: {
    PROGRAM: formatted.map(LINE => ({ LINE })),
    WRITES: []
  }
});
if (resp.result?.ERRORMESSAGE) console.error(resp.result.ERRORMESSAGE);
else console.log(resp.result?.WRITES?.map(w => w.ZEILE).join('\n'));
