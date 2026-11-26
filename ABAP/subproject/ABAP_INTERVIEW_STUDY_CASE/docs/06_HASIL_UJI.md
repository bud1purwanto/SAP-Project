# 06 — Hasil Uji Program Latihan (sandbox-new & S/4HANA)

> Tanggal uji: 25 Nov 2026. Penguji: Claude (RFC dari server Linux).
> Izin Baginda: buat program `ZTRAIN_*` di sandbox-new dan S/4 ADB (`$TMP`); buat 1 SO sungguhan di sandbox-new.
> Source yang diuji: [../src/](../src/). Script uji: [../scripts/](../scripts/) (`syncheck.py`, `push_sandbox.mjs`, `run_abap.mjs`, `s4_push_check.py`, `gw.py`).

## 1. Ringkasan

| Sistem | Program dibuat | Syntax check | Jalan (runtime) | Uji GUI |
|---|---|---|---|---|
| **sandbox-new** TRS 130 (ECC 6, 7.31) | 6 program `$TMP` + screen 0100 & status S100 untuk ALV C | **8/8 OK** (1 perbaikan di ALV D) | ALV A/B/D lewat background job OK; BAPI test run & create OK | **ALV B, C, D lulus**; ALV A tidak bisa (batasan SAP GUI Java) — §5 |
| **S/4HANA** ADB 130 (1909, 754) | 8 program `$TMP` + 1 program probe | Lewat GUI: **5 OK, 3 error** (field ZDATE/ZLINE tidak ada di S/4) — §4 | ALV B & D lulus | Hotspot → ME23N dump karena DDIC S/4 rusak — §5 |

## 2. sandbox-new — syntax check

Metode: program sementara via `RFC_ABAP_INSTALL_AND_RUN` + `SYNTAX-CHECK FOR itab` (tidak menyimpan objek). Pengecek divalidasi dengan kode yang sengaja salah (`a = b.` → "Field "B" is unknown").

| Program | Hasil |
|---|---|
| ZTRAIN_ALV_A (REUSE grid) | OK |
| ZTRAIN_ALV_B (hierseq list) | OK |
| ZTRAIN_ALV_C (CL_GUI_ALV_GRID) | OK |
| ZTRAIN_ALV_D (CL_SALV_TABLE) | Error pertama: `SET HANDLER ... FOR go_salv->get_event( )` → "." expected. Diperbaiki (simpan ke variabel `go_evt`), lalu OK |
| ZTRAIN_BAPI_SO | OK |
| ZTRAIN_PO_PRINT | OK |
| ZTRAIN_UEXIT_MOCK (kode V1/V2/V3 user exit) | OK |
| ZTRAIN_BADI_MOCK (method BAdI latihan) | OK |

## 3. sandbox-new — runtime

### 3.1 Push program
`Z_RFC_PROGRAM_UPDATE` ke `$TMP`, lalu dibaca ulang dan dibandingkan: 6/6 `EV_SUCCESS = X`, isi sama persis (ALV A 129, B 90, C 117, D 81, BAPI 135, PO_PRINT 60 baris). Nama dicek dulu tidak bentrok.

ALV C: screen `0100` dibuat via `RPY_DYNPRO_INSERT` (custom control `CC_ALV`, OK code `OK_CODE`), PF-STATUS `S100` via `RS_CUA_INTERNAL_WRITE` (fungsi BACK F3, CANCEL F12, EXIT F15).

### 3.2 ALV lewat background job (PO 6001000678–6001000682)

| Program | Job | Spool | Isi |
|---|---|---|---|
| ZTRAIN_ALV_A | status F | 8730 | Statistik 5 record, judul "Daftar PO - Latihan ALV A", 5 baris PO, baris total `*` |
| ZTRAIN_ALV_B | status F | 8731 | 5 header + 5 item, item tampil di bawah header PO-nya |
| ZTRAIN_ALV_D | status F | 8732 | 5 baris, kolom judul dari DDIC (Purch.Doc., Doc. Date, ...), baris agregasi `*` |

Catatan: background job membuktikan program jalan tanpa dump dan datanya benar. Hotspot ke ME23N, edit qty (ALV C), dan simpan layout hanya bisa diuji di GUI.

### 3.3 BAPI (`ZTRAIN_BAPI_SO`)

| # | Skenario | Hasil RETURN | SO di DB |
|---|---|---|---|
| 1 | TESTRUN, RPP-MZ, ZDOR/1000/01/00, cust 1141000100, 1000 KG | V4 233 (header ok), V4 233 (item ok), W V1 555 (incomplete) | 0 |
| 2 | TESTRUN, material NOTEXIST-XX | E V1 382, E V4 248, E V4 219 → rollback | 0 |
| 3 | Create (P_TEST kosong), PO `ZTRAIN-EXT`, ZDATE=hari ini, ZLINE=2 | S V1 311 "Domestic Sales Order 5683 has been saved" | **SO 5683** |
| 4 | Cek VBAP 5683 | — | ZDATE `00000000`, ZLINE kosong |
| 5 | `BAPI_SALESORDER_CHANGE` 5683 dengan EXTENSIONIN | S V1 311 | ZDATE/ZLINE tetap kosong |
| 6 | TESTRUN, SRAABI (grup 300001), ZLINE `QQ` (tidak valid) | lolos (W V1 555) | 0 |

