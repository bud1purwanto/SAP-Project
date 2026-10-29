// Read-only syntax check program aktif. Usage: node syntax_check.mjs <server> PROG
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';

const [server, prog] = process.argv.slice(2);
const src = [
  'REPORT ZTMP_SYN.',
  'DATA: LT_SRC TYPE STANDARD TABLE OF STRING,',
  '      LV_MSG TYPE STRING,',
  '      LV_LIN TYPE I,',
  '      LV_WRD TYPE STRING,',
  '      LV_INC TYPE SYREPID.',
  `READ REPORT '${prog}' INTO LT_SRC.`,
  'SYNTAX-CHECK FOR LT_SRC MESSAGE LV_MSG LINE LV_LIN',
  `  WORD LV_WRD PROGRAM '${prog}' INCLUDE LV_INC.`,
  'IF SY-SUBRC = 0.',
  "  WRITE / 'SYNTAX OK'.",
  'ELSE.',
  "  WRITE: / 'SYNTAX ERROR', LV_INC, LV_LIN.",
  '  WRITE: / LV_WRD.',
  '  WRITE: / LV_MSG(70).',
  '  WRITE: / LV_MSG+70(70).',
  'ENDIF.',
];
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const res = await HANDLERS.call_function({ function_name: 'RFC_ABAP_INSTALL_AND_RUN', parameters: { PROGRAM: src.map(LINE => ({ LINE })) } });
for (const w of (res.result?.WRITES || [])) console.log(w.ZEILE);
