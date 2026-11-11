// Deck QA: Mapping ZMAP_COA berbasis Alias (ZQM002) — rencana, belum dieksekusi
const pptxgen = require('pptxgenjs');
const { applyTheme } = require('/home/abap/.claude/remote/plugins/6a513545/eaa86030e55e0d06/skills/pptx/scripts/apply_theme.js');
const OUT = __dirname + '/../docs/Alias_Mapping_ZQM002_QA.pptx';

const THEME = { name: 'COA Alias', headFontFace: 'Cambria', bodyFontFace: 'Calibri',
  colors: { dk1: '1B2A33', lt1: 'FFFFFF', dk2: '0B4F5C', lt2: 'EEF5F6',
    accent1: '0B6E7F', accent2: '2E7D4F', accent3: 'C2571A', accent4: '5F6B73',
    accent5: 'FCEEE5', accent6: 'E6F3EC', hlink: '0B6E7F', folHlink: '5F6B73' } };

const pres = new pptxgen();
pres.layout = 'LAYOUT_WIDE';
pres.theme = { headFontFace: THEME.headFontFace, bodyFontFace: THEME.bodyFontFace };
pres.title = 'Mapping COA berbasis Alias — Konfirmasi QA';
const C = pres.SchemeColor;

pres.defineSlideMaster({ title: 'DARK', background: { color: THEME.colors.dk2 }, objects: [
  { placeholder: { options: { name: 'title', type: 'title', x: 0.8, y: 2.3, w: 11.7, h: 1.6, fontSize: 40, bold: true, color: C.background1, valign: 'bottom', align: 'left', margin: 0 }, text: '' } },
  { placeholder: { options: { name: 'body', type: 'body', x: 0.8, y: 4.1, w: 11.7, h: 1.2, fontSize: 18, color: C.background2, valign: 'top', margin: 0 }, text: '' } } ] });
pres.defineSlideMaster({ title: 'CONTENT', background: { color: 'FFFFFF' }, objects: [
  { placeholder: { options: { name: 'title', type: 'title', x: 0.6, y: 0.35, w: 12.1, h: 0.75, fontSize: 30, bold: true, color: C.text2, valign: 'top', align: 'left', margin: 0 }, text: '' } },
  { placeholder: { options: { name: 'sub', type: 'body', x: 0.6, y: 1.1, w: 12.1, h: 0.4, fontSize: 15, color: C.accent4, margin: 0 }, text: '' } },
  { text: { text: 'ZQM002 · Mapping berbasis Alias · Rencana (belum dieksekusi)', options: { x: 0.6, y: 7.05, w: 8, h: 0.3, fontSize: 10, color: '5F6B73', margin: 0 } } } ],
  slideNumber: { x: 12.2, y: 7.05, w: 0.5, h: 0.3, fontSize: 10, color: '5F6B73', align: 'right' } });

const card = (s, x, y, w, h, fill, line, name) => s.addShape(pres.shapes.ROUNDED_RECTANGLE,
  { x, y, w, h, rectRadius: 0.1, fill: { color: fill }, line: { color: line || fill, width: 1.25 }, objectName: name });
