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
