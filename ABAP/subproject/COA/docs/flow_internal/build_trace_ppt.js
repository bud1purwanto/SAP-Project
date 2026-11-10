const pptxgen = require('pptxgenjs');
const { applyTheme } = require('/home/abap/.claude/remote/plugins/6a513545/7b4711ebc297ee06/skills/pptx/scripts/apply_theme.js');
const THEME = { name: 'COA Trace', headFontFace: 'Calibri', bodyFontFace: 'Calibri',
  colors: { dk1: '1D2433', lt1: 'FFFFFF', dk2: '1F4E79', lt2: 'F4F8FC', accent1: '1F4E79', accent2: '2E7D32',
    accent3: 'C47F00', accent4: '6B7385', accent5: 'FFF8E8', accent6: 'EEF8EF', hlink: '1F4E79', folHlink: '6B7385' } };
const pres = new pptxgen(); pres.layout = 'LAYOUT_WIDE'; pres.theme = { headFontFace: 'Calibri', bodyFontFace: 'Calibri' };
const C = pres.SchemeColor;
pres.defineSlideMaster({ title: 'TITLE_ONLY', background: { color: 'FFFFFF' }, objects: [
  { placeholder: { options: { name: 'title', type: 'title', x: 0.5, y: 0.3, w: 12.3, h: 0.6, fontSize: 26, bold: true, color: C.text1, valign: 'top', margin: 0 }, text: '' } },
  { placeholder: { options: { name: 'sub', type: 'body', x: 0.5, y: 0.9, w: 12.3, h: 0.35, fontSize: 13, color: C.accent4, margin: 0 }, text: '' } } ] });
const H = t => ({ text: t, options: { bold: true, color: C.background1, fill: { color: C.accent1 } } });
const G = t => ({ text: t, options: { bold: true, color: C.accent2 } });

// ---------- Slide 1: alur end-to-end
let s = pres.addSlide({ masterName: 'TITLE_ONLY' });
s.addText('COA — Alur dari DO sampai Nilai Parameter', { placeholder: 'title' });
s.addText('Bagaimana sistem menentukan nilai setiap parameter (MIC) yang tercetak di COA', { placeholder: 'sub' });
const steps = [
  ['1', 'Baca DO', 'Ambil semua batch (roll) yang dikirim, material, dan customer.', 'Delivery Order', 'n'],
  ['2', 'Baca Mapping COA', 'Daftar parameter yang dicetak untuk material + customer ini, beserta asal tahapnya (SR/JR, Converting/Base Film), urutan, metode, dan spesifikasi.', 'Mapping COA per material / customer → slide 2', 'n'],
  ['3', 'Telusuri silsilah produksi', 'Dari roll di DO mundur ke tahap sebelumnya: SR → JR induk → SR yang dipakai JR → … sampai Base Film. Kalau film dari vendor (outsource), penelusuran berhenti di situ.', 'Data produksi & Vendor Batch → contoh per flow: slide 3–6', 'n'],
  ['4', 'Pilih inspection lot per parameter', 'Cari tahap yang menguji parameter itu. SR tanpa lot → lot SR saudara (JR sama). JR tanpa hasil → roll JR sebelumnya di production order yang sama.', 'Inspection lot SR / JR', 'd'],
  ['5', 'Ambil hasil inspeksi', 'Ambil nilai hasil uji (mean value) parameter tersebut dari setiap lot yang terkait dengan roll di DO.', 'Hasil inspeksi (QA32 / QE51N)', 'n'],
  ['6', 'Hitung & format', 'Rata-rata dari lot yang dipakai roll di DO (lot yang sama dihitung sekali; lot tanpa hasil tidak dihitung). MVTR/OTR: nilai cycle terakhir uji barrier. Desimal ikut master MIC.', 'Master MIC', 'n'],
  ['7', 'Cetak COA', 'Nilai rata-rata per parameter tampil di sertifikat sesuai urutan mapping, bersama Product Name (alias) dan Batch List.', 'Form COA · Product Name → slide 7', 'o']];
const KIND = { n: [C.accent1, C.background2], d: [C.accent3, C.accent5], o: [C.accent2, C.accent6] };
const rowH = 0.72, gap = 0.08; let y = 1.4;
steps.forEach(st => {
  const [ln, fill] = KIND[st[4]];
  s.addShape(pres.shapes.OVAL, { x: 0.5, y: y + rowH / 2 - 0.22, w: 0.44, h: 0.44, fill: { color: C.accent1 }, line: { color: C.accent1 }, objectName: 'no' + st[0] });
  s.addText(st[0], { x: 0.5, y: y + rowH / 2 - 0.22, w: 0.44, h: 0.44, isTextBox: true, align: 'center', valign: 'middle', fontSize: 14, bold: true, color: C.background1, margin: 0 });
  s.addText([{ text: st[1], options: { bold: true, fontSize: 14, breakLine: true } }, { text: st[2], options: { fontSize: 12 } }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 1.1, y, w: 8.6, h: rowH, fill: { color: fill }, line: { color: ln, width: 1.5 }, valign: 'middle', margin: 6, color: C.text1, objectName: 'step' + st[0] });
  s.addText([{ text: 'Data: ', options: { bold: true } }, { text: st[3] }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 9.9, y, w: 2.9, h: rowH, fill: { color: C.background2 }, line: { color: C.background2 }, valign: 'middle', margin: 6, fontSize: 11.5, color: C.text1, objectName: 'data' + st[0] });
  y += rowH + gap;
});

