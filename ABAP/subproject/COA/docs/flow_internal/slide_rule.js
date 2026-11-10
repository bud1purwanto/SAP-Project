module.exports = (pres, C, H, G) => {
  const s = pres.addSlide({ masterName: 'TITLE_ONLY' });
  s.addText('Rule Roll Tanpa Hasil Inspeksi', { placeholder: 'title' });
  s.addText('Contoh DO 0085006276 · tidak semua roll diinspeksi, jadi sistem mengambil nilai dari roll saudara · Data: DEV', { placeholder: 'sub' });
  const tb = { color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D2E0' }, fill: { color: C.background1 }, margin: [2, 6, 2, 6], valign: 'middle', fontSize: 11.5 };
  const rule = (x, title, txt, nm) => s.addText([{ text: title, options: { bold: true, fontSize: 14, breakLine: true } }, { text: txt, options: { fontSize: 12 } }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x, y: 1.4, w: 6.0, h: 1.35, fill: { color: C.accent5 }, line: { color: C.accent3, width: 1.25 }, color: C.text1, margin: 8, valign: 'top', objectName: nm });
  rule(0.5, 'A. Roll JR (parameter JR Base Film / JR Converting)', 'Kalau JR tidak punya hasil inspeksi, sistem memakai roll JR dengan nomor lebih kecil yang terdekat, di production order yang sama, yang sudah punya hasil. Kalau tidak ada → nilai kosong.', 'ruleJR');
  rule(6.8, 'B. Roll SR (parameter SR Base Film / SR Converting)', 'Kalau roll SR tidak punya inspection lot sendiri, sistem memakai lot roll SR saudara, yaitu SR lain yang di-slit dari JR (mother roll) yang sama dan punya lot.', 'ruleSR');
  s.addText('Order JR 100000073422: hanya roll 002 & 004 diinspeksi', { x: 0.5, y: 2.95, w: 6.0, h: 0.3, isTextBox: true, fontSize: 12, bold: true, color: C.text1, margin: 0 });
  s.addTable([
    [H('JR'), H('Roll'), H('Hasil?'), H('Nilai dipakai dari')],
    ['0000406861', '002', 'Ada', '(dirinya sendiri)'],
    ['0000406862', '003', 'Tidak', G('Roll 002 · Thickness 18.04')],
    ['0000406863', '004', 'Ada', '(dirinya sendiri)'],
    ['0000406864 … 0000406882', '005–023', 'Tidak', 'Roll 004'],
    ['0000406883', '024', 'Tidak', G('Roll 004 · Thickness 17.87')]],
    Object.assign({ x: 0.5, y: 3.3, w: 6.0, colW: [2.0, 0.85, 0.85, 2.3], rowH: 0.36, objectName: 'tblJR' }, tb));
  s.addText('Roll yang dikirim di DO (SR SRACBI)', { x: 6.8, y: 2.95, w: 6.0, h: 0.3, isTextBox: true, fontSize: 12, bold: true, color: C.text1, margin: 0 });
  s.addTable([
    [H('Roll SR'), H('JR induk'), H('Lot sendiri?'), H('Lot dipakai')],
    ['0000406885–886 (01–02)', '0000406862', 'Tidak', '050000014307'],
    ['0000406887 (03)', '0000406862', G('Ada'), G('050000014307')],
    ['0000406888–890 (04–06)', '0000406862', 'Tidak', '050000014307'],
    ['0000406891–894 (01–04)', '0000406883', 'Tidak', '050000014308'],
    ['0000406895 (05)', '0000406883', G('Ada'), G('050000014308')],
    ['0000406896 (06)', '0000406883', 'Tidak', '050000014308']],
    Object.assign({ x: 6.8, y: 3.3, w: 6.0, colW: [2.1, 1.25, 1.15, 1.5], rowH: 0.36, objectName: 'tblSR' }, tb));
  s.addText([{ text: 'Hasilnya di COA: ', options: { bold: true } },
    { text: 'parameter JR dihitung dari 2 nilai (roll 002 & 004), parameter SR dari 2 lot (14307 & 14308). Lot yang sama hanya dihitung sekali, jadi Thickness = (18.04 + 17.87) / 2 = 17.95 dan Shrinkage MD = (4.32 + 5.35) / 2 = 4.84.' }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 0.5, y: 6.0, w: 12.3, h: 0.95, fill: { color: C.accent6 }, line: { color: C.accent2, width: 1.25 }, fontSize: 12, color: C.text1, margin: 8, valign: 'middle', objectName: 'result' });
};