Analisa no. 4–6: lihat [02_BAPI_vs_BDC.md §5](02_BAPI_vs_BDC.md) dan [04_USER_EXIT.md §2](04_USER_EXIT.md). Ringkasnya, EXTENSIONIN sampai ke VBAP, lalu implicit enhancement `ZSDE_MV45AFZZ_03` di `USEREXIT_SAVE_DOCUMENT_PREPARE` mengosongkan ZDATE/ZLINE untuk material yang tidak terpetakan (grup bukan 3*). Test run tidak memanggil save prepare, jadi no. 6 lolos.

**Belum dibuktikan:** ZDATE/ZLINE tersimpan untuk material grup 3*. Ini butuh 1 SO sungguhan lagi dengan material SR (mis. SRAABI, customer 1141000004, plant 2000).

**Objek data yang tertinggal di sandbox:** SO **5683** (PO number `ZTRAIN-EXT`). Tidak dihapus.

### 3.4 Temuan saat uji yang mengoreksi dokumen
1. **User exit VA01/VA02 di DEV tidak kosong.** Ada 8 implicit enhancement (`ENHINCINX` program `SAPMV45A`; lokasi FORM dari `CL_ENH_TOOL_HOOK_IMPL`). Dokumen 04 sudah ditulis ulang.
2. 5 dari 8 enhancement berbeda isi antara DEV dan sandbox-new.
3. BAdI `ZBADI_ADD_TAB_SO` hanya ada di DEV, tidak di sandbox-new.

## 4. S/4HANA ADB

| Langkah | Hasil |
|---|---|
| Cek nama `ZTRAIN*` | Belum ada → aman |
| Push 8 program ke `$TMP` (gateway `write_program` = `Z_RFC_PROGRAM_UPDATE`) | 8/8 `EV_SUCCESS = X`, source terbaca ulang |
| Syntax check | **Tidak bisa via RFC**: `RFC_ABAP_INSTALL_AND_RUN` tidak ada di ADB; gateway menolak `SIW_RFC_SYNTAX_CHECK`, `RS_ABAP_ERROR_SYNTAX_CHECK`, `SCI_REMOTE_SYNTAX_CHECK`, `JOB_OPEN` ("cannot be classified; access denied") |
| Probe `ZTRAIN_PROBE` (sengaja berisi error) | Diterima dengan `EV_SUCCESS = X` → `Z_RFC_PROGRAM_UPDATE` di S/4 **tidak** melakukan syntax check. Program probe ini masih ada di `$TMP` S/4 |
| Data | EKKO ada (PO 4500000001–…, vendor 100000) → ALV bisa diuji. VBAK kosong, sales org template 0001/0003 → BAPI SO belum bisa diuji |
| Kompatibilitas | VBAP S/4 tidak punya ZDATE/ZLINE → `ZTRAIN_BAPI_SO` dan `ZTRAIN_UEXIT_MOCK` **pasti** error sintaks di S/4 (perlu versi tanpa field custom). Program ALV/PO_PRINT/BADI_MOCK diperkirakan OK karena hanya memakai objek standar, tetapi belum terverifikasi |

