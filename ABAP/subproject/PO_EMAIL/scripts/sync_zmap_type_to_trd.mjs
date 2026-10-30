import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tool-registry.js';
import fs from 'node:fs';

const srv = serverManager.getServers().find(s => s.name === 'Sandbox Build Competence');
if (srv) {
  srv.client = '130';
}

function escapeAbap(str) {
  return (str || '').replace(/'/g, "''");
}

function generateBatchAbap(batch, batchNum, totalBatches) {
  const lines = [
    `REPORT ZTMP_SYNC_ZMAP.`,
    `DATA: LT_DATA TYPE TABLE OF ZMAP_TYPE,`,
    `      LS_DATA TYPE ZMAP_TYPE.`,
    `REFRESH LT_DATA.`
  ];

  for (const r of batch) {
    lines.push(`CLEAR LS_DATA.`);
    lines.push(`LS_DATA-TCODE = '${escapeAbap(r.TCODE)}'.`);
    lines.push(`LS_DATA-PROG  = '${escapeAbap(r.PROG)}'.`);
    lines.push(`LS_DATA-TYPE  = '${escapeAbap(r.TYPE)}'.`);
    lines.push(`LS_DATA-OPT   = '${escapeAbap(r.OPT)}'.`);
    lines.push(`LS_DATA-VALUE = '${escapeAbap(r.VALUE)}'.`);
    if (r.TEXT1) lines.push(`LS_DATA-TEXT1 = '${escapeAbap(r.TEXT1)}'.`);
    if (r.TEXT2) lines.push(`LS_DATA-TEXT2 = '${escapeAbap(r.TEXT2)}'.`);
    if (r.TEXT3) lines.push(`LS_DATA-TEXT3 = '${escapeAbap(r.TEXT3)}'.`);
    if (r.TEXT4) lines.push(`LS_DATA-TEXT4 = '${escapeAbap(r.TEXT4)}'.`);
    if (r.TEXT5) lines.push(`LS_DATA-TEXT5 = '${escapeAbap(r.TEXT5)}'.`);
    if (r.TERM1) lines.push(`LS_DATA-TERM1 = '${escapeAbap(r.TERM1)}'.`);
    if (r.TERM2) lines.push(`LS_DATA-TERM2 = '${escapeAbap(r.TERM2)}'.`);
    if (r.DELETION) lines.push(`LS_DATA-DELETION = '${escapeAbap(r.DELETION)}'.`);
    if (r.CPUDT && r.CPUDT !== '00000000') lines.push(`LS_DATA-CPUDT = '${escapeAbap(r.CPUDT)}'.`);
    if (r.CPUTM && r.CPUTM !== '000000') lines.push(`LS_DATA-CPUTM = '${escapeAbap(r.CPUTM)}'.`);
    if (r.USNAM) lines.push(`LS_DATA-USNAM = '${escapeAbap(r.USNAM)}'.`);
    if (r.AEDAT && r.AEDAT !== '00000000') lines.push(`LS_DATA-AEDAT = '${escapeAbap(r.AEDAT)}'.`);
    if (r.AENAM) lines.push(`LS_DATA-AENAM = '${escapeAbap(r.AENAM)}'.`);
    if (r.PSOTM && r.PSOTM !== '000000') lines.push(`LS_DATA-PSOTM = '${escapeAbap(r.PSOTM)}'.`);
    lines.push(`APPEND LS_DATA TO LT_DATA.`);
  }

  lines.push(`MODIFY ZMAP_TYPE FROM TABLE LT_DATA.`);
  lines.push(`COMMIT WORK AND WAIT.`);
  lines.push(`WRITE: / 'BATCH', ${batchNum}, 'OF', ${totalBatches}, 'COUNT:', SY-DBCNT.`);

  return lines.map(line => ({ LINE: line }));
}

async function runSync() {
  const trsData = JSON.parse(fs.readFileSync('subproject/PO_EMAIL/outputs/ZMAP_TYPE_TRS_backup.json'));
  console.log(`Loaded ${trsData.length} rows from TRS backup.`);

  console.log('Connecting to Sandbox Build Competence (TRD client 130)...');
  const conn = await HANDLERS.set_active_server({ server_ref: 'sandbox-build' });
  if (!conn.connected) {
    throw new Error(`Failed to connect to target server: ${conn.connect_error}`);
  }

  const client = serverManager.getClient();
  const BATCH_SIZE = 50;
  const totalBatches = Math.ceil(trsData.length / BATCH_SIZE);
  console.log(`Starting sync in ${totalBatches} batches of up to ${BATCH_SIZE} rows...`);

  let totalUpdated = 0;
  for (let i = 0; i < totalBatches; i++) {
    const batch = trsData.slice(i * BATCH_SIZE, (i + 1) * BATCH_SIZE);
    const abapProg = generateBatchAbap(batch, i + 1, totalBatches);

    const res = await client.invoke('RFC_ABAP_INSTALL_AND_RUN', {
      MODE: 'F',
      PROGRAM: abapProg
    });

    if (res.result && res.result.ERRORMESSAGE) {
      throw new Error(`Batch ${i + 1} failed with error: ${res.result.ERRORMESSAGE}`);
    }

    const writes = (res.result?.WRITES || []).map(w => w.ZEILE).join(' ');
    console.log(`Batch ${i + 1}/${totalBatches} processed. Output: ${writes}`);
    totalUpdated += batch.length;
  }

  console.log(`\nAll ${totalBatches} batches executed successfully! Total rows submitted: ${totalUpdated}`);

  // Final verification: Count rows in TRD ZMAP_TYPE
  const checkProg = [
    { LINE: 'REPORT ZTMP_VERIFY.' },
    { LINE: 'DATA: LV_COUNT TYPE I.' },
    { LINE: 'SELECT COUNT(*) INTO LV_COUNT FROM ZMAP_TYPE.' },
    { LINE: 'WRITE: / \'FINAL_COUNT:\', LV_COUNT.' }
  ];
  const verifyRes = await client.invoke('RFC_ABAP_INSTALL_AND_RUN', {
    MODE: 'F',
    PROGRAM: checkProg
  });
  console.log('Verification output:', (verifyRes.result?.WRITES || []).map(w => w.ZEILE).join(' '));
}

runSync().catch(console.error);
