module.exports = (pres, C) => {
  const H = t => ({ text: t, options: { bold: true, color: C.background1, fill: { color: C.accent1 } } });
  return function keySlide(title, sub, rows) {
    const s = pres.addSlide({ masterName: 'TITLE_ONLY' });
    s.addText(title, { placeholder: 'title' });
    s.addText(sub, { placeholder: 'sub' });
    const data = [[H('No'), H('Langkah'), H('Tabel / FM'), H('Key yang dipakai'), H('Field yang diambil'), H('Contoh DEV')]]
      .concat(rows.map(r => r.map((c, i) => i === 2 ? { text: c, options: { bold: true } } : c)));
    s.addTable(data, { x: 0.5, y: 1.35, w: 12.3, colW: [0.45, 1.9, 2.4, 3.0, 2.45, 2.1], fontSize: rows.length > 12 ? 10 : 12, rowH: rows.length > 12 ? 0.3 : 0.45,
      color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D2E0' }, fill: { color: C.background1 }, margin: [2, 5, 2, 5], valign: 'middle', objectName: 'tblKey' });
  };
};
