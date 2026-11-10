module.exports = (pres, C) => {
  const H = t => ({ text: t, options: { bold: true, color: C.background1, fill: { color: C.accent1 } } });
  const opt = (x, y, w, colW, fs) => ({ x, y, w, colW, fontSize: fs, color: C.text1, border: { type: 'solid', pt: 0.75, color: 'C9D2E0' }, fill: { color: C.background1 }, margin: [2, 5, 2, 5], valign: 'middle' });
  const lbl = (s, t, y) => s.addText(t, { x: 0.5, y, w: 12.3, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
  const K = t => ({ text: t, options: { bold: true, color: C.accent2 } });
  return function () {
    // Slide: ZMAP_COA
    let s = pres.addSlide({ masterName: 'TITLE_ONLY' });
    s.addText('Master Data — Mapping COA (ZMAP_COA)', { placeholder: 'title' });
    s.addText('Menentukan parameter (MIC) apa saja yang dicetak per material, dari tahap mana, dan urutannya · 188 baris di DEV', { placeholder: 'sub' });
    lbl(s, '1. Struktur tabel', 1.3);
    s.addTable([[H('Field'), H('Key'), H('Arti')],
      ['MATNR', K('✓'), 'Material SR yang dikirim (material di DO)'],
      ['MIC', K('✓'), 'Kode parameter / Master Inspection Characteristic'],
      ['KUNNR', K('✓'), 'Customer. Kosong = berlaku umum; diisi = khusus customer (menimpa yang umum)'],
      ['MAPPING', '', 'Tahap sumber nilai: SR Converting · JR Converting · SR Base Film · JR Base Film'],
      ['METHOD', '', 'Metode uji yang dicetak (mis. ASTM D 1204)'],
      ['MIC_DESC', '', 'Nama parameter di COA (kosong → pakai teks MIC)'],
      ['UOM', '', 'Satuan yang dicetak'],
      ['LOWER_LIMIT / UPPER_LIMIT', '', 'Spesifikasi di COA (kosong → pakai batas dari MIC)'],
      ['SEQ_NO', '', 'Urutan baris parameter di COA'],
      ['DELETION', '', 'Flag hapus · + field log: CPUDT, USNAM, AEDAT, AENAM']],
      opt(0.5, 1.65, 5.6, [1.75, 0.45, 3.4], 10.5));
    s.addText('2. Contoh isi DEV — material SRGLBI (DO 0085006278)', { x: 6.4, y: 1.3, w: 6.4, h: 0.3, isTextBox: true, fontSize: 14, bold: true, color: C.text1, margin: 0 });
    s.addTable([[H('SEQ'), H('MIC'), H('KUNNR'), H('MAPPING'), H('MIC_DESC'), H('METHOD'), H('UOM')],
      ['001', 'PAH8TSMD', '', 'JR Base Film', 'Tensile Strength MD', 'ASTM D 882', 'kg/mm2'],
      ['003', 'PAH8ELMD', '', 'JR Base Film', 'Elongation MD', 'ASTM D 882', '%'],
      ['005', 'PGLASHMD', '', 'JR Converting', 'Shrinkage MD', 'ASTM D 1204', '%'],
      ['005', 'PGLASHMD', '1141000026', 'JR Converting', 'Shrinkage MD', 'ASTM D 1204', '%'],
      ['007', 'SGLASTCD', '', 'SR Converting', 'Surface Tension Coated Side', 'ASTM D 2578', 'dyne/cm'],
      ['008', 'SGLASTMZ', '', 'SR Converting', 'Surface Tension Metz Side', 'ASTM D 2578', 'dyne/cm'],
      ['009', 'PGLAG6CD', '', 'JR Converting', 'Gloss 60° (Coated Side)', 'ASTM D 2457', '%'],
      ['010', 'PGLBOD00', '', 'JR Converting', 'Optical Density', '', '']],
      opt(6.4, 1.65, 6.4, [0.45, 0.9, 0.95, 1.05, 1.5, 0.95, 0.6], 9.5));
    s.addText([{ text: 'Cara baca: ', options: { bold: true } }, { text: 'program ambil semua baris MATNR = material DO dengan KUNNR kosong, lalu baris dengan KUNNR = customer DO menimpa MIC yang sama. Material tanpa mapping → muncul pesan "Material belum dimapping di ZMAP_COA". LOWER/UPPER_LIMIT di contoh ini kosong, jadi spesifikasi diambil dari MIC.' }],
      { x: 6.4, y: 5.2, w: 6.4, h: 1.2, isTextBox: true, fontSize: 11, color: C.text1, margin: 0, valign: 'top' });

    // Slide: master lain
    s = pres.addSlide({ masterName: 'TITLE_ONLY' });
    s.addText('Master Data — MIC & Mapping Lain yang Dipakai Program', { placeholder: 'title' });
    s.addText('Hasil pencarian di program ZQMI_COA (F01/F02) · isi dari DEV', { placeholder: 'sub' });
    s.addTable([[H('Master data'), H('Tabel / T-code'), H('Key'), H('Dipakai untuk'), H('Contoh DEV')],
      ['Master MIC', 'QPMK, QPMT (QS21 / QS23)', 'MKMNR = MIC; ZAEHLER = plant; QPMT: bahasa E', 'Jumlah desimal (STELLEN), satuan, batas bawah/atas default, nama parameter', 'PGLASHMD plant 2000: 2 desimal, %, 3.00–5.00'],
      ['Kolom Batch List per customer', 'ZQM_COA_CUST_COL', 'KUNNR + FIELD_NAME', 'Kolom apa yang tampil di Batch List, label, urutan (SEQ_NO), lebar (COL_SIZE S/M/L), aktif', '1141000010: PALLET NO (01), TYPE (02), HU NUMBER (03)… · 788 baris'],
      ['Override nilai COA', 'ZLOG_COA', 'VBELN + PRUEFLOS + MIC + KUNNR', 'Nilai yang diubah user saat "Change Value" — menimpa hasil inspeksi saat print', 'DO 85006234 · PCADELMD = 75 · 18 baris'],
      ['Filter item category DO', 'ZMAP_TYPE', 'PROG = program; TYPE = ITEM CATEGORY', 'Item category delivery yang dibaca', 'Tidak ada baris untuk program COA di DEV → semua item dibaca'],
      ['Karakteristik batch', 'Class type 023 (MSC2N / CT04)', 'ZZALIAS, ZZTYPE, ZZTHICKNESS, ZZCORE, ZZWIDTH, ZZLENGTH…', 'Product Name (Alias / Type + Thickness) & kolom Batch List', 'SRACBI: HSB-18 / HSB4 / 18']],
      opt(0.5, 1.4, 12.3, [1.9, 2.1, 2.6, 3.1, 2.6], 12.5));
    s.addText([{ text: 'Bukan master (data transaksi): ', options: { bold: true } }, { text: 'ZBATCHISTORY (histori ganti batch), ZHMS & ZPALLETR (data pallet/HU untuk no. lot customer).' }],
      { x: 0.5, y: 5.9, w: 12.3, h: 0.5, isTextBox: true, fontSize: 12, color: C.accent4, margin: 0, valign: 'top' });
  };
};