require('./slide_master.js')(pres, C, H);
require('./slide_bf.js')(pres, C, H, G);
require('./slide_rule.js')(pres, C, H, G);
// ---------- Slide 2: contoh DO 0085006278
s = pres.addSlide({ masterName: 'TITLE_ONLY' });
s.addText('Flow Multi-level (4 Tahap): DO 0085006278', { placeholder: 'title' });
s.addText('Material SRGLBI · 10 roll · Produksi 4 tahap (Base Film → Coat → Metz → Coat) · Data: hasil program COA di DEV', { placeholder: 'sub' });
s.addText('Silsilah produksi (hasil langkah 3)', { x: 0.5, y: 1.3, w: 12, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
const stg = [['Tahap 1 · Base Film', 'JRAH8I', 'SRAH8I', C.accent1], ['Tahap 2 · Coat', 'JRGKAI', 'SRGKAI', C.accent1], ['Tahap 3 · Metz', 'JRGLAI', 'SRGLAI', C.accent1], ['Tahap 4 · Coat (dikirim)', 'JRGLBI', 'SRGLBI', C.accent2]];
const cw = 2.85, cg = 0.3;
stg.forEach((g, i) => {
  const x = 0.5 + i * (cw + cg);
  s.addText([{ text: g[0], options: { bold: true, breakLine: true, color: C.background1 } }, { text: 'JR ' + g[1] + '  →  SR ' + g[2], options: { color: C.background1 } }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x, y: 1.65, w: cw, h: 0.7, fill: { color: g[3] }, line: { color: g[3] }, fontSize: 12, margin: 6, valign: 'middle', objectName: 'stg' + (i + 1) });
  if (i < 3) s.addShape(pres.shapes.RIGHT_ARROW, { x: x + cw + 0.04, y: 1.88, w: 0.22, h: 0.25, fill: { color: C.accent1 }, line: { color: C.accent1 }, objectName: 'arr' + (i + 1) });
});
s.addText('Nilai per parameter (langkah 4 → 6)', { x: 0.5, y: 2.55, w: 12, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
s.addTable([
  [H('Parameter'), H('Mapping COA'), H('Diambil dari tahap'), H('Nilai yang dihitung'), H('Di COA')],
  ['Tensile Strength MD / TD', 'JR Base Film', 'Tahap 1 · JRAH8I', 'Tidak ada hasil di semua roll JR', G('0.00 / 0.00')],
  ['Elongation MD / TD', 'JR Base Film', 'Tahap 1 · JRAH8I', 'Tidak ada hasil di semua roll JR', G('0 / 0')],
  ['Shrinkage MD / TD', 'JR Converting', 'Tahap 3 · JRGLAI', 'Roll 4–10: 2.62 / 0.34 (roll 1–3 tanpa hasil, tidak dihitung)', G('2.62 / 0.34')],
  ['Gloss 60° (Coated Side)', 'JR Converting', 'Tahap 3 · JRGLAI', 'Roll 4–10: 636', G('636')],
  ['Surface Tension Coated Side', 'SR Converting', 'Tahap 3 · SRGLAI', '38, 42, 42, 42, 42, 42, 42, 42, 44, 44', G('42')],
  ['Surface Tension Metz Side', 'SR Converting', 'Tahap 3 · SRGLAI', '52, 48, 48, 48, 42, 56, 56, 56, 58, 58', G('52')],
  ['Optical Density', 'JR Converting', 'Tahap 4 · JRGLBI', '2.33 (7 roll), 2.49 (3 roll)', G('2.38')]],
  { x: 0.5, y: 2.9, w: 12.3, colW: [2.6, 1.7, 2.0, 4.4, 1.6], rowH: 0.4, fontSize: 12, color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D2E0' }, fill: { color: C.background1 }, margin: [2, 6, 2, 6], valign: 'middle', objectName: 'tblValue' });
s.addText([{ text: 'Catatan: ', options: { bold: true } }, { text: 'Mapping COA hanya menyebut jenis tahap (SR/JR). Shrinkage, Gloss dan Surface Tension diuji di tahap Metz, sehingga sistem mengambil dari tahap 3 walaupun produk yang dikirim adalah tahap 4. Tahap 2 (Coat pertama) tidak punya parameter di mapping, jadi tidak tampil di COA.' }],
  { x: 0.5, y: 6.3, w: 12.3, h: 0.8, isTextBox: true, fontSize: 11.5, color: C.text1, margin: 0, valign: 'top' });

require('./slide_out.js')(pres, C, H, G);
require('./slide_alias.js')(pres, C, H, G);
(async () => { await pres.writeFile({ fileName: 'COA_Alur_DO_ke_Nilai_MIC.pptx' }); await applyTheme('COA_Alur_DO_ke_Nilai_MIC.pptx', THEME); })();
