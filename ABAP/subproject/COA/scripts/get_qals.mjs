import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig(); 
await serverManager.setActiveServer('Development AIX');

const lots = ['040000015885', '040000021140'];
for (const lot of lots) {
  const r = await call_function({
    function_name: 'RFC_READ_TABLE',
    parameters: {
      QUERY_TABLE: 'QALS',
      OPTIONS: [{ TEXT: `PRUEFLOS = '${lot}'` }],
      FIELDS: [
        { FIELDNAME: 'PRUEFLOS' },
        { FIELDNAME: 'WERK' },
        { FIELDNAME: 'MATNR' },
        { FIELDNAME: 'CHARG' },
        { FIELDNAME: 'ENSTEHDAT' },
        { FIELDNAME: 'PASTRTERM' }
      ]
    }
  });
  console.log(`LOT ${lot}:`, JSON.stringify(r.result?.DATA ?? r));
}
process.exit(0);
