module.exports = (pres, C, H, G) => {
  const s = pres.addSlide({ masterName: 'TITLE_ONLY' });
  s.addText('Flow Base Film: DO 0085006276', { placeholder: 'title' });
  s.addText('Material SRACBI · 12 roll · Produksi 1 tahap (JR Base Film → SR Base Film) · Data: hasil program COA di DEV', { placeholder: 'sub' });
  s.addText('Silsilah produksi (hasil langkah 3)', { x: 0.5, y: 1.3, w: 12, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
  s.addText([{ text: 'Base Film', options: { bold: true, breakLine: true, color: C.background1 } }, { text: 'JR JRACBI (2 JR: 0000406862, 0000406883)', options: { color: C.background1 } }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 0.5, y: 1.65, w: 5.9, h: 0.7, fill: { color: C.accent1 }, line: { color: C.accent1 }, fontSize: 12, margin: 6, valign: 'middle', objectName: 'stgJR' });
  s.addShape(pres.shapes.RIGHT_ARROW, { x: 6.5, y: 1.88, w: 0.22, h: 0.25, fill: { color: C.accent1 }, line: { color: C.accent1 }, objectName: 'arr1' });
  s.addText([{ text: 'Dikirim', options: { bold: true, breakLine: true, color: C.background1 } }, { text: 'SR SRACBI (12 roll, 2 punya lot sendiri)', options: { color: C.background1 } }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 6.85, y: 1.65, w: 5.95, h: 0.7, fill: { color: C.accent2 }, line: { color: C.accent2 }, fontSize: 12, margin: 6, valign: 'middle', objectName: 'stgSR' });
  s.addText('Nilai per parameter (langkah 4 → 6)', { x: 0.5, y: 2.55, w: 12, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
  s.addTable([
    [H('Parameter'), H('Mapping COA'), H('Diambil dari'), H('Nilai yang dihitung (per lot)'), H('Di COA')],
    ['Thickness', 'JR Base Film', 'JRACBI *', '18.04 (roll 002), 17.87 (roll 004)', G('17.95')],
    ['Tensile Strength MD / TD', 'JR Base Film', 'JRACBI *', 'MD 13.21, 15.81 · TD 30.55, 25.75', G('14.51 / 28.15')],
    ['Elongation MD / TD', 'JR Base Film', 'JRACBI *', 'MD 135, 185 · TD 42, 56', G('160 / 49')],
    ['Seal Strength SIT Inside / Outside', 'JR Base Film', 'JRACBI *', '294 / 267', G('294 / 267')],
    ['Shrinkage MD / TD', 'SR Base Film', 'SRACBI **', 'MD 4.32, 5.35 · TD 6.49, 7.53', G('4.84 / 7.01')],
    ['Haze · Gloss 45°', 'SR Base Film', 'SRACBI **', 'Haze 2.40, 2.03 · Gloss 88, 88', G('2.21 · 88')],
    ['SIT Inside / Outside · COF Inside Dyn', 'SR Base Film', 'SRACBI **', 'SIT 111 / 110 · COF 0.28, 0.25', G('111 / 110 · 0.265')]],
    { x: 0.5, y: 2.9, w: 12.3, colW: [3.1, 1.5, 1.6, 3.9, 2.2], rowH: 0.38, fontSize: 12, color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D2E0' }, fill: { color: C.background1 }, margin: [2, 6, 2, 6], valign: 'middle', objectName: 'tblValueBF' });
  s.addText([{ text: 'Catatan: ', options: { bold: true } },
    { text: '* JR yang dikirim tidak diinspeksi → nilai dari roll JR 002 dan 004.  ** Hanya 2 dari 12 roll SR punya lot → roll lain memakai lot SR saudara. Detail rule di slide 4.' }],
    { x: 0.5, y: 6.15, w: 12.3, h: 0.6, isTextBox: true, fontSize: 12, color: C.text1, margin: 0, valign: 'top' });
};
