# Analisa ZPP001 (ZPPI_SR_PROCESS) — GR Duplikat Batch SR (Email "Error transfer data output SR")

Tanggal analisa: 2026-10-16. Sumber: email Rysca Chandra (16-10-2026 10:29) + reply Wafi; data PRD (PRT, read-only) via RFC_READ_TABLE; source PRD `ZPPI_SR_PROCESS`, `_TOP`, `_F01` (backup di `outputs/*_PRD_20261016.abap`).

## Fakta Data (PRD)

- Material `SRAAOI`, plant 2000, SLoc 2322. Original order `P20000383845`, combine order `100007232823` (HEADER_TXT/BKTXT).
- Original order AFPO: PSMNG 4, **WEMNG 12** (3x lipat).

| Waktu 15-10-2026 | User | Dokumen | Keterangan |
|---|---|---|---|
| 02:35:13 | OPPKR_07 | 5006877433 (101) | GR awal 4 batch @101,190 |
| 02:35:16 | OPPKR_07 | AFRU 36354766/1 | Confirmation combine order |
| 03:41:41 | OPPKR_19 | 5006877492 (102) | Cancel GR (via ZPP001 cancel) |
| 03:41:51 | OPPKR_19 | AFRU 36354766/2 | Cancel confirmation; GI 261 di-reverse 262 (4932902950/952) |
| 03:45:05–17 | OPPKR_19 | change batch original + **5006877495 (101)** + 4932902963 (411) + change batch JR 0034064873 | Run #1 — berhenti sebelum/di confirmation |
| 03:45:36 | OPPKR_19 | **5006877496 (101)** + 4932902964 (411) | Run #2 |
| 03:47:16 | OPPKR_19 | **5006877499 (101)** + 4932902969 (411) | Run #3 |

- Setelah 03:41 tidak ada AFRU baru untuk combine order `100007232823`, tidak ada GI 261 baru. Tidak ada short dump (SNAP) user OPPKR_19.
- Per 16-10 analisa, 3 dokumen 101 dan 3 dokumen 411 **belum di-reverse** (tidak ada SMBLN).
- Kasus pembanding `100007234254` (CVTKR_11): process → cancel → process ulang dengan confirmation lengkap = normal.

## Root Cause (Kode)

1. **Proses multi-LUW tanpa kompensasi.** Urutan `PROCESS_ALL` → `CHANGE_BATCH_ORIGINAL_ORDER` → `GR` → `SOTOUN` (411) → `CHANGE_BATCH_INPUTAN` → `CONFIRMATION` → `GI`. Setiap step `BAPI_TRANSACTION_COMMIT` sendiri. Jika step setelah GR gagal, program hanya tulis log "Failed" (+ undo karakteristik batch di beberapa cabang). **GR 101 dan 411 tidak pernah di-reverse otomatis** (form `CANCEL_GR`/`CANCEL_SOTOUN` hanya dipakai di proses cancel).
2. **Guard re-process lemah.** `CEK_COM_ORDER_STATUS` hanya cek status combine order (REL/PCNF/CNF/DLV/TECO/...). Karena confirmation gagal, combine order tetap `REL` → `SY-UCOMM = 'COMMIT'` lolos → user bisa execute ulang. Tidak ada cek GR existing di original order (AFPO-WEMNG / MSEG 101 aktif per batch+order).
3. **Log tidak persisten.** Error hanya tampil di ALV popup (`ALV3`), tidak disimpan (tidak ada SLG1/Z-log), sehingga pesan error confirmation/change batch inputan run #1–#3 tidak bisa ditelusuri dari sistem.

Kesimpulan: user melihat log gagal → klik proses lagi → setiap run posting GR+411 baru. Duplikasi batch di MB51 menyebabkan interface output SR ke OLAP error.

## Yang Belum Pasti

- Pesan error persis run #1–#3 (confirmation `BAPI_PROCORDCONF_CREATE_TT` vs `BAPI_OBJCL_CHANGE` batch JR). Perlu konfirmasi screenshot/ingatan user OPPKR_19 (Pak Agus Hariyanto) atau replay di QA.

## Rekomendasi

