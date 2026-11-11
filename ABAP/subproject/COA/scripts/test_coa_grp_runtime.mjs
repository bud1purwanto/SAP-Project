// Panggil FORM di program ZQMI_COA (sandbox) untuk beberapa DO: GET_BATCH_COL_CFG + PREPARE_DYNAMIC_ROLL_COLUMNS.
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const dos = process.argv.slice(2);
await serverManager.loadConfig(); await serverManager.setActiveServer('sandbox-new');
const L = ['REPORT ZTMP_COA_GRP_RT.',
  'DATA: LT_CFG TYPE TABLE OF ZMAP_COA_GRP_COL,',
  '      LS_CFG TYPE ZMAP_COA_GRP_COL,',
  '      LV_V TYPE LIKP-VBELN, LV_V10 TYPE LIPS-VBELN, LV_S TYPE STRING,',
  '      LV_N TYPE I.',
  'FIELD-SYMBOLS: <CNT> TYPE ANY, <ROLL> TYPE ANY TABLE.'];
for (const d of dos) {
  L.push(`LV_V = '${d.padStart(10, '0')}'. LV_V10 = LV_V. CLEAR LV_S.`,
    "PERFORM GET_BATCH_COL_CFG IN PROGRAM ZQMI_COA",
    '  USING LV_V CHANGING LT_CFG.',
    'LOOP AT LT_CFG INTO LS_CFG.',
    "  CONCATENATE LV_S LS_CFG-COA_GRP(6) ':' LS_CFG-FIELD_NAME",
    "    INTO LV_S SEPARATED BY ' '.",
    'ENDLOOP.',
    "WRITE: / LV_V, 'CFG', LV_S.",
    "PERFORM PREPARE_DYNAMIC_ROLL_COLUMNS IN PROGRAM ZQMI_COA USING LV_V10.",
    "ASSIGN ('(ZQMI_COA)GV_BATCH_COL_COUNT') TO <CNT>.",
    "ASSIGN ('(ZQMI_COA)GT_DYN_ROLL[]') TO <ROLL>.",
    'IF <ROLL> IS ASSIGNED. LV_N = LINES( <ROLL> ). ENDIF.',
    "IF <CNT> IS ASSIGNED. WRITE: / LV_V, 'COLS', <CNT>, 'ROLLS', LV_N.",
    'ENDIF.');
}
for (const l of L) if (l.length > 72) throw new Error('Line too long: ' + l);
const r = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: L.map(LINE => ({ LINE })) } });
console.log((r.result?.WRITES || []).map(w => w.ZEILE.replace(/ +/g, ' ')).join('\n'), r.result?.ERRORMESSAGE || '');
process.exit(0);
