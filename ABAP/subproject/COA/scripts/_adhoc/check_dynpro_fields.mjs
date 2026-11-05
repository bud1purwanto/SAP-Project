import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  serverManager.setActiveServer('dev-aix');
  const d021tRes = await call_function({
    function_name: 'RFC_READ_TABLE',
    parameters: {
      QUERY_TABLE: 'D021S',
      OPTIONS: [{ TEXT: "PROG LIKE 'ZQM%COA%' AND DYNR EQ '0100'" }]
    }
  });
  console.log('Fields:', d021tRes);
}
main().catch(console.error);
