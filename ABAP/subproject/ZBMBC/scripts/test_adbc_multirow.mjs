// Tes ADBC multi-row vs per-row ke MSSQL via DBCO, pakai temp table ##T_ZBMBC_ADBC (struktur dari Y_ZBMBCSR, TOP 0). Tidak menyentuh Y.
// Usage: node test_adbc_multirow.mjs <server> <dbco> [rows] [pack]
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';
const [server, dbco, rows = "71296", pack = "500"] = process.argv.slice(2);
const src = `REPORT ZTMP_ADBC LINE-SIZE 255.
DATA: LO_CON TYPE REF TO CL_SQL_CONNECTION,
 LO_ST TYPE REF TO CL_SQL_STATEMENT,
 LO_RS TYPE REF TO CL_SQL_RESULT_SET,
 LX TYPE REF TO CX_SQL_EXCEPTION, LR TYPE REF TO DATA,
 LT_ROWS TYPE STRING_TABLE, LT_VAL TYPE STRING_TABLE,
 LV_ROW TYPE STRING, LV_SQL TYPE STRING, LV_HEAD TYPE STRING,
 LV_V TYPE STRING, LV_CNT TYPE I, LV_I TYPE I, LV_N TYPE I,
 LV_K(10) TYPE C, T0 TYPE I, T1 TYPE I, T2 TYPE I, T3 TYPE I,
 LV_OUT(200) TYPE C, LV_MSG TYPE STRING.
DEFINE ADDV.
 LV_V = &1.
 REPLACE ALL OCCURRENCES OF '''' IN LV_V WITH ''''''.
 CONCATENATE 'N''' LV_V '''' INTO LV_V.
 APPEND LV_V TO LT_VAL.
END-OF-DEFINITION.
DEFINE QRY.
 CLEAR LV_OUT.
 LO_RS = LO_ST->EXECUTE_QUERY( LV_SQL ).
 GET REFERENCE OF LV_OUT INTO LR.
 LO_RS->SET_PARAM( LR ).
 LO_RS->NEXT( ). LO_RS->CLOSE( ).
END-OF-DEFINITION.
CONCATENATE 'INSERT INTO ##T_ZBMBC_ADBC ([Plant],[Material No],[Type],'
 '[Thick],[Batch],[Width],[Length],[TipeAlias],'
 '[CriteriaGrade],[Sloc],[Storage Bin],[SO No],[SO Item],'
 '[Sales Doc Type],[HU Box],[HU Pallet],[Customer Name])'
 ' VALUES ' INTO LV_HEAD RESPECTING BLANKS.
TRY.
 LO_CON = CL_SQL_CONNECTION=>GET_CONNECTION( '${dbco}' ).
 LO_ST = LO_CON->CREATE_STATEMENT( ).
 CONCATENATE 'SELECT CAST(SERVERPROPERTY(''ProductVersion'')'
  ' AS NVARCHAR(50))' INTO LV_SQL RESPECTING BLANKS.
 QRY.
 WRITE: / 'VER', LV_OUT.
 LV_SQL = 'SELECT TOP 0 * INTO ##T_ZBMBC_ADBC FROM Y_ZBMBCSR'.
 LO_ST->EXECUTE_UPDATE( LV_SQL ).
 GET RUN TIME FIELD T0.
 DO ${rows} TIMES.
  LV_I = SY-INDEX. LV_K = LV_I. CONDENSE LV_K.
  REFRESH LT_VAL.
  ADDV '1000'. ADDV 'SRA9BI'. ADDV 'ER10'. ADDV '22.0'.
  ADDV LV_K. ADDV '1020'. ADDV '2400'. ADDV 'ALIAS X'.
  ADDV 'First Grade'. ADDV '1801'. ADDV 'W1F042322'.
  ADDV '0084001234'. ADDV '000010'. ADDV 'ZOR'.
  ADDV '1000012154'. ADDV '6000009295'.
  IF LV_I MOD 1000 = 0. ADDV 'PT O''BRIEN TEST'.
  ELSE. ADDV 'PT TRIAS SENTOSA TBK'. ENDIF.
  CONCATENATE LINES OF LT_VAL INTO LV_ROW SEPARATED BY ','.
  CONCATENATE '(' LV_ROW ')' INTO LV_ROW.
  APPEND LV_ROW TO LT_ROWS. LV_CNT = LV_CNT + 1.
  IF LV_CNT >= ${pack} OR LV_I = ${rows}.
   CONCATENATE LINES OF LT_ROWS INTO LV_SQL SEPARATED BY ','.
   CONCATENATE LV_HEAD LV_SQL INTO LV_SQL.
   LO_ST->EXECUTE_UPDATE( LV_SQL ).
   REFRESH LT_ROWS. CLEAR LV_CNT.
  ENDIF.
 ENDDO.
 LO_CON->COMMIT( ).
 GET RUN TIME FIELD T1.
 DO 500 TIMES.
  CONCATENATE LV_HEAD LV_ROW INTO LV_SQL.
  LO_ST->EXECUTE_UPDATE( LV_SQL ).
 ENDDO.
 LO_CON->COMMIT( ).
 GET RUN TIME FIELD T2.
 LV_SQL = 'SELECT CAST(COUNT(*) AS NVARCHAR(20)) FROM ##T_ZBMBC_ADBC'.
 QRY.
 WRITE: / 'COUNT_T', LV_OUT.
 CONCATENATE 'SELECT CAST(COUNT(*) AS NVARCHAR(20)) FROM ##T_ZBMBC_ADBC'
  ' WHERE [Customer Name] = N''PT O''''BRIEN TEST'''
  INTO LV_SQL RESPECTING BLANKS.
 QRY.
 WRITE: / 'COUNT_QUOTE', LV_OUT.
 LV_SQL = 'DROP TABLE ##T_ZBMBC_ADBC'.
 LO_ST->EXECUTE_UPDATE( LV_SQL ).
 LO_CON->COMMIT( ).
 LO_CON->CLOSE( ).
 CATCH CX_SQL_EXCEPTION INTO LX.
  LV_MSG = LX->GET_TEXT( ). LV_OUT = LV_MSG.
  WRITE: / 'SQLERR', LV_OUT.
  LV_OUT = LX->SQL_MESSAGE. WRITE: / LV_OUT.
ENDTRY.
T3 = ( T1 - T0 ) / 1000. WRITE: / 'MULTI_MS', T3.
T3 = ( T2 - T1 ) / 500. WRITE: / 'PERROW_US', T3.
`;
const lines = src.split('\n').filter(l => l.trim());
const bad = lines.filter(l => l.length > 72);
if (bad.length) { console.log('TOO LONG:', bad); process.exit(1); }
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const res = await HANDLERS.call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: lines.map(LINE => ({ LINE })) } });
const r = res.result || res;
if (r.ERRORMESSAGE) console.log('ERR:', r.ERRORMESSAGE);
console.log((r.WRITES || []).map(w => w.ZEILE).join('\n') || JSON.stringify(res).slice(0, 800));
