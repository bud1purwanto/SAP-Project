// Usage: node read_indexes.mjs <server> TAB1 TAB2 ...
import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { HANDLERS } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';

const [server, ...tabs] = process.argv.slice(2);
await serverManager.loadConfig();
await serverManager.setActiveServer(server);
const rt = async (table, fields, where) => (await HANDLERS.read_table({ table, fields, where, rowcount: 0 })).rows || [];
for (const t of tabs) {
  const key = await rt('DD03L', ['FIELDNAME', 'POSITION'], [`TABNAME = '${t}' AND KEYFLAG = 'X' AND AS4LOCAL = 'A'`]);
  key.sort((a, b) => a.POSITION - b.POSITION);
  console.log(`\n${t}  PK: ${key.map(k => k.FIELDNAME).filter(f => !f.startsWith('.')).join(', ')}`);
  const idx = await rt('DD12L', ['INDEXNAME', 'UNIQUEFLAG', 'DBSTATE', 'DBINCLEXCL', 'DBSYSSEL1', 'DBSYSSEL2'], [`SQLTAB = '${t}' AND AS4LOCAL = 'A'`]);
  const flds = await rt('DD17S', ['INDEXNAME', 'POSITION', 'FIELDNAME'], [`SQLTAB = '${t}' AND AS4LOCAL = 'A'`]);
  for (const i of idx) {
    const f = flds.filter(x => x.INDEXNAME === i.INDEXNAME).sort((a, b) => a.POSITION - b.POSITION).map(x => x.FIELDNAME);
    const db = i.DBINCLEXCL ? ` dbsel=${i.DBINCLEXCL}:${i.DBSYSSEL1} ${i.DBSYSSEL2}` : '';
    console.log(`  ${i.INDEXNAME}${i.UNIQUEFLAG ? ' (U)' : ''} state=${i.DBSTATE || '-'}${db}: ${f.join(', ')}`);
  }
}
