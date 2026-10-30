import { serverManager } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from '/var/www/MCP/MCP SAP/sap-leader-mcp/src/tool-registry.js';
import fs from 'node:fs';

const srv = serverManager.getServers().find(s => s.name === 'Sandbox Build Competence');
if (srv) srv.client = '130';

async function patchGlobal() {
  console.log('Connecting to Sandbox Build Competence (TRD client 130)...');
  await HANDLERS.set_active_server({ server_ref: 'sandbox-build' });
  const client = serverManager.getClient();

  const sourceStr = fs.readFileSync('subproject/PO_EMAIL/src/ZMAP_GLOBAL.abap', 'utf-8');
  const sourceLines = sourceStr.split('\n').map(l => ({ LINE: l.replace(/\r/g, '') }));

  console.log(`Calling Z_RFC_PROGRAM_UPDATE for ZMAP_GLOBAL (${sourceLines.length} lines)...`);
  const res = await client.invoke('Z_RFC_PROGRAM_UPDATE', {
    IV_PROGRAM_NAME: 'ZMAP_GLOBAL',
    IV_PACKAGE: '$TMP',
    IV_CORRNUMBER: ' ',
    IT_SOURCE: sourceLines
  });
  console.log('Update result:', res);

  // Now set Textpool from XML
  const tpXml = fs.readFileSync('subproject/PO_EMAIL/outputs/ZMAP_GLOBAL_TP.xml', 'utf-8');
  // Chunk XML into lines of max 70 chars for RFC_ABAP_INSTALL_AND_RUN
  const xmlChunks = [];
  for (let i = 0; i < tpXml.length; i += 70) {
    xmlChunks.push(tpXml.substring(i, i + 70));
  }

  const progSetTp = [
    { LINE: 'REPORT ZTMP_SET_TP.' },
    { LINE: 'DATA: LT_TP TYPE TABLE OF TEXTPOOL, LV_XML TYPE STRING.' }
  ];
  for (const chunk of xmlChunks) {
    progSetTp.push({ LINE: `CONCATENATE LV_XML '${chunk.replace(/'/g, "''")}' INTO LV_XML.` });
  }
  progSetTp.push({ LINE: 'CALL TRANSFORMATION ID SOURCE XML LV_XML RESULT TP = LT_TP.' });
  progSetTp.push({ LINE: 'INSERT TEXTPOOL \'ZMAP_GLOBAL\' FROM LT_TP LANGUAGE SY-LANGU.' });
  progSetTp.push({ LINE: 'WRITE: / \'TP_INSERT_SUBRC:\', SY-SUBRC.' });

  const tpRes = await client.invoke('RFC_ABAP_INSTALL_AND_RUN', {
    MODE: 'F',
    PROGRAM: progSetTp
  });
  console.log('Textpool set result:', (tpRes.result?.WRITES || []).map(w => w.ZEILE).join(' '));

  // Syntax check ZMAP_GLOBAL
  const checkProg = [
    { LINE: 'REPORT ZTMP_CHECK.' },
    { LINE: 'DATA: LV_MSG(120), LV_LIN TYPE I, LV_WRD(30).' },
    { LINE: 'SYNTAX-CHECK FOR PROGRAM \'ZMAP_GLOBAL\'' },
    { LINE: '  MESSAGE LV_MSG LINE LV_LIN WORD LV_WRD.' },
    { LINE: 'WRITE: / \'SYNTAX_SUBRC:\', SY-SUBRC, \'MSG:\', LV_MSG.' }
  ];
  const synRes = await client.invoke('RFC_ABAP_INSTALL_AND_RUN', {
    MODE: 'F',
    PROGRAM: checkProg
  });
  console.log('Syntax check result:', (synRes.result?.WRITES || []).map(w => w.ZEILE).join(' '));
}

patchGlobal().catch(console.error);

