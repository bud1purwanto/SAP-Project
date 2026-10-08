import { readFileSync, writeFileSync } from 'node:fs';

const input = new URL('../outputs/ZQMF_COA_sandbox-new_baseline.xml', import.meta.url);
const output = new URL('../outputs/ZQMF_COA_EXPORT_candidate.xml', import.meta.url);
const xml = readFileSync(input, 'utf8');
const sourceTag = '<FORMNAME>ZQMF_COA</FORMNAME>';
const targetTag = '<FORMNAME>ZQMF_COA_EXPORT</FORMNAME>';
const count = xml.split(sourceTag).length - 1;
if (count < 2) throw new Error('Unexpected Smart Form XML structure');
const candidate = xml.replaceAll(sourceTag, targetTag);
if (candidate.includes(sourceTag)) throw new Error('Source form name remains');
if (!candidate.includes('<STYLE_NAME>ZQMF_COA</STYLE_NAME>')) {
  throw new Error('Source style was unexpectedly changed');
}
writeFileSync(output, candidate);
console.log(JSON.stringify({ output: output.pathname, formNameReplacements: count }));
