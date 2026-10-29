import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function fetchProgram(progName, server = 'Development AIX') {
  await serverManager.loadConfig();
  await serverManager.setActiveServer(server);

  const prog = [
    'REPORT ZFETCH_SRC.',
    'DATA: LT_SRC TYPE TABLE OF STRING WITH HEADER LINE,',
    '      LV_PROG TYPE PROGRAM VALUE \'' + progName + '\'.',
    'READ REPORT LV_PROG INTO LT_SRC.',
    'WRITE: / \'LINES:\', LINES( LT_SRC ).',
    'LOOP AT LT_SRC.',
    '  WRITE: / LT_SRC.',
    'ENDLOOP.'
  ];

  const res = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: prog.map(l => ({ LINE: l }))
    }
  });

  const writes = res.result?.WRITES || [];
  console.log(`Fetched ${progName} from ${server}: writes count = ${writes.length}`);
  if (writes.length > 0) {
    console.log(writes[0]);
  }
}

fetchProgram('ZQMI_COA_F02').catch(console.error);
