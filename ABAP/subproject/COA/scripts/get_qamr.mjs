import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

await serverManager.loadConfig(); 
await serverManager.setActiveServer('Development AIX');

const lots = ['040000015885', '040000021140'];
for (const lot of lots) {
  const r = await call_function({
    function_name: 'RFC_READ_TABLE',
    parameters: {
      QUERY_TABLE: 'QAMR',
      OPTIONS: [{ TEXT: `PRUEFLOS = '${lot}'` }],
      FIELDS: [
        { FIELDNAME: 'PRUEFLOS' },
        { FIELDNAME: 'MERKNR' },
        { FIELDNAME: 'MITTELWERT' },
        { FIELDNAME: 'ANZWERTG' },
        { FIELDNAME: 'MBEWERTG' }
      ]
    }
  });
  console.log(`QAMR FOR LOT ${lot}:`, JSON.stringify(r.result?.DATA ?? r));

  const rv = await call_function({
    function_name: 'RFC_READ_TABLE',
    parameters: {
      QUERY_TABLE: 'QAMV',
      OPTIONS: [{ TEXT: `PRUEFLOS = '${lot}'` }],
      FIELDS: [
        { FIELDNAME: 'PRUEFLOS' },
        { FIELDNAME: 'MERKNR' },
        { FIELDNAME: 'VERWMERKM' },
        { FIELDNAME: 'KURZTEXT' }
      ]
    }
  });
  console.log(`QAMV FOR LOT ${lot}:`, JSON.stringify(rv.result?.DATA ?? rv));
}
process.exit(0);
