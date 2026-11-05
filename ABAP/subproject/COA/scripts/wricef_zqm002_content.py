"""Konten WRICEF/FS ZQM002 (ZQMI_COA) — as-is dari source DEV AIX (TRD) 03.11.2026.

Sumber narasi: docs/WRICEF_ZQM002_Certificate_of_Analysis.md
"""
import os

DOCS = os.path.join(os.path.dirname(__file__), '..', 'docs')
HEADER_OLD = 'RICEFW-MM-ZMMI_PO_EMAIL PO Approval Notification Program'
HEADER_NEW = 'RICEFW-QM-ZQMI_COA Certificate of Analysis Print Program'
IMAGES = [(os.path.join(DOCS, 'flow_zqm002.png'), 'rId7'),
          (os.path.join(DOCS, 'flow_trace_lot_zqm002.png'), 'rId8')]

DOC_NAME = HEADER_NEW
W2 = [3120, 6240]
W3 = [2400, 3480, 3480]
W4 = [1900, 2500, 2480, 2480]

BODY = [
    # ---------------- COVER
    ('cover1', 'FUNCTIONAL DESIGN ENHANCEMENT'),
    ('cover2', 'SAP Form — Certificate of Analysis (ZQM002)'),
    ('cover3', DOC_NAME),
    ('cover4', 'Cetak COA per Delivery Order dengan trace Inspection Lot JR/SR Base Film & Converting'),
    ('cover5', 'Quality Management (QM) — Quality Certificate'),
    ('break',),

    # ---------------- 1. DOCUMENT INFORMATION
    ('h1', '1. DOCUMENT INFORMATION'),
    ('h2', 'General Information'),
    ('table', W2, [
        ['Item', 'Keterangan'],
        ['Project Name', 'Certificate of Analysis (COA) Dinamis — Go-Live 23 Nov 2026'],
        ['Document Name', DOC_NAME],
        ['Version', '1.00'],
    ]),
    ('empty',),
    ('h2', 'Document History'),
    ('table', [1560, 2600, 3200, 2000], [
        ['Version', 'Author', 'Reason for Change', 'Date Effective'],
        ['1.00', 'Tim ABAP', 'Functional Design (as-is)', '03 Nov 2026'],
    ]),
    ('empty',),
    ('h2', 'Object Overview'),
    ('table', W2, [
        ['Attribute', 'Value'],
        ['Business Process', 'Penerbitan Certificate of Analysis (COA) per Delivery Order untuk film BOPP / '
         'Converting yang dikirim ke customer'],
        ['SAP Module', 'Quality Management (QM) — lintas SD (Delivery), PP (Production Order), Batch Management'],
        ['Object Type', 'Form (Smart Forms) dengan driver program Dynpro (Report) dan log override nilai'],
        ['Object Title', 'Certificate (COA Print)'],
        ['Object Description', 'Menampilkan MIC per DO sesuai mapping ZMAP_COA, menelusuri Inspection Lot sumber '
         '(JR/SR Base Film/Converting), mengizinkan koreksi nilai dengan audit log ZLOG_COA, lalu mencetak COA '
         '(ZQMF_COA / ZQMF_COA_EXPORT) beserta lampiran Batch List dinamis.'],
        ['Cycle / Sprint', 'Existing sejak 28.09.2012; enhancement besar Jun–Nov 2026. Snapshot DEV AIX (TRD) '
         '03.11.2026.'],
        ['Complexity', 'High'],
        ['Priority', 'High'],
        ['SAP Program Name', 'ZQMI_COA (package ZTRD)'],
        ['Eksekusi', 'Online via TCODE ZQM002. Program yang sama dipakai ZQM003 (mode ALV report).'],
        ['Similar SAP Program', 'Standar: QC21 / QC22 (Quality Certificate). Custom: ZQM003 (Report COA).'],
        ['Enhancement Implementation', 'Smart Forms ZQMF_COA, ZQMF_COA_EXPORT, ZQMF_COA_BATCH. FM custom '
         'ZQM_GET_BATCH_JR_BY_SR, ZQM_GET_BATCH_SR_BY_JR. BAPI / User Exit / BADI: N/A.'],
        ['Programmer Name', 'Hisar Sianturi (2012); enhancement 2026: tim ABAP (J. Budi dkk.)'],
        ['Evaluated By', '—'],
    ]),
    ('break',),
    ('h1', 'TABLE OF CONTENT'),
    ('toc',),
    ('break',),

    # ---------------- 2. GENERAL REQUIREMENT
    ('h1', '2. GENERAL REQUIREMENT'),
    ('label', 'User Requirement :'),
    ('para', 'Customer mensyaratkan Certificate of Analysis (COA) untuk setiap pengiriman. COA memuat hasil uji '
     'Master Inspection Characteristic (MIC) dari batch yang dikirim. Hasil uji tidak selalu tercatat pada batch '
     'delivery: nilai dapat berasal dari tahap produksi sebelumnya, yaitu Jumbo Roll (JR) atau Slit Roll (SR) pada '
     'level Base Film atau Converting. Flow normal: Raw Material → JR Base Film → SR Base Film → JR Converting → '
     'SR Converting → Packing → Delivery. Change Grade (re-batching, histori ZBATCHISTORY) dan multi-level '
     'converting dapat memutus atau memperpanjang rantai batch. Program harus menelusuri silsilah batch, mengambil '
     'nilai dari Inspection Lot yang benar, mengizinkan koreksi nilai yang teraudit, lalu mencetak COA.'),
    ('field', 'Initiating Program', 'ZQMI_COA'),
    ('field', 'RICEFW Work Unit #', 'RICEFW-QM-ZQMI_COA'),
    ('field', 'Enhancement Title', 'SAP Form — Certificate of Analysis (ZQM002)'),
    ('field', 'Module & Sub module', 'Quality Management — Quality Certificate / Inspection Results'),
    ('field', 'When Enhancement required', 'Sudah produktif; enhancement COA dinamis menuju Go-Live 23 Nov 2026'),
    ('empty',),
    ('label', 'Lingkup :'),
    ('table', W2, [
        ['Dalam Lingkup', 'Di Luar Lingkup'],
        ['Pembacaan DO, batch, klasifikasi batch', 'Pembuatan/perubahan Inspection Lot, result recording, UD'],
        ['Mapping MIC dan sumber lot (ZMAP_COA)', 'Maintenance mapping (TCODE ZQM001 / program ZMAP_COA)'],
        ['Trace silsilah batch dan fallback', 'Desain layout detail Smart Form (SMARTFORMS)'],
        ['Override nilai + audit log ZLOG_COA', 'Mode report ALV ZQM003 (hanya disinggung)'],
        ['Print Domestic/Export + Batch List, export Excel', 'Pengiriman email / arsip COA'],
    ]),
    ('break',),

    # ---------------- 3. TECHNICAL INFORMATION
    ('h1', '3. TECHNICAL INFORMATION'),
    ('table', W2, [
        ['Item', 'Keterangan'],
        ['Functional Description', 'Program membaca item DO (LIPS) dan klasifikasi batch, menggabungkan mapping MIC '
         'generic + customer dari ZMAP_COA, menelusuri Inspection Lot per tahap produksi, menghitung nilai MIC '
         '(langsung / rata-rata sibling / Barrier), menampilkan di Table Control untuk dikoreksi, lalu mencetak '
         'Smart Form COA.'],
        ['Summary Level', 'Per DO + Material + MIC (rata-rata lintas batch dalam DO)'],
        ['Output', 'Screen (Table Control 0100 & 0200), Spool Smart Forms (LOCL), file .XLS / .XLSX'],
        ['Frequency', 'On demand, per DO yang akan dikirim'],
        ['Processing Type', 'Online (foreground). Read-only ke tabel standar; tulis hanya ke ZLOG_COA saat Save.'],
        ['Owner', 'IT / QA'],
        ['Audience', 'QA / QC Release — penerbit COA'],
        ['Business Driver', 'Kepatuhan dokumen mutu ke customer, ketertelusuran hasil uji'],
        ['Priority', 'High'],
        ['Complexity', 'High'],
        ['Design Assumptions', 'Setiap batch DO terhubung ke silsilah produksi via MSEG / ZBATCHISTORY / FM custom. '
         'Lot SR = QALS-ART Z04; lot JR = Z02/Z03. Nomor roll di karakteristik ZZNOMORROLL.'],
        ['BPF ID', 'N/A'],
    ]),
    ('empty',),
    ('label', 'Struktur Program :'),
    ('table', W2, [
        ['Objek', 'Fungsi'],
        ['ZQMI_COA', 'Report utama (dynpro awal 1000)'],
        ['Z_PROG_INFO', 'Tombol Program Information'],
        ['ZQMI_COA_TOP', 'TABLES, internal table, selection screen 1000 & 9000, cache global'],
        ['ZQMI_COA_F01', 'Event, ekstraksi data, trace lot, nilai MIC, print, export'],
        ['ZQMI_COA_F02', 'PBO/PAI Screen 0100 & 0200, Save log, helper BDC'],
        ['ZQMI_COA_ALV', 'Mode report ZQM003 (RPT_PRESELECT / FILTER / BUILD / DISPLAY)'],
    ]),
    ('break',),

    # ---------------- 4. SELECTION SCREEN
    ('h1', '4. PARAMETER SELEKSI'),
    ('h2', '4.1 Fungsi Tiap Parameter'),
    ('table', [1700, 1700, 1100, 4860], [
        ['Field', 'Referensi', 'Wajib', 'Keterangan'],
        ['S_ERDAT', 'LIKP-ERDAT', '—', 'Hanya tampil di ZQM003 / SE38 (MODIF ID R03); disembunyikan di ZQM002.'],
        ['P_WERKS', 'LIPS-WERKS', '—', 'Hanya tampil di ZQM003 / SE38.'],
        ['P_CHARG', 'LIPS-CHARG', '—', 'Filter batch.'],
        ['P_ATWRT', 'AUSP-ATWRT', '—', 'Filter nomor roll (ZZNOMORROLL); dipakai bila P_CHARG kosong.'],
        ['P_MATNR', 'LIPS-MATNR', '—', 'Filter material.'],
        ['P_VBELN', 'LIPS-VBELN', 'Ya', 'Nomor DO. Wajib di ZQM002 untuk mencegah time-out.'],
        ['P_POSNR', 'LIPS-POSNR', '—', 'Item utama; secondary item (LIPS-UECHA = P_POSNR) ikut diambil.'],
        ['INFO', '—', '—', 'Tombol Program Information (F_PROG_INFO).'],
    ]),
    ('note', 'Catatan: item category valid dibaca dari ZMAP_TYPE (PROG = SY-CPROG, TYPE = ITEM CATEGORY). Per '
     '03.11.2026 di TRD belum ada entri untuk ZQMI_COA, sehingga berlaku default PSTYV = ZB.'),
    ('h2', '4.2 Popup Export Header (Screen 9000)'),
    ('para', 'Muncul saat Print untuk DO Export (LIKP-LFART = ZELF). Terdiri dari 16 baris checkbox + nilai. '
     'Default tercentang: Customer Name, PO Number, PI Number, Product, Quantity. Opsional: Container Number, '
     'Delivery Date, Thickness, Grammage, Raw Material Code, LC Number, Width, Date Goods Shipped, #Part, '
     'Manufacturer, Shelf Life. Toolbar menyembunyikan Check, Variant, Print, Background Job.'),
    ('table', W2, [
        ['Field', 'Sumber Prefill'],
        ['PO Number', 'VBAK-BSTNK, fallback VBKD-BSTKD (item lalu header). SO dari LIPS-VGBEL atau VBFA (VBTYP_V = C).'],
        ['PI Number', 'Baris pertama text SO ID Z101 / object VBBK (READ_TEXT).'],
        ['Delivery Date', 'LIKP-LFDAT (DD/MM/YYYY).'],
        ['Thickness / Grammage', 'Karakteristik batch; diisi hanya bila semua batch bernilai sama.'],
        ['Shelf Life', 'Expired Date batch pertama.'],
        ['Manufacturer', 'Default "PT. Trias Sentosa Tbk".'],
    ]),
    ('break',),

    # ---------------- 5. RELATED TRANSACTION
    ('h1', '5. EXISTING / RELATED TRANSACTION'),
    ('table', W3, [
        ['TCODE / Objek', 'Program / Tipe', 'Keterangan'],
        ['ZQM002', 'ZQMI_COA', 'Certificate — cetak COA (dokumen ini)'],
        ['ZQM003', 'ZQMI_COA (cabang SY-TCODE)', 'Report COA — ALV, S_ERDAT wajib'],
        ['ZQM001', 'ZMAP_COA', 'Mapping COA — dispatcher ke ZMAP_COA_MIC / ZMAP_COA_BATCH'],
        ['QA03 / QE51N', 'Standar', 'Display Inspection Lot / result recording'],
        ['SMARTFORMS', 'Standar', 'Maintenance ZQMF_COA, ZQMF_COA_EXPORT, ZQMF_COA_BATCH'],
        ['SE16N', 'Standar', 'Display ZMAP_COA, ZLOG_COA, ZQM_COA_CUST_COL'],
    ]),
    ('break',),

    # ---------------- 6. DESIGN
    ('h1', '6. DESIGN'),
    ('h2', '6.1 Processing Flow Diagram'),
    ('figintro', 'Gambar 1 — Alur eksekusi ZQM002 dari layar seleksi hingga spool Smart Form.'),
    ('image', 0, 3500000),
    ('figcap', 'Gambar 1. Alur eksekusi ZQMI_COA (ZQM002)'),
    ('h2', '6.2 Detailed Description — Alur per Kebutuhan'),
    ('sub', 'Kebutuhan A — Seleksi Delivery & Batch'),
    ('table', [620, 8740], [
        ['#', 'Langkah'],
        ['1', 'Filter roll (P_ATWRT tanpa P_CHARG): AUSP (ZZNOMORROLL, hint index AUSP~N1) → INOB → batch → LIPS '
         'FOR ALL ENTRIES.'],
        ['2', 'Normal: LIPS by VBELN / POSNR / MATNR / CHARG / PSTYV / WERKS. Bila P_POSNR terisi, tambah '
         'secondary item (UECHA IN P_POSNR).'],
        ['3', 'Buang baris tanpa batch.'],
        ['4', 'Klasifikasi bulk: INOB (OBTAB = MCH1) + AUSP (KLART 023) untuk ZZNOMORROLL, ZZCODE, ZZWIDTH, '
         'ZZLENGTH; tabel pengontrol di-SORT dan DELETE ADJACENT DUPLICATES.'],
    ]),
    ('sub', 'Kebutuhan B — Mapping MIC (ZMAP_COA)'),
    ('table', W2, [
        ['Aturan', 'Perilaku'],
        ['Sumber', 'ZMAP_COA dengan DELETION <> X.'],
        ['Generic vs customer', 'Baca generic (KUNNR kosong) dan customer (KUNNR = LIKP-KUNAG); merge per MIC.'],
        ['Override customer', 'METHOD, KUNNR, MAPPING, UOM, MIC_DESC selalu menimpa. LOWER_LIMIT, UPPER_LIMIT, '
         'SEQ_NO menimpa hanya bila terisi.'],
        ['MIC khusus customer', 'Ditambahkan ke daftar.'],
        ['Mapping kosong', 'Pesan "Material belum dimapping di ZMAP_COA..." lalu STOP.'],
        ['Urutan', 'SEQ_NO menentukan urutan tampil & cetak (default 999).'],
    ]),
    ('table', W3, [
        ['ZMAP_COA-MAPPING', 'Variabel Lot', 'QALS-ART'],
        ['SR Converting', 'LOT_SR_CONV', 'Z04'],
        ['JR Converting', 'LOT_JR_CONV', 'Z02 / Z03'],
        ['SR Base Film', 'LOT_SR_BASE', 'Z04'],
        ['JR Base Film', 'LOT_JR_BASE', 'Z02 / Z03'],
        ['(lainnya / kosong)', 'LOT_SR_CONV (default)', '—'],
    ]),
    ('sub', 'Kebutuhan C — Trace Inspection Lot (GET_TRACED_LOTS)'),
    ('figintro', 'Gambar 2 — Alur penelusuran lot dari batch DO ke JR Base Film.'),
    ('image', 1, 3300000),
    ('figcap', 'Gambar 2. Alur GET_TRACED_LOTS'),
    ('table', W2, [
        ['Kasus', 'Perlakuan'],
        ['Lot SR delivery kosong', 'Cek batch original (change grade), lalu SR sibling dari JR yang sama '
         '(maks. 2 lot: LOT_SR_CONV, LOT_SR_CONV2).'],
        ['SR→JR gagal', 'Fallback wrapper: order GR (MSEG 101) → komponen (261/901) → GET_ORIGINAL_BATCH → panggil '
         'ulang ZQM_GET_BATCH_JR_BY_SR.'],
        ['Komponen order', 'Filter MKPF-BKTXT sama dengan dokumen GR; reversal (SMBLN) dibuang; collective order '
         'via AFPO-MILL_OC_AUFNR_U; material SR berakhiran A/O memakai MCH1-LICHA.'],
        ['JR Conv tanpa komponen SR/JR', 'Re-label: JR tersebut = JR Base Film, batch DO = SR Base Film; lot '
         'Converting dikosongkan.'],
        ['Lot JR kosong', 'GET_JR_SIBLING_LOT: roll sibling prefix sama, sequence ±10.'],
        ['Multi-level converting', 'GET_MT_LOTS (maks. 10 hop, proteksi siklus) bila JR Base masih punya komponen '
         'SR/JR; MIC yang tidak ada di lot 2 tingkat dicari ke lot stage sama yang lebih dalam.'],
        ['Cache', 'GT_TRACE_DATA per mother roll (4 segmen pertama ZZNOMORROLL).'],
    ]),
    ('sub', 'Kebutuhan D — Penentuan Nilai MIC'),
    ('table', [620, 8740], [
        ['#', 'Langkah'],
        ['1', 'Spec dari QAMV (PRUEFLOS = lot sumber, VERWMERKM = MIC): deskripsi, limit, MERKNR, STELLEN. MVTR/OTR '
         'menerima padanan WVTR/O2TR. MIC tanpa lot tetap tampil (deskripsi QPMT, UoM & limit QPMK).'],
        ['2', 'Lot JR (Z02/Z03): GET_JR_AVG — nilai lot sendiri; bila kosong, roll sibling sequence lebih kecil '
         'terdekat se-production order yang bernilai.'],
        ['3', 'Lainnya: QAMR-CODE1 (kualitatif).'],
        ['4', 'Kosong + MVTR/WVTR/OTR/O2TR: GET_BAR_AVG — rata-rata single result terakhir (QASE, ORDER BY DETAILERG '
         'DESC) lintas lot SR Converting dalam DO.'],
        ['5', 'Kosong: rata-rata SR sibling se-JR (cache GT_LOT_AVG, hanya ANZWERTG > 0) atau QAMR-MITTELWERT.'],
        ['6', 'Tetap kosong: nilai 0 sebagai penanda belum ada result.'],
        ['7', 'Format decimal sesuai QPMK-STELLEN per MIC + plant (MICFMT).'],
        ['8', 'Agregasi rata-rata nilai non-nol per VBELN + MATNR + MIC; GET_AVG_KEY memastikan 1 grup JR dihitung '
         '1x (fix QM04).'],
        ['9', 'Limit dari ZMAP_COA menimpa limit QAMV bila terisi; override nilai dari ZLOG_COA aktif; hitung '
         'RANGE_FLAG.'],
    ]),
    ('sub', 'Kebutuhan E — Koreksi Nilai & Audit Log (ZLOG_COA)'),
    ('table', [620, 8740], [
        ['#', 'Langkah'],
        ['1', 'Saat load, nilai aktif ZLOG_COA (VBELN + PRUEFLOS + MIC + KUNNR, DELETION <> X) menimpa nilai QM. '
         'VALUE2 (teks) diprioritaskan atas VALUE1 (FLTP).'],
        ['2', 'SAVE membandingkan nilai layar dengan log aktif, atau dengan nilai QM asli bila belum ada log.'],
        ['3', 'Ada perubahan: POPUP_TO_CONFIRM "Konfirmasi Simpan".'],
        ['4', 'Ya: record lama DELETION = X (+ AEDAT/PSOTM/AENAM/TERM2); record baru INSERT dengan SEQ = MAX + 1 '
         '(+ CPUDT/CPUTM/USNAM/TERM1); COMMIT WORK AND WAIT.'],
        ['5', 'Tidak ada perubahan: pesan "Tidak ada data yang berubah".'],
    ]),
    ('sub', 'Kebutuhan F — Print COA (F_PRINT)'),
    ('table', W4, [
        ['LIKP-LFART', 'Form Halaman 1', 'Lampiran Batch List', 'Header'],
        ['ZELF (Export)', 'ZQMF_COA_EXPORT', 'Tidak dicetak di spool', 'Popup Screen 9000'],
        ['Selain ZELF', 'ZQMF_COA', 'ZQMF_COA_BATCH bila 1–7 kolom', 'Customer, DO, Product, Qty, Width'],
    ]),
    ('para', 'Output LOCL, cetak langsung, spool baru; satu spool via SSF_OPEN / SSF_CLOSE. Company name dari '
     'T001-BUTXT (T001K-BWKEY = plant DO). Product = gabungan unik ZZALIAS batch terpilih, fallback ZZCODE. '
     'Width = daftar unik ZZWIDTH (maks. 40 karakter).'),
    ('sub', 'Kebutuhan G — Batch List Dinamis (ZQM_COA_CUST_COL)'),
    ('table', [620, 8740], [
        ['#', 'Langkah'],
        ['1', 'Konfigurasi per KUNNR = LIKP-KUNAG, ACTIVE = X, urut SEQ_NO.'],
        ['2', 'Bila kosong: fallback KUNNR = DOMESTIC (ZDLF / lainnya) atau EXPORT (ZELF).'],
        ['3', 'Maksimum 14 kolom; lebih dari itu error.'],
        ['4', 'Header dari FIELD_LABEL (GS_DYN_HDR); data per batch dari GET_COA_COL_VALUE (GT_DYN_ROLL).'],
        ['5', 'Export XLSX (BATLIST) via OLE Excel: lebar kolom dari COL_SIZE, landscape bila total lebar > 80, '
         'SaveAs format 51, opsi barcode Code39.'],
    ]),
    ('note', 'Field yang didukung: DO_NUMBER, PO_NUMBER, NO_PALET, HU_NUMBER, TYPE, ROLL_NUMBER, BATCH_NUMBER, '
     'WIDTH, LENGTH, CORE, WEIGHT_PER_ROL, JOINT, LENGTH_OF_SPLICE, TOTAL_ROLL, TOTAL_WEIGHT_PALET, EXPIRED_DATE, '
     'PRODUCTION_DATE, GG_PART_NUMBER.'),
    ('h2', '6.3 Input / Output Layout'),
    ('sub', 'Screen 0100 — Daftar MIC (Table Control TCERTI)'),
    ('para', 'Kolom: Checkbox, DO, Item/Group (UECHA), Batch, Nomor Roll SR, Film Type (ZZCODE), Material, Plant, '
     'MIC, Deskripsi, UoM, Method, Lower/Upper Limit, Inspection Lot, Value (editable), Range Flag. Urutan: VBELN, '
     'MATNR, CHK desc, NUMMIC, NUM (SEQ_NO), MIC.'),
    ('table', W2, [
        ['Function Code', 'Fungsi'],
        ['BACK', 'Kembali ke selection screen'],
        ['XPORT', 'Export baris tercentang ke .XLS (GUI_DOWNLOAD)'],
        ['SELALL / DESALL', 'Centang / hapus centang semua'],
        ['GRPCHK', 'Samakan centang per DO + UECHA sesuai baris di kursor'],
        ['SELMAP', 'Centang ulang hanya MIC mapping'],
        ['SAVE', 'Simpan perubahan nilai ke ZLOG_COA'],
        ['EXEC', 'Lanjut ke Screen 0200 (validasi 1 DO, 1 material, sudah Save, tidak campur tipe)'],
    ]),
    ('sub', 'Screen 0200 — Detail COA (Table Control TDETAIL)'),
    ('para', 'Kolom: Properties (MIC Desc), UoM, Testing Method, Lower Limit, Upper Limit, Value (editable), '
     'Range Flag.'),
    ('table', W2, [
        ['Function Code', 'Fungsi'],
        ['BACK', 'Kembali ke Screen 0100'],
        ['DLOAD', 'Export detail COA ke .XLS'],
        ['BATLIST', 'Export Batch List ke XLSX (OLE Excel)'],
        ['PRNT', 'Cetak COA; diblokir bila ada value kosong atau di luar limit'],
    ]),
    ('sub', 'Interface Smart Form'),
    ('table', [3000, 2120, 2120, 2120], [
        ['Parameter', 'ZQMF_COA', 'ZQMF_COA_EXPORT', 'ZQMF_COA_BATCH'],
        ['CUSTOMER / DELIVERY / PRODUCT / QUANTITY / WIDTH', 'X', 'X (isi label export)', 'X'],
        ['COMPANYTXT, GS_DYN_HDR', 'X', 'X', 'X'],
        ['H_LABEL1..5, EXTRA_LABEL/VALUE1..11', '—', 'X', '—'],
        ['IV_COL_COUNT', '—', '—', 'X'],
        ['IT_QAMV (QAMV), IT_ROLL (ZQMSAP), GT_DYN_ROLL', 'X', 'X', 'X'],
    ]),
    ('h2', '6.4 Processing Details — Custom Table'),
    ('sub', 'A. ZMAP_COA — Mapping MIC (tanpa MANDT)'),
    ('table', [2400, 2000, 900, 4060], [
        ['Field', 'Tipe', 'Key', 'Keterangan'],
        ['MATNR', 'CHAR18', 'X', 'Material'],
        ['MIC', 'CHAR8 (QMERKNR)', 'X', 'MIC'],
        ['KUNNR', 'CHAR10', 'X', 'Kosong = generic'],
        ['MIC_DESC', 'CHAR40', '', 'Override deskripsi'],
        ['LOWER_LIMIT / UPPER_LIMIT', 'CHAR20', '', 'Override limit'],
        ['UOM / METHOD / MAPPING', 'CHAR20 / 43 / 43', '', 'Unit, metode uji, sumber lot'],
        ['SEQ_NO', 'NUMC3', '', 'Urutan tampil'],
        ['CPUDT .. TERM2', '—', '', 'Audit create/change'],
        ['DELETION', 'CHAR1', '', 'X = non-aktif'],
    ]),
    ('sub', 'B. ZLOG_COA — Log Override Nilai (tanpa MANDT)'),
    ('table', [2400, 2000, 900, 4060], [
        ['Field', 'Tipe', 'Key', 'Keterangan'],
        ['SEQ', 'NUMC10', 'X', 'Versi (MAX + 1)'],
        ['VBELN', 'CHAR10', 'X', 'DO'],
        ['PRUEFLOS', 'NUMC12', 'X', 'Inspection Lot'],
        ['MIC', 'CHAR8', 'X', 'MIC'],
        ['KUNNR', 'CHAR10', 'X', 'Sold-to'],
        ['VALUE1', 'FLTP16 (QMESSWERT)', '', 'Nilai numerik'],
        ['VALUE2', 'CHAR25', '', 'Nilai teks (prioritas)'],
        ['CPUDT .. TERM2, DELETION', '—', '', 'Audit + soft delete'],
    ]),
    ('sub', 'C. ZQM_COA_CUST_COL — Kolom Batch List'),
    ('table', W3, [
        ['KUNNR', 'Kolom Aktif (urut SEQ_NO)', 'Jumlah'],
        ['DOMESTIC', 'HU_NUMBER, TYPE, ROLL_NUMBER, WIDTH, LENGTH, WEIGHT_PER_ROL', '6'],
        ['EXPORT', 'NO_PALET, TYPE, ROLL_NUMBER, WIDTH, LENGTH, CORE, WEIGHT_PER_ROL, TOTAL_ROLL, '
         'TOTAL_WEIGHT_PALET', '9'],
    ]),
    ('note', 'Key: MANDT, KUNNR, FIELD_NAME. Field lain: FIELD_LABEL (CHAR40), SEQ_NO (NUMC2), COL_SIZE (CHAR1), '
     'ACTIVE (CHAR1). Isi per TRD 03.11.2026.'),
    ('sub', 'D. Tabel Sumber Lain'),
    ('table', W2, [
        ['Tabel', 'Kegunaan'],
        ['LIKP / LIPS', 'Header & item DO (KUNAG, LFART, LFDAT, NTGEW, batch, UECHA, VGBEL)'],
        ['MCH1 / INOB / AUSP / CABN', 'Batch, LICHA, klasifikasi (ZZNOMORROLL, ZZCODE, ZZWIDTH, ZZLENGTH, ZZALIAS)'],
        ['QALS / QAMV / QAMR / QASE', 'Inspection Lot, spec MIC, result rata-rata & single result'],
        ['QPMK / QPMT', 'Master MIC: decimal, UoM, limit default, deskripsi'],
        ['MSEG / MKPF / AFPO', 'Trace GR/GI production order, BKTXT, collective order'],
        ['ZBATCHISTORY', 'Histori change grade (CHARG → NCHARG, BUDAT, UZEIT)'],
        ['VBAK / VBKD / VBFA / VBAP / KNMT', 'PO, PI text, customer material'],
        ['VEKP / VEPO', 'HU pallet/box untuk Batch List'],
        ['KNA1 / T001 / T001K', 'Nama customer, nama perusahaan'],
        ['ZMAP_TYPE', 'Item category valid per program'],
    ]),
    ('h2', '6.5 Summary / Sorting / Dependencies / Constraints'),
    ('table', W2, [
        ['Aspek', 'Keterangan'],
        ['Summary', 'Rata-rata nilai per DO + Material + MIC (non-nol, dedup per lot / grup JR).'],
        ['Sorting', 'Screen 0100: VBELN, MATNR, CHK desc, NUMMIC, NUM, MIC. Cetak: NUMMIC, NUM, MIC.'],
        ['Dependencies', 'FM ZQM_GET_BATCH_JR_BY_SR / ZQM_GET_BATCH_SR_BY_JR; Smart Forms aktif; data ZMAP_COA dan '
         'ZQM_COA_CUST_COL.'],
        ['Constraints', 'Cetak hanya 1 DO dan 1 material per eksekusi. Batch List di spool hanya Domestic 1–7 '
         'kolom. Maks. 14 kolom konfigurasi.'],
        ['Performance', 'Cache GT_TRACE_DATA, GT_JRAVG, GT_BARAVG, GT_LOT_AVG, GT_MICFMT; bulk FOR ALL ENTRIES; '
         'hint MSEG~Z07. Masih ada SELECT SINGLE dalam loop (LIKP, ZMAP_COA, ZLOG_COA).'],
    ]),
    ('break',),

    # ---------------- 7. AUTHORIZATION
    ('h1', '7. AUTHORIZATION CHECK'),
    ('para', 'Program tidak memuat AUTHORITY-CHECK eksplisit. Kontrol akses hanya pada level TCODE (S_TCODE untuk '
     'ZQM002). Fungsi SAVE menulis ke ZLOG_COA tanpa cek otorisasi Plant (WERKS) maupun Sales Organization. '
     'Rekomendasi: tambahkan AUTHORITY-CHECK level WERKS (auth object standar hasil review SU24, atau custom '
     'via SU21) sebelum tampil dan sebelum Save.'),

    # ---------------- 8. ERROR HANDLING
    ('h1', '8. ERROR HANDLING'),
    ('table', [5400, 1200, 2760], [
        ['Pesan', 'Tipe', 'Pemicu'],
        ['Nomor ODO (Delivery) WAJIB diisi! ...', 'I', 'P_VBELN kosong'],
        ['DO tidak ditemukan atau tidak ada item sesuai filter.', 'S/E', 'Data LIPS kosong'],
        ['Material belum dimapping di ZMAP_COA. ...', 'S/E + STOP', 'Mapping kosong'],
        ['Harap Save perubahan nilai (Preview) terlebih dahulu!', 'E', 'EXEC sebelum Save'],
        ['Pilih 1 ODO! / Tipe film tidak boleh berbeda!', 'I', 'EXEC multi DO / material'],
        ['Value mic tidak dapat qualitatif dan quantitatif!', 'I', 'MIC campur tipe nilai'],
        ['Ada data MIC yang belum di-record (kosong), tidak bisa cetak COA!', 'I/E', 'Print dengan nilai kosong'],
        ['Ada value MIC yang keluar dari Lower/Upper Limit ...', 'I/E', 'Print di luar limit'],
        ['Smartform ZQMF_COA / ZQMF_COA_BATCH belum aktif', 'E', 'FM Smart Form tidak ditemukan'],
        ['Gagal membuka / mencetak / menutup Smart Forms ...', 'E', 'Error SSF'],
        ['Konfigurasi kolom COA maksimum 14 kolom', 'E', 'ZQM_COA_CUST_COL > 14 aktif'],
        ['Tidak ada data yang berubah. Tidak ada yang disimpan.', 'S', 'SAVE tanpa perubahan'],
    ]),
    ('para', 'Urutan troubleshooting: ST22 (short dump) → SM21 (system log) → ABAP Debugger pada GET_TRACED_LOTS / '
     'GET_MIC → ST05 bila terkait performa query.'),
    ('break',),

    # ---------------- 9. TEST
    ('h1', '9. COMPONENT TEST REQUIREMENT'),
    ('para', 'Acuan resmi: STANDAR_SKENARIO_TESTING_COA.md (zero regression QM01–QM15 + multi-tier converting).'),
    ('table', [1200, 3600, 1700, 2860], [
        ['ID', 'Skenario', 'DO Acuan', 'Ekspektasi'],
        ['QM01', 'Normal BF — 1 JR dalam 1 DO', '85006234', 'Semua roll ambil lot JR yang sama'],
        ['QM02', 'Normal BF — beda JR dalam 1 DO', '85006235', 'Rata-rata per JR / multi-lot'],
        ['QM03', 'Normal Conv — 1 JR Conv', '85006240', 'Base dari root, Conv dari stage antara'],
        ['QM04', 'Normal Conv — beda JR Conv', '85006241', '1 grup JR = 1 kunci rata-rata'],
        ['QM05/06', 'SR BF inspeksi vs change grade', '85006242', 'Silsilah tetap ke JR asal'],
        ['QM07/08', 'SR Conv inspeksi vs change grade', '85006243', 'Lot lama terbaca di batch baru'],
        ['QM09/10', 'Secondary slitting BF / Conv', '85006244/45', 'Trace SR→SR→JR bertingkat'],
        ['QM11/12', 'Join 2 JR; inspeksi ke-20+', '—', 'Multi-parent; tanpa batas index'],
        ['QM13', '1 DO 3 JR beda line', '—', 'Nilai tidak saling menimpa'],
        ['QM14', 'Banyak DO sekali cetak', '—', 'Refresh variabel global per DO'],
        ['QM15', 'Ubah value di Print Certificate', '—', 'Nilai editan tidak tertimpa'],
        ['MT-1..7', 'Multi-tier JRAH8I → JRGLBI', '—', 'Optical Density 2.378; Surface Tension 42 / 52'],
    ]),
    ('table', [2400, 2400, 4560], [
        ['DO', 'Kolom Batch List', 'Ekspektasi Layout'],
        ['85004908', '6 (DOMESTIC)', 'ZQMF_COA + Batch List portrait'],
        ['0084000047', '7 (SRAABI)', 'ZQMF_COA + Batch List portrait'],
        ['0085000140', '10 (SRACLI)', 'Page 1 portrait + Batch List landscape (lihat Bagian 10, G-01)'],
    ]),
    ('note', 'Uji negatif: P_VBELN kosong; material tanpa mapping; EXEC 2 DO / 2 material; Print nilai 0 atau di '
     'luar limit; Save tanpa perubahan; ZQM_COA_CUST_COL lebih dari 14 kolom.'),
    ('break',),

    # ---------------- 10. GAP
    ('h1', '10. BATASAN & HAL YANG MASIH TERBUKA'),
    ('table', [900, 3500, 2480, 2480], [
        ['ID', 'Temuan', 'Dampak', 'Rekomendasi'],
        ['G-01', 'ZQMF_COA_BATCH_POTRAIT & ZQMF_COA_BATCH_LANDSCAPE (dokumen arsitektur) tidak ada di TRD; kode '
         'memanggil ZQMF_COA_BATCH hanya untuk Domestic 1–7 kolom.',
         'Batch List 8–14 kolom dan Export tidak tercetak di spool; hanya via XLSX.',
         'Selaraskan dokumen arsitektur atau lanjutkan form landscape.'],
        ['G-02', 'Mapping kosong untuk 1 material memicu STOP.', 'Seluruh DO tidak tampil.',
         'Skip material + pesan per material.'],
        ['G-03', 'CANCEL_UD (BDC QA12) tidak dipanggil.', 'Dead code; risiko bila diaktifkan.',
         'Hapus atau dokumentasikan.'],
        ['G-04', 'Tidak ada AUTHORITY-CHECK.', 'Override nilai cukup dengan akses TCODE.',
         'Cek level WERKS (SU24 / SU21).'],
        ['G-05', 'SAVE tanpa enqueue; SEQ = MAX + 1.', 'Race condition / duplicate key.',
         'Lock object custom untuk ZLOG_COA.'],
        ['G-06', 'Pembanding SAVE memformat VALUE1 dengan DECIMALS 3.', 'Deteksi perubahan palsu.',
         'Gunakan MICFMT saat membandingkan.'],
        ['G-07', 'ZMAP_COA & ZLOG_COA tanpa MANDT.', 'Data lintas client bercampur.',
         'Konfirmasi desain dengan Basis/functional.'],
        ['G-08', 'ZMAP_TYPE untuk ZQMI_COA kosong; fallback ZB.', 'Item category lain tidak terbaca.',
         'Isi ZMAP_TYPE bila perlu.'],
        ['G-09', 'SELECT SINGLE dalam loop (LIKP, ZMAP_COA, ZLOG_COA).', 'Response time naik pada DO besar.',
         'Pre-load + BINARY SEARCH.'],
    ]),

    # ---------------- 11. APPENDIX
    ('h1', '11. APPENDIX — CONFIRMATION POINTS'),
    ('h2', 'A. Transport & Landscape'),
    ('table', W2, [
        ['Langkah', 'Keterangan'],
        ['Analisis', 'DEV AIX (TRD) / server lain, read-only'],
        ['Perubahan source', 'Wajib di sandbox-new (TRS client 130) via Z_RFC_PROGRAM_UPDATE; Smart Form via XML '
         'upload'],
        ['Promosi', 'Dev → QAS → PRD via SE09 / STMS: PROG ZQMI_COA + include, SSFO ZQMF_COA*, TABL ZMAP_COA / '
         'ZLOG_COA / ZQM_COA_CUST_COL, struktur ZQM_COA_DYN_*'],
        ['Data konfigurasi', 'ZMAP_COA & ZQM_COA_CUST_COL diisi per environment via ZQM001 / SM30, bukan transport '
         'kode'],
    ]),
    ('h2', 'B. Daftar FORM Utama'),
    ('table', W2, [
        ['FORM', 'Fungsi'],
        ['GET_DATA', 'Ekstraksi DO, mapping, nilai, agregasi, override'],
        ['GET_TRACED_LOTS', 'Trace 4 lot + cache mother roll'],
        ['GET_ORIGINAL_BATCH / GET_NEWEST_BATCH', 'Telusur ZBATCHISTORY mundur / maju'],
        ['GET_VALID_ORDER_FROM_MSEG / GET_VALID_COMPONENT_FROM_MSEG', 'Order GR & komponen GI aktif (filter BKTXT)'],
        ['GET_JR_SIBLING_LOT / GET_MT_LOTS', 'Sibling JR & multi-level converting'],
        ['GET_MIC / GET_JR_AVG / GET_BAR_AVG / GET_AVG_KEY', 'Spec & nilai MIC'],
        ['MICFMT / PARSE_LIMIT_TO_RAW', 'Format decimal & konversi limit'],
        ['PREPARE_DYNAMIC_ROLL_COLUMNS / GET_COA_COL_VALUE', 'Batch List dinamis'],
        ['F_PRINT / PREPARE_EXPORT_HEADER / GET_COMPANY_NAME', 'Cetak Smart Form'],
        ['DOWNLOAD / DOWNLOAD_DETAIL / DOWNLOAD_BATCH_LIST_XLSX', 'Export Excel'],
        ['SAVE_ADD_INFO / SET_COA_RANGE_FLAG', 'Log override & flag limit'],
    ]),
    ('h2', 'C. Dokumen'),
    ('table', W2, [
        ['Dokumen', 'Lokasi'],
        ['WRICEF (Markdown)', 'subproject/COA/docs/WRICEF_ZQM002_Certificate_of_Analysis.md'],
        ['Tech Spec', 'subproject/COA/docs/ZQMI_COA_Technical_Specification.md'],
        ['Proses bisnis', 'subproject/COA/docs/COA.md'],
        ['Arsitektur Smart Form', 'subproject/COA/ARCHITECTURE_COA_DYNAMIC.md'],
        ['Skenario uji', 'subproject/COA/docs/STANDAR_SKENARIO_TESTING_COA.md'],
        ['Source DEV AIX', 'subproject/COA/outputs/seq_check_20261103/'],
    ]),
    ('end', '— Selesai —'),
]