const circ = (s, x, y, n, color, name) => {
  s.addShape(pres.shapes.OVAL, { x, y, w: 0.55, h: 0.55, fill: { color }, line: { color }, objectName: name });
  s.addText(String(n), { x, y, w: 0.55, h: 0.55, isTextBox: true, align: 'center', valign: 'middle', fontSize: 18, bold: true, color: C.background1, margin: 0 });
};
const tbl = (rows, hdrFill) => rows.map((r, i) => r.map(c => {
  const o = typeof c === 'object' ? c : { text: String(c) };
  const base = i === 0 ? { bold: true, color: C.background1, fill: { color: hdrFill || C.accent1 } } : {};
  return { text: o.text, options: Object.assign({ fontSize: 13, valign: 'middle' }, base, o.options || {}) };
}));
const TOPT = { fontFace: 'Calibri', color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D6DA' }, margin: [4, 8, 4, 8] };

// 1. Title
pres.addSection({ title: 'Pembuka' });
let s = pres.addSlide({ masterName: 'DARK', sectionTitle: 'Pembuka' });
s.addText('Mapping COA berbasis Alias', { placeholder: 'title' });
s.addText('ZQM002 · Usulan desain dan pertanyaan konfirmasi untuk QA · 11 November 2026', { placeholder: 'body' });
s.addNotes('Tujuan sesi: menjelaskan usulan agar alias batch menjadi patokan utama mapping ZMAP_COA, menunjukkan temuan data PRD, dan meminta keputusan QA atas 5 pertanyaan. Belum ada perubahan program.');

// 2. Permintaan + hierarki
pres.addSection({ title: 'Usulan' });
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Usulan' });
s.addText('Alias menjadi kunci utama pencarian mapping', { placeholder: 'title' });
s.addText('Alias sama = 1 mapping, walaupun material atau FTYPE batch berbeda', { placeholder: 'sub' });
const flow = [
  ['Batch punya alias', 'ZZALIAS dari klasifikasi batch', C.background2, C.accent1],
  ['Alias → material', 'Lewat FTYPE-THICK di material master', C.background2, C.accent1],
  ['Mapping material alias', 'ZMAP_COA: customer dulu, lalu umum', C.accent6, C.accent2],
  ['Fallback material DO', 'Logic sekarang, kalau alias gagal / tanpa mapping', C.accent5, C.accent3]];
flow.forEach((f, i) => {
  const x = 0.6 + i * 3.1;
  card(s, x, 2.0, 2.75, 2.35, f[2], f[3], 'flow' + i);
  circ(s, x + 0.2, 2.2, i + 1, f[3], 'flowNo' + i);
  s.addText([{ text: f[0], options: { bold: true, fontSize: 17, breakLine: true } }, { text: f[1], options: { fontSize: 14 } }],
    { x: x + 0.2, y: 2.85, w: 2.4, h: 1.4, isTextBox: true, valign: 'top', color: C.text1, margin: 0 });
  if (i < 3) s.addShape(pres.shapes.RIGHT_TRIANGLE, { x: x + 2.82, y: 2.9, w: 0.22, h: 0.3, rotate: 90, fill: { color: C.accent4 }, line: { color: C.accent4 }, objectName: 'arr' + i });
});
s.addText([
  { text: 'Aturan yang sudah disepakati', options: { bold: true, fontSize: 16, breakLine: true } },
  { text: 'Mapping dibaca per batch, jadi 1 DO dengan alias berbeda bisa punya MIC berbeda', options: { bullet: true, breakLine: true } },
  { text: 'Mapping material alias tidak digabung dengan mapping material DO', options: { bullet: true, breakLine: true } },
  { text: 'Alias gagal dikonversi → pakai mapping material DO + warning di layar', options: { bullet: true, breakLine: true } },
  { text: 'Struktur ZMAP_COA, aturan limit per kolom, dan filter deletion tidak berubah', options: { bullet: true } }],
  { x: 0.6, y: 4.75, w: 12.1, h: 2.1, isTextBox: true, fontSize: 15, color: C.text1, valign: 'top', paraSpaceAfter: 4, margin: 0 });

// 3. Konversi
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Usulan' });
s.addText('Alias dikonversi lewat FTYPE-THICK material', { placeholder: 'title' });
s.addText('Material sudah menyimpan FTYPE-THICK di dua tempat dengan isi yang sama (data DEV)', { placeholder: 'sub' });
s.addTable(tbl([['Material', 'MAKT', 'ZZCODE', 'Teks ZZCODE'],
  ['SRACBI', 'SLITT ROLL HSB4-18', 'ACB', 'HSB4-18'], ['SRCASI', 'SLITT ROLL EPB-12', 'CAS', 'EPB-12'],
  ['SREASI', 'SLITT ROLL MZOB-50', 'EAS', 'MZOB-50'], ['SRALZI', 'SLITT ROLL PWLMI7-70', '–', '–']]),
  Object.assign({ x: 0.6, y: 1.75, w: 7.0, colW: [1.3, 2.7, 1.2, 1.8] }, TOPT));
card(s, 8.0, 1.75, 4.7, 2.0, C.background2, C.accent1, 'urutan');
s.addText([{ text: 'Urutan konversi', options: { bold: true, fontSize: 16, breakLine: true } },
  { text: 'Teks ZZCODE = alias (utama)', options: { bullet: { type: 'number' }, breakLine: true } },
  { text: 'MAKT = awalan + alias (cadangan)', options: { bullet: { type: 'number' }, breakLine: true } },
  { text: 'Lebih dari 1 material: jenis sama dengan DO, lalu yang punya mapping', options: { bullet: { type: 'number' } } }],
  { x: 8.2, y: 1.9, w: 4.3, h: 1.75, isTextBox: true, fontSize: 14, color: C.text1, valign: 'top', paraSpaceAfter: 4, margin: 0 });
s.addTable(tbl([['Alias di batch', 'Hasil konversi'],
  ['HSS-18', { text: 'SRACJI (SLITT ROLL HSS-18)', options: { color: C.accent2, bold: true } }],
  ['HSB-18 · HSP-18 · HS - 18 M', { text: 'Tidak ditemukan → fallback material DO', options: { color: C.accent3, bold: true } }]], C.text2),
  Object.assign({ x: 0.6, y: 4.6, w: 12.1, colW: [4.5, 7.6] }, TOPT));

// 4. PRD alias sama material beda
pres.addSection({ title: 'Temuan PRD' });
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Temuan PRD' });
s.addText('Di PRD, satu alias memang dipakai beberapa material', { placeholder: 'title' });
s.addText('Sampel 50.000 nilai alias batch (131 alias unik), 8 batch per alias ditelusuri ke materialnya', { placeholder: 'sub' });
s.addTable(tbl([['Alias', 'Material (FTYPE-THICK)'],
  ['GLOSS', 'SRIBRI (LCAT-24) · SRIARI (LC01-22)'], ['LC02', 'SRIARI (LC01-22) · SRIASI (LC02-20)'],
  ['LF01', 'SRICRI (LF01-25) · SRKYGI (TLF01-25)'], ['KZMB-9', 'SREWCI (ZMB-9) · SRKPKI (TZMB-9) · SREUAI (ZB-9)'],
  ['VMPET-9', 'SRKPKI (TZMB-9) · SREUAI (ZB-9)']]), Object.assign({ x: 0.6, y: 1.75, w: 7.4, colW: [1.6, 5.8] }, TOPT));
card(s, 8.4, 1.75, 4.3, 2.75, C.accent5, C.accent3, 'ejaan');
s.addText([{ text: 'Ejaan alias tidak konsisten', options: { bold: true, fontSize: 16, color: C.accent3, breakLine: true } },
  { text: 'Satu material dipakai banyak alias:', options: { breakLine: true } },
  { text: 'SRCADI: KTM-12, KTM, GP/FDW, PPF-12, IF-12', options: { bullet: true, breakLine: true } },
  { text: 'SRCAHI: KTM.12, KTM.', options: { bullet: true, breakLine: true } },
  { text: 'Kalau dicocokkan persis, "KTM-12" dan "KTM.12" dianggap alias berbeda', options: { breakLine: true } }],
  { x: 8.6, y: 1.9, w: 3.9, h: 2.5, isTextBox: true, fontSize: 14, color: C.text1, valign: 'top', paraSpaceAfter: 4, margin: 0 });

// 5. MIC beda
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Temuan PRD' });
s.addText('Alias sama, tapi kode MIC dan kadang limitnya beda', { placeholder: 'title' });
s.addText('Perbandingan MIC dari inspection lot Z04 terakhir per material (PRD)', { placeholder: 'sub' });
const R = t => ({ text: t, options: { color: C.accent3, bold: true } });
const G = t => ({ text: t, options: { color: C.accent2, bold: true } });
s.addTable(tbl([['Alias', 'Material', 'Kode MIC', 'Deskripsi', 'Limit'],
  ['GLOSS', 'SRIBRI vs SRIARI', R('SIBR* vs SIAR*'), G('Sama'), R('Seal to Paper 3.5–6.5 vs 3.0–5.5')],
  ['LC02', 'SRIARI vs SRIASI', R('SIAR* vs SIAS*'), G('Sama'), G('Sama')],
  ['LF01', 'SRICRI vs SRKYGI', R('SICR* vs SKYG*'), G('Sama'), G('Sama')],
  ['KZMB-9', 'SREWCI vs SRKPKI', R('SEWC* vs SKPK*'), G('Sama'), R('Optical Density 2.7–3.3 vs 3.0–3.5')]]),
  Object.assign({ x: 0.6, y: 1.75, w: 12.1, colW: [1.3, 2.4, 2.3, 1.4, 4.7] }, TOPT));
card(s, 0.6, 4.0, 12.1, 1.75, C.background2, C.accent1, 'dampak');
s.addText([{ text: 'Dampak ke desain', options: { bold: true, fontSize: 16, breakLine: true } },
  { text: 'Kode MIC = S + kode film + akhiran properti (SIBR', options: {} }, { text: 'SPTH', options: { bold: true } },
  { text: ' dan SIAR', options: {} }, { text: 'SPTH', options: { bold: true } }, { text: ')', options: { breakLine: true } },
  { text: 'Mapping material alias harus diterjemahkan ke MIC milik batch, kalau tidak Value akan kosong', options: { bullet: true, breakLine: true } },
  { text: 'Usulan: cocokkan lewat akhiran properti, cadangannya lewat deskripsi MIC', options: { bullet: true } }],
  { x: 0.8, y: 4.15, w: 11.7, h: 1.5, isTextBox: true, fontSize: 15, color: C.text1, valign: 'top', paraSpaceAfter: 4, margin: 0 });

// 6. Traceability
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Temuan PRD' });
s.addText('Traceability batch tidak berubah', { placeholder: 'title' });
s.addText('Alias hanya mengubah cara COA ditampilkan, bukan asal nilai hasil inspeksi', { placeholder: 'sub' });
card(s, 0.6, 1.75, 5.9, 3.0, C.accent6, C.accent2, 'tetap');
s.addText([{ text: 'Tetap dari batch asli', options: { bold: true, fontSize: 18, color: C.accent2, breakLine: true } },
  { text: 'Material dan batch di DO', options: { bullet: true, breakLine: true } },
  { text: 'Inspection lot dan genealogi multi-level', options: { bullet: true, breakLine: true } },
  { text: 'Nilai hasil (Value) per MIC', options: { bullet: true, breakLine: true } },
  { text: 'Batch List per roll', options: { bullet: true } }],
  { x: 0.9, y: 2.0, w: 5.3, h: 2.6, isTextBox: true, fontSize: 16, color: C.text1, valign: 'top', paraSpaceAfter: 6, margin: 0 });
card(s, 6.8, 1.75, 5.9, 3.0, C.background2, C.accent1, 'berubah');
s.addText([{ text: 'Diambil dari mapping alias', options: { bold: true, fontSize: 18, color: C.accent1, breakLine: true } },
  { text: 'Daftar MIC yang tampil dan urutannya', options: { bullet: true, breakLine: true } },
  { text: 'Deskripsi, method, dan UOM', options: { bullet: true, breakLine: true } },
  { text: 'Lower/Upper limit, kalau diisi di mapping', options: { bullet: true, breakLine: true } },
  { text: 'Perlu keputusan QA: limit mana yang dicetak kalau spec material asli berbeda', options: { bold: true, color: C.accent3 } }],
  { x: 7.1, y: 2.0, w: 5.3, h: 2.6, isTextBox: true, fontSize: 16, color: C.text1, valign: 'top', paraSpaceAfter: 6, margin: 0 });

// 7. Pertanyaan QA
pres.addSection({ title: 'Konfirmasi' });
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Konfirmasi' });
s.addText('Lima keputusan yang dibutuhkan dari QA', { placeholder: 'title' });
s.addText('Jawaban QA menentukan desain final sebelum program diubah', { placeholder: 'sub' });
const qs = [
  ['Limit', 'Alias sama tapi spec beda (GLOSS, KZMB-9): cetak limit mapping alias atau limit material asli?'],
  ['Ejaan alias', 'KTM-12, KTM.12, KTM, KTM. dianggap alias yang sama? Kalau ya, perlu aturan normalisasi atau master alias'],
  ['Alias tak dikenal', 'Alias yang tidak cocok dengan material mana pun (HSB-18): cukup fallback ke material DO + warning?'],
  ['Pencocokan MIC', 'Boleh mencocokkan MIC antar material lewat akhiran properti (SIBRSPTH dan SIARSPTH)?'],
  ['Material acuan', 'Kalau 1 alias dipakai beberapa material (KZMB-9 → 3 material), material mana yang jadi acuan mapping?']];
qs.forEach((q, i) => {
  const y = 1.7 + i * 1.03;
  circ(s, 0.6, y + 0.12, i + 1, i === 0 ? C.accent3 : C.accent1, 'qNo' + i);
  s.addText([{ text: q[0] + '  ', options: { bold: true } }, { text: q[1] }],
    { x: 1.35, y, w: 11.35, h: 0.8, isTextBox: true, fontSize: 15, color: C.text1, valign: 'middle', margin: 0 });
});

// 8. Next step
s = pres.addSlide({ masterName: 'DARK', sectionTitle: 'Konfirmasi' });
s.addText('Setelah QA menjawab', { placeholder: 'title' });
s.addText([
  { text: 'Revisi desain → spec final → persetujuan untuk eksekusi', options: { breakLine: true } },
  { text: 'Regresi L-QM01–15, ML-QM01–04, dan skenario alias baru' }], { placeholder: 'body' });

(async () => {
  await pres.writeFile({ fileName: OUT });
  await applyTheme(OUT, THEME);
  console.log('OK', OUT);
})();
