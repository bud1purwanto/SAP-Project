# Status Bukti GR 3x ZPP001 — 2026-10-17

## Hipotesis yang GUGUR (dites Baginda)
1. YES ditekan ulang setelah gagal normal → window tertutup (popup log + RW).
2. Multi-session → validasi lock "PO sedang diproses".
3. Status buffer basi (list lama, cancel, proses ulang) → di session A diblok "Order sudah di-TECO".

## Fakta PRD yang terbukti
- Ketiga run dari ZPPI_SR_PROCESS (ABLAD 8040/TH/R, SGTXT UNREST), input identik.
- BALHDR PPORDER (BAPI_PROCORD_RELEASE, awal PROCESS_ALL, TCODE ZPP001): 03:45:05, 03:45:27, 03:47:07 → tombol Ya ditekan 3x.
- Setelah 03:45:15 Execute pasti diblok DLV (original 865/885/905/925/945 DLV tanpa TECO).
- Maka window Ya untuk run #2/#3 harus sudah ada sebelum 03:45:15.
- Undo JR run #1 tidak pernah berhasil (JR 360 m, tanpa change doc). Tidak ada AFRU/GI baru, tidak ada dump.

## Sumber bukti yang sudah habis
- STAD 15-10 03:35–03:50: sudah terhapus (retensi).
- SM20 (RSAU_READ_FILE): 0 record.
- SNAP: tidak ada dump. VBHDR: kosong. Tidak ada tabel log Z. CDPOS (cluster) tidak terbaca via RFC.

## Sisa kemungkinan (belum terbukti)
- (a) Run #1 terhenti abnormal sehingga window Ya tetap terbuka.
- (b) Execute di session lain pada 03:45:05–03:45:15.
- Satu-satunya sumber tersisa: keterangan user OPPKR_19.

## Update — pemetaan flow ke log (2026-10-17)
- Source ZPPI_SR_PROCESS (main/TOP/F01) Dev AIX = PRD (diff kosong).
- Jejak per langkah PROCESS_ALL: BAPI_PROCORD_RELEASE → BALHDR PPORDER; CHANGE_BATCH_ORIGINAL_ORDER → CDHDR CLASSIFY (hanya jika nilai berubah); GR → MKPF MB31; SOTOUN → MKPF MB1B (+CDHDR CHARGE); CHANGE_BATCH_INPUTAN → CDHDR CLASSIFY JR; CONFIRMATION → AFRU; GI → MKPF MB1A; SLOC_TO_SLOC → MB1B; layar core 3000 → ZCORER + CLASSIFY kedua.
- Pembanding normal OPPKR_19 03:37 (800000043922): classify 03:37:43–48 → MB31 03:37:52 → MB1B/CHARGE 03:37:53 → JR 03:37:55 → MB1A+AFRU 03:37:55 → MB1B 03:37:56 → classify kedua 03:38:03–07 (layar core).
- Dev test Baginda (100000073337): pola gagal sama dengan PRD run #1 (release → classify → GR → JR → tanpa AFRU, tanpa undo JR). Jadi "undo JR tidak jalan" BUKAN bukti abort — inferensi dicabut.
- SM21 (RSLG_READ_FILE) dan SM20 (RSAU_READ_FILE): 0 record via RFC. ZCORER: tidak ada entri OPPKR_19 (jalur sukses tidak pernah dilalui).
- Kontradiksi tersisa: Ya ditekan 03:45:27 & 03:47:07 (BALHDR), padahal Execute diblok DLV dan window tertutup pada jalur gagal normal (Dev). Kondisi PRD yang BELUM pernah direproduksi: original order pertama (845) TECO+DLV sementara combine order REL (akibat cancel melewati 845).