- Data: reverse 5006877495/496/499 (102) dan 4932902963/964/969 (reversal 411) via proses cancel standar/MBST oleh user PP, lalu proses ulang 1x dan pastikan confirmation + GI terbentuk. Cek ulang karakteristik JR 0034064873 (ZZLENGTH/ZZCONVERSION) karena run #1 sempat mengubahnya.
- Program (enhancement di sandbox-new):
  - Guard sebelum GR: tolak jika sudah ada MSEG 101 aktif (tanpa reversal) untuk AUFNR+CHARG yang sama, atau AFPO-WEMNG >= PSMNG.
  - Kompensasi: jika step setelah GR gagal → `CANCEL_SOTOUN`/`CANCEL_SOTOSO` + `CANCEL_GR` otomatis (BAPI_GOODSMVT_CANCEL), lalu undo karakteristik.
  - Simpan log proses ke application log (SLG1) / Z-table per combine order.

## Update Kronologi Perilaku User (analisa lanjutan 2026-10-16)

Koreksi cakupan: combine order `100007232823` mencakup **11 batch** (0034057174–0034057184) dari 6 original order (P20000383845/865/885/905/925/945). Setiap dokumen GR (5006877433/495/496/499) berisi 11 item, jadi duplikasi = 11 batch x 3.

Pola normal ZPP001 (user OPPKR_19, order lain, mis. 800000043922 pada 03:37:52–03:37:56): MB31 (GR 101) -> MB1B (411) -> MB1A (GI 261 + confirmation) -> MB1B, selesai dalam ~4 detik.

| Waktu | User | Aksi | Bukti |
|---|---|---|---|
| 02:35:13–19 | OPPKR_07 | Proses slitting lengkap: GR 11 batch (semua stok SO/E), confirmation, GI JR, transfer | 5006877433, AFRU 36354766/1, 4932902698/699/702/703 |
| 03:37:52 | OPPKR_19 | Proses normal order lain (800000043922), sukses penuh | MB31+MB1B+MB1A+MB1B |
| 03:41:41–51 | OPPKR_19 | Cancel proses combine order via ZPP001: 102 + cancel confirmation + reversal GI/transfer + undo karakteristik 11 batch | 5006877492, AFRU /2, MB11 4932902949–952 |
| 03:45:05–17 | OPPKR_19 | Run #1 ulang dengan input baru: 5 batch (174,175,178,183,184) berat naik ±0,5% dan ditandai Unrestricted (411). GR + 411 sukses, karakteristik JR berubah, **confirmation/GI tidak terbentuk** | 5006877495, 4932902963, CDHDR CLASSIFY/CHARGE |
| 03:45:36–38 | OPPKR_19 | Run #2 (~19 detik setelah run #1). GR + 411 lagi, berhenti sebelum GI | 5006877496, 4932902964 |
| 03:47:16–17 | OPPKR_19 | Run #3 (~1,5 menit kemudian). GR + 411 lagi, berhenti sebelum GI | 5006877499, 4932902969 |
| 04:16:35 | OPPKR_19 | Lanjut order lain (800000043923), normal | MB31+MB1B+MB1A+MB1B |
| 05:32–06:36 | OPPKR_09 | VLMOVE 311 batch stok SO (176,177,179–182) | 4932903306…627 |
| 11:27–11:28 | LOG_09 | VLMOVE 311 lanjutan batch yang sama | 4932905391…412 |

Interpretasi: cancel dilakukan untuk koreksi input (berat/panjang 5 batch dan alokasi SO -> Unrestricted). Run #1–#3 gagal di step confirmation/GI (log hanya popup), user mengulang karena melihat status Failed. Pesan error persis belum diketahui.

## Revisi Kronologi & Titik Gagal (verifikasi lanjutan 2026-10-16)

Koreksi atas bagian sebelumnya: urutan dokumen tetap valid. Yang direvisi adalah interpretasi "user mengulang proses lengkap".

