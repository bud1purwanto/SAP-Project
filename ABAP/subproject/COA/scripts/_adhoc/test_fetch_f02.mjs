import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  // Baca seluruh isi ZQMI_COA_F02 saat ini via RFC
  const getCode = [
    'REPORT ZFETCH_FULL_F02.',
    'DATA: LT_SRC TYPE TABLE OF ABAPTXT255 WITH HEADER LINE.',
    'READ REPORT \'ZQMI_COA_F02\' INTO LT_SRC.',
    'LOOP AT LT_SRC.',
    '  WRITE: / LT_SRC-LINE.',
    'ENDLOOP.'
  ];

  const fetchRes = await call_function({
    function_name: 'RFC_ABAP_INSTALL_AND_RUN',
    parameters: { PROGRAM: getCode.map(l => ({ LINE: l })) }
  });

  const rawLines = fetchRes.result?.WRITES.map(w => w.ZEILE) || [];
  console.log('Fetched lines from Sandbox ZQMI_COA_F02:', rawLines.length);

  // Buat script update presisi menggunakan Z_RFC_PROGRAM_UPDATE atau RFC_ABAP_INSTALL_AND_RUN
  // Let's verify how Z_RFC_PROGRAM_UPDATE works or if RFC_ABAP_INSTALL_AND_RUN can write include
  // Normally RFC_PROGRAM_UPDATE or Z_RFC_PROGRAM_UPDATE is used.
  // Let's check available program update function in sandbox-new
}
main().catch(console.error);
