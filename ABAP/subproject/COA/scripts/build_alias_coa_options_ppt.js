// Deck konfirmasi QA: Film type alias di COA — Opsi 1 (1 COA per alias) vs Opsi 2 (COA per tipe produksi)
// Rencana saja, belum ada perubahan program.
const pptxgen = require('pptxgenjs');
const { applyTheme } = require('/home/abap/.claude/remote/plugins/6a513545/eaa86030e55e0d06/skills/pptx/scripts/apply_theme.js');
const OUT = __dirname + '/../docs/Alias_COA_Opsi_QA.pptx';

const THEME = { name: 'COA Alias Opsi', headFontFace: 'Cambria', bodyFontFace: 'Calibri',
  colors: { dk1: '1B2A33', lt1: 'FFFFFF', dk2: '0B4F5C', lt2: 'EEF5F6',
    accent1: '0B6E7F', accent2: '2E7D4F', accent3: 'C2571A', accent4: '5F6B73',
    accent5: 'FCEEE5', accent6: 'E6F3EC', hlink: '0B6E7F', folHlink: '5F6B73' } };

const pres = new pptxgen();
pres.layout = 'LAYOUT_WIDE';
pres.theme = { headFontFace: THEME.headFontFace, bodyFontFace: THEME.bodyFontFace };
pres.title = 'Film Type Alias di COA — Konfirmasi QA';
const C = pres.SchemeColor;

pres.defineSlideMaster({ title: 'DARK', background: { color: THEME.colors.dk2 }, objects: [
  { placeholder: { options: { name: 'title', type: 'title', x: 0.8, y: 2.1, w: 11.7, h: 1.6, fontSize: 40, bold: true, color: C.background1, valign: 'bottom', align: 'left', margin: 0 }, text: '' } },
  { placeholder: { options: { name: 'body', type: 'body', x: 0.8, y: 3.9, w: 11.7, h: 1.4, fontSize: 18, color: C.background2, valign: 'top', margin: 0 }, text: '' } }] });
pres.defineSlideMaster({ title: 'CONTENT', background: { color: 'FFFFFF' }, objects: [
  { placeholder: { options: { name: 'title', type: 'title', x: 0.6, y: 0.35, w: 12.1, h: 0.75, fontSize: 30, bold: true, color: C.text2, valign: 'top', align: 'left', margin: 0 }, text: '' } },
  { placeholder: { options: { name: 'sub', type: 'body', x: 0.6, y: 1.1, w: 12.1, h: 0.4, fontSize: 15, color: C.accent4, margin: 0 }, text: '' } },
  { text: { text: 'COA (ZQM002) · Film type alias · Bahan konfirmasi, belum ada perubahan program', options: { x: 0.6, y: 7.05, w: 9, h: 0.3, fontSize: 10, color: '5F6B73', margin: 0 } } }],
  slideNumber: { x: 12.2, y: 7.05, w: 0.5, h: 0.3, fontSize: 10, color: '5F6B73', align: 'right' } });

const card = (s, x, y, w, h, fill, line, name) => s.addShape(pres.shapes.ROUNDED_RECTANGLE,
  { x, y, w, h, rectRadius: 0.1, fill: { color: fill }, line: { color: line || fill, width: 1.25 }, objectName: name });
const txt = (s, runs, o) => s.addText(runs, Object.assign({ isTextBox: true, margin: 0, valign: 'top', color: C.text1, fontSize: 14 }, o));
const arrow = (s, x, y, w, name) => s.addShape(pres.shapes.RIGHT_ARROW,
  { x, y, w, h: 0.45, fill: { color: 'C9D6DA' }, line: { color: 'C9D6DA' }, objectName: name });
