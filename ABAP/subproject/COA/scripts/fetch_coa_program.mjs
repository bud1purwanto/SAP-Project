import { writeFileSync } from 'node:fs';
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { read_program } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/abap-tools.js';

const programName = process.argv[2] || 'ZQMI_COA_F01';
const serverRef = process.argv[3] || 'sandbox-new';
const outputTag = process.argv[4] || 'baseline';
if (!/^[a-z0-9_-]+$/i.test(outputTag)) throw new Error('Invalid output tag');
await serverManager.loadConfig();
const server = await serverManager.setActiveServer(serverRef);
if (!server.connected) throw new Error(server.connect_error || 'SAP not connected');
const response = await read_program({ program_name: programName });
if (response.mode !== 'LIVE' || !response.source) throw new Error('Live source unavailable');
const target = new URL(`../outputs/${programName}_${serverRef}_${outputTag}.abap`, import.meta.url);
writeFileSync(target, response.source);
console.log(JSON.stringify({ programName, serverRef, lineCount: response.line_count, target: target.pathname }));
