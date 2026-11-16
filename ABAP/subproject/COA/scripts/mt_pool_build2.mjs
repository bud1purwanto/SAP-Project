// Pool harness ZQMI_COA dengan patch di TOP/F01/F02/ALV (in-memory, program DEV tidak diubah).
// usage: TAG=<tag orig> [TOP=f] [F01=f] [F02=f] [ALV=f] [RUNNER=f] [UC=1] node scripts/mt_pool_build2.mjs <out harness.abap>
// UC=1: MODULE USER_COMMAND_0100 diubah jadi FORM ZZ_UC0100 (CALL SCREEN 0200 -> PERFORM ZZ_AFTER_EXEC).
import { readFileSync, writeFileSync, mkdtempSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
const O = new URL('../outputs/', import.meta.url).pathname;
const rd = f => readFileSync(f, 'utf8').split('\n').map(l => l.replace(/\r$/, ''));
const orig = n => rd(`${O}${n}_Development AIX_${process.env.TAG || 'live_fetched'}.abap`);
const [outFile] = process.argv.slice(2);
const names = ['ZQMI_COA_TOP', 'ZQMI_COA_F01', 'ZQMI_COA_F02', 'ZQMI_COA_ALV'];
const env = { ZQMI_COA_TOP: 'TOP', ZQMI_COA_F01: 'F01', ZQMI_COA_F02: 'F02', ZQMI_COA_ALV: 'ALV' };
const out = [];
const ref = (name, n) => out.push({ inc: name, n });
const lit = s => out.push({ lit: s });
function mapLines(o, nw) { // GNU diff: new line -> orig line no (null = literal)
  const d = mkdtempSync(join(tmpdir(), 'mtp'));
  writeFileSync(join(d, 'o'), o.join('\n') + '\n'); writeFileSync(join(d, 'n'), nw.join('\n') + '\n');
  let txt;
  try { txt = execFileSync('diff', ['--unchanged-line-format=U %dn\n', '--old-line-format=', '--new-line-format=N\n', join(d, 'o'), join(d, 'n')], { encoding: 'utf8', maxBuffer: 1 << 26 }); }
  catch (e) { if (e.status === 1) txt = e.stdout; else throw e; }
  const m = txt.split('\n').filter(Boolean).map(x => x.startsWith('U ') ? +x.slice(2) : null);
  if (m.length !== nw.length) throw new Error('diff map length ' + m.length + ' vs ' + nw.length);
  return m;
}
lit('PROGRAM ZTMP_MT_POOL.');
for (const name of names) {
  const o = orig(name);
  const nw = process.env[env[name]] ? rd(process.env[env[name]]) : o;
  const m = mapLines(o, nw);
  const emit = (i, l) => { if (m[i]) ref(name, m[i]); else lit(l); };
  if (name === 'ZQMI_COA_TOP') {
    nw.forEach((l, i) => {
      const u = l.trim().toUpperCase(); let mm;
      if (u.startsWith('SELECTION-SCREEN')) {
        if ((mm = l.match(/COMMENT\s+\S+\((\d+)\)\s+(\w+)/i))) lit(`DATA ${mm[2]}(${mm[1]}).`);
        else if ((mm = l.match(/PUSHBUTTON\s+\S*?\((\d+)\)\s+(\w+)/i))) lit(`DATA ${mm[2]}(${mm[1]}).`);
        else if ((mm = l.match(/BEGIN OF SCREEN \d+ AS WINDOW TITLE (\w+)/i))) lit(`DATA ${mm[1]}(70).`);
        else lit('*');
      } else if ((mm = l.match(/^\s*SELECT-OPTIONS:?\s+(\w+)\s+FOR\s+([\w-]+)/i))) lit(`RANGES ${mm[1]} FOR ${mm[2]}.`);
      else if ((mm = l.match(/^\s*PARAMETERS:?\s+(\w+)\s+(.*)$/i))) {
        let rest = mm[2].replace(/AS CHECKBOX/i, 'TYPE C').replace(/DEFAULT\s+'X'/i, "VALUE 'X'").replace(/OBLIGATORY/i, '');
        lit(`DATA ${mm[1]} ${rest}`);
      } else if (/^\s*CONTROLS:/i.test(l)) lit('DATA: TCERTI TYPE CXTAB_CONTROL,');
      else if (/^\s*TDETAIL TYPE TABLEVIEW/i.test(l)) lit('      TDETAIL TYPE CXTAB_CONTROL.');
      else emit(i, l);
    });
  } else if (name === 'ZQMI_COA_F01') {
    let skip = false;
    nw.forEach((l, i) => {
      const u = l.trim().toUpperCase();
      if (/^(INITIALIZATION|AT SELECTION-SCREEN.*|START-OF-SELECTION)\.$/.test(u)) skip = true;
      if (skip && (/^\*\s*CACHE FORMAT MIC/.test(u) || /^FORM GET_DATA\./.test(u))) skip = false;
      if (skip) { lit('*'); return; }
      if (/CALL SELECTION-SCREEN 9000/i.test(l)) { lit('*'); return; }
      emit(i, l);
    });
  } else {
    let inMod = false, uc = false;
    nw.forEach((l, i) => {
      if (/^\s*MODULE\s/i.test(l)) {
        inMod = true;
        if (process.env.UC && /MODULE\s+USER_COMMAND_0100\s+INPUT/i.test(l)) { uc = true; lit('FORM ZZ_UC0100.'); return; }
      }
      if (inMod) {
        if (/^\s*ENDMODULE/i.test(l)) { inMod = false; if (uc) { uc = false; lit('ENDFORM.'); return; } }
        if (uc) {
          if (/^\s*CALL SCREEN 0200\./i.test(l)) { lit('            PERFORM ZZ_AFTER_EXEC.'); return; }
          if (/^\s*LEAVE TO SCREEN 0\./i.test(l)) { lit('      EXIT.'); return; }
          emit(i, l); return;
        }
        lit('*'); return;
      }
      emit(i, l);
    });
  }
}
const runner = rd(process.env.RUNNER || new URL('../tests/mt_pool_runner.abap', import.meta.url).pathname);
runner.forEach(lit);
const H = [];
H.push('REPORT ZTMP_MT_POOLRUN.');
H.push("PARAMETERS: PV TYPE LIPS-VBELN DEFAULT '0085006278'.");
H.push('TYPES: TY_L TYPE C LENGTH 255.');
H.push('DATA: LT_P TYPE TABLE OF TY_L, LV_L TYPE TY_L,');
H.push('      LT_I TYPE TABLE OF TY_L, LV_PROG TYPE PROGNAME,');
H.push('      LV_MSG TYPE STRING, LV_LIN TYPE I, LV_WRD TYPE STRING.');
H.push('DATA: LV_SB TYPE STRING.');
H.push('DATA: BEGIN OF LS_C, N TYPE PROGNAME, T LIKE LT_I, END OF LS_C,');
H.push('      LT_C LIKE TABLE OF LS_C.');
H.push('FIELD-SYMBOLS: <C> LIKE LS_C.');
H.push('DEFINE R.');
H.push('  READ TABLE LT_C ASSIGNING <C> WITH KEY N = &1.');
H.push('  IF SY-SUBRC <> 0.');
H.push('    CLEAR LS_C. LS_C-N = &1. READ REPORT &1 INTO LS_C-T.');
H.push('    APPEND LS_C TO LT_C. DESCRIBE TABLE LT_C LINES LV_LIN.');
H.push('    READ TABLE LT_C ASSIGNING <C> INDEX LV_LIN.');
H.push('  ENDIF.');
H.push('  APPEND LINES OF <C>-T FROM &2 TO &3 TO LT_P.');
H.push('END-OF-DEFINITION.');
H.push('DEFINE A.');
H.push('  APPEND &1 TO LT_P.');
H.push('END-OF-DEFINITION.');
H.push('DEFINE C.');
H.push('  CONCATENATE LV_SB &1 INTO LV_SB RESPECTING BLANKS.');
H.push('END-OF-DEFINITION.');
H.push('START-OF-SELECTION.');
const q = s => "'" + s.replace(/'/g, "''") + "'";
let i = 0, nlit = 0;
while (i < out.length) {
  const o = out[i];
  if (o.inc) {
    let k = i; while (k + 1 < out.length && out[k + 1].inc === o.inc && out[k + 1].n === out[k].n + 1) k++;
    H.push(`R '${o.inc}' ${o.n} ${out[k].n}.`);
    i = k + 1; continue;
  }
  nlit++;
  const s = o.lit.replace(/\s+$/, '');
  if (s.length <= 55 && !s.includes("'")) H.push(`A ${q(s || ' ')}.`);
  else {
    H.push('CLEAR LV_SB.');
    let rest = s;
    while (rest.length) { const c = rest.slice(0, 40); rest = rest.slice(40); H.push(`C ${q(c)}.`); }
    H.push('APPEND LV_SB TO LT_P.');
  }
  i++;
}
H.push('GENERATE SUBROUTINE POOL LT_P NAME LV_PROG MESSAGE LV_MSG');
H.push('  LINE LV_LIN WORD LV_WRD.');
H.push('IF SY-SUBRC <> 0.');
H.push("  WRITE: / 'GENERR', SY-SUBRC, LV_LIN, LV_WRD.");
H.push('  WRITE: / LV_MSG.');
H.push('  READ TABLE LT_P INTO LV_L INDEX LV_LIN. WRITE: / LV_L(120).');
H.push('  EXIT.');
H.push('ENDIF.');
H.push('PERFORM ZZ_MT_RUN IN PROGRAM (LV_PROG) USING PV.');
for (const [n, l] of H.entries()) if (l.length > 72) throw new Error(`harness line ${n + 1} too long: ${l}`);
writeFileSync(outFile, H.join('\n') + '\n');
console.error('pool lines', out.length, 'literal lines', nlit, 'harness lines', H.length);
