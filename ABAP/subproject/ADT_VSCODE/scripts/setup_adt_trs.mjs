// Setup ADT di sandbox-new (TRS): aktifkan ICF /sap/bc/adt + ICM HTTP port 8000 (dinamis).
// Pemakaian: node setup_adt_trs.mjs [apply|rollback|status]   (default: status)
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function, read_table } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

const MODE = process.argv[2] || 'status';
const PORT = '8000';
const OUT = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'outputs');
const stamp = new Date().toISOString().replace(/[-:]/g, '').slice(0, 13);

async function status() {
  const icm = await call_function({ function_name: 'ICM_GET_INFO', parameters: {} });
  const icf = await read_table({ table: 'ICFSERVLOC', where: ["ICF_NAME = 'ADT' AND ICFPARGUID = 'EEPI2GLFNOLHN7IW9R54I61RZ'"], fields: ['ICF_NAME', 'ICFACTIVE'] });
  return {
    sid: icm.sid,
    icm_services: (icm.result?.SERVLIST || []).map(s => ({ PROTOCOL: s.PROTOCOL, SERVICE: s.SERVICE, ACTIVE: s.ACTIVE, KEEPALIVE: s.KEEPALIVE, PROC_TIMEOUT: s.PROC_TIMEOUT })),
    icf_adt: icf.rows
  };
}

// ICM_CHANGE_SERV tidak RFC-enabled -> panggil lewat temp program
async function icmServ(action) {
  const prog = [
    'REPORT ZTMP_ICM.',
    'DATA: LT_SERV TYPE TABLE OF ICM_SCHNG,',
    '      LS_SERV TYPE ICM_SCHNG.',
    `LS_SERV-SERVICE = '${PORT}'.`,
    'LS_SERV-PROTOCOL = 1.',
    'LS_SERV-KEEPALIVE = 60.',
    'LS_SERV-PROC_TIMEOUT = 60.',
    'LS_SERV-VCLIENT = 1.',
    'LS_SERV-VIRT_HOST_IDX = -1.',
    'APPEND LS_SERV TO LT_SERV.',
    'CALL FUNCTION \'ICM_CHANGE_SERV\'',
    `  EXPORTING ACTION = ${action}`,
    '  TABLES SERVTAB = LT_SERV',
    '  EXCEPTIONS ICM_OP_FAILED = 1 ICM_NO_ACL_SUPPORT = 2',
    '             OTHERS = 3.',
    'WRITE: / \'ICM_SUBRC\', SY-SUBRC.'
  ];
  const res = await call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: prog.map(l => ({ LINE: l })) } });
  return { errormessage: res.result?.ERRORMESSAGE, writes: (res.result?.WRITES || []).map(w => w.ZEILE), error: res.error };
}

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  const before = await status();
  if (before.sid !== 'TRS') throw new Error(`Guard: server aktif bukan TRS (${before.sid})`);
  console.log('STATUS', JSON.stringify(before));
  if (MODE === 'status') return;

  fs.writeFileSync(path.join(OUT, `before_${MODE}_${stamp}.json`), JSON.stringify(before, null, 2));
  const log = { mode: MODE, before };

  if (MODE === 'apply') {
    log.icf = await call_function({ function_name: 'HTTP_ACTIVATE_NODE', parameters: { URL: '/sap/bc/adt/', EXPAND: 'X' } });
    const hasPort = before.icm_services.some(s => s.PROTOCOL === 1 && s.SERVICE === PORT);
    log.icm = hasPort ? 'skip: port sudah ada' : await icmServ(21);   // 21 = DP_PLUGIN_OP_SERV_CREATE
  } else if (MODE === 'rollback') {
    log.icf = await call_function({ function_name: 'HTTP_INACTIVATE_NODE', parameters: { URL: '/sap/bc/adt/', EXPAND: 'X' } });
    log.icm = await icmServ(28);                                       // 28 = DP_PLUGIN_OP_SERV_DEL
  }
  log.after = await status();
  fs.writeFileSync(path.join(OUT, `result_${MODE}_${stamp}.json`), JSON.stringify(log, null, 2));
  console.log('RESULT', JSON.stringify({ icf: log.icf?.result ?? log.icf?.error ?? log.icf, icm: log.icm, after: log.after }, null, 1));
}
main().catch(e => { console.error('ERROR', e.message || e); process.exit(1); });
