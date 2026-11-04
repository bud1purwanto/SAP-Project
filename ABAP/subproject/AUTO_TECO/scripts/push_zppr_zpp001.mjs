import fs from 'fs';
import { HANDLERS } from 'file:///C:/Users/User/Documents/Claude/MCP%20SAP/sap-leader-mcp/src/tool-registry.js';

async function push() {
  console.log('1. Setting active server to sandbox-new...');
  const srvRes = await HANDLERS.set_active_server({ server_ref: 'sandbox-new' });
  console.log('Server result:', srvRes);

  if (!srvRes.success) {
    throw new Error('Failed to connect to sandbox-new');
  }

  console.log('2. Reading ZPPR_ZPP001.abap source...');
  const sourcePath = 'C:/Users/User/Documents/Claude Project/Projects/ABAP/subproject/AUTO_TECO/src/ZPPR_ZPP001.abap';
  const source = fs.readFileSync(sourcePath, 'utf8');
  const lines = source.split(/\r?\n/);

  // Each line max 255 chars
  const it_source = lines.map(line => ({
    LINE: line.length > 255 ? line.substring(0, 255) : line
  }));

  console.log(`3. Pushing program ZPPR_ZPP001 (${it_source.length} lines) via Z_RFC_PROGRAM_UPDATE...`);
  const result = await HANDLERS.call_function({
    function_name: 'Z_RFC_PROGRAM_UPDATE',
    parameters: {
      IV_PROGRAM_NAME: 'ZPPR_ZPP001',
      IV_PACKAGE: '$TMP',
      IV_CORRNUMBER: ' ',
      IT_SOURCE: it_source
    }
  });

  console.log('Push result:', JSON.stringify(result, null, 2));
}

push().catch(err => {
  console.error('Push error:', err);
  process.exit(1);
});
