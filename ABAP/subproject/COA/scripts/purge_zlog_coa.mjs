import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function purgeServer(server) {
  console.log(`--- Purging ZLOG_COA on ${server} ---`);
  await serverManager.loadConfig();
  await serverManager.setActiveServer(server);

  const response = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: {
      PROGRAM: [
        { LINE: 'REPORT ZTMP_PURGE_ZLOG.' },
        { LINE: 'DATA: LV_BEFORE TYPE I, LV_AFTER TYPE I.' },
        { LINE: 'SELECT COUNT(*) INTO LV_BEFORE FROM ZLOG_COA.' },
        { LINE: 'DELETE FROM ZLOG_COA.' },
        { LINE: 'COMMIT WORK AND WAIT.' },
        { LINE: 'SELECT COUNT(*) INTO LV_AFTER FROM ZLOG_COA.' },
        { LINE: 'WRITE: / \'BEFORE:\', LV_BEFORE, \'AFTER:\', LV_AFTER.' }
      ],
      WRITES: []
    }
  });

  console.log(response.result?.WRITES);
}

async function main() {
  await purgeServer('sandbox-new');
  await purgeServer('dev-aix');
}

main().catch(console.error);
