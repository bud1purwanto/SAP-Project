# Evaluasi Tool "Ekstrak Program ABAP" untuk Poin 1 dan 2

| Atribut | Isi |
|---|---|
| Tanggal | 2026-11-24 |
| Tool | [`tools/ekstrak-program-abap/`](../tools/ekstrak-program-abap/PETUNJUK.txt), buatan rekan tim (versi zip 23 Nov 2026) |
| Acuan | Email manager: (1) ABAP Inventory, (2) Dependency Analysis |
| Uji | Mode lokal di Linux (`ringkas-abap.mjs`) terhadap `COA/src/ZQMI_COA_F01.abap`, hasil di [`outputs/uji_tool_20261124/`](../outputs/uji_tool_20261124/ZQMI_COA_F01_mode_lokal.txt). Mode SAP (RFC) belum diuji karena butuh Windows + NW RFC SDK |

## 1. Cara kerja tool

| Mode | Input | Yang dilakukan |
|---|---|---|
| SAP | T-code atau nama program | Petakan T-code ke program (TSTC/TSTCP), lalu baca source lewat `ZRFC_READ_REPORT`. Ikuti INCLUDE, `SUBMIT Z*`, `CALL FUNCTION Z*`, `CALL TRANSACTION Z*` secara rekursif (deep scan) |
| Lokal | File `.abap` utama + INCLUDE di folder yang sama | Parse statis, ikuti INCLUDE saja |

Keluaran berupa folder `artifacts/ekstraksi-abap/<program>-<waktu>/` yang berisi `source/`, `.txt`, dan `.xlsx` 13 sheet: Program, INCLUDE, Tabel dan View, Function Module, BAPI, BDC, Transaksi, Layar Seleksi, Teks Seleksi, Layar dan GUI, Tipe DDIC, Field DDIC, Class dan Interface.

Keamanan: tool hanya membaca (`RFC_READ_TABLE`, `ZRFC_READ_REPORT`) dan tidak menulis ke SAP. Kredensial ada di `.env` lokal yang sudah dimasukkan ke `.gitignore`.

## 2. Penilaian terhadap permintaan manager

### Poin 1: ABAP Inventory (jawab sebagian)

| Yang diminta | Status | Catatan |
|---|---|---|
| Program | Sebagian | Hanya program yang ditelusuri dari 1 titik awal. Bukan daftar lengkap semua objek Z/Y di sistem |
| INCLUDE | Ya | Diikuti rekursif |
| Function Module | Sebagian | FM Z yang dipanggil statis ikut dibaca. FM lain di function group yang sama tidak |
| Class | Tidak | Class hanya terdeteksi lewat regex nama (`ZCL_`, `CL_`). Source class tidak ditelusuri dan pemanggilan method tidak dipetakan |
| BAdI | Tidak | Implementasi BAdI (SE19) tidak terdeteksi |
| User Exit | Tidak | CMOD/SMOD tidak terdeteksi |
| Enhancement | Tidak | Enhancement implisit/eksplisit (ENHO) tidak terdeteksi |
| Smart Form / SAPscript, DDIC Z (tabel, data element) | Tidak / sebagian | Tabel Z hanya muncul kalau dirujuk di SELECT/JOIN |

### Poin 2: Dependency Analysis (jawab sebagian, arah ke bawah saja)

| Aspek | Status | Catatan |
|---|---|---|
| Program ke INCLUDE / FM / SUBMIT / transaksi | Ya | Statis, ada nomor baris |
| Program ke tabel (baca dan tulis) | Ya | Uji `ZQMI_COA_F01`: 35 tabel terdeteksi, cocok dengan pemindaian manual (sisa selisih hanya internal table) |
| BAPI, BDC, layar seleksi | Ya | Nilai tambah, berguna untuk uji regresi nanti |
| Arah balik (objek ini dipakai oleh siapa) | Tidak | Butuh Where-Used / `WBCROSSGT`, `CROSS`, `D010INC` |
| Pemanggilan method / OO | Tidak | Uji: 43 baris `->`/`=>` di `ZQMI_COA_F01` tidak masuk relasi |
| Panggilan dinamis (`CALL FUNCTION lv_fm`, `SUBMIT (lv)`, `PERFORM ... IN PROGRAM`) | Tidak | Sudah diakui di PETUNJUK.txt |
| OLE / Native SQL / ADBC | Terdeteksi di analyzer tapi tidak masuk Excel | `nativeSqlBlocks` dan `adbcUsages` dihitung tapi tidak diekspor. OLE (`CREATE OBJECT 'EXCEL.APPLICATION'`) tidak ditandai, padahal penting untuk S/4 dan Fiori |

## 3. Kesesuaian dengan aturan manager

- Manager meminta **"standard SAP tools and established procedures"**. Tool ini custom: parser regex Node.js ditambah FM custom `ZRFC_READ_REPORT`. Jadi posisinya **pelengkap**, bukan pengganti tool standar.
- `ZRFC_READ_REPORT` ada di DEV AIX (function group `ZFRFC`). Belum dicek apakah juga ada di PRD.
- Tool **tidak memakai Generative AI**, jadi sesuai dengan arahan hemat token.
- Mode lokal **cocok untuk file dari Alfa** (baseline sesuai scope). Syaratnya, INCLUDE harus ada di folder yang sama. INCLUDE yang hilang dilaporkan sebagai `INCLUDE belum tersedia`, dan itu langsung jadi bahan deliverable "missing objects".

## 4. Kekurangan teknis kecil

1. `ekstrak-program.ps1` dan `ringkas-abap.mjs` masih menunjuk path workspace pembuat (`SAP-Agent-Discovery-Platform`, `discovery-ai-tools`). Tidak fatal karena hanya dipakai sebagai default atau fallback.
2. Opsi `-Migration` di `ekspor-excel.ps1` (kolom catatan S/4, katalog aturan per rilis) belum dipanggil dari peluncur.
3. Profil `.env` terkunci ke DEV AIX (`SAP_DEV_AIX_*`). Untuk membaca PRD perlu profil lain.
4. `stripCommentTail` memotong baris pada `"` pertama, termasuk yang ada di dalam literal `'...'`. Ini jarang terjadi, tapi bisa menghilangkan relasi.
5. Hanya jalan di Windows (PowerShell + `.bat`). Mode lokal bisa dijalankan di Linux langsung lewat `node tools/ringkas-abap.mjs <file.abap> <folder_out>`.

## 5. Rekomendasi pemakaian

| Kebutuhan | Pakai |
|---|---|
| Daftar lengkap objek custom (poin 1) | **TADIR** (SE16, `OBJ_NAME` Z*/Y*, per `DEVCLASS`) + SMOD/CMOD (`MODACT`) + SE19 + SE20 (`ENHHEADER`) + SE95. Hasilnya dicocokkan dengan file Alfa |
| Relasi dua arah (poin 2) | SAPRSEUB (bangun index), lalu Where-Used / `WBCROSSGT`, `CROSS`, `D010INC` |
| Detail per program pilot (5–10 program) | **Tool ini**, untuk tabel, FM, BAPI, BDC, layar seleksi per baris source dan untuk mendeteksi INCLUDE yang hilang dari file Alfa |

Kesimpulan: tool ini menjawab poin 1 dan 2 **untuk level per program** (drill-down pilot) dengan baik. Tool ini **belum** menjawab inventory menyeluruh, relasi balik, BAdI/exit/enhancement, dan class. Bagian itu tetap harus dikerjakan dengan tool standar SAP sesuai arahan manager.
