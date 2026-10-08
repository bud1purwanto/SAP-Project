import { readFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

const programName = process.argv[2];
const sourcePath = process.argv[3];
if (!['ZQMI_COA_TOP', 'ZQMI_COA_F01'].includes(programName) || !sourcePath) {
  throw new Error('Only COA include candidates are allowed');
}
const source = readFileSync(sourcePath, 'utf8').split(/\r?\n/);
if (source[source.length - 1] === '') source.pop();
if (source.some(line => line.length > 255)) throw new Error('ABAP line exceeds 255 chars');
await serverManager.loadConfig();
const server = await serverManager.setActiveServer('sandbox-new');
if (!server.connected) throw new Error(server.connect_error || 'SAP not connected');
const response = await call_function({
  function_name: 'Z_RFC_PROGRAM_UPDATE',
  parameters: {
    IV_PROGRAM_NAME: programName,
    IV_PACKAGE: '$TMP',
    IV_CORRNUMBER: ' ',
    IT_SOURCE: source.map(LINE => ({ LINE }))
  }
});
const result = response.result || {};
console.log(JSON.stringify({ programName, lineCount: source.length, success: result.EV_SUCCESS, message: result.EV_MESSAGE }));
if (result.EV_SUCCESS !== 'X') process.exitCode = 1;
