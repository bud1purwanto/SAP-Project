// Build in-memory SUBROUTINE POOL harness of ZQMI_COA (TOP+F01+F02+ALV) for Development AIX.
// Unchanged lines are copied server-side (READ REPORT); only changed lines are sent as literals.
// usage: node scripts/mt_pool_build.mjs <F01 file (patched or orig)> <out harness.abap>
import { readFileSync, writeFileSync } from 'node:fs';
const O = new URL('../outputs/', import.meta.url).pathname;
const rd = n => readFileSync(`${O}${n}_Development AIX_${process.env.TAG || "now20261016"}.abap`, 'utf8').split('\n').map(l => l.replace(/\r$/, ''));
const [f01File, outFile] = process.argv.slice(2);
const inc = { ZQMI_COA_TOP: rd('ZQMI_COA_TOP'), ZQMI_COA_F01: rd('ZQMI_COA_F01'), ZQMI_COA_F02: rd('ZQMI_COA_F02'), ZQMI_COA_ALV: rd('ZQMI_COA_ALV') };
const f01New = readFileSync(f01File, 'utf8').split('\n').map(l => l.replace(/\r$/, ''));
const out = []; // {inc, n} (1-based) or {lit}
const ref = (name, n) => out.push({ inc: name, n });
const lit = s => out.push({ lit: s });
lit('PROGRAM ZTMP_MT_POOL.');
// TOP
inc.ZQMI_COA_TOP.forEach((l, i) => {
  const u = l.trim().toUpperCase();
  let m;
  if (u.startsWith('SELECTION-SCREEN')) {
    if ((m = l.match(/COMMENT\s+\S+\((\d+)\)\s+(\w+)/i))) lit(`DATA ${m[2]}(${m[1]}).`);
    else if ((m = l.match(/PUSHBUTTON\s+\S*?\((\d+)\)\s+(\w+)/i))) lit(`DATA ${m[2]}(${m[1]}).`);
    else if ((m = l.match(/BEGIN OF SCREEN \d+ AS WINDOW TITLE (\w+)/i))) lit(`DATA ${m[1]}(70).`);
    else lit('*');
  } else if ((m = l.match(/^\s*SELECT-OPTIONS:?\s+(\w+)\s+FOR\s+([\w-]+)/i))) lit(`RANGES ${m[1]} FOR ${m[2]}.`);
  else if ((m = l.match(/^\s*PARAMETERS:?\s+(\w+)\s+(.*)$/i))) {
    let rest = m[2].replace(/AS CHECKBOX/i, 'TYPE C').replace(/DEFAULT\s+'X'/i, "VALUE 'X'").replace(/OBLIGATORY/i, '');
    lit(`DATA ${m[1]} ${rest}`);
  } else if (/^\s*CONTROLS:/i.test(l)) { lit('DATA: TCERTI TYPE CXTAB_CONTROL,'); }
  else if (/^\s*TDETAIL TYPE TABLEVIEW/i.test(l)) { lit('      TDETAIL TYPE CXTAB_CONTROL.'); }
  else ref('ZQMI_COA_TOP', i + 1);
});
// F01: drop event blocks (INITIALIZATION ... until first decl comment; AT SELECTION-SCREEN ... up to FORM GET_DATA header)
const f01Orig = inc.ZQMI_COA_F01;
// map new F01 lines to orig line numbers when identical (simple LCS-free: sequential match)
let j = 0; const mapNew = [];
for (let i = 0; i < f01New.length; i++) {
  let k = j; while (k < f01Orig.length && k < j + 400 && f01Orig[k] !== f01New[i]) k++;
  if (k < f01Orig.length && f01Orig[k] === f01New[i] && k < j + 400) { mapNew.push(k + 1); j = k + 1; } else mapNew.push(null);
}
let skip = false;
f01New.forEach((l, i) => {
  const u = l.trim().toUpperCase();
  if (/^(INITIALIZATION|AT SELECTION-SCREEN.*|START-OF-SELECTION)\.$/.test(u)) skip = true;
  if (skip && (/^\*\s*CACHE FORMAT MIC/.test(u) || /^FORM GET_DATA\./.test(u))) skip = false;
  if (skip) { lit('*'); return; }
  if (/CALL SELECTION-SCREEN 9000/i.test(l)) { lit('*'); return; }
  if (mapNew[i] && !process.env.F01_LITERAL) ref('ZQMI_COA_F01', mapNew[i]); else lit(l);
});
// F02 + ALV: drop MODULE ... ENDMODULE
for (const name of ['ZQMI_COA_F02', 'ZQMI_COA_ALV']) {
  let inMod = false;
  inc[name].forEach((l, i) => {
    if (/^\s*MODULE\s/i.test(l)) inMod = true;
    if (inMod) { if (/^\s*ENDMODULE/i.test(l)) inMod = false; lit('*'); return; }
    ref(name, i + 1);
  });
}
// runner form
const runner = readFileSync(new URL('../tests/mt_pool_runner.abap', import.meta.url), 'utf8').split('\n');
runner.forEach(lit);
// --- emit harness ---
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
H.push('    APPEND LS_C TO LT_C. LV_LIN = LINES( LT_C ).');
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
let i = 0;
while (i < out.length) {
  const o = out[i];
  if (o.inc) {
    let k = i; while (k + 1 < out.length && out[k + 1].inc === o.inc && out[k + 1].n === out[k].n + 1) k++;
    H.push(`R '${o.inc}' ${o.n} ${out[k].n}.`);
    i = k + 1; continue;
  }
  const s = o.lit.replace(/\s+$/, '');
  if (s.length <= 55 && !s.includes("'") ) { H.push(`A ${q(s || ' ')}.`); }
  else {
    H.push('CLEAR LV_SB.');
    // chunk preserving blanks; avoid chunk ending/starting issues
    let rest = s;
    while (rest.length) { let c = rest.slice(0, 40); rest = rest.slice(40); H.push(`C ${q(c)}.`.replace(/^C '(.*)'\.$/, (m) => m)); }
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
console.error('pool lines', out.length, 'harness lines', H.length);
