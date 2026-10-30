import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tool-registry.js';
import fs from 'node:fs';

const srv = serverManager.getServers().find(s => s.name === 'Sandbox Build Competence');
if (srv) {
  srv.client = '130';
}

async function checkServer(serverRef, label) {
  console.log(`\n=================== Checking ${label} (${serverRef}) ===================`);
  const conn = await HANDLERS.set_active_server({ server_ref: serverRef });
  console.log('Connect result:', conn.mode, conn.connected ? 'SUCCESS' : conn.connect_error);
  if (!conn.connected) return null;

  // 1. Check TSTC for ZMAP
  console.log('Checking TSTC for TCODE = ZMAP:');
  const tstc = await HANDLERS.read_table({
    table: 'TSTC',
    fields: ['TCODE', 'PGMNA', 'DYPNO'],
    where: ["TCODE = 'ZMAP'"],
    rowcount: 5
  });
  console.log('TSTC:', JSON.stringify(tstc.rows || tstc));

  // 2. Check Table Structure ZMAP_TYPE
  console.log('Checking table structure ZMAP_TYPE:');
  const struct = await HANDLERS.read_table_structure({ object_name: 'ZMAP_TYPE' });
  const fieldList = (struct.fields || []).map(f => f.field);
  console.log(`Fields count: ${fieldList.length}`);
  console.log('Field list:', fieldList.join(', '));

  // 3. Count & Read rows in ZMAP_TYPE
  console.log('Reading all rows from ZMAP_TYPE:');
  // RFC_READ_TABLE line length limit is typically 512 bytes.
  // Let's read fields in chunks or select specific fields
  const allRows = await HANDLERS.read_table({
    table: 'ZMAP_TYPE',
    fields: fieldList,
    rowcount: 10000
  });
  console.log(`Total rows in ZMAP_TYPE: ${allRows.rows ? allRows.rows.length : (allRows.error || '0')}`);

  // 4. Check Programs ZMAP_TYPE and ZMAP_GLOBAL
  for (const progName of ['ZMAP_TYPE', 'ZMAP_GLOBAL']) {
    try {
      const p = await HANDLERS.read_program({ program_name: progName });
      console.log(`Program ${progName}: EXISTS (${p.lines ? p.lines.length : 'ok'} chars/lines)`);
    } catch (e) {
      console.log(`Program ${progName}: NOT FOUND / ERROR (${e.message || e})`);
    }
  }

  return {
    tstc: tstc.rows,
    fields: struct.fields,
    fieldList,
    rows: allRows.rows
  };
}

async function main() {
  const resNew = await checkServer('sandbox-new', 'Sandbox New Company (Source)');
  const resBuild = await checkServer('sandbox-build', 'Sandbox Build Competence (Target)');

  console.log('\n=================== Summary Comparison ===================');
  console.log(`Sandbox New ZMAP_TYPE rows: ${resNew?.rows ? resNew.rows.length : 'ERR'}`);
  console.log(`Sandbox Build ZMAP_TYPE rows: ${resBuild?.rows ? resBuild.rows.length : 'ERR'}`);

  if (resNew?.rows) {
    fs.writeFileSync('subproject/PO_EMAIL/outputs/ZMAP_TYPE_TRS_backup.json', JSON.stringify(resNew.rows, null, 2));
    console.log(`Saved ${resNew.rows.length} TRS rows to subproject/PO_EMAIL/outputs/ZMAP_TYPE_TRS_backup.json`);
  }
  if (resBuild?.rows) {
    fs.writeFileSync('subproject/PO_EMAIL/outputs/ZMAP_TYPE_TRD_backup.json', JSON.stringify(resBuild.rows, null, 2));
    console.log(`Saved ${resBuild.rows.length} TRD rows to subproject/PO_EMAIL/outputs/ZMAP_TYPE_TRD_backup.json`);
  }
}

main().catch(console.error);
