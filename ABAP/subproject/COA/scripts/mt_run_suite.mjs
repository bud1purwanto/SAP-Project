// node scripts/mt_run_suite.mjs harness.abap outfile [server]
// Runs harness per DO, each in a fresh node process (fresh RFC session -> no stale ZQMI_COA globals)
import { readFileSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
const [file, out, server = 'Development AIX'] = process.argv.slice(2);
const DOS = (process.env.DOS || '0085006234 0085006235 0085006240 0085006241 0085006242 0085006243 0085006244 0085006245 0085004908 0084000047 0085000140 0085006278').split(' ');
const src = readFileSync(file, 'utf8');
const tmp = process.env.TMPDIR_MT || '/tmp/claude-1000/-data-Projects-SAP-ABAP/1eefdbeb-2948-4503-9828-8b2f17604f9a/scratchpad';
let all = '';
for (const d of DOS) {
  const f = `${tmp}/suite_${d}.abap`;
  writeFileSync(f, src.replaceAll("DEFAULT '0085006278'", `DEFAULT '${d}'`));
  let txt;
  try { txt = execFileSync('node', [new URL('./mt_run_abap.mjs', import.meta.url).pathname, f, server], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], maxBuffer: 1 << 26 }); }
  catch (e) { txt = 'EXEC_ERR ' + (e.stderr || e.message); }
  all += `### ${d}\n${txt.trimEnd()}\n`;
  console.error(d, txt.split('\n').length);
}
writeFileSync(out, all);
