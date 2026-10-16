import { readFileSync } from 'node:fs';

const raw = JSON.parse(readFileSync('/data/Projects/SAP/ABAP/subproject/COA/outputs/dynpro_0100_backup_hex.json', 'utf8'));

for (let i = 0; i < raw.length; i++) {
  const line = raw[i].ZEILE;
  if (line && line.length > 10 && !line.includes(':')) {
    const buf = Buffer.from(line, 'hex');
    // try to print utf16le and ascii/raw
    const utf16 = buf.toString('utf16le');
    const latin = buf.toString('latin1');
    console.log(`Line ${i} [${raw[i-1]?.ZEILE}]:`);
    console.log('  UTF16:', utf16.replace(/[\x00-\x1f]/g, '.'));
    console.log('  LATIN:', latin.replace(/[\x00-\x1f]/g, '.'));
  }
}
