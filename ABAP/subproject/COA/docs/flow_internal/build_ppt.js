const pptxgen = require('pptxgenjs');
const { applyTheme } = require('/home/abap/.claude/remote/plugins/6a513545/7b4711ebc297ee06/skills/pptx/scripts/apply_theme.js');
const THEME = { name: 'COA Flow', headFontFace: 'Calibri', bodyFontFace: 'Calibri',
  colors: { dk1: '1D2433', lt1: 'FFFFFF', dk2: '1F4E79', lt2: 'F4F8FC', accent1: '1F4E79', accent2: '2E7D32',
    accent3: 'C47F00', accent4: '6B7385', accent5: 'FFF8E8', accent6: 'EEF8EF', hlink: '1F4E79', folHlink: '6B7385' } };
const pres = new pptxgen(); pres.layout = 'LAYOUT_WIDE'; pres.theme = { headFontFace: 'Calibri', bodyFontFace: 'Calibri' };
const C = pres.SchemeColor;
pres.defineSlideMaster({ title: 'TITLE_ONLY', background: { color: 'FFFFFF' }, objects: [
  { placeholder: { options: { name: 'title', type: 'title', x: 0.5, y: 0.3, w: 12.3, h: 0.6, fontSize: 26, bold: true, color: C.text1, valign: 'top', margin: 0 }, text: '' } },
  { placeholder: { options: { name: 'sub', type: 'body', x: 0.5, y: 0.9, w: 12.3, h: 0.35, fontSize: 13, color: C.accent4, margin: 0 }, text: '' } } ] });
const KIND = { n: [C.accent1, C.background2], d: [C.accent3, C.accent5], o: [C.accent2, C.accent6] };
function runs(arr, base) { return arr.map((r, i) => ({ text: typeof r === 'string' ? r : r.t,
  options: Object.assign({}, base, typeof r === 'string' ? {} : r.o, i < arr.length - 1 && (typeof r === 'string' ? false : r.br) ? { breakLine: true } : {}) })); }
// step row: number circle, box (title, desc runs, source), example box
function stepRow(s, y, h, no, kind, title, desc, src, ex) {
  const [ln, fill] = KIND[kind];
  s.addShape(pres.shapes.OVAL, { x: 0.5, y: y + h / 2 - 0.22, w: 0.44, h: 0.44, fill: { color: C.accent1 }, line: { color: C.accent1 }, objectName: 'no' + no });
  s.addText(String(no), { x: 0.5, y: y + h / 2 - 0.22, w: 0.44, h: 0.44, isTextBox: true, align: 'center', valign: 'middle', fontSize: 14, bold: true, color: C.background1, margin: 0 });
  const body = [{ text: title, options: { bold: true, fontSize: 14, breakLine: true } }, ...desc.map((t, i) => ({ text: t.t ?? t, options: Object.assign({ fontSize: 12 }, t.o || {}, (t.br || (i === desc.length - 1 && src)) ? { breakLine: true } : {}) }))];
  if (src) body.push({ text: 'Sumber: ' + src, options: { fontSize: 10, color: C.accent4 } });
  s.addText(body, { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 1.1, y, w: 7.3, h, fill: { color: fill }, line: { color: ln, width: 1.5 }, valign: 'middle', margin: [4, 10, 4, 10], color: C.text1, objectName: 'step' + no });
  if (ex) s.addText(ex, { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 8.6, y, w: 4.2, h, fill: { color: C.accent6 }, line: { color: C.accent6 }, valign: 'middle', margin: [4, 10, 4, 10], fontSize: 11.5, color: C.text1, objectName: 'ex' + no });
}
const B = (t, br) => ({ t, o: { bold: true }, br });
const G = (t, br) => ({ t, o: { bold: true, color: C.accent2 }, br });
const T = (t, br) => ({ t, br });
function ex(arr) { return arr.map((r, i) => { const o = Object.assign({ fontSize: 11.5 }, r.o || {}); if (r.br) o.breakLine = true; return { text: r.t, options: o }; }); }
function hdr(s, y) {
  s.addText('ALUR', { x: 1.1, y, w: 3, h: 0.25, isTextBox: true, fontSize: 10, bold: true, color: C.accent4, margin: 0 });
  s.addText('CONTOH DATA DEV', { x: 8.6, y, w: 4, h: 0.25, isTextBox: true, fontSize: 10, bold: true, color: C.accent4, margin: 0 });
}

