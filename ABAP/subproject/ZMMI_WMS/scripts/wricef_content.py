"""Konten WRICEF/FS ZMMI_WMS (HU Stock with Characteristic for WMS) — dari source TRS Ref 002 (03.11.2026)."""
import os

DOCS = os.path.join(os.path.dirname(__file__), '..', 'docs')
HEADER_OLD = 'RICEFW-MM-ZMMI_PO_EMAIL PO Approval Notification Program'
HEADER_NEW = 'RICEFW-MM-ZMMI_WMS HU Stock with Characteristic for WMS'
IMAGES = [(os.path.join(DOCS, 'flow_zmmi_wms.png'), 'rId7'),
          (os.path.join(DOCS, 'flow_wms_unique_zmmi_wms.png'), 'rId8')]

DOC_NAME = HEADER_NEW
W2 = [3120, 6240]          # tabel 2 kolom (Item | Keterangan)
WSTEP = [620, 8740]        # tabel langkah (# | Langkah)

BODY = [
    # ---------------- COVER
    ('cover1', 'FUNCTIONAL DESIGN ENHANCEMENT'),
    ('cover2', 'SAP Report & Interface — HU Stock with Characteristic for WMS'),
    ('cover3', DOC_NAME),
    ('cover4', 'Stok batch per HU Box / HU Pallet beserta karakteristik, ditampilkan di ALV atau dikirim ke WMS gudang FGS'),
    ('cover5', 'Materials Management (MM) — Inventory Management / Handling Unit'),
    ('break',),

    # ---------------- 1. DOCUMENT INFORMATION
    ('h1', '1. DOCUMENT INFORMATION'),
    ('h2', 'General Information'),
    ('table', W2, [
        ['Item', 'Keterangan'],
        ['Project Name', 'WMS Gudang FGS — feed stok berbasis Handling Unit'],
        ['Document Name', DOC_NAME],
        ['Version', '1.00'],
    ]),
    ('empty',),
    ('h2', 'Document History'),
    ('table', [1560, 2600, 3200, 2000], [
        ['Version', 'Author', 'Reason for Change', 'Date Effective'],
        ['1.00', 'Tim ABAP (Budi)', 'Functional Design program baru (Ref 001 + 002)', '05 Nov 2026'],
    ]),
    ('empty',),
    ('h2', 'Object Overview'),
    ('table', W2, [
        ['Attribute', 'Value'],
        ['Business Process', 'Sinkronisasi stok Finished/Semi-Finished Goods per HU ke WMS gudang FGS'],
        ['SAP Module', 'Materials Management (MM) — Inventory Management & Handling Unit Management'],
        ['Object Type', 'Report (ALV) + Interface outbound (Native SQL ke MSSQL)'],
        ['Object Title', 'HU Stock with Characteristic for WMS'],
        ['Object Description', 'Mengambil HU berdasarkan Created On / HU Number dan Material Group Packaging (BOX / PLT), '
         'menurunkan isi batch ke HU Box dan HU Pallet, mengecek stok batch di MCHB / MSKA, melengkapi karakteristik '
         'batch, lalu menampilkan ALV atau mengirim ke staging WMS Y_ZBMBCSR + SP_Merge_ZBMBCSR_WMS.'],
        ['Cycle / Sprint', 'Baru. Ref 001 30.10.2026 (initial), Ref 002 03.11.2026 (unique batch mode WMS). Status: test '
         'di TRS (sandbox-new), belum transport ke PRD.'],
        ['Complexity', 'Medium'],
        ['Priority', 'High'],
        ['SAP Program Name', 'ZMMI_WMS (1 program tanpa include, package $TMP di TRS)'],
        ['Eksekusi', 'SE38 / background job (TCODE belum dibuat)'],
        ['Similar SAP Program', 'ZBMBC (ZBAP_STOCK_BY_CHAR1, Execution Type WMS). Standar: HUMO, MMBE, MSC3N.'],
        ['Enhancement Implementation', 'BAPI / BDC / User Exit / BADI: N/A (read-only di SAP). Output WMS via EXEC SQL '
         '(DBCO, DBMS MSS). Class standar: CL_SALV_TABLE.'],
        ['Programmer Name', 'Budi (generate by AI)'],
        ['Evaluated By', '—'],
    ]),
    ('break',),
    ('h1', 'TABLE OF CONTENT'),
    ('toc',),
    ('break',),

    # ---------------- 2. GENERAL REQUIREMENT
    ('h1', '2. GENERAL REQUIREMENT'),
    ('label', 'User Requirement :'),
    ('para', 'WMS gudang FGS membutuhkan data stok per batch lengkap dengan HU Box, HU Pallet, Storage Bin, Sales Order dan '
     'karakteristik batch (Type, Thick, Width, Length, TipeAlias, CriteriaGrade). Alur lama memakai ZBMBC / ZBMBCSR yang '
     'membaca stok per material (seluruh stok, ~70–80 ribu baris, 2,5–6 menit) lalu dikirim lewat OLAP ke WMS. '
     'Kebutuhan baru: feed harian berbasis HU yang dibuat pada tanggal tertentu (Created On), sehingga data yang dikirim '
     'hanya HU baru dan prosesnya cepat. Satu baris output = satu stock line x isi HU. Kolom dan sumber data mengikuti '
     'ZBMBC (17 kolom WMS). Tambahan 03.11.2026 (permintaan Rasyid, tim WMS): sebelum insert ke SQL, batch harus unik '
     'karena SP WMS melakukan MERGE ON [Batch].'),
    ('field', 'Initiating Program', 'ZMMI_WMS'),
    ('field', 'RICEFW Work Unit #', 'RICEFW-MM-ZMMI_WMS'),
    ('field', 'Enhancement Title', 'HU Stock with Characteristic for WMS'),
    ('field', 'Module & Sub module', 'Materials Management — Inventory Management / Handling Unit Management'),
    ('field', 'When Enhancement required', 'Sebelum go-live WMS gudang FGS (tanggal menunggu konfirmasi)'),

    # ---------------- 3. TECHNICAL INFORMATION
    ('h1', '3. TECHNICAL INFORMATION'),
    ('table', W2, [
        ['Item', 'Keterangan'],
        ['Functional Description', 'Program memilih HU (VEKP), membaca isi HU (VEPO) termasuk HU level bawah (box di '
         'dalam pallet) dan level atas (pallet dari box), memetakan batch ke HU Box / HU Pallet, mengecek stok batch '
         '(MCHB, MSKA) untuk material ZFGS / ZSFG, lalu mengisi kolom pelengkap dengan preload sekali (mass select). '
         'Mode Screen menampilkan ALV; mode WMS memilih 1 baris per batch lalu mengirim ke MSSQL.'],
        ['Summary Level', 'Detail: 1 baris per stock line x HU (Screen); 1 baris per batch (WMS)'],
        ['Output', 'Screen (ALV CL_SALV_TABLE, 22 kolom) atau WMS (tabel staging Y_ZBMBCSR, 17 kolom, lalu SP merge ke '
         'ZBMBCSR_WMS)'],
        ['Frequency', 'Harian (Created On = hari ini) atau on demand'],
        ['Processing Type', 'Online atau background. Read-only di SAP; tulis hanya ke database WMS eksternal (mode WMS).'],
        ['Owner', 'IT'],
        ['Audience', 'Tim WMS (Rasyid) dan gudang FGS'],
        ['Business Driver', 'Data stok HU di WMS akurat dan cepat; pengganti alur ZBMBCSR → OLAP → WMS'],
        ['Priority', 'High'],
        ['Complexity', 'Medium'],
        ['Design Assumptions', 'Struktur HU: pallet berisi box (VEPO VELIN 3 / UNVEL) atau langsung batch (VELIN 1); box '
         'berisi batch (VELIN 1) dan menunjuk pallet di VEKP-UEVEL. Material Group Packaging BOX = HU Box, PLT = HU '
         'Pallet. Batch unik secara bisnis per nomor batch (key MERGE di WMS).'],
        ['BPF ID', 'N/A'],
    ]),
    ('break',),

    # ---------------- 4. PARAMETER
    ('h1', '4. PARAMETER SELEKSI & VARIANT PROGRAM'),
    ('para', 'Program dijalankan via SE38 atau background job. Bagian ini menjelaskan parameter layar seleksi dan aturan '
     'validasinya.'),
    ('h2', '4.1 Fungsi Tiap Parameter'),
    ('table', [1400, 2400, 5560], [
        ['Parameter', 'Memfilter data', 'Fungsi / Penjelasan'],
        ['S_ERDAT (Created On)', 'VEKP-ERDAT', 'Tanggal HU dibuat. Default hari ini (SY-DATUM). Tidak wajib, tetapi '
         'Created On atau HU Number minimal salah satu harus terisi. Dibaca lewat extension index VEKP~Z02.'],
        ['S_EXIDV (HU Number)', 'VEKP-EXIDV', 'Nomor HU eksternal. Bila diisi, seleksi lewat index VEKP~C dan Created On '
         'menjadi filter tambahan (AND). Untuk HU lama, kosongkan Created On.'],
        ['S_MAGRV (Matl Grp Pckmat)', 'VEKP-MAGRV', 'Wajib, tanpa interval. BOX → turun/naik ke pallet; PLT → turun ke '
         'box. Difilter di memori setelah baca VEKP.'],
        ['S_WERKS (Plant)', 'VEPO-WERKS (isi HU)', 'Tanpa interval. Membatasi plant batch isi HU. Tiap nilai dicek '
         'otorisasi Z_WERKS.'],
        ['P_ALV (Screen)', '— (mode output)', 'Default. Tampilkan semua baris di ALV.'],
        ['P_WMS (WMS)', '— (mode output)', 'Kirim ke WMS. Hanya tampil bila user punya otorisasi Z_OLAP (ZOLAP = 1).'],
        ['P_CONN (DBCO Name)', '— (koneksi)', 'Nama koneksi DBCO ke MSSQL WMS. Tampil dan wajib saat mode WMS.'],
    ]),
    ('note', 'Filter tetap di program (bukan parameter): status HU 0060 (Deleted) dibuang; material type MARA-MTART IN '
     "('ZFGS','ZSFG'); stok > 0 di salah satu kolom unrestricted / quality / restricted / blocked."),
    ('empty',),
    ('h2', '4.2 TCODE & Variant'),
    ('para', 'TCODE belum dibuat. Untuk jadwal harian mode WMS disarankan variant dengan Created On dinamis (hari ini) '
     'dan DBCO Name terisi, dijalankan sebagai background job (SM36). Lihat Bagian 10.'),

    # ---------------- 5. EXISTING
    ('h1', '5. EXISTING / RELATED TRANSACTION'),
    ('field', 'Existing Program Name', 'ZBAP_STOCK_BY_CHAR1 (ZBMBC — Stock Overview with Characteristic, Execution Type '
     'Screen / OLAP / WMS); ZBMBCSR'),
    ('field', 'Existing Menu / Transaction', 'ZBMBC; standar HUMO, MMBE, MSC3N'),
    ('field', 'Legacy Enhancement Name / No.', 'N/A'),
    ('note', 'ZMMI_WMS dan ZBMBC (mode WMS) memakai staging Y_ZBMBCSR dan SP_Merge_ZBMBCSR_WMS yang sama.'),
    ('break',),

    # ---------------- 6. DESIGN
    ('h1', '6. DESIGN'),
    ('h2', '6.1 Processing Flow Diagram'),
    ('figintro', 'Gambar 1 — Alur eksekusi program dari layar seleksi hingga output ALV / WMS.'),
    ('image', 0, 3300000),
    ('figcap', 'Gambar 1. Alur eksekusi ZMMI_WMS'),
    ('h2', '6.2 Detailed Description — Alur per Kebutuhan'),
    ('para', 'Satu eksekusi terdiri dari empat kebutuhan berurutan: seleksi HU, stok batch, pelengkap kolom, dan output.'),
    ('sub', 'Kebutuhan A — Seleksi HU (FORM GT_HU)'),
    ('table', WSTEP, [
        ['#', 'Langkah'],
        ['1', 'Validasi: Created On dan HU Number tidak boleh kosong keduanya; mode WMS wajib DBCO Name.'],
        ['2', 'Baca VEKP (VENUM, EXIDV, MAGRV, UEVEL, STATUS): HU Number diisi → hint VEKP~C; selain itu → hint '
         'VEKP~Z02 (MANDT, ERDAT). Buang MAGRV di luar S_MAGRV dan STATUS = 0060.'],
        ['3', 'Baca VEPO isi HU terpilih (VEPO~0). HU level bawah (VELIN = 3, UNVEL) yang belum terpilih dibaca VEKP + '
         'VEPO-nya. HU level atas (VEKP-UEVEL) yang belum terpilih dibaca VEKP-nya.'],
        ['4', 'Nomor HU dikonversi ke format tampilan (CONVERSION_EXIT_ALPHA_OUTPUT), sama seperti ZBMBC.'],
        ['5', 'Isi batch (VELIN = 1, Material & Batch terisi): HU MAGRV BOX → HU Box, HU Pallet dari UEVEL bila MAGRV '
         'pallet = PLT; HU MAGRV PLT → HU Pallet (HU Box kosong). Filter Plant, hapus duplikat.'],
        ['6', 'Mode WMS: simpan Sloc isi HU (VEPO-LGORT) per Material + Plant + Batch untuk aturan unique batch.'],
    ]),
    ('empty',),
    ('sub', 'Kebutuhan B — Stok Batch (FORM GT_STOCK, GT_OUTPUT)'),
    ('table', WSTEP, [
        ['#', 'Langkah'],
        ['1', "Saring material lewat MARA: MTART IN ('ZFGS','ZSFG')."],
        ['2', 'MCHB (hint MCHB~Z05) per Material + Plant + Batch dengan CLABS / CINSM / CEINM / CSPEM > 0.'],
        ['3', 'MSKA (hint MSKA~Z02) per Material + Batch + Plant dengan KALAB / KAINS / KAEIN / KASPE > 0.'],
        ['4', 'Satu stock line (Sloc, SO) dikalikan dengan setiap HU yang berisi batch tersebut. Sloc dan SO mengikuti '
         'stok saat ini, bukan HU.'],
        ['5', "Output kosong → pesan 'No data found'."],
    ]),
    ('empty',),
    ('sub', 'Kebutuhan C — Kolom Pelengkap (FORM GT_PRELOAD, GT_FILL)'),
    ('table', WSTEP, [
        ['#', 'Langkah'],
        ['1', 'Semua data pelengkap dibaca sekali (FOR ALL ENTRIES), lalu dibaca per baris dengan READ TABLE BINARY '
         'SEARCH.'],
        ['2', 'Storage Bin: quant LQUA pertama per Material + Plant + Batch (hint LQUA~Z01).'],
        ['3', 'Baris dengan SO: Sales Doc Type dari VBAK-AUART; Customer Name dari VBPA (PARVW AG, baris pertama) → '
         'ADRC-NAME1.'],
        ['4', 'Baris tanpa SO: Customer Name dari MSKU (stok konsinyasi batch) → KNA1-NAME1.'],
        ['5', "Karakteristik batch: MCH1-CUOBJ_BM → AUSP (KLART '023'). ZZTYPE, ZZALIAS = ATWRT; ZZTHICKNESS, ZZWIDTH, "
         "ZZLENGTH = ATFLV; ZZCRITERIA = deskripsi CAWNT-ATWTB (bahasa E)."],
    ]),
    ('empty',),
    ('sub', 'Kebutuhan D — Output'),
    ('para', 'Mode Screen: ALV CL_SALV_TABLE dengan semua fungsi standar dan lebar kolom optimal. Mode WMS: unique batch '
     'lalu kirim ke MSSQL (Gambar 2 dan 6.2.1).'),
    ('h2', '6.2.1 Detail Logic Unique Batch & Kirim WMS'),
    ('para', 'SP WMS melakukan MERGE ON [Batch]; bila satu batch muncul di lebih dari satu baris, MERGE gagal. Karena itu '
     'mode WMS memilih tepat 1 baris per nomor batch dengan aturan berikut (FORM GT_UNIQUE_BATCH).'),
    ('table', [1000, 2500, 3060, 2800], [
        ['Urutan', 'Aturan', 'Sumber', 'Keterangan'],
        ['1', 'Sloc stok = Sloc isi HU', 'MCHB/MSKA-LGORT vs VEPO-LGORT', 'Baris yang cocok (PRIO 1) didahulukan'],
        ['2', 'Tanggal stok terbaru', 'MCHB-LAEDA (kosong → ERSDA); MSKA-ERSDA', 'Dipakai bila aturan 1 masih seri'],
        ['3', 'Baris pertama', 'Urutan output', 'Tie-break terakhir (lihat Bagian 10)'],
    ]),
    ('table', WSTEP, [
        ['#', 'Langkah kirim WMS (FORM INSERT_SQL_WMS)'],
        ['1', "Cek DBCON: koneksi ada dan DBMS = 'MSS'; selain itu pesan 'DBCO Connection not found..!!'."],
        ['2', 'CONNECT / SET CONNECTION ke DBCO Name.'],
        ['3', 'DELETE FROM Y_ZBMBCSR, INSERT setiap baris (semua kolom NVARCHAR; angka dikirim sebagai teks), COMMIT.'],
        ['4', 'EXECUTE dbo.SP_Merge_ZBMBCSR_WMS: MERGE ke [WHS_130].[dbo].[ZBMBCSR_WMS] ON [Batch] (update bila ada, '
         'insert bila belum), DownloadTime = GETDATE(), COMMIT.'],
        ['5', "Error native SQL → ROLLBACK dan pesan 'Error in procedure insert WMS'. Akhir: DISCONNECT."],
    ]),
    ('break',),
    ('figintro', 'Gambar 2 — Alur unique batch dan pengiriman ke WMS.'),
    ('image', 1, 3600000),
    ('figcap', 'Gambar 2. Unique batch & kirim WMS'),
    ('empty',),
    ('h2', '6.3 Input / Output Layout'),
    ('para', 'Input — parameter layar seleksi dijelaskan pada Bagian 4.'),
    ('sub', 'Output — Kolom ALV dan Kolom WMS'),
    ('table', [1700, 2100, 2860, 2700], [
        ['Kolom ALV', 'Kolom WMS (Y_ZBMBCSR)', 'Sumber', 'Keterangan'],
        ['Plant', 'Plant', 'MCHB / MSKA-WERKS', ''],
        ['Material No', 'Material No', 'MCHB / MSKA-MATNR', ''],
        ['Type', 'Type', 'AUSP ZZTYPE (ATWRT)', ''],
        ['Thick', 'Thick', 'AUSP ZZTHICKNESS (ATFLV)', '1 desimal'],
        ['Batch', 'Batch', 'MCHB / MSKA-CHARG', 'Key MERGE WMS'],
        ['Width', 'Width', 'AUSP ZZWIDTH (ATFLV)', 'Tanpa desimal'],
        ['Length', 'Length', 'AUSP ZZLENGTH (ATFLV)', 'Tanpa desimal'],
        ['TipeAlias', 'TipeAlias', 'AUSP ZZALIAS (ATWRT)', ''],
        ['CriteriaGrade', 'CriteriaGrade', 'CAWNT-ATWTB (ZZCRITERIA)', 'Kosong bila nilai tanpa teks'],
        ['Sloc', 'Sloc', 'MCHB / MSKA-LGORT', 'Sloc stok saat ini'],
        ['Storage Bin', 'Storage Bin', 'LQUA-LGPLA', 'Quant pertama'],
        ['SO No', 'SO No', 'MSKA-VBELN', 'Hanya stok SO'],
        ['SO Item', 'SO Item', 'MSKA-POSNR', ''],
        ['Sales Doc Type', 'Sales Doc Type', 'VBAK-AUART', ''],
        ['HU Box', 'HU Box', 'VEKP-EXIDV (MAGRV BOX)', ''],
        ['HU Pallet', 'HU Pallet', 'VEKP-EXIDV (MAGRV PLT)', ''],
        ['Customer Name', 'Customer Name', 'ADRC-NAME1 / KNA1-NAME1', 'Sold-to SO atau konsinyasi'],
        ['Special Stock', '—', 'MSKA-SOBKZ', 'Hanya ALV'],
        ['Unrestricted', '—', 'CLABS / KALAB', 'Hanya ALV'],
        ['Quality Insp.', '—', 'CINSM / KAINS', 'Hanya ALV'],
        ['Restricted', '—', 'CEINM / KAEIN', 'Hanya ALV'],
        ['Blocked', '—', 'CSPEM / KASPE', 'Hanya ALV'],
    ]),
    ('empty',),
    ('h2', '6.4 Processing Details — Akses Database & Index'),
    ('para', 'Semua data dibaca sekali di awal (mass select) tanpa SELECT di dalam LOOP. Hint index Oracle dipasang '
     'untuk setiap tabel.'),
    ('table', [1600, 2400, 5360], [
        ['Tabel', 'Index', 'Pemakaian'],
        ['VEKP', 'Z02 (MANDT, ERDAT)', 'Seleksi Created On. Extension index baru (R3TR XINX, request TRDK924903).'],
        ['VEKP', 'C (MANDT, EXIDV) / 0', 'Seleksi HU Number / HU level bawah & atas'],
        ['VEPO', '0 (MANDT, VENUM, VEPOS)', 'Isi HU'],
        ['MARA', '0', 'Material type ZFGS / ZSFG'],
        ['MCHB', 'Z05 (MANDT, MATNR, WERKS, CHARG, LGORT)', 'Stok batch'],
        ['MSKA', 'Z02 (MANDT, MATNR, CHARG, WERKS, LGORT)', 'Stok sales order'],
        ['VBAK / VBPA / ADRC', '0', 'Sales Doc Type & Customer Name'],
        ['MSKU / KNA1', '0', 'Customer konsinyasi'],
        ['LQUA', 'Z01 (MANDT, MATNR, WERKS, CHARG)', 'Storage Bin'],
        ['CABN / CAWN / CAWNT', '1 / join', 'Nomor internal karakteristik & teks CriteriaGrade'],
        ['MCH1 / AUSP', '0 / N3', 'Objek klasifikasi batch & nilai karakteristik'],
    ]),
    ('note', 'TRS belum memiliki index VEKP~Z02 (hint diabaikan, hasil tetap benar). Di PRD, VEKP ±5,8 juta baris; '
     'tanpa Z02 seleksi 1 hari = full scan ±7 detik.'),
    ('h2', '6.5 Summary / Footer / Breaking / Totals / Sorting / Dependencies / Constraints'),
    ('para', 'Summary / Footer / Breaking: N/A · Totals: dari fungsi ALV (perhatikan qty berulang per HU) · Sorting: '
     'Material, Plant, Sloc, Batch. Dependencies: DBCO ke MSSQL WMS, tabel Y_ZBMBCSR, SP_Merge_ZBMBCSR_WMS, index '
     'VEKP~Z02. Constraints: read-only di SAP; staging dipakai bersama ZBMBC. Upload Program: N/A.'),

    # ---------------- 7. AUTHORIZATION
    ('h1', '7. AUTHORIZATION CHECK'),
    ('table', [2200, 2400, 4760], [
        ['Objek', 'Titik cek', 'Perilaku'],
        ['Z_WERKS (ZWERKS)', 'START-OF-SELECTION', 'Setiap nilai S_WERKS-LOW dicek; gagal → pesan E. S_WERKS kosong '
         'tidak dicek (semua plant).'],
        ['Z_OLAP (ZOLAP = 1)', 'AT SELECTION-SCREEN OUTPUT', 'Tanpa otorisasi → radio WMS disembunyikan. Tidak dicek '
         'ulang saat eksekusi.'],
        ['S_TCODE / S_PROGRAM', 'Standar', 'TCODE belum ada; akses via SE38 / job.'],
    ]),
    ('note', 'Temuan review 05.11.2026: cek Z_OLAP perlu diulang saat eksekusi mode WMS, dan Plant kosong perlu '
     'dibatasi otorisasi (Bagian 10).'),

    # ---------------- 8. ERROR HANDLING
    ('h1', '8. ERROR HANDLING'),
    ('table', [620, 4000, 4740], [
        ['No.', 'Possible Error', 'Notification / Procedure'],
        ['1', 'Created On dan HU Number kosong', "Pesan 'Isi Created On atau HU Number...!' (S, tampil E); berhenti."],
        ['2', 'Mode WMS tanpa DBCO Name', "Pesan 'Masukan DBCO Connection name...!'; berhenti."],
        ['3', 'Plant tanpa otorisasi', "Pesan 'No Authorization' (E)."],
        ['4', 'Tidak ada HU / stok sesuai filter', "Pesan 'No data found'."],
        ['5', 'DBCO tidak ada atau bukan MSSQL', "Pesan 'DBCO Connection not found..!!' (I)."],
        ['6', 'Gagal CONNECT', "Pesan 'Not Connected..!!' (I)."],
        ['7', 'Error INSERT / SP di MSSQL', "ROLLBACK; pesan 'Error in procedure insert WMS' (I). Detail SQL tidak "
         'ditampilkan.'],
        ['8', 'Gagal membuat ALV', 'Teks exception CX_SALV_MSG ditampilkan sebagai pesan.'],
    ]),

    # ---------------- 9. TEST
    ('h1', '9. COMPONENT TEST REQUIREMENT'),
    ('table', [620, 3700, 3040, 2000], [
        ['No.', 'Test Condition', 'Expected Result', 'Hasil'],
        ['1', 'TRS, Created On 01–31.12.2028, MAGRV PLT/BOX, Screen', 'Baris identik ZBMBC untuk batch sama',
         'PASS — 13/13 baris'],
        ['2', 'HU Number saja (2 HU)', 'Isi kedua HU tampil', 'PASS — 4 baris'],
        ['3', 'HU Number + Created On cocok / tidak cocok', 'Cocok tampil; tidak cocok 0 baris', 'PASS — 3 / 0 baris'],
        ['4', 'Created On & HU Number kosong', 'Pesan validasi', 'PASS'],
        ['5', 'DEV, Created On 03.11.2024–03.11.2026, BOX/PLT, Screen vs ZBMBC (17 kolom)', 'Identik',
         'PASS — 1.181/1.181'],
        ['6', 'TRS, Created On 2000–2099, BOX/PLT/TRS, Screen vs ZBMBC', 'Identik kecuali beda yang dikenal',
         'WARN — 50.780/50.885; 105 beda'],
        ['7', 'TRS, mode WMS (program copy tanpa insert SQL)', '1 baris per batch; pilihan sesuai aturan unique',
         'PASS — 50.821 baris; 51/51 batch double benar'],
        ['8', 'Mode WMS insert nyata ke MSSQL + SP', 'Staging terisi, ZBMBCSR_WMS ter-merge, pesan sukses',
         'NOT RUN'],
        ['9', 'Background job harian (variant Created On dinamis)', 'Job selesai, data WMS ter-update', 'NOT RUN'],
    ]),
    ('note', 'Beda TRS (no. 6–7): HU kosong di ZBMBC tetapi terisi di ZMMI (93 / 42 baris), HU berbeda untuk batch di '
     'lebih dari satu HU (11 / 2 baris), Storage Bin berbeda karena quant interim (1 baris). Detail: '
     'outputs/COMPARE_SUMMARY_20261103.md.'),
    ('break',),

    # ---------------- 10. BATASAN
    ('h1', '10. BATASAN & HAL YANG MASIH TERBUKA'),
    ('table', W2, [
        ['Hal', 'Kondisi saat ini / Usulan'],
        ['Otorisasi mode WMS', 'Z_OLAP hanya menyembunyikan radio WMS. Via variant / SUBMIT / job, mode WMS tetap bisa '
         'jalan. Usulan: cek ulang Z_OLAP di START-OF-SELECTION.'],
        ['Otorisasi Plant', 'S_WERKS kosong = semua plant tanpa cek. Usulan: saring hasil per plant dengan Z_WERKS.'],
        ['Staging bersama ZBMBC', 'Y_ZBMBCSR dikosongkan lalu diisi tanpa lock; run paralel ZBMBC / ZMMI_WMS saling '
         'menimpa. Usulan: ENQUEUE_E_TABLE (Y_ZBMBCSR) di kedua program, atau jadwal job terpisah.'],
        ['HU vs Sloc stok', 'Batch dipasangkan ke semua HU berisi batch itu tanpa melihat Sloc. ZBMBC mensyaratkan '
         'VEPO-LGORT = Sloc stok. Perlu keputusan bisnis.'],
        ['Tie-break unique batch', 'Aturan ke-3 bergantung urutan baris (SORT tidak STABLE; nomor HU diurut sebagai '
         'teks). Usulan: urut eksplisit per nomor HU internal.'],
        ['Storage Bin', 'Quant LQUA pertama, bisa quant interim (922) / negatif. Usulan: filter qty > 0 & storage type '
         'non-interim.'],
        ['Customer Name stok bebas', 'Diambil dari MSKU (konsinyasi) bila batch ada di MSKU. Perlu konfirmasi.'],
        ['Qty berulang di ALV', 'Batch di lebih dari satu HU → qty stok tampil di setiap baris HU; total ALV dobel.'],
        ['Default Created On', 'Default hari ini; pencarian HU lama lewat HU Number harus mengosongkan Created On.'],
        ['Performa insert', 'INSERT native SQL per baris. Ukur di PRD; opsi bulk insert bila lambat.'],
        ['Transport', 'Index VEKP~Z02 (TRDK924903) diimport sebelum / bersama program; create index PRD di jam sepi + '
         'statistik (DB20). Program saat ini di $TMP (TRS) — perlu package & request.'],
        ['Test WMS', 'Insert nyata ke MSSQL dan job harian belum dites.'],
    ]),

    # ---------------- 11. APPENDIX
    ('h1', '11. APPENDIX — CONFIRMATION POINTS'),
    ('para', 'Poin yang perlu dikonfirmasi ke user / tim WMS. Kolom Keputusan diisi setelah konfirmasi.'),
    ('h2', 'A. Arsitektur Program'),
    ('table', [700, 2500, 4360, 1800], [
        ['#', 'Topik', 'Pertanyaan', 'Keputusan'],
        ['A1', 'Eksekusi harian', 'Jalan sebagai background job harian? Jam berapa, dan perlu TCODE?', 'Perlu konfirmasi'],
        ['A2', 'Staging bersama', 'ZBMBC mode WMS masih dipakai setelah ZMMI_WMS live? Bila ya, pakai lock atau jadwal '
         'terpisah?', 'Perlu konfirmasi'],
    ]),
    ('empty',),
    ('h2', 'B. Aturan Data'),
    ('table', [700, 2500, 4360, 1800], [
        ['#', 'Topik', 'Pertanyaan', 'Keputusan'],
        ['B1', 'HU vs Sloc', 'HU hanya dikirim bila Sloc isi HU = Sloc stok (seperti ZBMBC)?', 'Perlu konfirmasi'],
        ['B2', 'Tie-break HU', 'Bila masih seri, pilih HU nomor terkecil atau HU terbaru?', 'Perlu konfirmasi'],
        ['B3', 'Key unik', 'Nomor batch unik lintas material (MERGE ON Batch cukup), atau perlu Material + Batch?',
         'Perlu konfirmasi'],
        ['B4', 'Storage Bin', 'Quant interim / negatif boleh dikirim ke WMS?', 'Perlu konfirmasi'],
        ['B5', 'Customer Name', 'Stok bebas boleh diisi nama customer konsinyasi (MSKU)?', 'Perlu konfirmasi'],
    ]),
    ('empty',),
    ('h2', 'C. Otorisasi'),
    ('table', [700, 2500, 4360, 1800], [
        ['#', 'Topik', 'Pertanyaan', 'Keputusan'],
        ['C1', 'Mode WMS', 'Cek Z_OLAP diulang saat eksekusi?', 'Perlu konfirmasi'],
        ['C2', 'Plant kosong', 'User tanpa otorisasi semua plant boleh menjalankan tanpa isi Plant?', 'Perlu konfirmasi'],
    ]),
    ('empty',),
    ('end', '— Selesai —'),
]
