// Create ZMAP_COA_GRP_COL and ZMAP_COA_GRP_CST ($TMP) via RFC_ABAP_INSTALL_AND_RUN
// Usage: node create_coa_grp_tables.mjs [server]   (default sandbox-new)
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
const srv = process.argv[2] || 'sandbox-new';
if (/prod/i.test(srv)) throw new Error('Not for production');

const tables = [
  { name: 'ZMAP_COA_GRP_COL', text: 'COA Batch List: Kolom per Group', fields: [
    ['MANDT','X','MANDT','',0,'Client'],
    ['COA_GRP','X','','CHAR',20,'COA Group'],
    ['FIELD_NAME','X','','CHAR',30,'Field Name'],
    ['FIELD_LABEL','','','CHAR',40,'Label di Batch List'],
    ['SEQ_NO','','','NUMC',2,'Urutan'],
    ['COL_SIZE','','','CHAR',1,'Ukuran Kolom S/M/L'],
    ['ACTIVE','','','CHAR',1,'Aktif'],
    ['AENAM','','AENAM','',0,''],
    ['AEDAT','','AEDAT','',0,''],
    ['AEZET','','AEZET','',0,''] ] },
  { name: 'ZMAP_COA_GRP_CST', text: 'COA Batch List: Customer per Group', fields: [
    ['MANDT','X','MANDT','',0,'Client'],
    ['KUNNR','X','KUNNR','',0,''],
    ['COA_GRP','','','CHAR',20,'COA Group'],
    ['AENAM','','AENAM','',0,''],
    ['AEDAT','','AEDAT','',0,''],
    ['AEZET','','AEZET','',0,''] ] },
];

const only=process.argv[3];const todo=only?tables.filter(t=>t.name===only):tables;
const L = [];
L.push('REPORT ZTMP_CRT_GRP_TAB.');
L.push('DATA: LS_02 TYPE DD02V, LS_09 TYPE DD09V,');
L.push('      LT_03 TYPE TABLE OF DD03P, LS_03 TYPE DD03P,');
L.push('      LV_RC TYPE SYSUBRC.');
for (const t of todo) {
  L.push('CLEAR: LS_02, LS_09. REFRESH LT_03.');
  L.push(`LS_02-TABNAME = '${t.name}'.`);
  L.push("LS_02-DDLANGUAGE = SY-LANGU.");
  L.push("LS_02-TABCLASS = 'TRANSP'.");
  L.push("LS_02-CONTFLAG = 'A'.");
  L.push("LS_02-MAINFLAG = 'X'.");
  L.push("LS_02-EXCLASS = '1'.");
  L.push(`LS_02-DDTEXT = '${t.text}'.`);
  L.push(`LS_09-TABNAME = '${t.name}'.`);
  L.push("LS_09-AS4LOCAL = 'A'.");
  L.push("LS_09-TABKAT = '1'.");
  L.push("LS_09-TABART = 'APPL0'.");
  L.push("LS_09-BUFALLOW = 'N'.");
  t.fields.forEach(([fn,key,roll,dt,len,txt],i) => {
    L.push('CLEAR LS_03.');
    L.push(`LS_03-TABNAME = '${t.name}'.`);
    L.push(`LS_03-FIELDNAME = '${fn}'.`);
    L.push(`LS_03-POSITION = ${i+1}.`);
    if (key) { L.push("LS_03-KEYFLAG = 'X'."); L.push("LS_03-NOTNULL = 'X'."); }
    if (roll) L.push(`LS_03-ROLLNAME = '${roll}'.`);
    else { L.push(`LS_03-DATATYPE = '${dt}'.`); L.push(`LS_03-LENG = ${len}.`); }
    if (txt) L.push(`LS_03-DDTEXT = '${txt}'.`);
    L.push("LS_03-DDLANGUAGE = SY-LANGU.");
    L.push('APPEND LS_03 TO LT_03.');
  });
  L.push(`CALL FUNCTION 'DDIF_TABL_PUT'`);
  L.push(`  EXPORTING NAME = '${t.name}' DD02V_WA = LS_02`);
  L.push('            DD09L_WA = LS_09');
  L.push('  TABLES DD03P_TAB = LT_03');
  L.push('  EXCEPTIONS OTHERS = 9.');
  L.push(`WRITE: / '${t.name} PUT', SY-SUBRC.`);
  L.push(`CALL FUNCTION 'TR_TADIR_INTERFACE'`);
  L.push("  EXPORTING WI_TEST_MODUS = ' ' WI_TADIR_PGMID = 'R3TR'");
  L.push(`    WI_TADIR_OBJECT = 'TABL' WI_TADIR_OBJ_NAME = '${t.name}'`);
  L.push("    WI_TADIR_DEVCLASS = '$TMP' WI_TADIR_AUTHOR = SY-UNAME");
  L.push("    WI_TADIR_MASTERLANG = SY-LANGU");
  L.push('  EXCEPTIONS OTHERS = 9.');
  L.push(`WRITE: / '${t.name} TADIR', SY-SUBRC.`);
  L.push(`CALL FUNCTION 'DDIF_TABL_ACTIVATE'`);
  L.push(`  EXPORTING NAME = '${t.name}' AUTH_CHK = ' '`);
  L.push('  IMPORTING RC = LV_RC');
  L.push('  EXCEPTIONS OTHERS = 9.');
  L.push(`WRITE: / '${t.name} ACT', SY-SUBRC, LV_RC.`);
}
for (const l of L) if (l.length > 72) throw new Error('Line too long: ' + l);

await serverManager.loadConfig();
await serverManager.setActiveServer(srv);
const res = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: L.map(LINE => ({ LINE })) } });
console.log(srv, JSON.stringify(res.result?.WRITES?.map(w => w.ZEILE)), res.result?.ERRORMESSAGE || '');
process.exit(0);
