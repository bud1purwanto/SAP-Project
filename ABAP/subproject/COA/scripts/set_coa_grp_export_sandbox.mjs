// Ganti kolom EXP-G / EXP-01 dan customer EXP-01 di sandbox-new sesuai gambar user (2026-11-11).
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
export const COLS = {
  'EXP-G': [['NO_PALET','No Palet','M'],['TYPE','Type','S'],['HU_NUMBER','HU Number','M'],['ROLL_NUMBER','Roll Number','L'],
            ['BATCH_NUMBER','Batch Number','M'],['WIDTH','Width','M'],['LENGTH','Length','M']],
  'EXP-01': [['NO_PALET','No Palet','M'],['TYPE','Type','S'],['ROLL_NUMBER','Roll Number','L'],['BATCH_NUMBER','Batch Number','M'],
            ['WIDTH','Width','M'],['LENGTH','Length','M'],['WEIGHT_PER_ROL','Weight per rol','M'],['JOINT','Joint','S'],
            ['NUMBER_OF_JOINT','Number of Joint (Splice)','S'],['TOTAL_ROLL','Total Rol','M'],['TOTAL_WEIGHT_PALET','Total Weight per palet','M']] };
// KUNNR PRD (KNA1 Production AIX 2026-11-11)
export const EXP01 = ['1141100299','1141100699','1141100394','1141100255','1141100239','1141100236','1141100264','1141100502',
  '1141100490','1141100695','1141100441','1141100208','1141100592','1141100551','1141100181','1800000005','1141100319',
  '1141100353','1600000053','1141100041','1141100081','1141100082','1141100083','1141100084','1141100603','1141100280',
  '1141100311','1141100588'];
if (process.argv[1].endsWith('set_coa_grp_export_sandbox.mjs')) {
  await serverManager.loadConfig(); await serverManager.setActiveServer('sandbox-new');
  const L = ['REPORT ZTMP_COA_GRP_EXP.',
    'DATA: LS_C TYPE ZMAP_COA_GRP_COL, LS_K TYPE ZMAP_COA_GRP_CST.',
    "DELETE FROM ZMAP_COA_GRP_COL WHERE COA_GRP = 'EXP-G'",
    "  OR COA_GRP = 'EXP-01'.",
    "DELETE FROM ZMAP_COA_GRP_CST WHERE COA_GRP = 'EXP-01'."];
  for (const [g, rows] of Object.entries(COLS)) rows.forEach(([f, l, z], i) => L.push('CLEAR LS_C.',
    `LS_C-COA_GRP = '${g}'. LS_C-FIELD_NAME = '${f}'.`, `LS_C-FIELD_LABEL = '${l}'.`,
    `LS_C-SEQ_NO = '${String(i + 1).padStart(2, '0')}'. LS_C-COL_SIZE = '${z}'.`,
    "LS_C-ACTIVE = 'X'. LS_C-AENAM = SY-UNAME.", 'LS_C-AEDAT = SY-DATUM. LS_C-AEZET = SY-UZEIT.',
    'INSERT ZMAP_COA_GRP_COL FROM LS_C.'));
  for (const k of EXP01) L.push('CLEAR LS_K.', `LS_K-KUNNR = '${k}'. LS_K-COA_GRP = 'EXP-01'.`,
    'LS_K-AENAM = SY-UNAME. LS_K-AEDAT = SY-DATUM.', 'LS_K-AEZET = SY-UZEIT.', 'MODIFY ZMAP_COA_GRP_CST FROM LS_K.');
  L.push('COMMIT WORK.', "SELECT COUNT(*) FROM ZMAP_COA_GRP_COL WHERE COA_GRP = 'EXP-G'.", "WRITE: / 'EXP-G', SY-DBCNT.",
    "SELECT COUNT(*) FROM ZMAP_COA_GRP_COL WHERE COA_GRP = 'EXP-01'.", "WRITE: / 'EXP-01 col', SY-DBCNT.",
    "SELECT COUNT(*) FROM ZMAP_COA_GRP_CST WHERE COA_GRP = 'EXP-01'.", "WRITE: / 'EXP-01 cust', SY-DBCNT.");
  for (const l of L) if (l.length > 72) throw new Error('Line too long: ' + l);
  const r = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: L.map(LINE => ({ LINE })) } });
  console.log((r.result?.WRITES || []).map(w => w.ZEILE.replace(/ +/g, ' ')).join(' | '), r.result?.ERRORMESSAGE || '');
  process.exit(0);
}