const tbl = (rows, hdrFill, fs) => rows.map((r, i) => r.map(c => {
  const o = typeof c === 'object' ? c : { text: String(c) };
  const base = i === 0 ? { bold: true, color: C.background1, fill: { color: hdrFill || C.accent1 } } : {};
  return { text: o.text, options: Object.assign({ fontSize: fs || 13, valign: 'middle' }, base, o.options || {}) };
}));
const TOPT = { fontFace: 'Calibri', color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D6DA' }, margin: [4, 8, 4, 8] };
const OUTC = { color: C.accent3, bold: true };
const OKC = { color: C.accent2, bold: true };

// Mock COA: kotak header + tabel hasil
function mockCoa(s, x, y, w, head, sub, rows, tag) {
  card(s, x, y, w, 0.95, C.background2, C.accent1, 'coaHead' + tag);
  txt(s, [{ text: 'CERTIFICATE OF ANALYSIS', options: { bold: true, fontSize: 11, color: C.accent4, breakLine: true } },
    { text: 'Product: ' + head, options: { bold: true, fontSize: 17, color: C.text2, breakLine: true } },
    { text: sub, options: { fontSize: 11, color: C.accent4 } }], { x: x + 0.2, y: y + 0.1, w: w - 0.4, h: 0.8 });
  s.addTable(tbl([['Property', 'Spec', 'Value'], ...rows], C.accent1, 12),
    Object.assign({ x, y: y + 1.05, w, colW: [w * 0.5, w * 0.25, w * 0.25] }, TOPT));
}

// 1. Judul
pres.addSection({ title: 'Pembuka' });
let s = pres.addSlide({ masterName: 'DARK', sectionTitle: 'Pembuka' });
s.addText('Film Type Alias di COA', { placeholder: 'title' });
s.addText('Satu DO berisi beberapa tipe produksi dengan alias yang sama: dicetak 1 COA per alias, atau 1 COA per tipe produksi?\nBahan konfirmasi ke QA · 12 November 2026', { placeholder: 'body' });
s.addNotes('Tujuan: menyamakan persepsi blueprint. Saat blueprint confirmation, leader menangkap bahwa dua tipe produksi dengan alias sama digabung jadi satu. Program sekarang mencetak per tipe produksi. QA perlu memilih salah satu proses.');

// 2. Kasus
pres.addSection({ title: 'Kasus' });
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Kasus' });
s.addText('Kasus yang perlu dikonfirmasi', { placeholder: 'title' });
s.addText('Satu DO berisi roll dari dua tipe produksi, keduanya dialiaskan PLE-18', { placeholder: 'sub' });
[['SRAANI', 'Produksi PLE6-18', 'Roll A1, A2'], ['SRAPAI', 'Produksi PLE7-18', 'Roll B1, B2']].forEach((m, i) => {
  const y = 1.95 + i * 1.75;
  card(s, 0.6, y, 3.3, 1.45, C.background2, C.accent1, 'prod' + i);
  txt(s, [{ text: m[1], options: { bold: true, fontSize: 18, color: C.text2, breakLine: true } },
    { text: 'Material ' + m[0], options: { fontSize: 14, breakLine: true } },
    { text: m[2], options: { fontSize: 14, color: C.accent4 } }], { x: 0.85, y: y + 0.18, w: 2.9, h: 1.15 });
  arrow(s, 4.1, y + 0.5, 1.0, 'arrA' + i);
});
card(s, 5.3, 2.55, 2.7, 1.75, C.accent1, C.accent1, 'alias');
txt(s, [{ text: 'Alias batch', options: { fontSize: 14, color: C.background2, breakLine: true } },
  { text: 'PLE-18', options: { bold: true, fontSize: 30, color: C.background1 } }], { x: 5.5, y: 2.8, w: 2.3, h: 1.3, align: 'center' });
arrow(s, 8.2, 3.2, 1.0, 'arrB');
card(s, 9.4, 2.15, 3.3, 2.55, 'FFFFFF', C.accent3, 'coaQ');
txt(s, [{ text: 'COA yang dicetak?', options: { bold: true, fontSize: 18, color: C.accent3, breakLine: true } },
  { text: 'Opsi 1: 1 COA PLE-18 (gabungan)', options: { fontSize: 14, breakLine: true } },
  { text: 'Opsi 2: 2 COA, per tipe produksi', options: { fontSize: 14 } }], { x: 9.6, y: 2.4, w: 2.9, h: 2.1, paraSpaceAfter: 8 });
card(s, 0.6, 5.55, 12.1, 1.2, C.accent6, C.accent2, 'fakta');
txt(s, [{ text: 'Data PRD (lot Z04): ', options: { bold: true, color: C.accent2 } },
  { text: 'kedua tipe diuji dengan properti dan limit yang sama (Surface Tension Treated 38–42, Decay Time Treated maks. 100). Tapi kode MIC-nya berbeda per material, misalnya SAANSTTR (PLE6-18) dan SAPASTTR (PLE7-18).' }],
  { x: 0.85, y: 5.7, w: 11.6, h: 0.95, fontSize: 15, valign: 'middle' });
s.addNotes('Material dicek di Production AIX: SRAANI = SLITT ROLL PLE6-18, SRAPAI = SLITT ROLL PLE7-18. Sembilan MIC di lot terakhir: deskripsi dan limit sama, kode MIC berbeda karena memakai kode film material.');

// 3. As-is
pres.addSection({ title: 'Sekarang' });
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Sekarang' });
s.addText('Kondisi program sekarang', { placeholder: 'title' });
s.addText('1 COA = 1 DO + 1 tipe produksi. Alias hanya tampil di header.', { placeholder: 'sub' });
[['Mapping', 'Diambil dari tipe produksi (material roll). Contoh: produksi HSB4-18 memakai mapping HSB4-18.'],
  ['Value', 'Rata-rata dari roll yang dipilih, dengan tipe produksi yang sama. Tiap roll ditelusuri ke lot inspeksinya sendiri.'],
  ['Header', 'Product diisi alias roll. Kalau aliasnya beberapa, digabung dengan koma: "HSP-18, HSS-18".']].forEach((c, i) => {
  const x = 0.6 + i * 4.1;
  card(s, x, 1.85, 3.8, 2.55, C.background2, C.accent1, 'asis' + i);
  txt(s, [{ text: c[0], options: { bold: true, fontSize: 20, color: C.text2, breakLine: true } },
    { text: c[1], options: { fontSize: 15 } }], { x: x + 0.25, y: 2.05, w: 3.3, h: 2.2, paraSpaceAfter: 6 });
});
card(s, 0.6, 4.75, 12.1, 1.95, C.accent5, C.accent3, 'tolak');
txt(s, [{ text: 'Untuk kasus PLE-18', options: { bold: true, fontSize: 17, color: C.accent3, breakLine: true } },
  { text: 'Kalau roll PLE6-18 dan PLE7-18 dipilih bersamaan, print ditolak: "Tipe film tidak boleh berbeda!". User harus mencetak 2 COA, masing-masing dengan header PLE-18.', options: { fontSize: 15, breakLine: true } },
  { text: 'Artinya, kondisi sekarang sudah sama dengan Opsi 2.', options: { fontSize: 15, bold: true } }],
  { x: 0.85, y: 4.95, w: 11.6, h: 1.6, paraSpaceAfter: 4 });

// 4. Opsi 1
pres.addSection({ title: 'Opsi' });
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Opsi' });
s.addText('Opsi 1: satu COA per alias', { placeholder: 'title' });
s.addText('PLE6-18 dan PLE7-18 digabung menjadi 1 COA PLE-18 dengan 1 mapping', { placeholder: 'sub' });
mockCoa(s, 0.6, 1.8, 6.0, 'PLE-18', 'Roll A1, A2 (PLE6-18) + B1, B2 (PLE7-18)', [
  ['Surface Tension Treated', '38 – 42', '40 *'],
  ['Decay Time Treated', '≤ 100', '35 *'],
  ['Surface Tension Untreated', '–', '36 *']], '1');
txt(s, '* Contoh ilustrasi: rata-rata 4 roll dari 2 tipe produksi.', { x: 0.6, y: 4.65, w: 6, h: 0.35, fontSize: 11, color: C.accent4 });
card(s, 7.0, 1.8, 5.7, 4.95, C.background2, C.accent1, 'op1');
txt(s, [{ text: 'Cara kerjanya', options: { bold: true, fontSize: 17, color: C.text2, breakLine: true } },
  { text: 'Mapping: 1 mapping untuk PLE-18', options: { bullet: true, breakLine: true } },
  { text: 'Value: rata-rata semua roll, lintas tipe produksi', options: { bullet: true, breakLine: true } },
  { text: 'Traceability: tiap roll tetap dibaca dari lotnya sendiri, tapi angka yang tercetak adalah gabungan', options: { bullet: true, breakLine: true } },
  { text: 'Yang perlu dibuat', options: { bold: true, fontSize: 17, color: C.accent3, breakLine: true } },
  { text: 'Pencocokan MIC berdasarkan nama properti (SAANSTTR = SAPASTTR)', options: { bullet: true, breakLine: true } },
  { text: 'Aturan kalau spec kedua tipe berbeda', options: { bullet: true, breakLine: true } },
  { text: 'Program diubah agar tipe berbeda boleh dicetak bersama kalau aliasnya sama', options: { bullet: true } }],
  { x: 7.25, y: 2.0, w: 5.2, h: 4.6, fontSize: 14, paraSpaceAfter: 6 });

// 5. Opsi 2
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Opsi' });
s.addText('Opsi 2: satu COA per tipe produksi', { placeholder: 'title' });
s.addText('Tiap tipe produksi punya COA, mapping, dan traceability sendiri. Header tetap memakai alias.', { placeholder: 'sub' });
mockCoa(s, 0.6, 1.8, 5.9, 'PLE-18', 'COA #1 · Produksi PLE6-18 · Roll A1, A2', [
  ['Surface Tension Treated', '38 – 42', '41 *'], ['Decay Time Treated', '≤ 100', '30 *']], '2a');
mockCoa(s, 6.8, 1.8, 5.9, 'PLE-18', 'COA #2 · Produksi PLE7-18 · Roll B1, B2', [
  ['Surface Tension Treated', '38 – 42', '39 *'], ['Decay Time Treated', '≤ 100', '40 *']], '2b');
txt(s, '* Contoh ilustrasi: rata-rata roll dari tipe produksi itu saja.', { x: 0.6, y: 4.3, w: 8, h: 0.35, fontSize: 11, color: C.accent4 });
card(s, 0.6, 4.8, 12.1, 1.95, C.accent6, C.accent2, 'op2');
txt(s, [{ text: 'Mapping per tipe produksi (PLE6-18 dan PLE7-18 masing-masing).', options: { bullet: true, breakLine: true } },
  { text: 'Value dan limit sesuai spec tipe produksinya sendiri, jadi tidak tercampur.', options: { bullet: true, breakLine: true } },
  { text: 'Sudah berjalan seperti ini sekarang. Perubahan program minimal atau tidak ada.', options: { bullet: true, breakLine: true } },
  { text: 'Konsekuensi: customer menerima 2 COA dengan header yang sama (PLE-18).', options: { bullet: true } }],
  { x: 0.85, y: 4.95, w: 11.6, h: 1.7, fontSize: 15, paraSpaceAfter: 4 });

// 6. Perbandingan
pres.addSection({ title: 'Perbandingan' });
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Perbandingan' });
s.addText('Perbandingan kedua opsi', { placeholder: 'title' });
s.addText('Contoh: 1 DO berisi PLE6-18 dan PLE7-18, alias PLE-18', { placeholder: 'sub' });
s.addTable(tbl([
  ['', 'Opsi 1: 1 COA per alias', 'Opsi 2: COA per tipe produksi'],
  [{ text: 'Jumlah COA', options: { bold: true } }, '1 (PLE-18)', '2 (header keduanya PLE-18)'],
  [{ text: 'Mapping', options: { bold: true } }, '1 mapping untuk alias', 'Per tipe produksi (seperti sekarang)'],
  [{ text: 'Value', options: { bold: true } }, 'Rata-rata semua roll, lintas tipe', 'Rata-rata roll satu tipe'],
  [{ text: 'Traceability', options: { bold: true } }, 'Per roll, tapi angka COA gabungan', 'Per roll dan per tipe, terpisah penuh'],
  [{ text: 'Kalau spec beda', options: { bold: true } }, { text: 'Perlu aturan: limit mana yang tercetak', options: OUTC }, { text: 'Tidak ada masalah', options: OKC }],
  [{ text: 'Perubahan program', options: { bold: true } }, { text: 'Besar (gabung tipe + cocokkan MIC)', options: OUTC }, { text: 'Minimal / tidak ada', options: OKC }]
], C.accent1, 15), Object.assign({ x: 0.6, y: 1.8, w: 12.1, colW: [2.5, 4.8, 4.8], rowH: 0.62 }, TOPT));

// 7. Risiko rata-rata gabungan
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Perbandingan' });
s.addText('Risiko Opsi 1 kalau spec kedua tipe berbeda', { placeholder: 'title' });
s.addText('Kasus nyata di PRD, alias GLOSS: Seal to Paper SRIBRI 3.5–6.5, SRIARI 3.0–5.5', { placeholder: 'sub' });
s.addTable(tbl([
  ['Roll', 'Tipe produksi', 'Spec tipe sendiri', 'Value', 'Hasil'],
  ['A1', 'SRIBRI', '3.5 – 6.5', '3.2', { text: 'Keluar spec', options: OUTC }],
  ['B1', 'SRIARI', '3.0 – 5.5', '5.0', { text: 'Masuk spec', options: OKC }],
  [{ text: 'COA GLOSS (gabungan)', options: { bold: true } }, '–', '3.0 – 5.5 ?', { text: '4.1', options: { bold: true } }, { text: 'Terlihat lolos', options: OUTC }]
], C.accent1, 15), Object.assign({ x: 0.6, y: 1.8, w: 7.6, colW: [2.1, 1.5, 1.6, 1.0, 1.4], rowH: 0.6 }, TOPT));
txt(s, 'Angka Value adalah contoh ilustrasi; spec diambil dari lot Z04 PRD.', { x: 0.6, y: 4.35, w: 7.6, h: 0.35, fontSize: 11, color: C.accent4 });
card(s, 8.6, 1.8, 4.1, 4.9, C.accent5, C.accent3, 'risk');
txt(s, [{ text: 'Kenapa berbahaya', options: { bold: true, fontSize: 18, color: C.accent3, breakLine: true } },
  { text: 'Rata-rata bisa menutupi roll yang keluar spec.', options: { bullet: true, breakLine: true } },
  { text: 'Limit yang tercetak bisa bukan spec roll itu sendiri.', options: { bullet: true, breakLine: true } },
  { text: 'COA menyatakan lolos untuk produk yang sebenarnya gagal.', options: { bullet: true } }],
  { x: 8.85, y: 2.0, w: 3.6, h: 4.5, fontSize: 15, paraSpaceAfter: 8 });
s.addNotes('Untuk PLE6-18 dan PLE7-18 spec saat ini sama, jadi risiko ini belum muncul. Tapi alias lain seperti GLOSS dan KZMB-9 sudah punya spec berbeda antar material.');

// 8. Pertanyaan
pres.addSection({ title: 'Keputusan' });
s = pres.addSlide({ masterName: 'CONTENT', sectionTitle: 'Keputusan' });
s.addText('Yang perlu diputuskan QA', { placeholder: 'title' });
s.addText('Jawaban pertanyaan 1 menentukan apakah pertanyaan 2–4 perlu dijawab', { placeholder: 'sub' });
const qs = [
  ['1', 'Untuk 1 DO dengan alias sama tetapi tipe produksi berbeda, dicetak 1 COA per alias (Opsi 1) atau 1 COA per tipe produksi (Opsi 2)?'],
  ['2', 'Jika Opsi 1: Value di COA memakai rata-rata gabungan semua roll dari semua tipe?'],
  ['3', 'Jika Opsi 1 dan spec kedua tipe berbeda: limit mana yang tercetak, atau print diblokir?'],
  ['4', 'Jika Opsi 1: mapping PLE-18 dibuat khusus per alias, atau mengikuti salah satu tipe produksi? Siapa yang maintain?'],
  ['5', 'Header COA: cukup alias (PLE-18), atau alias ditambah tipe produksi?']];
qs.forEach((q, i) => {
  const y = 1.8 + i * 1.0;
  const first = i === 0;
  card(s, 0.6, y, 12.1, 0.85, first ? C.accent1 : C.background2, C.accent1, 'q' + i);
  txt(s, [{ text: q[0] + '.  ', options: { bold: true } }, { text: q[1] }],
    { x: 0.85, y, w: 11.6, h: 0.85, valign: 'middle', fontSize: 15, color: first ? C.background1 : C.text1, bold: first });
});

(async () => {
  await pres.writeFile({ fileName: OUT });
  await applyTheme(OUT, THEME);
  console.log('OK', OUT);
})();
