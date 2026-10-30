import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tool-registry.js';

const srv = serverManager.getServers().find(s => s.name === 'Sandbox Build Competence');
if (srv) srv.client = '130';

async function verifyAll() {
  console.log('Connecting to Sandbox Build Competence (TRD client 130)...');
  await HANDLERS.set_active_server({ server_ref: 'sandbox-build' });
  const client = serverManager.getClient();

  // 1. Check TSTC & TSTCT for ZMAP
  const tstc = await HANDLERS.read_table({
    table: 'TSTC',
    fields: ['TCODE', 'PGMNA', 'DYPNO'],
    where: ["TCODE = 'ZMAP'"]
  });
  const tstct = await HANDLERS.read_table({
    table: 'TSTCT',
    fields: ['TCODE', 'SPRSL', 'TTEXT'],
    where: ["TCODE = 'ZMAP'"]
  });
  console.log('\n--- 1. TCODE ZMAP ---');
  console.log('TSTC:', JSON.stringify(tstc.rows));
  console.log('TSTCT:', JSON.stringify(tstct.rows));

  // 2. Check Programs ZMAP_GLOBAL and ZMAP_TYPE
  console.log('\n--- 2. Programs ---');
  for (const pName of ['ZMAP_GLOBAL', 'ZMAP_TYPE']) {
    const p = await HANDLERS.read_program({ program_name: pName });
    const lineCount = (p.source || '').split('\n').length;
    console.log(`Program ${pName}: lines = ${lineCount}`);
  }

  // 3. Syntax checks
  console.log('\n--- 3. Syntax Checks ---');
  const progSyntax = [
    { LINE: 'REPORT ZTMP_CHECK.' },
    { LINE: 'DATA: LV_MSG(120), LV_LIN TYPE I, LV_WRD(30).' },
    { LINE: 'SYNTAX-CHECK FOR PROGRAM \'ZMAP_GLOBAL\'' },
    { LINE: '  MESSAGE LV_MSG LINE LV_LIN WORD LV_WRD.' },
    { LINE: 'WRITE: / \'ZMAP_GLOBAL SYNTAX:\', SY-SUBRC, LV_MSG.' },
    { LINE: 'SYNTAX-CHECK FOR PROGRAM \'ZMAP_TYPE\'' },
    { LINE: '  MESSAGE LV_MSG LINE LV_LIN WORD LV_WRD.' },
    { LINE: 'WRITE: / \'ZMAP_TYPE SYNTAX:\', SY-SUBRC, LV_MSG.' }
  ];
  const synRes = await client.invoke('RFC_ABAP_INSTALL_AND_RUN', {
    MODE: 'F',
    PROGRAM: progSyntax
  });
  console.log((synRes.result?.WRITES || []).map(w => w.ZEILE).join('\n'));

  // 4. Dynpros
  console.log('\n--- 4. Dynpros ---');
  const d020s = await HANDLERS.read_table({
    table: 'D020S',
    fields: ['PROG', 'DNUM'],
    where: ["PROG = 'ZMAP_TYPE'"]
  });
  console.log('D020S ZMAP_TYPE:', JSON.stringify(d020s.rows));

  // 5. CUA Titles
  console.log('\n--- 5. CUA Titles & Statuses ---');
  const progCuaCheck = [
    { LINE: 'REPORT ZTMP_CHECK_CUA.' },
    { LINE: 'DATA: LS_ADM TYPE RSMPE_ADM.' },
    { LINE: 'DATA: LT_STA TYPE TABLE OF RSMPE_STAT, WA_STA TYPE RSMPE_STAT.' },
    { LINE: 'DATA: LT_TIT TYPE TABLE OF RSMPE_TITT, WA_TIT TYPE RSMPE_TITT.' },
    { LINE: 'DATA: LT_BUT TYPE TABLE OF RSMPE_BUT, LT_PFK TYPE TABLE OF RSMPE_PFK.' },
    { LINE: 'DATA: LT_FUN TYPE TABLE OF RSMPE_FUNT, LT_MEN TYPE TABLE OF RSMPE_MEN.' },
    { LINE: 'DATA: LT_MTX TYPE TABLE OF RSMPE_MNLT, LT_ACT TYPE TABLE OF RSMPE_ACT.' },
    { LINE: 'DATA: LT_DOC TYPE TABLE OF RSMPE_ATRT, LT_BIV TYPE TABLE OF RSMPE_BUTS.' },
    { LINE: 'DATA: LT_SET TYPE TABLE OF RSMPE_STAF.' },
    { LINE: 'CALL FUNCTION \'RS_CUA_INTERNAL_FETCH\'' },
    { LINE: '  EXPORTING PROGRAM = \'ZMAP_TYPE\'' },
    { LINE: '  IMPORTING ADM = LS_ADM' },
    { LINE: '  TABLES STA = LT_STA TIT = LT_TIT BUT = LT_BUT PFK = LT_PFK' },
    { LINE: '         FUN = LT_FUN MEN = LT_MEN MTX = LT_MTX ACT = LT_ACT' },
    { LINE: '         DOC = LT_DOC BIV = LT_BIV SET = LT_SET' },
    { LINE: '  EXCEPTIONS OTHERS = 1.' },
    { LINE: 'WRITE: / \'CUA FETCH SUBRC:\', SY-SUBRC.' },
    { LINE: 'LOOP AT LT_TIT INTO WA_TIT. WRITE: / \'TIT:\', WA_TIT-CODE, WA_TIT-TEXT. ENDLOOP.' },
    { LINE: 'LOOP AT LT_STA INTO WA_STA. WRITE: / \'STA:\', WA_STA-CODE, WA_STA-INT_NOTE. ENDLOOP.' }
  ];
  const cuaRes = await client.invoke('RFC_ABAP_INSTALL_AND_RUN', {
    MODE: 'F',
    PROGRAM: progCuaCheck
  });
  console.log((cuaRes.result?.WRITES || []).map(w => w.ZEILE).join('\n'));

  // 6. Table ZMAP_TYPE rows count
  console.log('\n--- 6. Table ZMAP_TYPE Data ---');
  const progCount = [
    { LINE: 'REPORT ZTMP_COUNT.' },
    { LINE: 'DATA: LV_COUNT TYPE I.' },
    { LINE: 'SELECT COUNT(*) INTO LV_COUNT FROM ZMAP_TYPE.' },
    { LINE: 'WRITE: / \'TOTAL ROWS IN ZMAP_TYPE:\', LV_COUNT.' }
  ];
  const countRes = await client.invoke('RFC_ABAP_INSTALL_AND_RUN', {
    MODE: 'F',
    PROGRAM: progCount
  });
  console.log((countRes.result?.WRITES || []).map(w => w.ZEILE).join(' '));
}

verifyAll().catch(console.error);

