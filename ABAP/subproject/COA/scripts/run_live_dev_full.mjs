import { readFileSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const DOS = [
  '0085006234', '0085006235', '0085006240', '0085006241', '0085006242',
  '0085006243', '0085006244', '0085006245', '0085006270', '0085006271',
  '0085006272', '0085006276', '0085006277', '0085006278', '0085006279',
  '0085006280', '0085006281', '0085006282', '0085006284', '0085006285',
  '0085006286'
];

const harnessPath = '/data/Projects/SAP/ABAP/subproject/COA/tests/mt_harness_live_full.abap';
const runAbapPath = '/data/Projects/SAP/ABAP/subproject/COA/scripts/mt_run_abap.mjs';
const outPath = '/data/Projects/SAP/ABAP/subproject/COA/outputs/MT_LIVE_TEST_DEV_AIX_20261118.txt';

const harnessTpl = readFileSync(harnessPath, 'utf8');
let fullLog = '';

console.log(`Starting Live Testing ZQM002 on DEV AIX for ${DOS.length} Scenarios...`);

for (let i = 0; i < DOS.length; i++) {
  const d = DOS[i];
  const tmpHarness = `/tmp/suite_live_${d}.abap`;
  writeFileSync(tmpHarness, harnessTpl.replace("DEFAULT '0085006278'", `DEFAULT '${d}'`));
  
  let txt = '';
  try {
    txt = execFileSync('node', [runAbapPath, tmpHarness, 'Development AIX'], {
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'pipe'],
      maxBuffer: 1 << 26
    });
  } catch (err) {
    txt = 'EXEC_ERR ' + (err.stderr || err.message);
  }
  
  const lines = txt.trim().split('\n').filter(l => l.startsWith('|'));
  console.log(`[${i+1}/${DOS.length}] DO ${d}: ${lines.length} MICs retrieved`);
  fullLog += `### ${d}\n${txt.trimEnd()}\n\n`;
}

writeFileSync(outPath, fullLog, 'utf8');
console.log(`\nLive testing complete! Saved to ${outPath}`);
