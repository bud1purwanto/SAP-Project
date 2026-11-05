import { readFileSync } from 'node:fs';

const filePath = process.argv[2] || '/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F01_sandbox-new_fresh.abap';
const lines = readFileSync(filePath, 'utf8').split(/\r?\n/);

let longLines = 0;
for (let i = 0; i < lines.length; i++) {
  if (lines[i].length > 255) {
    console.error(`Line ${i + 1} exceeds 255: ${lines[i].length} chars`);
    longLines++;
  }
}
console.log(`Total lines: ${lines.length}, Lines > 255 chars: ${longLines}`);
