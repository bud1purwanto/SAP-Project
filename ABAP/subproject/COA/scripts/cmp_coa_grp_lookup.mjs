// Bandingkan kolom Batch List lookup lama (ZQM_COA_CUST_COL) vs baru (group) per DO, read-only.
// Usage: node cmp_coa_grp_lookup.mjs [server]
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const srv = process.argv[2] || 'sandbox-new';
if (/prod/i.test(srv)) throw new Error('Not for production');
await serverManager.loadConfig(); await serverManager.setActiveServer(srv);
const L = `REPORT ZTMP_COA_GRP_CMP.
TYPES: BEGIN OF TY_D, VBELN TYPE LIKP-VBELN, KUNAG TYPE LIKP-KUNAG,
  KUNNR TYPE LIKP-KUNNR, LFART TYPE LIKP-LFART, END OF TY_D.
DATA: LT_D TYPE TABLE OF TY_D, LS_D TYPE TY_D, LT_U TYPE TABLE OF TY_D,
  LV_K TYPE KUNNR, LV_G TYPE ZMAP_COA_GRP_CST-COA_GRP,
  LT_O TYPE TABLE OF ZQM_COA_CUST_COL, LS_O TYPE ZQM_COA_CUST_COL,
  LT_N TYPE TABLE OF ZMAP_COA_GRP_COL, LS_N TYPE ZMAP_COA_GRP_COL,
  LV_SO TYPE STRING, LV_SN TYPE STRING, LV_SZ TYPE C LENGTH 1,
  LV_SAME TYPE I, LV_DIFF TYPE I.
SELECT VBELN KUNAG KUNNR LFART FROM LIKP INTO TABLE LT_D
  WHERE LFART = 'ZDLF' OR LFART = 'ZELF'.
SORT LT_D BY KUNAG LFART VBELN DESCENDING.
DELETE ADJACENT DUPLICATES FROM LT_D COMPARING KUNAG LFART.
LOOP AT LT_D INTO LS_D.
  LV_K = LS_D-KUNAG.
  IF LV_K IS INITIAL. LV_K = LS_D-KUNNR. ENDIF.
  SELECT * FROM ZQM_COA_CUST_COL INTO TABLE LT_O
    WHERE KUNNR = LV_K AND ACTIVE = 'X' ORDER BY SEQ_NO.
  IF LT_O IS INITIAL.
    IF LS_D-LFART = 'ZELF'. LV_K = 'EXPORT'.
    ELSE. LV_K = 'DOMESTIC'. ENDIF.
    SELECT * FROM ZQM_COA_CUST_COL INTO TABLE LT_O
      WHERE KUNNR = LV_K AND ACTIVE = 'X' ORDER BY SEQ_NO.
  ENDIF.
  LV_K = LS_D-KUNAG.
  IF LV_K IS INITIAL. LV_K = LS_D-KUNNR. ENDIF.
  CLEAR: LV_G, LT_N.
  SELECT SINGLE COA_GRP INTO LV_G FROM ZMAP_COA_GRP_CST
    WHERE KUNNR = LV_K.
  IF LV_G IS NOT INITIAL.
    SELECT * FROM ZMAP_COA_GRP_COL INTO TABLE LT_N
      WHERE COA_GRP = LV_G AND ACTIVE = 'X' ORDER BY SEQ_NO.
  ENDIF.
  IF LT_N IS INITIAL.
    IF LS_D-LFART = 'ZELF'. LV_G = 'EXP-G'.
    ELSE. LV_G = 'DOM-G'. ENDIF.
    SELECT * FROM ZMAP_COA_GRP_COL INTO TABLE LT_N
      WHERE COA_GRP = LV_G AND ACTIVE = 'X' ORDER BY SEQ_NO.
  ENDIF.
  CLEAR: LV_SO, LV_SN.
  LOOP AT LT_O INTO LS_O.
    LV_SZ = LS_O-COL_SIZE.
    CONCATENATE LV_SO LS_O-FIELD_NAME '/' LS_O-FIELD_LABEL '/'
      LV_SZ ';' INTO LV_SO.
  ENDLOOP.
  LOOP AT LT_N INTO LS_N.
    LV_SZ = LS_N-COL_SIZE.
    CONCATENATE LV_SN LS_N-FIELD_NAME '/' LS_N-FIELD_LABEL '/'
      LV_SZ ';' INTO LV_SN.
  ENDLOOP.
  IF LV_SO = LV_SN.
    LV_SAME = LV_SAME + 1.
  ELSE.
    LV_DIFF = LV_DIFF + 1.
    WRITE: / 'DIFF', LS_D-VBELN, LV_K, LS_D-LFART, LV_G.
  ENDIF.
ENDLOOP.
WRITE: / 'SAME', LV_SAME, 'DIFF', LV_DIFF.`.split('\n');
for (const l of L) if (l.length > 72) throw new Error('Line too long: ' + l);
const r = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: L.map(LINE => ({ LINE })) } });
console.log((r.result?.WRITES || []).map(w => w.ZEILE.replace(/ +/g, ' ')).join('\n'), r.result?.ERRORMESSAGE || '');
process.exit(0);