// ---------- Slide 1: Alias
let s = pres.addSlide({ masterName: 'TITLE_ONLY' });
s.addText('COA — Alur Product Name (Alias)', { placeholder: 'title' });
s.addText('Contoh: DO 0085006276 (1 alias) · DO 0085006277 (lebih dari 1 alias) · DO 0085006278 (tanpa alias) · Data: DEV', { placeholder: 'sub' });
hdr(s, 1.35);
stepRow(s, 1.65, 0.95, 1, 'n', 'Ambil batch dari DO', ['Sistem membaca semua batch yang ada di Delivery Order.'], 'Delivery item (LIPS)',
  ex([T('DO 0085006276 → batch 0000406885 (SRACBI)', 1), T('DO 0085006277 → 18 batch (SRACBI)', 1), T('DO 0085006278 → batch 0000406850 (SRGLBI)')]));
stepRow(s, 2.75, 1.45, 2, 'n', 'Baca karakteristik batch', ['Seperti di MSC3N tab Classification: ', B('Alias'), T(', '), B('Type'), T(', dan '), B('Thickness'), T('.')], 'Klasifikasi batch, class type 023 (MCH1, INOB, CABN, AUSP)', null);
s.addTable([
  [{ text: 'Karakteristik', options: { bold: true, color: C.background1, fill: { color: C.accent1 } } }, { text: 'DO …6276', options: { bold: true, color: C.background1, fill: { color: C.accent1 } } }, { text: 'DO …6277', options: { bold: true, color: C.background1, fill: { color: C.accent1 } } }, { text: 'DO …6278', options: { bold: true, color: C.background1, fill: { color: C.accent1 } } }],
  ['Alias', { text: 'HSB-18', options: { bold: true, color: C.accent2 } }, { text: 'HSS-18 / HSP-18', options: { bold: true, color: C.accent2 } }, '(kosong)'],
  ['Type', 'HSB4', 'HSB4', 'MB51'], ['Thickness', '18', '18', '50']],
  { x: 8.6, y: 2.75, w: 4.2, colW: [0.95, 1.0, 1.35, 0.9], rowH: 0.3, fontSize: 10, color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D2E0' }, fill: { color: C.background1 }, margin: [2, 5, 2, 5], objectName: 'tblChar' });
stepRow(s, 4.35, 1.0, 3, 'd', 'Alias terisi?', [B('YA'), T(' → Product Name = Alias', 1), B('TIDAK'), T(' → Product Name = Type + "-" + Thickness')], null,
  ex([T('DO 0085006276 → '), G('HSB-18', 1), T('DO 0085006278 → '), G('MB51-50'), T(' (Type + Thickness)')]));
stepRow(s, 5.5, 1.0, 4, 'o', 'Tampil di COA', [T('• Product Name di header sertifikat (Domestic & Export)', 1), T('• Kolom Type di Batch List')], null,
  ex([T('DO 0085006276 = '), G('HSB-18', 1), T('DO 0085006277 = per batch '), G('HSS-18'), T(' (12 roll) & '), G('HSP-18'), T(' (6 roll)', 1), T('DO 0085006278 = '), G('MB51-50')]));
s.addText([{ text: 'DO lebih dari 1 alias: ', options: { bold: true } }, { text: 'Batch List menampilkan alias per batch. Header sertifikat memakai alias batch pertama yang terisi; untuk Export, Product Name bisa diubah di pop-up header saat print.' }],
  { x: 0.5, y: 6.7, w: 12.3, h: 0.5, isTextBox: true, fontSize: 11, color: C.text1, margin: 0, valign: 'top' });

// ---------- Slide 2: 4 tahap
s = pres.addSlide({ masterName: 'TITLE_ONLY' });
s.addText('COA — Alur Produksi 4 Tahap (BF → Coat → Metz → Coat)', { placeholder: 'title' });
s.addText('Contoh: DO 0085006278 · material SRGLBI · 10 roll · Data: DEV', { placeholder: 'sub' });
s.addText('1. Silsilah produksi (ditelusuri mundur dari batch DO)', { x: 0.5, y: 1.3, w: 12, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
const stg = [
  ['Tahap 1 · Base Film', 'JRAH8I 0000406687', 'lot 040000021013', 'SRAH8I 0000406719', 'pakai lot SR saudara', 'SRGKAA 0000406742', '0000406719'],
  ['Tahap 2 · Coat', 'JRGKAI 0000406735', 'lot 040000021022', 'SRGKAI 0000406760', 'lot 050000014280', 'SRGLAA 0000406788', '0000406760'],
  ['Tahap 3 · Metz', 'JRGLAI 0000406781', 'lot 040000021033', 'SRGLAI 0000406810', 'lot 050000014288', 'SRGLBA 0000406820', '0000406810'],
  ['Tahap 4 · Coat (dikirim)', 'JRGLBI 0000406821', 'lot 040000021043', 'SRGLBI 0000406850', 'lot 050000014314', null, null]];
const cw = 2.85, gap = 0.3;
stg.forEach((g, i) => {
  const x = 0.5 + i * (cw + gap), fin = i === 3, col = fin ? C.accent2 : C.accent1;
  s.addText(g[0], { shape: pres.shapes.RECTANGLE, x, y: 1.7, w: cw, h: 0.35, fill: { color: col }, line: { color: col }, fontSize: 12, bold: true, color: C.background1, margin: 6, objectName: 'stgH' + (i + 1) });
  s.addText([{ text: 'JR ', options: { breakLine: false } }, { text: g[1], options: { bold: true, breakLine: true } }, { text: g[2], options: { fontSize: 10, color: C.accent4 } }],
    { shape: pres.shapes.RECTANGLE, x, y: 2.05, w: cw, h: 0.55, fill: { color: C.background1 }, line: { color: col }, fontSize: 11.5, color: C.text1, margin: 6, objectName: 'stgJR' + (i + 1) });
  s.addText([{ text: 'SR ' }, { text: g[3], options: { bold: true, breakLine: true } }, { text: g[4], options: { fontSize: 10, color: C.accent4 } }],
    { shape: pres.shapes.RECTANGLE, x, y: 2.6, w: cw, h: 0.55, fill: { color: C.background1 }, line: { color: col }, fontSize: 11.5, color: C.text1, margin: 6, objectName: 'stgSR' + (i + 1) });
  const last = fin ? [{ text: '= batch di DO 0085006278' }] : [{ text: '→ jadi material ' }, { text: g[5], options: { bold: true, breakLine: true } }, { text: 'Vendor Batch = ' + g[6], options: { fontSize: 10, color: C.accent4 } }];
  s.addText(last, { shape: pres.shapes.RECTANGLE, x, y: 3.15, w: cw, h: 0.55, fill: { color: fin ? C.accent6 : C.accent5 }, line: { color: col }, fontSize: 11, color: C.text1, margin: 6, objectName: 'stgMat' + (i + 1) });
  if (i < 3) s.addShape(pres.shapes.RIGHT_ARROW, { x: x + cw + 0.04, y: 2.55, w: 0.22, h: 0.25, fill: { color: C.accent1 }, line: { color: C.accent1 }, objectName: 'arr' + (i + 1) });
});
s.addText('2. Cara sistem menelusuri', { x: 0.5, y: 3.85, w: 12, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
const how = [
  ['A. SR → JR induk', 'SR berasal dari JR mana (hasil slitting).', 'FM ZQM_GET_BATCH_JR_BY_SR'],
  ['B. JR → SR tahap sebelumnya', 'Lihat production order JR: SR apa yang dipakai (goods issue), dicocokkan per roll.', 'MSEG 101/261, MKPF-BKTXT, AFPO'],
  ['C. Material SR*A → SR asli', 'SR diproses jadi SR*A / SR*O (order M). SR asli dibaca dari Vendor Batch. SR*X (outsource) dipakai langsung.', 'MCH1-LICHA'],
  ['D. Ulangi sampai Base Film', 'Sampai JR hanya memakai bahan baku (maks. 10 tahap). Lot tiap tahap dikumpulkan.', 'QALS Z04 (SR), Z02/Z03 (JR)']];
how.forEach((h, i) => {
  s.addText([{ text: h[0], options: { bold: true, fontSize: 12.5, breakLine: true } }, { text: h[1], options: { fontSize: 11, breakLine: true } }, { text: 'Sumber: ' + h[2], options: { fontSize: 9.5, color: C.accent4 } }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 0.5 + i * (cw + gap), y: 4.2, w: cw, h: 1.3, fill: { color: C.background2 }, line: { color: C.accent1, width: 1.25 }, valign: 'top', margin: [5, 8, 5, 8], color: C.text1, objectName: 'how' + (i + 1) });
});
s.addText('3. Parameter COA diambil dari tahap yang punya parameter tersebut (mapping hanya menyebut SR / JR)', { x: 0.5, y: 5.6, w: 12.3, h: 0.3, isTextBox: true, fontSize: 13, bold: true, color: C.text1, margin: 0 });
const H = t => ({ text: t, options: { bold: true, color: C.background1, fill: { color: C.accent1 } } });
s.addTable([[H('Parameter (MIC)'), H('Mapping'), H('Ketemu di tahap'), H('Lot'), H('Nilai rata-rata')],
  ['Tensile MD/TD, Elongation MD/TD (PAH8*)', 'JR Base Film', '1 · JRAH8I', '040000021013', '0.00 / 0'],
  ['Shrinkage MD/TD, Gloss 60° (PGLASH*, PGLAG6CD)', 'JR Converting', '3 · JRGLAI', '040000021033', '2.62 / 0.34 / 636'],
  ['Surface Tension Coated / Metz (SGLAST*)', 'SR Converting', '3 · SRGLAI', '050000014288', '42 / 52'],
  ['Optical Density (PGLBOD00)', 'JR Converting', '4 · JRGLBI', '040000021043', '2.378']],
  { x: 0.5, y: 5.95, w: 12.3, colW: [4.3, 2.0, 2.0, 2.0, 2.0], rowH: 0.27, fontSize: 10.5, color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D2E0' }, fill: { color: C.background1 }, margin: [1, 6, 1, 6], objectName: 'tblParam' });

// ---------- Slide 3: Outsource
s = pres.addSlide({ masterName: 'TITLE_ONLY' });
s.addText('COA — Alur Outsource (Base Film dari Luar)', { placeholder: 'title' });
s.addText('Contoh: DO 0085006279 · material SREC7I · Data: DEV', { placeholder: 'sub' });
hdr(s, 1.35);
const h3 = 0.85, g3 = 0.1; let y = 1.65;
stepRow(s, y, h3, 0, 'n', 'Ambil batch DO & mapping parameter', ['Sama dengan flow produksi.'], 'Delivery (LIPS) · Mapping COA (ZMAP_COA)',
  ex([T('Batch 0000407199 (SREC7I)', 1), T('Mapping: SR Conv, JR Conv, SR Base Film; tanpa JR Base')])); y += h3 + g3;
stepRow(s, y, h3, 1, 'n', 'SR Converting', ['Batch DO tidak punya lot sendiri → pakai lot SR lain dari JR yang sama.'], 'Inspection lot Z04',
  ex([T('Lot dari SR saudara (satu JR induk)')])); y += h3 + g3;
stepRow(s, y, h3, 2, 'n', 'JR Converting', ['Cari JR induk, lalu ambil lot JR-nya.'], 'Relasi SR → JR · Inspection lot Z02/Z03',
  ex([T('JR '), B('0000407183'), T(' (JREC7I)', 1), T('lot 040000021124')])); y += h3 + g3;
stepRow(s, y, h3, 3, 'n', 'SR Base Film outsource', [T('SR Base Film yang dipakai JR: material outsource '), B('SR*X'), T(' (bisa juga '), B('SR*O'), T('). Ambil lot-nya.')], 'Goods issue 261 (MSEG) · Inspection lot Z04',
  ex([T('SRVLCX 0000407171 – 0000407174', 1), T('lot '), G('050000014330')])); y += h3 + g3;
stepRow(s, y, h3, 4, 'd', 'Penelusuran berhenti', ['Base film datang dari vendor, tidak ada JR Base Film di SAP.'], null,
  ex([T('JR Base Film: tidak ada (sesuai mapping)')])); y += h3 + g3;
stepRow(s, y, h3, 5, 'o', 'Ambil nilai & rata-rata', ['Sama dengan flow produksi. Parameter Base Film (tensile, elongation, shrinkage) dari lot base film outsource.'], null,
  ex([T('Product Name: '), G('MZUBD-18'), T(' (Type + Thickness)')]));

(async () => { await pres.writeFile({ fileName: 'COA_Alur_Internal.pptx' }); await applyTheme('COA_Alur_Internal.pptx', THEME); })();
