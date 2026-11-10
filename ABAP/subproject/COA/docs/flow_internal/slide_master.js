module.exports = (pres, C, H) => {
  const s = pres.addSlide({ masterName: 'TITLE_ONLY' });
  s.addText('Master Data yang Dibaca di Langkah 2', { placeholder: 'title' });
  s.addText('Bentuk dan isi master data mapping · contoh isi dari DEV', { placeholder: 'sub' });
  const tb = { color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D2E0' }, fill: { color: C.background1 }, margin: [2, 5, 2, 5], valign: 'middle' };
  s.addText([{ text: 'A. Mapping COA ', options: { bold: true } }, { text: '(ZMAP_COA) — parameter apa yang dicetak per material, dari tahap mana', options: { color: C.accent4 } }], { x: 0.5, y: 1.3, w: 12.3, h: 0.3, isTextBox: true, fontSize: 14, color: C.text1, margin: 0 });
  s.addTable([
    [H('Material'), H('Customer'), H('Parameter (MIC)'), H('Nama di COA'), H('Metode'), H('Satuan'), H('Tahap sumber'), H('Spek min / maks'), H('Urutan')],
    ['SRGLBI', '(umum)', 'PAH8TSMD', 'Tensile Strength MD', 'ASTM D 882', 'kg/mm2', 'JR Base Film', '(dari MIC)', '1'],
    ['SRGLBI', '(umum)', 'PGLASHMD', 'Shrinkage MD', 'ASTM D 1204', '%', 'JR Converting', '(dari MIC)', '5'],
    ['SRGLBI', '1141000026', 'PGLASHMD', 'Shrinkage MD', 'ASTM D 1204', '%', 'JR Converting', '(dari MIC)', '5'],
    ['SRGLBI', '(umum)', 'SGLASTCD', 'Surface Tension Coated Side', 'ASTM D 2578', 'dyne/cm', 'SR Converting', '(dari MIC)', '7'],
    ['SRGLBI', '(umum)', 'PGLBOD00', 'Optical Density', '', '', 'JR Converting', '(dari MIC)', '10']],
    Object.assign({ x: 0.5, y: 1.65, w: 12.3, colW: [1.0, 1.15, 1.3, 2.9, 1.25, 0.95, 1.5, 1.35, 0.9], rowH: 0.3, fontSize: 11, objectName: 'tblZmap' }, tb));
  s.addText('Kunci: Material + Parameter + Customer. Baris customer khusus menimpa baris umum untuk parameter yang sama. "Tahap sumber" dipakai di langkah 4 untuk memilih inspection lot.',
    { x: 0.5, y: 3.65, w: 12.3, h: 0.35, isTextBox: true, fontSize: 11, color: C.accent4, margin: 0 });
  s.addText([{ text: 'B. Mapping Batch List ', options: { bold: true } }, { text: '(ZQM_COA_CUST_COL) — kolom per customer', options: { color: C.accent4 } }], { x: 0.5, y: 4.1, w: 7.2, h: 0.3, isTextBox: true, fontSize: 14, color: C.text1, margin: 0 });
  s.addTable([
    [H('Customer'), H('Kolom'), H('Label di Batch List'), H('Urutan'), H('Lebar'), H('Aktif')],
    ['1141000010', 'NO_PALET', 'PALLET NO', '1', 'M', 'X'],
    ['1141000010', 'TYPE', 'TYPE', '2', 'S', 'X'],
    ['1141000010', 'HU_NUMBER', 'HU NUMBER', '3', 'M', 'X'],
    ['1141000010', 'ROLL_NUMBER', 'ROLL NUMBER', '4', 'L', 'X'],
    ['1141000010', 'WEIGHT_PER_ROL', 'WEIGHT PER ROLL (Kgm)', '11', 'M', 'X']],
    Object.assign({ x: 0.5, y: 4.45, w: 7.2, colW: [1.15, 1.6, 2.35, 0.7, 0.65, 0.75], rowH: 0.3, fontSize: 11, objectName: 'tblCustCol' }, tb));
  s.addText([{ text: 'C. Master pendukung', options: { bold: true, fontSize: 14, breakLine: true } },
    { text: 'Master MIC (QS21): ', options: { bold: true } }, { text: 'jumlah desimal, satuan dan spek default per plant — dipakai jika spek di Mapping COA kosong.', options: { breakLine: true } },
    { text: 'Karakteristik batch: ', options: { bold: true } }, { text: 'Alias, Type, Thickness, Core, Width, Length — untuk Product Name dan isi Batch List.' }],
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 8.0, y: 4.1, w: 4.8, h: 2.15, fill: { color: C.background2 }, line: { color: C.accent1, width: 1.25 }, fontSize: 11.5, color: C.text1, margin: 8, valign: 'top', objectName: 'boxSupport' });
  s.addText('Lanjut → slide 3–6: contoh penelusuran per jenis flow (Base Film + rule roll tanpa hasil · Multi-level · Outsource)',
    { shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.08, x: 0.5, y: 6.6, w: 12.3, h: 0.45, fill: { color: C.accent6 }, line: { color: C.accent2 }, fontSize: 12, bold: true, color: C.accent2, margin: 6, valign: 'middle', objectName: 'next' });
};
