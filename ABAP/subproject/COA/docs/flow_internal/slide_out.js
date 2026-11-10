module.exports = (pres, C, H, G) => {
  const s = pres.addSlide({ masterName: 'TITLE_ONLY' });
  s.addText('Flow Outsource: DO 0085006279', { placeholder: 'title' });
  s.addText('Material SREC7I · 10 roll · Base Film dari vendor (SRVLCX) → Converting · Data: hasil program COA di DEV', { placeholder: 'sub' });
  s.addText('Silsilah produksi (hasil langkah 3)', { x: 0.5, y: 1.3, w: 12, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
  const box = (x, w, t1, t2, col, nm) => s.addText([{ text: t1, options: { bold: true, breakLine: true, color: C.background1 } }, { text: t2, options: { color: C.background1 } }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x, y: 1.65, w, h: 0.7, fill: { color: col }, line: { color: col }, fontSize: 12, margin: 6, valign: 'middle', objectName: nm });
  box(0.5, 3.6, 'Vendor (di luar SAP produksi)', 'Base film dibeli, tidak ada JR Base Film', C.accent4, 'stgVendor');
  s.addShape(pres.shapes.RIGHT_ARROW, { x: 4.17, y: 1.88, w: 0.22, h: 0.25, fill: { color: C.accent1 }, line: { color: C.accent1 }, objectName: 'arr1' });
  box(4.45, 3.9, 'Base Film outsource', 'SR SRVLCX (roll dari vendor)', C.accent1, 'stgBF');
  s.addShape(pres.shapes.RIGHT_ARROW, { x: 8.42, y: 1.88, w: 0.22, h: 0.25, fill: { color: C.accent1 }, line: { color: C.accent1 }, objectName: 'arr2' });
  box(8.7, 4.1, 'Converting (dikirim)', 'JR JREC7I  →  SR SREC7I', C.accent2, 'stgConv');
  s.addText('Nilai per parameter (langkah 4 → 6)', { x: 0.5, y: 2.55, w: 12, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
  s.addTable([
    [H('Parameter'), H('Mapping COA'), H('Diambil dari'), H('Nilai yang dihitung (per lot)'), H('Di COA')],
    ['Tensile Strength MD / TD', 'SR Base Film', 'SRVLCX (3 lot)', 'MD 18.45, 16.70, 13.30 · TD 25.5, 24.5, 22.5', G('16.15 / 24.17')],
    ['Elongation MD / TD', 'SR Base Film', 'SRVLCX (3 lot)', 'MD 260, 250, 200 · TD 75, 65, 78', G('237 / 73')],
    ['Shrinkage MD / TD', 'SR Base Film', 'SRVLCX (3 lot)', '0 di semua lot', G('0.00 / 0.00')],
    ['Surface Tension Corona Side', 'SR Converting', 'SREC7I (5 lot)', '41, 39, 39, 38, 38', G('39')],
    ['COF Corona Side Dyn', 'JR Converting', 'JREC7I', 'Hanya 1 JR punya hasil: 0.54 (JR lain tanpa hasil, tidak dihitung)', G('0.540')],
    ['MVTR / O2TR', 'SR Converting', 'SREC7I', 'Nilai cycle terakhir uji barrier, dirata-rata semua lot SR', G('0.07 / 0.07')]],
    { x: 0.5, y: 2.9, w: 12.3, colW: [2.5, 1.6, 1.6, 4.6, 2.0], rowH: 0.42, fontSize: 12, color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D2E0' }, fill: { color: C.background1 }, margin: [2, 6, 2, 6], valign: 'middle', objectName: 'tblValueOut' });
  s.addText([{ text: 'Catatan: ', options: { bold: true } }, { text: '10 roll di DO berasal dari 5 JR. Sistem mencocokkan roll base film yang dipakai tiap JR; hasilnya 3 lot SRVLCX berbeda, jadi parameter base film dihitung dari 3 lot (lot yang sama hanya dihitung sekali). Base film dari vendor tidak punya JR induk, jadi penelusuran berhenti di SRVLCX.' }],
    { x: 0.5, y: 6.3, w: 12.3, h: 0.9, isTextBox: true, fontSize: 11.5, color: C.text1, margin: 0, valign: 'top' });
};
