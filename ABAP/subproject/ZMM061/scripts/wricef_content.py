"""Konten WRICEF/FS ZMM061 (ZMMR_RETURN_PALLET_STOCK) — as-is dari source DEV = PRD."""
import os

DOCS = os.path.join(os.path.dirname(__file__), '..', 'docs')
HEADER_OLD = 'RICEFW-MM-ZMMI_PO_EMAIL PO Approval Notification Program'
HEADER_NEW = 'RICEFW-MM-ZMMR_RETURN_PALLET_STOCK Returnable Pallet Stock Report'
IMAGES = [(os.path.join(DOCS, 'flow_zmm061.png'), 'rId7'),
          (os.path.join(DOCS, 'flow_status_zmm061.png'), 'rId8')]

DOC_NAME = HEADER_NEW
W2 = [3120, 6240]          # tabel 2 kolom (Item | Keterangan)
WSTEP = [620, 8740]        # tabel langkah (# | Langkah)

BODY = [
    # ---------------- COVER
    ('cover1', 'FUNCTIONAL DESIGN ENHANCEMENT'),
    ('cover2', 'SAP Report — Returnable Pallet Stock (ZMM061)'),
    ('cover3', DOC_NAME),
    ('cover4', 'Laporan stok dan status siklus Returnable Pallet (RTP) per Pallet ID beserta Terminal'),
    ('cover5', 'Materials Management (MM) — Inventory Management'),
    ('break',),

    # ---------------- 1. DOCUMENT INFORMATION
    ('h1', '1. DOCUMENT INFORMATION'),
    ('h2', 'General Information'),
    ('table', W2, [
        ['Item', 'Keterangan'],
        ['Project Name', 'Returnable Pallet (RTP) Management — Reporting'],
        ['Document Name', DOC_NAME],
        ['Version', '1.00'],
    ]),
    ('empty',),
    ('h2', 'Document History'),
    ('table', [1560, 2600, 3200, 2000], [
        ['Version', 'Author', 'Reason for Change', 'Date Effective'],
        ['1.00', 'Tim ABAP', 'Functional Design (as-is)', '29 Okt 2026'],
    ]),
    ('empty',),
    ('h2', 'Object Overview'),
    ('table', W2, [
        ['Attribute', 'Value'],
        ['Business Process', 'Returnable Pallet (RTP) Tracking — monitoring stok & status siklus pallet'],
        ['SAP Module', 'Materials Management (MM) — Inventory Management'],
        ['Object Type', 'Report (ALV)'],
        ['Object Title', 'Report Returnable Pallet Stock'],
        ['Object Description', 'Menampilkan stok Returnable Pallet (ZRTP) per Pallet ID beserta status siklus terakhir '
         '(dari log ZPALLETR) dan Terminal lokasi (dari mapping ZMAP_TYPE).'],
        ['Cycle / Sprint', 'Existing (as-is); dibuat 21 Des 2017, enhancement terakhir 24.03.2026. DEV = PRD.'],
        ['Complexity', 'Low'],
        ['Priority', 'Medium'],
        ['SAP Program Name', 'ZMMR_RETURN_PALLET_STOCK'],
        ['Eksekusi', 'Online via TCODE ZMM061 dan 6 TCODE varian (lihat Bagian 4.2)'],
        ['Similar SAP Program', 'ZMMR_RETURN_PALLET (ZMM062 — Returnable Pallet History). Standar: MMBE / MB52.'],
        ['Enhancement Implementation', 'BAPI / BDC / User Exit / BADI: N/A (custom report, read-only). FM standar '
         'dipakai: REUSE_ALV_GRID_DISPLAY, F4IF_INT_TABLE_VALUE_REQUEST.'],
        ['Programmer Name', 'Mualifi (2017); enhancement: Stefan & Jarwo (2019), William (2020–2026)'],
        ['Evaluated By', '—'],
    ]),
    ('break',),
    ('h1', 'TABLE OF CONTENT'),
    ('toc',),
    ('break',),

    # ---------------- 2. GENERAL REQUIREMENT
    ('h1', '2. GENERAL REQUIREMENT'),
    ('label', 'User Requirement :'),
    ('para', 'Returnable Pallet (RTP) — material type ZRTP (Returnable Pack) dengan material group 900001 (Pallet Besi), '
     '900002 (Pallet Kayu) dan 900003 (Pallet Plastik) — dipakai sebagai alas packing barang jadi, ikut terkirim ke '
     'customer, lalu dikembalikan ke gudang. Setiap pallet dikelola sebagai batch (Pallet ID) dan pergerakannya dicatat '
     'pada tabel log ZPALLETR (Packed → At Customer → Completed). Pengguna gudang membutuhkan laporan stok pallet yang '
     'masih tercatat di gudang beserta status siklus terakhir dan lokasi Terminal, untuk memantau pallet yang siap '
     'dipakai (NEW/FREE), sedang dipakai packing (PACKING), maupun yang secara dokumen masih di customer. Pengembangan '
     'lanjutan: pilihan RTP Core & RTP Sideboard (2019–2020) serta kolom dan filter Terminal berbasis mapping ZMAP_TYPE '
     '(2026).'),
    ('field', 'Initiating Program', 'ZMMR_RETURN_PALLET_STOCK'),
    ('field', 'RICEFW Work Unit #', 'RICEFW-MM-ZMMR_RETURN_PALLET_STOCK'),
    ('field', 'Enhancement Title', 'SAP Report — Returnable Pallet Stock (ZMM061)'),
    ('field', 'Module & Sub module', 'Materials Management — Inventory Management (Returnable Packaging)'),
    ('field', 'When Enhancement required', 'Sudah produktif (dokumentasi as-is)'),

    # ---------------- 3. TECHNICAL INFORMATION
    ('h1', '3. TECHNICAL INFORMATION'),
    ('table', W2, [
        ['Item', 'Keterangan'],
        ['Functional Description', 'Program membaca stok batch pallet RTP di MCHB sesuai filter, mengambil dokumen '
         'ZPALLETR terakhir untuk tiap Pallet ID, menurunkan status siklus pallet, melengkapi tanggal GR pallet (MCH1) '
         'dan nama Terminal (ZMAP_TYPE), lalu menampilkan hasil dalam ALV grid.'],
        ['Summary Level', 'Detail (1 baris per Pallet ID per Plant/Sloc)'],
        ['Output', 'Screen (ALV Grid). Dapat diekspor ke spreadsheet melalui fungsi standar ALV.'],
        ['Frequency', 'On demand (dijalankan user saat dibutuhkan)'],
        ['Processing Type', 'Online (foreground). Read-only — tidak ada update database.'],
        ['Owner', 'IT'],
        ['Audience', 'Gudang / Logistik — pengelola Returnable Pallet (Waru, Krian, Bekasi)'],
        ['Business Driver', 'Kontrol aset Returnable Pallet (ketersediaan & posisi pallet)'],
        ['Priority', 'Medium'],
        ['Complexity', 'Low'],
        ['Design Assumptions', 'Hanya pallet dengan stok unrestricted (MCHB-CLABS > 0). Status dari dokumen ZPALLETR '
         'terakhir berstatus P/E/C. Mapping Terminal dibaca per TCODE (SY-TCODE).'],
        ['BPF ID', 'N/A'],
    ]),
    ('break',),

    # ---------------- 4. PARAMETER
    ('h1', '4. PARAMETER SELEKSI & VARIANT PROGRAM'),
    ('para', 'Program dijalankan online melalui TCODE ZMM061 atau TCODE varian yang memanggil variant tersimpan. Bagian '
     'ini menjelaskan seluruh parameter layar seleksi beserta fungsinya (data apa yang difilter), lalu menampilkan '
     'pemetaan TCODE ke variant.'),
    ('h2', '4.1 Fungsi Tiap Parameter'),
    ('table', [1400, 2400, 5560], [
        ['Parameter', 'Memfilter data', 'Fungsi / Penjelasan'],
        ['P_RAD1 (RTP Pallet)', '— (pilihan jenis RTP)', 'Radio button default. Menjalankan report stok Returnable '
         'Pallet pada program ini.'],
        ['P_RAD2 (RTP Core)', '— (pilihan jenis RTP)', 'Meneruskan ke ZMMR_RETURN_CORE_STOCK (SUBMIT ... AND RETURN): '
         'P_MATNR → P_MATNR, P_PALID → P_COREID, P_WERKS1 → P_WERKS, P_LGORT1 → P_LGORT. Filter Terminal tidak '
         'diteruskan.'],
        ['P_RAD3 (RTP Sideboard)', '— (pilihan jenis RTP)', 'Meneruskan ke ZMMR_RETURN_BOARD_STOCK dengan pola yang sama '
         '(P_PALID → P_BOARD). Filter Terminal tidak diteruskan.'],
        ['P_MATNR', 'Material (MCHB-MATNR)', 'Membatasi material pallet RTP tertentu.'],
        ['P_PALID', 'Pallet ID / Batch (MCHB-CHARG)', 'Menjalankan untuk satu/beberapa Pallet ID (RTP ID).'],
        ['P_WERKS1', 'Plant (MCHB-WERKS)', 'Membatasi plant stok pallet.'],
        ['P_LGORT1', 'Storage Location (MCHB-LGORT)', 'Membatasi storage location. PENTING: hanya berlaku bila filter '
         'Terminal kosong; bila Terminal diisi, P_LGORT1 diabaikan.'],
        ['P_TRMNL1', 'Terminal → Sloc (ZMAP_TYPE-TEXT1 → VALUE)', 'Memilih nama Terminal (F4 dari ZMAP_TYPE). Nama '
         'Terminal dikonversi menjadi daftar Sloc (VALUE) yang dipakai sebagai filter LGORT. Mendukung huruf kecil '
         '(LOWER CASE).'],
    ]),
    ('note', 'Catatan: seluruh parameter data bersifat opsional dan berupa select-option (mendukung banyak nilai/range). '
     "Filter dasar program yang selalu berlaku (tidak lewat parameter): material type MARA-MTART = 'ZRTP', material "
     "group MARA-MATKL IN ('900001','900002','900003'), dan stok unrestricted MCHB-CLABS > 0."),
    ('empty',),
    ('h2', '4.2 Isi Variant (Aktual)'),
    ('para', 'Setiap TCODE varian memanggil program yang sama dengan variant tersimpan. Karena mapping Terminal dibaca '
     'berdasarkan SY-TCODE, ketersediaan kolom dan filter Terminal bergantung pada TCODE yang dipakai.'),
    ('table', [3120, 3120, 3120], [
        ['TCODE', 'Variant', 'Keterangan (TSTCT)'],
        ['ZMM061', '(tanpa variant)', 'Report Returnable Pallet Stock'],
        ['ZMM061_K', 'ZMM061K', 'Returnable Pallet Stock Krian'],
        ['ZMM061_W', 'ZMM061W', 'Returnable Pallet Stock Waru'],
        ['ZMM061_TS', 'ZMM061_TS', 'TS Returnable Pallet Stock Krian'],
        ['ZMM061_WKA', 'ZMM061_WKA', 'RTP Stock for Trias-TTA'],
        ['ZAMM061K', 'TTA_KRIAN', 'TA Returnable Pallet Stock Krian'],
        ['ZEMM061', 'ZEMM061-01', 'TE Returnable Pallet Stock Report'],
    ]),
    ('empty',),
    ('table', [1900, 2600, 4860], [
        ['TCODE', 'Mapping Terminal (PRD)', 'Dampak'],
        ['ZMM061', '33 baris / 15 Terminal', 'Kolom & filter Terminal berfungsi.'],
        ['ZMM061_K', '33 baris / 15 Terminal', 'Berfungsi (isi identik ZMM061).'],
        ['ZMM061_W', '33 baris / 15 Terminal', 'Berfungsi (isi identik ZMM061).'],
        ['ZMM061_TS, ZMM061_WKA, ZAMM061K, ZEMM061', 'Tidak ada', 'Kolom Terminal kosong; filter Terminal tidak '
         'membatasi Sloc (seluruh Sloc tampil).'],
        ['SE38 (langsung)', "Tidak ada (SY-TCODE = 'SE38')", 'Sama seperti baris di atas.'],
    ]),
    ('note', 'Efek: perilaku Terminal berbeda per TCODE walaupun programnya sama. Di DEV, mapping hanya tersedia untuk '
     'ZMM061. Isi nilai tiap variant belum terverifikasi karena tidak dapat dibaca via RFC (RS_VARIANT_CONTENTS → '
     'pesan DA 300); verifikasi di SE38 > Goto > Variants (lihat Bagian 10).'),

    # ---------------- 5. EXISTING
    ('h1', '5. EXISTING / RELATED TRANSACTION'),
    ('field', 'Existing Program Name', 'ZMMR_RETURN_PALLET (ZMM062 — Returnable Pallet History); ZMMR_GRN_PALLET '
     '(ZMM060 — GRN Returnable Pallet)'),
    ('field', 'Existing Menu / Transaction', 'MMBE / MB52 (stok batch standar SAP)'),
    ('field', 'Legacy Enhancement Name / No.', 'N/A'),
    ('break',),

    # ---------------- 6. DESIGN
    ('h1', '6. DESIGN'),
    ('h2', '6.1 Processing Flow Diagram'),
    ('figintro', 'Gambar 1 — Alur eksekusi program dari layar seleksi hingga tampilan ALV.'),
    ('image', 0, 3300000),
    ('figcap', 'Gambar 1. Alur eksekusi ZMMR_RETURN_PALLET_STOCK (ZMM061)'),
    ('h2', '6.2 Detailed Description — Alur per Kebutuhan'),
    ('para', 'Program memenuhi tiga kebutuhan yang saling berurutan dalam satu kali eksekusi mode RTP Pallet. Mode RTP '
     'Core dan RTP Sideboard hanya meneruskan parameter ke program lain. Berikut alur masing-masing kebutuhan.'),
    ('sub', 'Kebutuhan A — Seleksi Stok Pallet (Terminal & Sloc)'),
    ('table', WSTEP, [
        ['#', 'Langkah'],
        ['1', "Baca mapping Terminal dari ZMAP_TYPE: TCODE = SY-TCODE, TYPE = 'PALLET', OPT = 'TERMINAL', DELETION <> "
         "'X'. Bila filter Terminal diisi, hanya baris dengan TEXT1 IN P_TRMNL1."],
        ['2', 'Bentuk range Sloc: Terminal kosong → range = P_LGORT1; Terminal diisi → range = seluruh VALUE (Sloc) '
         'dari mapping terpilih (P_LGORT1 diabaikan).'],
        ['3', "Ambil stok batch: MCHB JOIN MARA JOIN MAKT dengan filter MATNR, CHARG (Pallet ID), WERKS, LGORT (range), "
         "MTART = 'ZRTP', MATKL IN ('900001','900002','900003'), CLABS > 0. Urutkan per Pallet ID."],
        ['4', "Bila tidak ada data → tampil pesan error 'Data tidak ada...!' dan program berhenti."],
    ]),
    ('empty',),
    ('sub', 'Kebutuhan B — Penentuan Status Pallet'),
    ('para', 'Status diturunkan dari dokumen log pergerakan pallet ZPALLETR terakhir untuk setiap Pallet ID. Satu Pallet '
     'ID hanya memiliki satu status.'),
    ('table', WSTEP, [
        ['#', 'Langkah'],
        ['1', "Untuk tiap Pallet ID hasil stok, ambil 1 dokumen ZPALLETR dengan STATUS IN ('P','E','C') dan DOCNO "
         "terbesar (dokumen terakhir)."],
        ['2', 'Bila tidak ada satu pun dokumen untuk seluruh pallet → semua pallet berstatus NEW (tanpa Pallet GR Date), '
         'lalu langsung ke tampilan ALV.'],
        ['3', 'Cocokkan dokumen per pallet: PALID + WERKS1 (plant dokumen) = plant stok; bila tidak cocok, cukup PALID.'],
        ['4', 'Turunkan status: E → CUSTOMER; P → PACKING; C → FREE (FREE (RETURN) bila Sloc 1810/2810/3810); tanpa '
         'dokumen → NEW (NEW (RETURN) bila Sloc 1810/2810/3810).'],
        ['5', 'Lengkapi Pallet GR Date dari MCH1-ERSDA (tanggal batch dibuat) dan Terminal dari mapping (VALUE = Sloc).'],
    ]),
    ('empty',),
    ('h2', '6.2.1 Detail Logic Status Pallet (sumber tabel & rumus)'),
    ('para', 'Status dibaca dari field ZPALLETR-STATUS yang ditulis oleh program siklus pallet (packing HU, pengiriman '
     'ke customer, GRN pengembalian pallet ZMM060). Tabel berikut merinci kode sumber, tabel/field SAP, dan rumus '
     'logika (sesuai kode program).'),
    ('table', [1500, 2050, 1900, 2810, 1100], [
        ['Status Report', 'Kode ZPALLETR', 'Tabel & Field', 'Logika', 'Status'],
        ['CUSTOMER', 'E (At Customer)', 'ZPALLETR-STATUS, DOCNO', 'Dokumen terakhir pallet berstatus E: pallet tercatat '
         'dikirim ke customer.', 'Aktif'],
        ['PACKING', 'P (Packed)', 'ZPALLETR-STATUS', 'Dokumen terakhir berstatus P: pallet dipakai packing HU, belum '
         'dikirim.', 'Aktif'],
        ['FREE', 'C (Completed)', 'ZPALLETR-STATUS; MCHB-LGORT', 'Dokumen terakhir berstatus C (sudah GRN kembali via '
         'ZMM060) dan Sloc bukan 1810/2810/3810.', 'Aktif'],
        ['FREE (RETURN)', 'C (Completed)', 'ZPALLETR-STATUS; MCHB-LGORT', 'Status C dan Sloc = 1810/2810/3810 (Gudang FG '
         'Return WR/KR/BKS).', 'Aktif'],
        ['NEW', '(tidak ada)', 'ZPALLETR', 'Tidak ada dokumen P/E/C untuk Pallet ID: pallet belum pernah dipakai.',
         'Aktif'],
        ['NEW (RETURN)', '(tidak ada)', 'ZPALLETR; MCHB-LGORT', 'Tidak ada dokumen dan Sloc = 1810/2810/3810.', 'Aktif*'],
        ['—', 'L (Deleted / Cancelled)', 'ZPALLETR-STATUS', 'Tidak ikut seleksi; pallet dinilai dari dokumen P/E/C '
         'sebelumnya, bila tidak ada → NEW.', 'Diabaikan'],
    ]),
    ('note', 'Catatan: Sloc return (1810/2810/3810) di-hardcode di program, tidak dibaca dari ZMAP_TYPE. * Penanda '
     '(RETURN) pada NEW tidak diterapkan bila tidak ada satu pun dokumen ZPALLETR untuk seluruh hasil seleksi (jalur '
     'keluar awal, langkah B2).'),
    ('break',),
    ('figintro', 'Gambar 2 — Alur logika penentuan Status per Pallet ID.'),
    ('image', 1, 3900000),
    ('figcap', 'Gambar 2. Alur logika Status Pallet'),
    ('empty',),
    ('sub', 'Kebutuhan C — Tampilan ALV'),
    ('table', WSTEP, [
        ['#', 'Langkah'],
        ['1', 'Susun field catalog 8 kolom (lihat 6.3) dan layout ALV: zebra, kotak pilih baris (BOX), cell merge, '
         'konfirmasi keluar.'],
        ['2', "Urutkan hasil per Pallet ID lalu tampilkan via REUSE_ALV_GRID_DISPLAY (layout user dapat disimpan, "
         "I_SAVE = 'A')."],
        ['3', 'GUI status STANDARD_FULLSCREEN. Tombol OLAP (download ke server RTP via ZDL_STOCK_RTP) dinonaktifkan '
         'sejak 13.06.2023.'],
    ]),
    ('h2', '6.3 Input / Output Layout'),
    ('para', 'Input — parameter layar seleksi dijelaskan lengkap pada Bagian 4 (Parameter Seleksi & Variant).'),
    ('sub', 'Output — Kolom ALV'),
    ('table', [1800, 2600, 4960], [
        ['Field', 'Sumber', 'Keterangan'],
        ['Material', 'MCHB-MATNR', 'Nomor material pallet RTP'],
        ['Material Description', 'MAKT-MAKTX', 'Deskripsi material'],
        ['Pallet ID', 'MCHB-CHARG', 'Nomor batch = ID pallet'],
        ['Plant', 'MCHB-WERKS', 'Plant stok'],
        ['Sloc', 'MCHB-LGORT', 'Storage location stok'],
        ['Status', 'Hasil logika (ZPALLETR)', 'NEW / NEW (RETURN) / PACKING / CUSTOMER / FREE / FREE (RETURN)'],
        ['Pallet GR Date', 'MCH1-ERSDA', 'Tanggal pembuatan batch pallet'],
        ['Terminal', 'ZMAP_TYPE-TEXT1', 'Nama Terminal berdasarkan Sloc (kosong bila Sloc tidak termapping)'],
    ]),
    ('empty',),
    ('h2', '6.4 Processing Details — Full Mapping (Tabel ZMAP_TYPE)'),
    ('para', "Mapping Terminal disimpan pada tabel konfigurasi ZMAP_TYPE (key: TCODE = SY-TCODE, TYPE = 'PALLET', "
     "OPT = 'TERMINAL'). VALUE = Sloc, TEXT1 = nama Terminal. Baris dengan Deletion = 'X' diabaikan program. Selain "
     "itu terdapat dua aturan yang di-hardcode: kode status ZPALLETR dan material group RTP."),
    ('sub', 'A. TERMINAL — Mapping Sloc ke Terminal (PRD, TCODE ZMM061)'),
    ('table', [2600, 3200, 3560], [
        ['Terminal (TEXT1)', 'Sloc (VALUE)', 'Keterangan'],
        ['Converting WR', '1042, 1054, 1062, 1306, 1308, 1310', 'Area converting Waru'],
        ['Gudang FG', '1082', '—'],
        ['Gudang FG WR', '1802', 'Gudang FG Waru'],
        ['Gudang FG Return WR', '1810', 'Sloc return → label (RETURN)'],
        ['Gudang RPMS WR', '1815', '—'],
        ['Converting KR', '2012, 2042, 2048, 2054, 2062, 2074', 'Area converting Krian'],
        ['CPP & OPP L4', '2302, 2304, 2330, 2334, 2336', 'Line produksi'],
        ['BOPET 1 & BOPET 2', '2306, 2308', 'Line produksi'],
        ['OPP L6 & L7', '2322, 2324, 2326, 2328', 'Line produksi'],
        ['Gudang FG KR', '2802', 'Gudang FG Krian'],
        ['Gudang FG Return KR', '2810', 'Sloc return → label (RETURN)'],
        ['Gudang RPMS KR', '2815', '—'],
        ['Gudang FG BKS', '3802', 'Gudang FG Bekasi'],
        ['Gudang FG Return BKS', '3810', 'Sloc return → label (RETURN)'],
        ['Gudang RPMS BKS', '3815', '—'],
    ]),
    ('note', "Mapping identik untuk TCODE ZMM061_K dan ZMM061_W di PRD (masing-masing 33 baris). Di DEV hanya ZMM061 "
     "(35 baris; Sloc 2082 dan 3082 Deletion = 'X'). TCODE ZMM061_TS, ZMM061_WKA, ZAMM061K, ZEMM061 belum memiliki "
     "mapping."),
    ('empty',),
    ('sub', 'B. STATUS — Kode Status ZPALLETR'),
    ('table', [1100, 2400, 3500, 2360], [
        ['Kode', 'Arti (ZMM062)', 'Sumber pencatatan', 'Dipakai ZMM061'],
        ['P', 'Packed', 'Packing HU (ZHUI_PACK_*)', 'Ya → PACKING'],
        ['E', 'At Customer', 'Proses pengiriman pallet ke customer', 'Ya → CUSTOMER'],
        ['C', 'Completed', 'GRN pengembalian pallet ZMM060 (ZMMR_GRN_PALLET)', 'Ya → FREE / FREE (RETURN)'],
        ['L', 'Deleted / Cancelled', 'Pembatalan packing HU (ZHUI_PACK_*)', 'Tidak (diabaikan)'],
    ]),
    ('note', 'Terkait: BAdI MIGO (ZCL_IM_MB_MIGO_BADI / ZCL_IM_MB_MIGO_ITEM_BADI) menolak pergerakan pallet yang '
     'dokumen ZPALLETR terakhirnya berstatus P atau E.'),
    ('empty',),
    ('sub', 'C. MATERIAL GROUP — Filter Jenis Pallet (hardcode)'),
    ('table', [1900, 3000, 4460], [
        ['MATKL', 'Deskripsi (T023T)', 'Masuk laporan ZMM061 (RTP Pallet)'],
        ['900001', 'RTP-Pallet Besi', 'Ya'],
        ['900002', 'RTP-Pallet Kayu', 'Ya'],
        ['900003', 'RTP-Pallet Plastik', 'Ya'],
        ['900004', 'RTP-Core Plastik', 'Tidak (dikeluarkan 21.08.2019)'],
        ['900005', 'RTP-Core Besi', 'Tidak (dikeluarkan 21.08.2019)'],
        ['900006', 'RTP-Side B. Plastik', 'Tidak'],
        ['900007', 'RTP-Core Aluminium', 'Tidak'],
    ]),
    ('note', 'Catatan: isi variant & fungsi parameter seleksi telah dijelaskan pada Bagian 4.'),
    ('h2', '6.5 Summary / Footer / Breaking / Totals / Sorting / Dependencies / Constraints'),
    ('para', 'Summary Data: N/A · Footer Data: N/A · Breaking: N/A · Totals: N/A (teks Sub Total/Total tersedia bila '
     'user menambah total di layout ALV) · Sorting: berdasarkan Pallet ID. Pre/Post-Processing: mapping Terminal '
     'ZMAP_TYPE per TCODE wajib terisi agar kolom/filter Terminal berfungsi. Design Constraints: read-only; akurasi '
     'status bergantung kelengkapan log ZPALLETR. Upload Program: N/A.'),

    # ---------------- 7. AUTHORIZATION
    ('h1', '7. AUTHORIZATION CHECK'),
    ('para', 'Program tidak melakukan pemeriksaan otorisasi organisasi (AUTHORITY-CHECK Plant/Sloc) secara eksplisit. '
     'Akses dibatasi hanya oleh otorisasi TCODE (S_TCODE) untuk ZMM061 dan TCODE varian. Pengecekan objek Z_OLAP '
     'untuk tombol download OLAP telah dinonaktifkan (13.06.2023) bersamaan dengan penghapusan fitur download. '
     'Penambahan authority-check Plant merupakan open item (lihat bagian Batasan).'),

    # ---------------- 8. ERROR HANDLING
    ('h1', '8. ERROR HANDLING'),
    ('table', [620, 4000, 4740], [
        ['No.', 'Possible Error', 'Notification / Procedure'],
        ['1', 'Tidak ada stok pallet sesuai filter', "Pesan error 'Data tidak ada...!' (type E). User mengubah filter."],
        ['2', 'Filter Terminal diisi namun tidak ada mapping untuk TCODE berjalan', 'Tidak ada pesan; range Sloc kosong '
         'sehingga seluruh Sloc tampil. Gunakan TCODE yang memiliki mapping.'],
        ['3', 'Program dijalankan via SE38 / TCODE tanpa mapping', 'Kolom Terminal & F4 Terminal kosong. Tambahkan '
         'mapping ZMAP_TYPE untuk TCODE tersebut.'],
        ['4', 'Pallet tidak memiliki dokumen ZPALLETR P/E/C', 'Bukan error — ditampilkan status NEW / NEW (RETURN).'],
        ['5', 'Gagal menampilkan ALV (PROGRAM_ERROR / OTHERS)', 'SY-SUBRC tidak dicek oleh program. Bila terjadi dump, '
         'cek ST22.'],
    ]),

    # ---------------- 9. TEST
    ('h1', '9. COMPONENT TEST REQUIREMENT'),
    ('table', [620, 4400, 4340], [
        ['No.', 'Test Condition', 'Expected Result'],
        ['1', 'ZMM061, RTP Pallet, tanpa filter', 'Tampil seluruh pallet ZRTP (MATKL 900001–900003) dengan stok '
         'unrestricted > 0, urut Pallet ID.'],
        ['2', "Filter Terminal = 'Gudang FG KR'", "Hanya pallet di Sloc 2802 yang tampil; kolom Terminal = "
         "'Gudang FG KR'."],
        ['3', 'Filter Terminal dan Sloc diisi bersamaan', 'Filter Sloc diabaikan; hasil mengikuti Sloc dari Terminal.'],
        ['4', 'Pallet dengan dokumen ZPALLETR terakhir status E', 'Status = CUSTOMER.'],
        ['5', 'Pallet dengan dokumen terakhir status P', 'Status = PACKING.'],
        ['6', 'Pallet dengan dokumen terakhir status C di Sloc 2810', 'Status = FREE (RETURN).'],
        ['7', 'Pallet tanpa dokumen ZPALLETR di Sloc 1802', 'Status = NEW.'],
        ['8', 'Pilih RTP Core / RTP Sideboard', 'ZMMR_RETURN_CORE_STOCK / ZMMR_RETURN_BOARD_STOCK terbuka dengan '
         'parameter yang diteruskan.'],
        ['9', 'Filter tanpa hasil', "Pesan 'Data tidak ada...!'."],
        ['10', 'Jalankan ZMM061_TS (tanpa mapping Terminal)', 'Kolom Terminal kosong.'],
    ]),
    ('break',),

    # ---------------- 10. BATASAN
    ('h1', '10. BATASAN & HAL YANG MASIH TERBUKA'),
    ('table', W2, [
        ['Hal', 'Kondisi saat ini / Usulan'],
        ['Filter Terminal tanpa mapping', 'Bila Terminal diisi tetapi mapping untuk TCODE berjalan tidak ada, range Sloc '
         'kosong sehingga seluruh Sloc tampil tanpa peringatan. Usulan: tampilkan pesan atau hentikan proses.'],
        ['Kombinasi Terminal + Sloc', 'P_LGORT1 diabaikan saat Terminal diisi. Usulan: gunakan irisan keduanya atau beri '
         'keterangan di layar seleksi.'],
        ['Mapping per TCODE', 'Empat TCODE varian (ZMM061_TS, ZMM061_WKA, ZAMM061K, ZEMM061) belum memiliki mapping '
         'Terminal di PRD. Usulan: tambah mapping, atau baca mapping berdasarkan program, bukan SY-TCODE.'],
        ['Sloc return hardcode', "1810/2810/3810 di-hardcode. Usulan: pindahkan ke ZMAP_TYPE (mis. OPT = "
         "'RETURN_SLOC')."],
        ['Jalur tanpa histori', 'Bila tidak ada dokumen ZPALLETR untuk seluruh hasil seleksi, Pallet GR Date tidak terisi '
         'dan label NEW (RETURN) tidak diterapkan (tidak konsisten dengan jalur normal).'],
        ['Field ERDAT1 / DONUM / LICHA', 'ERDAT1 diisi setelah CLEAR (selalu kosong); DONUM dan LICHA (No. SKEP) diisi '
         'tetapi tidak ditampilkan. Tidak berdampak ke output.'],
        ['Deskripsi material (MAKT)', 'Join MAKT tanpa filter bahasa (SPRAS) — potensi baris ganda bila deskripsi '
         'material tersedia dalam lebih dari satu bahasa. Usulan: tambah C~SPRAS = SY-LANGU.'],
        ['Performa', 'SELECT ZPALLETR di dalam LOOP per pallet dan 2× SELECT SINGLE MCH1 per baris (SELECT pertama tanpa '
         'MATNR). Untuk volume besar disarankan FOR ALL ENTRIES + READ TABLE BINARY SEARCH.'],
        ['Pemeriksaan otorisasi', 'Belum ada authority-check Plant; hanya S_TCODE.'],
        ['Isi variant', 'Isi nilai variant TCODE varian belum terverifikasi (tidak terbaca via RFC). Verifikasi di SE38 '
         '> Goto > Variants.'],
    ]),

    # ---------------- 11. APPENDIX
    ('h1', '11. APPENDIX — CONFIRMATION POINTS'),
    ('para', 'Ringkasan poin yang perlu dikonfirmasi ke user/key user untuk memvalidasi perilaku as-is program. Kolom '
     'Keputusan diisi setelah konfirmasi.'),
    ('h2', 'A. Arsitektur Program'),
    ('table', [700, 2500, 4360, 1800], [
        ['#', 'Topik', 'Pertanyaan', 'Keputusan'],
        ['A1', 'Filter Terminal tanpa mapping', 'Bila mapping tidak ditemukan, boleh tampil semua Sloc atau harus '
         'dihentikan?', 'Perlu konfirmasi'],
        ['A2', 'Terminal + Sloc', 'Bila keduanya diisi, Sloc diabaikan. Apakah sesuai kebutuhan?', 'Perlu konfirmasi'],
        ['A3', 'TCODE varian', 'Apakah ZMM061_TS / ZMM061_WKA / ZAMM061K / ZEMM061 membutuhkan kolom Terminal?',
         'Perlu konfirmasi'],
    ]),
    ('empty',),
    ('h2', 'B. Definisi Status'),
    ('table', [700, 2500, 4360, 1800], [
        ['#', 'Topik', 'Pertanyaan', 'Keputusan'],
        ['B1', 'Sloc return', 'Apakah daftar Sloc return tetap 1810/2810/3810 (WR/KR/BKS)?', 'Perlu konfirmasi'],
        ['B2', 'Status CUSTOMER', 'Pallet berstatus E tetapi stoknya ada di gudang (indikasi belum GRN ZMM060). Perlu '
         'penanda khusus?', 'Perlu konfirmasi'],
        ['B3', 'Pallet GR Date', 'Saat ini memakai MCH1-ERSDA (tanggal batch dibuat). Sudah sesuai definisi user?',
         'Perlu konfirmasi'],
    ]),
    ('empty',),
    ('h2', 'C. Dokumen'),
    ('table', [700, 2500, 4360, 1800], [
        ['#', 'Topik', 'Pertanyaan', 'Keputusan'],
        ['C1', 'Kolom No. SKEP', 'Kolom No. SKEP (MCH1-LICHA) dinonaktifkan sejak 25.02.2026. Tetap tidak ditampilkan?',
         'Perlu konfirmasi'],
    ]),
    ('empty',),
    ('end', '— Selesai —'),
]
