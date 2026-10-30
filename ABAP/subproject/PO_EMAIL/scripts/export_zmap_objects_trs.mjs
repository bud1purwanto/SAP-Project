import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tool-registry.js';
import fs from 'node:fs';

async function exportAll() {
  console.log('Connecting to sandbox-new (TRS)...');
  await HANDLERS.set_active_server({ server_ref: 'sandbox-new' });
  const client = serverManager.getClient();

  // 1. Export CUA for ZMAP_TYPE as XML
  console.log('Exporting CUA for ZMAP_TYPE...');
  const progCua = [
    { LINE: 'REPORT ZTMP_EXP_CUA.' },
    { LINE: 'DATA: LS_ADM TYPE RSMPE_ADM.' },
    { LINE: 'DATA: LT_STA TYPE TABLE OF RSMPE_STAT.' },
    { LINE: 'DATA: LT_TIT TYPE TABLE OF RSMPE_TITT.' },
    { LINE: 'DATA: LT_BUT TYPE TABLE OF RSMPE_BUT.' },
    { LINE: 'DATA: LT_PFK TYPE TABLE OF RSMPE_PFK.' },
    { LINE: 'DATA: LT_FUN TYPE TABLE OF RSMPE_FUNT.' },
    { LINE: 'DATA: LT_MEN TYPE TABLE OF RSMPE_MEN.' },
    { LINE: 'DATA: LT_MTX TYPE TABLE OF RSMPE_MNLT.' },
    { LINE: 'DATA: LT_ACT TYPE TABLE OF RSMPE_ACT.' },
    { LINE: 'DATA: LT_DOC TYPE TABLE OF RSMPE_ATRT.' },
    { LINE: 'DATA: LT_BIV TYPE TABLE OF RSMPE_BUTS.' },
    { LINE: 'DATA: LT_SET TYPE TABLE OF RSMPE_STAF.' },
    { LINE: 'DATA: LV_XML TYPE STRING, LV_LEN TYPE I.' },
    { LINE: 'DATA: LV_OFF TYPE I, LV_CHUNK TYPE C LENGTH 70.' },
    { LINE: 'CALL FUNCTION \'RS_CUA_INTERNAL_FETCH\'' },
    { LINE: '  EXPORTING PROGRAM = \'ZMAP_TYPE\'' },
    { LINE: '  IMPORTING ADM = LS_ADM' },
    { LINE: '  TABLES STA = LT_STA TIT = LT_TIT BUT = LT_BUT PFK = LT_PFK' },
    { LINE: '         FUN = LT_FUN MEN = LT_MEN MTX = LT_MTX ACT = LT_ACT' },
    { LINE: '         DOC = LT_DOC BIV = LT_BIV SET = LT_SET' },
    { LINE: '  EXCEPTIONS OTHERS = 1.' },
    { LINE: 'CALL TRANSFORMATION ID' },
    { LINE: '  SOURCE ADM = LS_ADM STA = LT_STA TIT = LT_TIT BUT = LT_BUT' },
    { LINE: '         PFK = LT_PFK FUN = LT_FUN MEN = LT_MEN MTX = LT_MTX' },
    { LINE: '         ACT = LT_ACT DOC = LT_DOC BIV = LT_BIV SET = LT_SET' },
    { LINE: '  RESULT XML LV_XML.' },
    { LINE: 'LV_LEN = STRLEN( LV_XML ).' },
    { LINE: 'WHILE LV_OFF < LV_LEN.' },
    { LINE: '  LV_CHUNK = LV_XML+LV_OFF.' },
    { LINE: '  WRITE: / LV_CHUNK.' },
    { LINE: '  LV_OFF = LV_OFF + 70.' },
    { LINE: 'ENDWHILE.' }
  ];

  const cuaRes = await client.invoke('RFC_ABAP_INSTALL_AND_RUN', {
    MODE: 'F',
    PROGRAM: progCua
  });
  if (cuaRes.result?.ERRORMESSAGE) throw new Error(cuaRes.result.ERRORMESSAGE);
  const cuaXml = (cuaRes.result?.WRITES || []).map(w => w.ZEILE).join('');
  console.log(`Exported CUA XML length: ${cuaXml.length}`);
  fs.writeFileSync('subproject/PO_EMAIL/outputs/ZMAP_TYPE_CUA.xml', cuaXml);

  // 2. Export Dynpro 0100 for ZMAP_TYPE as XML
  console.log('Exporting Dynpro 0100 for ZMAP_TYPE...');
  const progDyn = [
    { LINE: 'REPORT ZTMP_EXP_DYN.' },
    { LINE: 'DATA: LS_HEADER TYPE RPY_DYHEAD.' },
    { LINE: 'DATA: LT_CONT TYPE DYCATT_TAB.' },
    { LINE: 'DATA: LT_FIELDS TYPE DYFATC_TAB.' },
    { LINE: 'DATA: LT_FLOW TYPE TABLE OF RPY_DYFLOW.' },
    { LINE: 'DATA: LV_XML TYPE STRING, LV_LEN TYPE I.' },
    { LINE: 'DATA: LV_OFF TYPE I, LV_CHUNK TYPE C LENGTH 70.' },
    { LINE: 'CALL FUNCTION \'RPY_DYNPRO_READ\'' },
    { LINE: '  EXPORTING PROGNAME = \'ZMAP_TYPE\' DYNNR = \'0100\'' },
    { LINE: '  IMPORTING HEADER = LS_HEADER' },
    { LINE: '  TABLES CONTAINERS = LT_CONT' },
    { LINE: '         FIELDS_TO_CONTAINERS = LT_FIELDS' },
    { LINE: '         FLOW_LOGIC = LT_FLOW' },
    { LINE: '  EXCEPTIONS OTHERS = 1.' },
    { LINE: 'CALL TRANSFORMATION ID' },
    { LINE: '  SOURCE HEADER = LS_HEADER CONT = LT_CONT' },
    { LINE: '         FIELDS = LT_FIELDS FLOW = LT_FLOW' },
    { LINE: '  RESULT XML LV_XML.' },
    { LINE: 'LV_LEN = STRLEN( LV_XML ).' },
    { LINE: 'WHILE LV_OFF < LV_LEN.' },
    { LINE: '  LV_CHUNK = LV_XML+LV_OFF.' },
    { LINE: '  WRITE: / LV_CHUNK.' },
    { LINE: '  LV_OFF = LV_OFF + 70.' },
    { LINE: 'ENDWHILE.' }
  ];

  const dynRes = await client.invoke('RFC_ABAP_INSTALL_AND_RUN', {
    MODE: 'F',
    PROGRAM: progDyn
  });
  if (dynRes.result?.ERRORMESSAGE) throw new Error(dynRes.result.ERRORMESSAGE);
  const dynXml = (dynRes.result?.WRITES || []).map(w => w.ZEILE).join('');
  console.log(`Exported Dynpro XML length: ${dynXml.length}`);
  fs.writeFileSync('subproject/PO_EMAIL/outputs/ZMAP_TYPE_DYN0100.xml', dynXml);

  console.log('Export finished successfully!');
}

exportAll().catch(console.error);