Untuk menyelesaikan uji S/4: login SAP GUI di server (koneksi "S4 HANA" sudah ada di SAP GUI Java :99), lalu SE38 → cek sintaks + jalankan, atau buka lewat ADT (http://192.168.1.199:8080).

### 4.1 Uji lewat SAP GUI (login TRSTABAP, 25 Nov 2026)

Tombol *Check* di SE38 tidak bisa dipakai, karena editor source (`CL_GUI_SOURCEEDIT`) tidak didukung SAP GUI Java dan langsung dump `CNTL_ERROR`. Penggantinya: program dijalankan lewat SA38. Kalau ada error sintaks, muncul dump `SYNTAX_ERROR` beserta pesannya. Metode ini divalidasi dengan `ZTRAIN_PROBE` → "Field "B" is unknown".

| Program | Hasil di S/4 |
|---|---|
| ZTRAIN_ALV_A, B, C, D, ZTRAIN_PO_PRINT | Selection screen tampil → sintaks OK |
| ZTRAIN_BAPI_SO | `SYNTAX_ERROR` baris 14: "No component exists with the name ZDATE" |
| ZTRAIN_UEXIT_MOCK | `SYNTAX_ERROR` baris 35: "No component exists with the name ZLINE" |
| ZTRAIN_BADI_MOCK | `SYNTAX_ERROR` baris 25: "IS_VBAP does not have a component called ZLINE" |

Ketiga error sesuai perkiraan: append ZDATE/ZLINE hanya ada di ECC. Bahan diskusi interview soal migrasi S/4: field custom di tabel standar harus di-*append* ulang (atau diganti custom field / extensibility) sebelum kode bisa dipakai.

## 5. Uji GUI (SAP GUI Java di server, display :99)

Screenshot: [../outputs/gui_test_20261125/](../outputs/gui_test_20261125/) (`sb_*` = sandbox-new, `s4_*` = S/4).

| Program | Sistem | Uji | Hasil | Screenshot |
|---|---|---|---|---|
| ZTRAIN_ALV_A | sandbox | Tampil grid | **Klien SAP GUI Java macet.** Thread dump: event thread menunggu JxBrowser (komponen HTML). REUSE grid dengan `I_CALLBACK_TOP_OF_PAGE` merender header sebagai HTML, dan komponen itu tidak bisa jalan di Xvfb. GUI di-restart. Program tetap terbukti jalan lewat background job (§3.2); di SAP GUI Windows tidak ada masalah ini | `sb_05*` |
| ZTRAIN_ALV_D | sandbox | Grid + hotspot | Tampil. **Temuan 1:** PO 6001000678–682 ternyata RFQ (BSART ZQ07), dan ME23N menolak "Not possible to process an RFQ using this function" → tambah filter `BSTYP = 'F'` di semua program ALV. Setelah diperbaiki, hotspot 4503000351 membuka ME23N PO yang benar | `sb_07`–`sb_10` |
| ZTRAIN_ALV_D | sandbox | Total | **Temuan 2:** total 2,879,120.00 mencampur USD + IDR, dan nilai IDR tampil 100× lebih kecil (2,807,820.00 seharusnya 280,782,000). Diperbaiki dengan `set_currency_column( 'WAERS' )` → total 280,782,000 IDR dan 71,300.00 USD | `sb_09`, `sb_11` |
| ZTRAIN_ALV_C | sandbox | Grid OO + edit | Tampil di screen 0100. Ubah Qty = 0 → Error Log "Qty harus > 0" (event `DATA_CHANGED`). Qty = 50 diterima (hanya tabel internal). Back (F3) kembali ke selection screen | `sb_13`–`sb_16` |
| ZTRAIN_ALV_B | sandbox | List header-item | 5 header PO, expand menampilkan item | `sb_17`, `sb_18` |
| ZTRAIN_ALV_D | S/4 | Grid | 10 PO (4500000001–010), total 146.350,00 EUR. Catatan: S/4 punya *type-ahead* di field select-option yang menutupi tombol Execute; tutup dengan Esc dulu | `s4_09` |
| ZTRAIN_ALV_D | S/4 | Hotspot | ME23N terpanggil tetapi **dump `DDIC_TYPE_INCONSISTENCY`** di program standar `SAPLIPW1` (struktur `INCL_EEW_AUFK_PS`). Ini masalah DDIC di sistem S/4 lab (perlu aktivasi ulang oleh Basis), bukan masalah program latihan | `s4_07` |
| ZTRAIN_ALV_B | S/4 | List | 10 header, expand OK | `s4_10` |

Catatan tambahan:
- Selection text belum dibuat, jadi layar menampilkan `S_EBELN`, `S_BEDAT`. Untuk latihan cukup; di program nyata isi lewat *Goto → Text elements → Selection texts*.
- ALV C belum memakai kolom mata uang untuk Net Value (IDR tampil 2,807,820.00). Dibiarkan sebagai latihan: tambahkan `WAERS` ke tabel + `CFIELDNAME`.
- ALV C hanya diuji di sandbox, karena screen 0100 dan status S100 belum dibuat di S/4.
- Sesi login: sandbox memakai "continue without ending other logons" (TRSTDEV juga dipakai 2 orang lain). Kedua sistem sudah logout (`/nex`).

## 6. Sisa pekerjaan uji

- [ ] ALV A interaktif (hotspot, layout) — perlu SAP GUI Windows.
- [ ] ALV C di S/4 — perlu screen 0100 + status S100 dibuat di S/4.
- [ ] (Opsional, perlu izin) 1 SO dengan material SR untuk membuktikan ZDATE/ZLINE tersimpan.
- [ ] Bersih-bersih (hanya atas perintah Baginda): `ZTRAIN_PROBE` di S/4.

## 7. IDoc (25–26 Nov 2026)

Detail lengkap: [07_IDOC.md §3](07_IDOC.md). Ringkasnya:
- Outbound **IDoc 199012** → status 03, file `/tmp/ZTRN_PO_00199012`.
- Inbound **199016** → 53; **199019** → 51, lalu diedit (69) dan diproses ulang → 53.
- Bug FM ditemukan dan diperbaiki: IDoc error tidak lagi meninggalkan data di `ZTRN_PO_LOG`. Backup include sebelum perbaikan: `outputs/LZTRN_IDOCU01_before_fix_20261126.abap`.
- Transport request latihan: TRDK921884, TRDK921886 (jangan di-release).
