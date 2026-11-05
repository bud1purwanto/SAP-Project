import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('dev-aix');

  // Cari order produksi roll SR 0000406810
  const mseg101 = await call_function({
    function_name: 'RFC_READ_TABLE',
    parameters: {
      QUERY_TABLE: 'MSEG',
      FIELDS: [{ FIELDNAME: 'AUFNR' }, { FIELDNAME: 'CHARG' }, { FIELDNAME: 'BWART' }],
      OPTIONS: [{ TEXT: "CHARG = '0000406810' AND BWART = '101'" }]
    }
  });
  console.log('MSEG 101 for 0000406810:', mseg101.result?.DATA);
  const aufnr = mseg101.result?.DATA?.[0]?.WA.substring(0, 12).trim();

  // Cari input komponen 261 dari order tersebut
  const mseg261 = await call_function({
    function_name: 'RFC_READ_TABLE',
    parameters: {
      QUERY_TABLE: 'MSEG',
      FIELDS: [{ FIELDNAME: 'CHARG' }, { FIELDNAME: 'MATNR' }, { FIELDNAME: 'BWART' }],
      OPTIONS: [{ TEXT: "AUFNR = '" + aufnr + "' AND BWART = '261'" }]
    }
  });
  console.log('MSEG 261 consumed in order', aufnr, ':', mseg261.result?.DATA);
  const parentCharg = mseg261.result?.DATA?.[0]?.WA.substring(0, 10).trim();

  // Sekarang cari semua order yang mengonsumsi parentCharg tersebut dengan BWART = 261!
  const siblingOrders = await call_function({
    function_name: 'RFC_READ_TABLE',
    parameters: {
      QUERY_TABLE: 'MSEG',
      FIELDS: [{ FIELDNAME: 'AUFNR' }, { FIELDNAME: 'CHARG' }, { FIELDNAME: 'BWART' }],
      OPTIONS: [{ TEXT: "CHARG = '" + parentCharg + "' AND BWART = '261'" }]
    }
  });
  console.log('All orders consuming parent', parentCharg, ':', siblingOrders.result?.DATA);

  // Dari order-order tersebut, cari output batch 101-nya!
  const aufnrs = siblingOrders.result?.DATA?.map(r => r.WA.substring(0, 12).trim()) || [];
  const uniqAufnrs = [...new Set(aufnrs)];
  console.log('Unique Aufnrs:', uniqAufnrs);

  const outBatches = [];
  for (const a of uniqAufnrs) {
    const out = await call_function({
      function_name: 'RFC_READ_TABLE',
      parameters: {
        QUERY_TABLE: 'MSEG',
        FIELDS: [{ FIELDNAME: 'CHARG' }],
        OPTIONS: [{ TEXT: "AUFNR = '" + a + "' AND BWART = '101'" }]
      }
    });
    if (out.result?.DATA?.[0]) {
      outBatches.push(out.result.DATA[0].WA.trim());
    }
  }
  console.log('Output batches from parent JR consumption:', outBatches);
}
main();
