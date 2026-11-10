module.exports = (pres, C, H, G) => {
  const s = pres.addSlide({ masterName: 'TITLE_ONLY' });
  s.addText('Product Name (Alias) di COA', { placeholder: 'title' });
  s.addText('Diambil dari karakteristik batch (seperti di MSC3N tab Classification) · Data: DEV', { placeholder: 'sub' });
  const box = (y, h, t, d, ln, fill, nm) => s.addText([{ text: t, options: { bold: true, fontSize: 14, breakLine: true } }, { text: d, options: { fontSize: 12 } }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 0.5, y, w: 5.6, h, fill: { color: fill }, line: { color: ln, width: 1.5 }, valign: 'middle', margin: 8, color: C.text1, objectName: nm });
  const arrow = (y, nm) => s.addShape(pres.shapes.DOWN_ARROW, { x: 3.15, y, w: 0.3, h: 0.25, fill: { color: C.accent1 }, line: { color: C.accent1 }, objectName: nm });
  box(1.4, 0.85, '1. Baca batch di DO', 'Setiap roll yang dikirim dibaca karakteristik batch-nya.', C.accent1, C.background2, 'a1');
  arrow(2.3, 'aa1');
  box(2.6, 0.95, '2. Ambil karakteristik', 'Alias, Type, dan Thickness dari batch tersebut.', C.accent1, C.background2, 'a2');
  arrow(3.6, 'aa2');
  box(3.9, 1.05, '3. Alias terisi?', 'YA → Product Name = Alias\nTIDAK → Product Name = Type + "-" + Thickness', C.accent3, C.accent5, 'a3');
  arrow(5.0, 'aa3');
  box(5.3, 1.1, '4. Tampil di COA', 'Header sertifikat (Domestic & Export) dan kolom Type di Batch List.', C.accent2, C.accent6, 'a4');
  s.addText('Contoh', { x: 6.5, y: 1.4, w: 6.3, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
  s.addTable([
    [H('DO'), H('Alias'), H('Type'), H('Thickness'), H('Product Name')],
    ['0085006276', 'HSB-18', 'HSB4', '18', G('HSB-18')],
    ['0085006277', 'HSS-18 (12 roll)\nHSP-18 (6 roll)', 'HSB4', '18', G('HSS-18 / HSP-18')],
    ['0085006278', '(kosong)', 'MB51', '50', G('MB51-50')],
    ['0085006279', '(kosong)', 'MZUBD', '18', G('MZUBD-18')]],
    { x: 6.5, y: 1.75, w: 6.3, colW: [1.25, 1.55, 0.9, 1.0, 1.6], fontSize: 12, color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D2E0' }, fill: { color: C.background1 }, margin: [3, 6, 3, 6], valign: 'middle', objectName: 'tblAlias' });
  s.addText([{ text: 'DO dengan lebih dari 1 alias ', options: { bold: true } }, { text: '(DO 0085006277): Batch List menampilkan alias per roll. Header sertifikat memakai alias roll pertama yang terisi; untuk Export, Product Name masih bisa diubah di pop-up header saat print.' }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 6.5, y: 4.6, w: 6.3, h: 1.4, fill: { color: C.background2 }, line: { color: C.accent1, width: 1.25 }, fontSize: 12, color: C.text1, margin: 8, valign: 'middle', objectName: 'noteMulti' });
};