### Fakta tambahan
- Terminal (USR41): OPPKR_07 = 192.168.7.57 (KR-BOPP6), OPPKR_19 = 192.168.7.236 (KR-BOPP7). Bukan 1 PC. Cancel + 3 run = OPPKR_19 sendiri.
- JR 0034064873: ZZLENGTH sekarang 360 m; panjang slitting MAX_LENGTH 8.040 m; ZZCONVERSIONMTRKG 0,15652. 8.400 m x 0,15652 = 1.314,77 kg = stok fisik JR (F018 1.145,75 + 2P03 169,05). Jadi sebelum run #1 JR = 8.400 m; run #1 memotong ke 360 m; tidak pernah di-undo.
- JCDS original order P20000383845: DLV (I0012) aktif 02:35:15, nonaktif 03:41:44 (cancel), **aktif lagi 03:45:15 (run #1)**.
- CDHDR: run #1 mengubah karakteristik 11 batch SR + JR. Run #2/#3 tidak menghasilkan change document sama sekali.
- Tidak ada AFRU baru, tidak ada GI 261 baru, tidak ada SNAP, tidak ada VBHDR.

### Dua jalur tombol di ZPP001
- **COMMIT** (`USER_COMMAND` TOP 1260): CEK_COM_ORDER_STATUS → RETRIEVE_DATA_BOXER (cek original order DLV/PDLV, lock EZGR 'PO'+combine order, baca ulang JR) → CHECKING_DATA_BOXER → CHECK_LENGTH_BOXER → POPUP_CONFIRMATION (cek MAX_LENGTH >= ZZLENGTH JR) → window konfirmasi (PF-STATUS STCONF, tombol YES).
- **YES** (TOP 1310): hanya CEK_COM_ORDER_STATUS (REL + ucomm YES lolos) → PROCESS_ALL memakai data di memori (IT_MAIN, IT_INBATCH). Tidak ada cek DLV, cek panjang, maupun lock.

### Kesimpulan run #2/#3
Setelah 03:45:15 original order DLV dan JR 360 m < 8.040 m, sehingga COMMIT pasti diblok ("Order sudah di good receipt" / "Panjang Maksimal >= panjang batch 1"). GR tetap terposting → run #2/#3 berasal dari **tombol YES ditekan lagi** dengan data memori run #1 (JR 8.400 m → hitung 360 m = nilai DB → BAPI_OBJCL_CHANGE tanpa perubahan → tanpa change document). Konsisten 100% dengan CDHDR.

### Titik gagal
- Ketiga run berhasil: change batch original → GR 101 → 411 → change batch JR, lalu **gagal di step CONFIRMATION** (`BAPI_PROCORDCONF_CREATE_TT`, AFRU tidak terbentuk). Pesan error persis tidak tersimpan.
- Setelah confirmation gagal: `UNDO_CHANGE_BATCH_INPUTAN` dipanggil, tetapi undo JR juga tidak berhasil (JR tetap 360 m, tanpa change document) → `CANCEL_CONFIRMATION` tidak dipanggil → GR/411 tidak di-cancel.
- Andai undo berhasil pun, `CANCEL_CONFIRMATION` akan berhenti karena tidak ada AFRU aktif (G1) → GR/411 tetap tidak di-cancel.

### Dampak turunan
- Karakteristik JR (360 m / 56,35 kg) tidak sesuai stok (1.314,8 kg). 16-10 09:46–09:51 OPPKR_02 melakukan 3x transfer 311 masing-masing 56,35 kg ke 2P03 (MB1B 4932911992/2161/2173), kemungkinan mengikuti nilai karakteristik yang salah — perlu konfirmasi user.

### Perlu replay (QA/sandbox) untuk kepastian
1. Pesan error BAPI_PROCORDCONF_CREATE_TT setelah cancel → proses ulang.
2. Penyebab undo karakteristik JR gagal.
3. Apakah window konfirmasi (YES) tetap aktif setelah popup log ditutup (bukan via BACKL), padahal ada `SET USER-COMMAND 'RW'`.
Alternatif: Basis cek STAD user OPPKR_19 15-10 03:44–03:48 untuk urutan dialog step.

## Update 2026-10-17 — Hasil Test Baginda & Mekanisme GR 3x

- Test Baginda (confirmation gagal + JR gagal → GR tidak ter-cancel) mengkonfirmasi G1/G2.
- Saat transaksi ulang via **1. Execute (COMMIT)** muncul "Order sudah di good receipt" (RETRIEVE_DATA_BOXER cek DLV) → jalur COMMIT memang memblok. Konsisten dengan kesimpulan: GR #2/#3 tidak lewat Execute.
- Mekanisme dugaan kuat: setelah PROCESS_ALL gagal, popup log (ALV3) ditutup selain via BACKL → kembali ke **window konfirmasi STCONF yang masih terbuka** (tombol YES masih aktif). `SET USER-COMMAND 'RW'` di WHEN 'YES' tidak efektif menutup window (RW tidak ditangani di CASE AT USER-COMMAND). Klik YES lagi → PROCESS_ALL dengan data memori, tanpa cek DLV/panjang JR/lock EZGR (lock sudah dilepas di akhir PROCESS_ALL).
- Jalur sukses tidak terdampak karena masuk CALL SCREEN 3000.
- Uji replay (sandbox/QA): skenario gagal confirmation → tutup popup log dengan ✓/X → cek window konfirmasi masih ada → klik YES → harus muncul GR kedua.

## Update 2026-10-17 (2) — Test Baginda: YES ulang tidak bisa; hipotesis multi-session

- Baginda: setelah gagal, YES tidak bisa ditekan ulang (hipotesis window YES tetap terbuka TIDAK terbukti).
- Dev test 100000073337: GR 5000077582/584 + 102 583/585, tanpa AFRU, original P29000003278 tidak pernah TECO → Execute ulang pasti diblok DLV. Kondisi beda dengan PRD (run awal 02:35 sukses penuh + TECO).
- `GET_ORDER_STATUS` cek TECO dulu lalu EXIT → order TECO+DLV dianggap 'TECO' (lolos cek DLV).
- PRD cancel 03:41:41 me-revoke TECO combine order + 5 original (865/885/905/925/945), **tidak** untuk 845 (item 0001). Jadi pada 03:45:15+ original 865 dst = DLV → Execute ulang tetap diblok di PRD.
- 03:56:49–52 OPPKR_07 men-TECO ulang combine order + 5 original (setelah run #3).
- Hipotesis utama baru: lebih dari satu session ZPP001. Lock EZGR (`ENQUEUE_EZGR`, default _SCOPE 2) diduga lepas pada COMMIT WORK pertama run #1 (03:45:05). Session lain yang menekan Execute pada 03:45:05–03:45:14 lolos semua cek (order belum DLV, JR masih 8.400 m), lalu YES di session tsb → GR #2/#3. Konsisten dengan CDHDR (tanpa change doc run #2/#3).
- Rencana bukti live (tanpa ubah ZPP001, tanpa GUI): temp program via RFC_ABAP_INSTALL_AND_RUN di Development AIX — ENQUEUE_EZGR argumen dummy 'POZZLOCKTEST' → ENQUEUE_READ → COMMIT WORK AND WAIT → ENQUEUE_READ → DEQUEUE. Menunggu izin Baginda.

## Update 2026-10-17 (3) — Hasil test YES ulang Baginda & skenario simulasi

- Pesan "Order sudah di good receipt" (tanpa tanda hubung) berasal dari RETRIEVE_DATA_BOXER (jalur Execute). Jalur YES memakai "Order sudah di-good receipt". Jadi pada test Baginda window YES sudah tertutup (jalur gagal normal: popup log ALV3 → SET USER-COMMAND 'RW').
- Program tidak punya MESSAGE tipe E/A sendiri; tidak ada CMOD CONFPP aktif; BAdI WORKORDER_CONFIRM hanya implementasi standar.
- Dua kandidat tersisa: (A) event YES run #1 terhenti abnormal (pesan E dari FM/BAPI di step confirmation) sehingga window tetap terbuka — juga menjelaskan kenapa undo JR & cancel GR tidak jalan; (B) multi-session (lock EZGR lepas saat COMMIT pertama).
- Input run #1–#3 identik (qty & marking 411 sama) → lebih condong ke (A) satu session, data memori sama.
- Skenario simulasi Dev harus meniru urutan PRD: proses sukses penuh → cancel via ZPP001 → proses ulang dengan input diubah (marking Free Stock/411 + panjang) → amati jenis kegagalan (popup log vs status bar) dan apakah window YES tetap tampil.

## Update 2026-10-17 (4) — Eliminasi jalur & kesimpulan multi-session

Dieliminasi (dengan bukti):
- Execute ulang setelah 03:45:15: diblok DLV (865/885/905/925/945 DLV tanpa TECO; ZBOXER berisi 6 order, LICHA batch valid).
- YES ulang di window yang sama: window ditutup `SET USER-COMMAND 'RW'` (test Baginda). STCONF hanya punya NO/RW/YES/BACK (F1/F7/F8/F9), tidak ada COMMIT → window tidak bisa bertumpuk.
- TCODE lain: OPPKR_19 punya ZPP001/ZPP001N/ZPP001L/ZTYB02; ZPP001N (ZPPI_SR_PROCESS_BC) memiliki cek identik.
- Jalur Execute tidak memiliki COMMIT/ROLLBACK/DEQUEUE → lock EZGR bertahan sampai COMMIT pertama run #1 (CHANGE_BATCH_ORIGINAL_ORDER, 03:45:05).
- STAD 15-10 03:35–03:50 sudah tidak tersedia (retensi).

Satu-satunya jalur yang konsisten dengan kode + data: **lebih dari satu session ZPP001** untuk combine order yang sama. Session B/C menekan Execute pada 03:45:05–03:45:14 (lock sudah lepas, order belum DLV, JR masih 8.400 m) → window YES → Ya. Kontensi lock antar-session juga menjelaskan confirmation gagal di ketiga run (order sedang dikunci session lain; BAPI gagal tanpa ROLLBACK menahan lock) dan undo JR gagal.

## Update 2026-10-17 (5) — Hipotesis multi-session GUGUR; bukti BALHDR & status buffer

- Test Baginda 2 session: validasi lock jalan → multi-session gugur.
- Sidik jari dokumen: GR 495/496/499 ABLAD `8040/TH/R`, 411 SGTXT `UNREST` → ketiga run dari ZPPI_SR_PROCESS (PROCESS_ALL), input identik.
- **BALHDR (PPORDER/HEADER, ext 100007232823, ALTCODE ZPP001, ALPROG SAPLCOAPPLLOG)** dari BAPI_PROCORD_RELEASE (langkah pertama PROCESS_ALL): 03:45:05 (run #1), 03:45:27 (run #2), 03:47:07 (run #3). Run #2 dimulai 10 detik setelah JR diubah run #1 (03:45:17) → satu session, Ya ditekan ulang.
- Window Ya tetap terbuka karena event YES run #1 **terhenti mendadak di step confirmation** (pesan E dari dalam BAPI standar): undo JR tidak jalan (JR tetap 360 m, tanpa change doc), popup log tidak muncul, `SET USER-COMMAND 'RW'` tidak tereksekusi. Test Baginda melewati jalur gagal normal (popup log + RW) sehingga window tertutup.
- Anomali 845: saat cancel 03:41:41 TECO 5 original dicabut, 845 tidak. Status 845 & 865 identik. Penyebab: READ_ORDER baris 290 membaca status original order pertama (845) saat list dibuat → buffer status session (STATUS_READ). PROCESS_CANCEL memakai GET_STATUS → AIP9_STATUS_READ (buffer) → 845 terbaca tanpa TECO (list dibuat sebelum OPPKR_07 TECO 02:35:19) → revoke dilewati.
- Kesimpulan kronologi: list ZPP001 OPPKR_19 sudah terbuka sejak sebelum 02:35 (tidak di-refresh); OPPKR_07 memproses sukses di PC lain 02:35; OPPKR_19 cancel dari list basi 03:41 (845 tetap TECO); Execute 03:44 lolos; Ya 03:45:05 → GR + 411 + JR → confirmation abort → window Ya tetap → Ya 03:45:27 → Ya 03:47:07; OPPKR_07 TECO ulang 03:56.
- Belum terbukti: teks pesan error confirmation (hipotesis: terkait original 845 TECO / buffer status basi). Bukti dengan replay Dev sesuai urutan di atas.
