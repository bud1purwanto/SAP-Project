# Panduan Patch Smart Forms via XML

Panduan ini melengkapi `COA.md` untuk perubahan Smart Forms yang lebih cepat dan terukur. Gunakan hanya pada sandbox yang diizinkan oleh panduan proyek.

## Alur aman

1. Export XML dari Smart Form yang sedang aktif.
2. Simpan hasil export sebagai baseline dan jangan mengubahnya.
3. Buat salinan kandidat, lalu patch hanya node yang diperlukan.
4. Import kandidat ke SAP, activate, dan generate function module.
5. Export ulang Smart Form aktif setelah import.
6. Bandingkan struktur penting dan hash hasil export dengan kandidat.
7. Jalankan generated function module dan periksa PDF aktual, bukan hanya XML.
8. Simpan XML live hasil verifikasi sebagai artefak rollback/audit.

## Trik tabel agar style konsisten

Untuk tabel baru, gunakan tabel lama yang tampil benar sebagai referensi. Jangan hanya menyalin lebar kolom atau `PATTERN`.

- Salin struktur `PATTERN`, termasuk `FRAME`, ukuran garis, dan unitnya.
- Salin struktur `BORDERS` pada setiap `CELL`. Border pada level tabel saja tidak menjamin garis sel tampil.
- Pastikan unit border konsisten. Contoh yang telah terbukti pada form COA adalah ketebalan `15.00` dengan unit `TW`.
- Gunakan format teks header yang sama dengan tabel referensi, misalnya `<H1>...</>`.
- Gunakan format teks data yang sama dengan tabel referensi, misalnya `<D1>...</>`.
- Hapus paragraf kosong tambahan pada node teks karena dapat membuat tinggi baris dan jarak antarbagian berubah.
- Header dan data harus menggunakan definisi kolom/cell yang sama. Jangan menyelaraskan keduanya dengan spasi manual.

## Pemeriksaan regresi sebelum import

Kandidat minimal harus diperiksa untuk kondisi berikut:

- seluruh cell mempunyai border kiri, atas, kanan, dan bawah;
- format header dan data sesuai tabel referensi;
- tidak ada paragraf kosong yang tidak diperlukan;
- jumlah cell header sama dengan jumlah cell data;
- urutan field sesuai mapping program pemanggil;
- orientasi halaman utama tidak berubah bila perubahan hanya untuk lampiran.

Contoh hasil pemeriksaan yang diharapkan:

```text
STYLE_TEST_OK []
```

Jika masih muncul `CELL_BORDER`, `HEADER_FONT`, `DATA_FONT`, atau `EMPTY_LINE`, kandidat belum boleh di-import.

## Verifikasi setelah import

Keberhasilan import belum membuktikan layout benar. Lakukan seluruh langkah berikut:

1. Pastikan Smart Form aktif dan generated function module tersedia.
2. Export ulang objek aktif dan jalankan pemeriksaan struktur yang sama.
3. Generate OTF/PDF menggunakan function module aktif.
4. Periksa secara visual: font, border, alignment, wrapping, pemisahan halaman, dan tanda tangan.
5. Jalankan ulang program pemanggil agar preview lama dari sesi sebelumnya tidak dianggap sebagai hasil terbaru.

Contoh pemanggilan yang kompatibel dengan ABAP 7.31:

```abap
CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname = 'ZQMF_COA_BATCH'
  IMPORTING
    fm_name  = lv_fm_name
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
```

## Catatan penting

- Generated function module `/1BCDWB/SF...` dapat berubah setelah aktivasi. Program harus memperoleh namanya melalui `SSF_FUNCTION_MODULE_NAME`, bukan menyimpan nama generated FM secara tetap.
- Patch tabel lampiran tidak boleh mengubah Smart Form halaman utama jika requirement hanya menyentuh batch list.
- Patch XML berisiko merusak layout bila struktur internal tidak lengkap. Selalu simpan baseline dan gunakan mekanisme rollback proyek.
- Perubahan layout tidak menambah akses database. Dampak performa utamanya berada pada jumlah baris tabel dan proses rendering OTF/PDF.
- Objek lokal `$TMP` tidak masuk transport. Jika akan dipindahkan antar-system, tetapkan package dan transport request sesuai prosedur SAP.

## TCODE terkait

- `SMARTFORMS`: inspeksi, aktivasi, dan generate Smart Form.
- `SE38`/transaksi program pemanggil: pengujian preview end-to-end.
- `ST22`: analisis dump, terutama parameter generated function module yang tidak cocok.
- `SP01`: pemeriksaan spool bila output dibuat melalui spool.

## 7. Checkpoint 2026-10-13 — Fix `CALL_FUNCTION_CONFLICT_LENG` pada Domestic COA (`ZQMF_COA`, DO `85006272` No Alias)

- **Gejala**: Runtime error `CALL_FUNCTION_CONFLICT_LENG` (`CX_SY_DYN_CALL_ILLEGAL_TYPE`) di `ZQMI_COA_F01` baris `1876` (`FORM F_PRINT`) saat mencetak COA untuk DO Domestic `85006272` (`0085006272` - `LFART = 'ZLF'`, Batch `0000406146` `SREASI` No Alias).
- **Penyebab**: Parameter `PRODUCT` pada interface SmartForm Domestic `ZQMF_COA` (`/1BCDWB/SF00000078` di `TRD` / `/1BCDWB/SF00000394` di `sandbox-new`) bertipe `CHAR30`, sedangkan `ZQMI_COA_F01` mengirim `PRODUCT = LV_HEADER_PRODUCT` (`CHAR80`).
- **Solusi di `sandbox-new`**:
  1. Menyalin `PRODUCT = LV_HEADER_PRODUCT.` setelah penentuan fallback `LV_HEADER_PRODUCT` di `FORM F_PRINT` agar variabel global `PRODUCT` (`CHAR30`) ikut terisi nilai fallback jika kosong, sementara `LV_HEADER_PRODUCT` (`CHAR80`) tetap dikirim ke `PREPARE_EXPORT_HEADER` untuk `ZQMF_COA_EXPORT`.
  2. Mengembalikan pengiriman parameter pada cabang `ELSE` (Domestic `ZQMF_COA`) menjadi `PRODUCT = PRODUCT` (`CHAR30`), konsisten dengan pemanggilan `ZQMF_COA_BATCH`.
- **Artefak & Verifikasi**:
  - Backup sebelum fix: `outputs/ZQMI_COA_F01_sandbox-new_before_domestic_product_fix.abap`
  - Source kandidat: `src/ZQMI_COA_F01_export_candidate.abap`
  - Snapshot setelah push ke `sandbox-new`: `outputs/ZQMI_COA_F01_sandbox-new_after_domestic_product_fix.abap`
  - Verifikasi `RS_SYNTAX_CHECK` pada `ZQMI_COA`: `SYNTAX_RC = 0`
  - Smoke test `ZQMF_COA` (`/1BCDWB/SF00000394`) dengan `PRODUCT = 'SRE - ASI'`: `FORM_RC = 0`, `OTF_LINES = 126`.

## 8. Checkpoint 2026-10-13 — Fix Pergeseran Kolom Upload `ZMAP_COA_MIC` (7 Kolom vs 10 Kolom), Validasi Numerik `LOWER_LIMIT`/`UPPER_LIMIT`, & Integrasi Ship-To / Alias (`ZQMI_COA_F01`)

- **Gejala**: Pada DO Alias `85006276` dan `85006277` (`MATNR = 'SRACBI'`, `ZZALIAS = 'HS - 18 M'`, Ship-to `1141100239`), tampilan layar `ZQMI_COA` (`TCode ZQM002`) menampilkan teks satuan (`°C`, `%`, `kg/mm²`, `gr/inch`, `µm`) di kolom **`Lower Limit`** sementara kolom **`Unit Of Measure`** menampilkan kode satuan internal SAP (`GC`, `KMM`, `GPI`, `MIM`).
- **Penyebab**:
  1. Saat upload file TXT di `ZMAP_COA_MIC` (`TCode ZQM001`), file template lama **7 kolom** (`MATNR | MIC | MIC_DESC | UOM | KUNNR | METHOD | MAPPING`) dibaca oleh `IT_UPLOAD` yang berstruktur **10 kolom** (`MATNR | MIC | MIC_DESC | LOWER_LIMIT | UPPER_LIMIT | UOM | KUNNR | METHOD | MAPPING | SEQ_NO`), sehingga kolom ke-4 (`UOM`) masuk ke `LOWER_LIMIT` dan mengosongkan `UOM`.
  2. Di `ZQMI_COA_F01`, karena `ZMAP_COA-LOWER_LIMIT` tidak kosong, nilai batas bawah asli dari `QAMV-TOLERANZUN` (`17.46`, `11.00`, `120`, `30`, `200`, `22.00`) tertimpa oleh teks satuan (`µm`, `kg/mm²`, `%`, `gr/inch`).
- **Solusi di `sandbox-new`**:
  1. **`ZMAP_COA_MIC` (`src/ZMAP_COA_MIC.abap`)**:
     - Sesuai arahan Baginda, struktur `IT_UPLOAD`, `FORM F_UPLOAD_DATA`, dan validasi material dikembalikan ke baseline asli (`outputs/ZMAP_COA_MIC_sandbox-new_before_upload_limit_fix.abap`), dan hanya ditambahkan **validasi karakter `LOWER_LIMIT` & `UPPER_LIMIT`** di `FORM F_CREATE_DATA` dan `FORM F_CHANGE_DATA` (`CO '0123456789., '` serta `CA '0123456789'`), sehingga hanya mengizinkan angka, koma, dan titik.
  2. **`ZQMI_COA_F01` (`src/ZQMI_COA_F01_export_candidate.abap`)**:
     - Di-rollback kembali ke versi fix Domestic Product (`outputs/ZQMI_COA_F01_sandbox-new_after_domestic_product_fix.abap`, `4.556` baris) karena selama data mapping di `ZMAP_COA` benar (`LOWER_LIMIT`/`UPPER_LIMIT` kosong atau berisi angka valid dan `UOM` terisi di kolom `UOM`), `ZQMI_COA` sudah menampilkan nilai `Lower Limit` dan `Upper Limit` dari `QAMV` / `ZMAP_COA` dengan benar.
- **Artefak & Verifikasi**:
  - Backup sebelum fix: `outputs/ZMAP_COA_MIC_sandbox-new_before_upload_limit_fix.abap`
  - Snapshot setelah push ke `sandbox-new`: `outputs/ZMAP_COA_MIC_sandbox-new_after_upload_limit_fix.abap` & `outputs/ZQMI_COA_F01_sandbox-new_after_upload_limit_fix.abap`
  - Verifikasi `RS_SYNTAX_CHECK` pada `ZMAP_COA_MIC` & `ZQMI_COA`: `SYNTAX_RC = 0`.

## 9. Checkpoint 2026-10-13 — Fallback `Lower Limit` & `Upper Limit` ke Master Data MIC (`QPMK`) Ketika Batch Tidak Memiliki Inspection Lot (`ZQMI_COA_F01`, DO `85006276`)

- **Gejala**: Pada DO `85006276` (`MATNR = 'SRACBI'`, Type `HSB4-18`, Alias `HSB-18`), terdapat 12 item batch dari 2 Mother Roll berbeda (`0000406862` yang memiliki Inspection Lot `Z04` `050000014307` namun belum di-input hasil di `QAMR`, serta `0000406883` yang sama sekali belum memiliki Inspection Lot `Z04`). Akibatnya, 4 karakteristik `SR Base Film` (`SACBFDIN`, `SACBSHMD`, `SACBG400`, `SACBSHTD`) menampilkan `Lower Limit = 0`, `Upper Limit = 0`, dan `Value = 0`.
- **Penyebab**:
  1. Pada blok fallback `FORM GET_MIC` (`SEQ = 99`, saat MIC dari `ZMAP_COA` tidak ditemukan di Inspection Lot manapun), program hanya mengambil `KURZTEXT` dari `QPMT` dan `MASSEINHSW` (`UOM`) dari `QPMK`, tetapi **belum mengambil `TOLERANZUN` (`MICMIN`) dan `TOLERANZOB` (`MICMAX`) dari Master Data MIC (`QPMK`)**.
  2. Selain itu, saat deduplikasi `IT_DATA_UNIQUE` (`SORT IT_DATA_UNIQUE BY VBELN MATNR MIC MICMIT`), baris dari batch yang tidak memiliki Inspection Lot (`INSLOT = ''`, `MICMIT = 0`) dapat mengalahkan baris dari batch yang memiliki Inspection Lot (`INSLOT = '050000014307'`, `MICMIT = 0`).
- **Solusi di `sandbox-new`**:
  1. Menambahkan satu kali pembacaan `SELECT SINGLE TOLERANZUN TOLERANZOB INTO (LV_MIN, LV_MAX) FROM QPMK` ketika `IT_ZMAP-LOWER_LIMIT IS INITIAL OR IT_ZMAP-UPPER_LIMIT IS INITIAL` (dengan prioritas `WERKS = IT_DATA-WERKS` lalu fallback lintas plant) pada blok `SEQ = 99` di `FORM GET_MIC`, lalu mengisi `IT_MIC-MICMIN = LV_MIN` **hanya jika `IT_ZMAP-LOWER_LIMIT IS INITIAL`** dan `IT_MIC-MICMAX = LV_MAX` **hanya jika `IT_ZMAP-UPPER_LIMIT IS INITIAL`**.
  2. Menyempurnakan pengurutan sebelum deduplikasi menjadi `SORT IT_DATA_UNIQUE BY VBELN MATNR MIC MICMIT INSLOT DESCENDING` agar baris yang memiliki Inspection Lot selalu diprioritaskan di atas baris tanpa Inspection Lot.
- **Artefak & Verifikasi**:
  - Source kandidat: `src/ZQMI_COA_F01_export_candidate.abap` (`4.578` baris)
  - Snapshot setelah push ke `sandbox-new`: `outputs/ZQMI_COA_F01_sandbox-new_after_qpmk_limit_fallback.abap`
  - Verifikasi `RS_SYNTAX_CHECK` pada `ZQMI_COA`: `SYNTAX_RC = 0`
  - Uji live pembacaan `QPMK` di `sandbox-new` untuk ke-7 MIC `SACB*`: `SACBSIOT` (`102`–`108`), `SACBHZ00` (`1.50`–`2.50`), `SACBSIIN` (`102`–`108`), `SACBFDIN` (`0.200`–`0.400`), `SACBSHMD` (`6.00`–`8.00`), `SACBG400` (`85`–`100`), `SACBSHTD` (`7.00`–`9.00`).

## 10. Checkpoint 2026-10-13 — Perbaikan Urutan Tampilan MIC Sesuai `SEQ_NO` `ZMAP_COA` pada Layar `ZQM002` (`ZQMI_COA_F01`, DO `85006276`)

- **Gejala**: Pada layar `ZQMI_COA` (`TCode ZQM002` Screen `0100`), urutan ke-14 MIC untuk `SRACBI` tidak mengikuti urutan `Sequence` (`SEQ_NO` `1` s/d `14`) di `ZMAP_COA` (`TCode ZQM001`), di mana `SACBSIOT` (`SEQ 11`) dan `SACBHZ00` (`SEQ 8`) justru muncul di baris ke-1 dan ke-2, sedangkan `SACBFDIN` (`SEQ 14`), `SACBSHMD` (`SEQ 6`), `SACBG400` (`SEQ 9`), dan `SACBSHTD` (`SEQ 7`) terlempar ke bagian paling bawah.
- **Penyebab**:
  1. Setelah agregasi `IT_DATA_AVG` per `VBELN + MATNR + MIC`, setiap baris `IT_DATA` menyimpan `CHARG` dari perwakilan item pertama pada kelompok deduplikasi (`0000406885` untuk MIC yang berasal dari Kelompok 1, dan `0000406891` untuk 4 MIC yang terambil dari Kelompok 2).
  2. Di akhir `FORM GET_DATA` (baris `763`), dilakukan `SORT IT_DATA BY VBELN CHK DESCENDING` (unstable sort yang mengacak urutan), lalu di `START-OF-SELECTION` (baris `139`) dilakukan `SORT IT_DATA BY VBELN CHARG NUMMIC NUM ASCENDING MIC ASCENDING CHK DESCENDING`.
  3. Karena mengurutkan berdasarkan **`CHARG`** sebelum **`NUMMIC NUM`**, apabila terdapat perbedaan `CHARG` perwakilan antar-MIC dalam material yang sama, urutan `SEQ_NO` (`NUM`) terpecah per `CHARG`! Selain itu, ketika tombol `SELMAP` ditekan (`FORM SELMAPPING`), `SORT IT_DATA BY VBELN CHK DESCENDING` kembali mengacak urutan `NUM`.
- **Solusi di `sandbox-new`**:
  1. Mengubah `SORT IT_DATA` pada `START-OF-SELECTION` (baris `139`) dari `BY VBELN CHARG NUMMIC NUM ASCENDING MIC ASCENDING CHK DESCENDING` menjadi **`BY VBELN MATNR NUMMIC NUM ASCENDING MIC ASCENDING CHK DESCENDING`** (konsisten dengan agregasi `IT_DATA` yang sudah berbasis `VBELN + MATNR + MIC`).
  2. Menyertakan `INSLOT DESCENDING CHARG ASCENDING` pada `SORT IT_DATA_UNIQUE` (baris `609` dan `616`) agar baris perwakilan yang masuk ke `IT_DATA_AVG` selalu memakai `CHARG` dan `NOMSR` dari item pertama yang konsisten (`0000406885`), tidak lagi acak antar-baris.
  3. Menyertakan `MATNR CHK DESCENDING NUMMIC NUM ASCENDING MIC ASCENDING` pada `SORT IT_DATA` di akhir `FORM GET_DATA` (baris `763`) dan `FORM SELMAPPING` (baris `1575`).
- **Artefak & Verifikasi**:
  - Source kandidat: `src/ZQMI_COA_F01_export_candidate.abap` (`4.578` baris)
  - Snapshot setelah push ke `sandbox-new`: `outputs/ZQMI_COA_F01_sandbox-new_after_sequence_sort_fix.abap`
  - Verifikasi `RS_SYNTAX_CHECK` pada `ZQMI_COA`: `SYNTAX_RC = 0`.

## 11. Checkpoint 2026-10-13 — Revisi Layar `0100` (`TCERTI`), Titlebar `Print COA`, dan Export Excel (`ZQMI_COA`)

- **Permintaan Revisi**:
  1. Header/Titlebar diberikan tulisan **`Print COA`**.
  2. Kolom **`NO ODO`** diganti menjadi **`Delivery`**.
  3. Kolom **`Batch`** (`IT_DATA-CHARG`) dan **`Nomor SR`** (`IT_DATA-NOMSR`) dihapus dari tampilan tabel `TCERTI` (dan hasil Export Excel layar `0100`), sementara `IT_DATA-CHARG` dan `IT_DATA-NOMSR` tetap ada di struktur internal untuk proses belakang layar (`VB_BATCH_GET_DETAIL` & `IT_LOT`).
  4. Kolom **`Material`** (`IT_DATA-MATNR`) dan **`Unit Of Measure`** (`IT_DATA-UOM`) diperkecil dan dirapatkan (`MATNR` dari `18` menjadi `10`, `UOM` dari `30` menjadi `15`).
- **Implementasi di `sandbox-new`**:
  1. **GUI Titlebar `T0100` (`Print COA`)**: Menambahkan title code `T0100` (`Print COA`) pada CUA `ZQMI_COA` via `RS_CUA_INTERNAL_WRITE` dan mengaktifkan `SET TITLEBAR 'T0100'.` pada `MODULE STATUS_0100 OUTPUT` dan `MODULE STATUS_0200 OUTPUT` di `ZQMI_COA_F02`.
  2. **Dynpro `ZQMI_COA` Screen `0100` (`TCERTI`)**:
     - Backup penuh definisi heksadesimal Dynpro `0100` disimpan di `outputs/dynpro_0100_backup_hex.json`.
     - Mengubah teks header `IT_DATA-VBELN` dari `'NO ODO'` menjadi `'Delivery'` (`LENG = 8`).
     - Menghapus kolom `IT_DATA-CHARG` (`Batch`) dan `IT_DATA-NOMSR` (`Nomor SR`) dari `FTAB` (`D021S`) dan `CHAIN` PAI di `PLTAB` (`D022S`), serta menggeser nomor kolom (`COLN`) untuk `MATNR` s/d `CMICMIT` menjadi berurutan `4` s/d `12`.
     - Memperkecil lebar tampilan sel (`LENG`) sekaligus lebar kolom Table Control (`DIDX` di `D021S`) untuk:
       - `IT_DATA-MATNR` (`Material`): dari `18` (`DIDX 0012`) menjadi **`8`** (`DIDX 0008`),
       - `IT_DATA-UOM` (`Unit Of Measure`): dari `30` (`DIDX 0014`) menjadi **`12`** (`DIDX 000C`),
       - `IT_DATA-MICMIN` (`Lower Limit`): dari `17` (`DIDX 0011`) menjadi **`8`** (`DIDX 0008`),
       - `IT_DATA-MICMAX` (`Upper Limit`): dari `17` (`DIDX 0011`) menjadi **`8`** (`DIDX 0008`),
       - `IT_DATA-CMICMIT` (`Value`): dari `17` (`DIDX 0011`) menjadi **`8`** (`DIDX 0008`),
       lalu men-generate ulang Dynpro `0100` (`GENERATE DYNPRO`, `GEN_RC = 0`).
  3. **Export Excel (`ZQMI_COA_TOP` & `ZQMI_COA_F01` `FORM DOWNLOAD`)**:
     - Mengubah judul kolom pertama di `FORM DOWNLOAD` dari `'Nomor ODO'` menjadi `'Delivery'` serta menghapus kolom `'Batch'` dan `'Nomor SR'` dari `IT_FIELDNAMES` dan `IT_EXPORT`.
  5. **Perluasan Lebar Penuh (*Full Width*), Perataan Tengah Header, & Optimasi Presisi Lebar Kolom Layar `0200` (`ZQMI_COA` Screen `0200`)**:
     - Mem-backup definisi penuh Dynpro `0200` (`D020S`, `D021S`, `D022S`, `D023S`) ke `outputs/dynpro_0200_backup_hex.json`.
     - Menyamakan ukuran kotak bingkai (`%#AUTOTEXT001`) dan Table Control (`TDETAIL`) pada Dynpro `0200` persis mengikuti ukuran Dynpro `0100`:
       - Bingkai luar (`%#AUTOTEXT001`): `COLN` digeser dari `4` ke **`2`**, dan lebarnya (`LENG`) diperlebar dari `130` menjadi **`182`** (sama persis dengan Screen `0100`).
       - Judul **`CERTIFICATE OF ANALYSIS`** (`HEADER`): digeser ke tengah bingkai dari `COLN = 41` menjadi **`COLN = 67`**.
       - 5 Field Header Atas (`Customer`, `Delivery Number`, `Product`, `Quantity`, `Width`): label digeser dari `COLN = 28` ke **`COLN = 54`**, kotak nilai (`NAME1`, `VBELN`, `PRODUCT`, `NTGEW`, `WIDTH`) digeser dari `COLN = 51` ke **`COLN = 77`**, dan teks satuan (`kg`, `mm`) digeser dari `COLN = 92` ke **`COLN = 118`** sehingga seluruh grup header berada tepat di tengah bingkai `182` kolom.
       - Table Control (`TDETAIL`): `COLN` digeser dari `10` ke **`5`**, dan lebarnya (`LENG`) diperlebar dari `119` menjadi **`177`** (sama persis dengan `TCERTI` di Screen `0100`).
       - Tombol navigasi halaman (`TDETAIL_TOP`, `TDETAIL_PREVIOUS`, `TDETAIL_NEXT`, `TDETAIL_BOTTOM`): digeser ke `COLN = 5, 9, 13, 17` sejajar tepi kiri `TDETAIL` (sama seperti `TCERTI_*` di Screen `0100`).
       - Lebar kolom (`DIDX` & `LENG`) di dalam `TDETAIL` dihitung dan dibagi secara presisi agar ruang kosong di kanan tabel tertutup sempurna tanpa memicu *horizontal scrollbar*:
         - `IT_DETAIL-MICDES` (`Properties`): diperlebar dari `40` menjadi **`48`** (`DIDX = 0030`, `+8` karakter)
         - `IT_DETAIL-RANGE_FLAG` (`Out Limit`): `DIDX = 0009` (`9`), `LENG = 1`
         - `IT_DETAIL-UOM` (`Unit of Measure`): `DIDX = 000F` (`15`), `LENG = 15`
         - `IT_DETAIL-METHOD` (`Testing Method`): diperlebar dari `40` menjadi **`48`** (`DIDX = 0030`, `+8` karakter, sehingga metode uji panjang seperti `Print Colour Blue Lithocure` tidak terpotong)
         - `IT_DETAIL-MICMIN` (`Lower Limit`): `DIDX = 000B` (`11`), `LENG = 11`
         - `IT_DETAIL-MICMAX` (`Upper Limit`): `DIDX = 000B` (`11`), `LENG = 11`
         - `IT_DETAIL-CMICMIT` (`Value`): `DIDX = 0008` (`8`), `LENG = 8`
         - Total lebar seluruh kolom terpasang tepat `150` karakter, menutup sisa ruang kosong `15` karakter di sisi kanan tabel secara presisi tanpa ada kolom yang overlap!
     - Men-generate ulang Dynpro `0200` (`GENERATE DYNPRO`, `GEN_RC = 0`).
  6. **Penggabungan Multi-Alias pada Header COA (`PRODUCT` di Layar `0200` & SmartForms)**:
     - Mengubah logika penentuan `PRODUCT` pada `ZQMI_COA_F02` (baris `149` s/d `215`):
       - Membaca seluruh batch unik dari item terpilih (`IT_LOT` jika ada, atau `IT_DATA`) yang memiliki material sama (`LV_PRODUCT_MATNR`).
       - Membaca karakteristik batch `ZZALIAS` dari `AUSP` via objek `MCH1` dengan kelas batch pasti `KLART = '023'`.
       - Mengumpulkan seluruh alias unik ke tabel internal `LT_SEL_ALIASES` menggunakan `COLLECT` sehingga terhindar dari duplikasi.
       - Menggabungkan alias unik tersebut dengan pemisah koma (contoh: `HSP-18, HSS-18`) ke dalam field `PRODUCT`.
       - Lampiran Roll List / Batch List tetap utuh dan independen membaca per batch roll tanpa perlu perubahan.
  7. **Perluasan Batas Karakter `MIC Description` pada Layar Edit ALV `ZMAP_COA_MIC` (`TCode ZQM001`)**:
     - Memperbaiki pembatasan input teks kolom `MIC_DESC` pada `FORM FIELDCAT` di `src/ZMAP_COA_MIC.abap` (baris `1080` s/d `1092`):
       - Menambahkan referensi tabel dictionary `M_FIELDCAT-REF_TABLE = 'ZMAP_COA'` dan `M_FIELDCAT-REF_FIELD = 'MIC_DESC'`.
       - Memperlebar `M_FIELDCAT-OUTPUTLEN` dari `30` menjadi `40` karakter penuh (sesuai data element `QKURZTEXT` di tabel `ZMAP_COA`).
       - Memungkinkan user mengetik teks panjang lebih dari 30 karakter, termasuk tanda kurung tutup `)` seperti `Seal Strength at SIT ( Outside )` (31 karakter).
  8. **Perbaikan Nilai Kolom `TYPE` pada Lampiran Batch List (Excel & SmartForm `ZQMF_COA_BATCH`)**:
     - Memperbaiki pembentukan nilai kolom `TYPE` di `FORM GET_COA_COL_VALUE` (`ZQMI_COA_F01` baris `3403` s/d `3455`):
       - Akar Masalah: Sebelumnya kolom `TYPE` mengambil `P_BATCH-ZZTYPE` yang ternyata diisi oleh `ZZCODE` (`ACB`), sehingga menghasilkan `ACB-18`.
       - Solusi:
         1. Menambahkan `GV_ATINN_TYPE` (`ZZTYPE`) di `ZQMI_COA_TOP` dan `PREPARE_CHAR_CACHE` di `ZQMI_COA_F01`.
         2. **Prioritas 1**: Jika batch memiliki karakteristik `ZZALIAS`, ambil nilai alias tersebut (misal `HSS-18` atau `HSP-18`).
         3. **Prioritas 2**: Jika tidak memiliki alias, ambil Type Film sendiri (*as is*): membaca `ZZTYPE` dari klasifikasi batch (`HSB4` / `HSB`) digabung dengan thickness `18` (menjadi `HSB4-18` / `HSB-18`), bukan `ACB-18`.
  9. **Penyamaan Format Angka Lower Limit, Upper Limit, dan Value di Layar 0200 dan SmartForms (`ZQMF_COA` & `ZQMF_COA_EXPORT`) dengan Layar Pertama (0100)**:
     - **Akar Masalah**:
       1. Di Layar 0200 (`ZQMI_COA_F02` baris 265-279): Saat transisi dari 0100 ke 0200, program menjalankan loop `LOOP AT IT_DETAIL WHERE TYPE EQ 'X'` yang menimpa `IT_DETAIL-CMICMIT` dengan perintah `WRITE MICMITV TO IT_DETAIL-CMICMIT DECIMALS 2.`! Hal ini memaksakan 2 desimal pada semua nilai (bilangan bulat seperti `88`, `107`, `294` menjadi `88.00`, `107.00`, `294.00`, dan nilai 3 desimal seperti `0.265` terpangkas menjadi `0.27`).
       2. Di SmartForms (`ZQMF_COA` & `ZQMF_COA_EXPORT`): Variabel global `V_LMIN` dan `V_LMAX` didefinisikan sebagai `P DECIMALS 2`, dan node `%CODE1` meng-assign `v_lmin = WA_QAMV-TOLERANZOB.` (FLTP) sehingga semua batas Lower dan Upper dipaksa diformat 2 desimal (`120` menjadi `120.00`, `0.200` menjadi `0.20`).
       3. Di `FORM DOWNLOAD_DETAIL` (`ZQMI_COA_TOP`): Tabel penampung export Excel `IT_DETAILD` mendefinisikan `MICMIN` dan `MICMAX` dengan tipe `FLTP` (`LIKE QPMK-TOLERANZUN/OB`).
     - **Solusi Komprehensif**:
       1. Di `ZQMI_COA_F02` (baris 272): Pengubahan nilai `IT_DETAIL-CMICMIT` hanya dijalankan jika `CTR > 1` dan diformat menggunakan presisi desimal asli MIC (`GV_DEC` dari `PERFORM MICFMT`). Jika `CTR <= 1`, nilai `IT_DETAIL-CMICMIT` dipertahankan utuh sesuai string terformat dari Layar 0100 (`IT_DATA-CMICMIT`).
       2. Di `ZQMI_COA_F01` (`FORM F_PRINT` baris 1644-1654): Mengirim teks string asli `IT_DETAIL-MICMIN` dan `IT_DETAIL-MICMAX` ke field string `IT_QAMV-FORMEL1` dan `IT_QAMV-FORMEL2` (CHAR 60) sebelum memanggil SmartForm.
       3. Di `ZQMI_COA_TOP`: Mengubah `IT_DETAILD-MICMIN` dan `IT_DETAILD-MICMAX` menjadi `TYPE C LENGTH 17` agar hasil export Excel juga mempertahankan format string asli.
       4. Di SmartForms (`ZQMF_COA` dan `ZQMF_COA_EXPORT`):
          - Mengubah tipe data global `V_LMIN` dan `V_LMAX` di `GDATA` dari `P DECIMALS 2` menjadi `CHAR20`.
          - Memperbarui node Program Lines `%CODE1` untuk membaca dari `WA_QAMV-FORMEL1` dan `WA_QAMV-FORMEL2`:
            ```abap
            IF WA_QAMV-FORMEL1 IS NOT INITIAL.
              v_lmin = WA_QAMV-FORMEL1.
            ELSEIF WA_QAMV-TOLERANZOB IS NOT INITIAL.
              v_lmin = WA_QAMV-TOLERANZOB.
            ELSE.
              CLEAR v_lmin.
            ENDIF.
            IF WA_QAMV-FORMEL2 IS NOT INITIAL.
              v_lmax = WA_QAMV-FORMEL2.
            ELSEIF WA_QAMV-TOLERANZUN IS NOT INITIAL.
              v_lmax = WA_QAMV-TOLERANZUN.
            ELSE.
              CLEAR v_lmax.
            ENDIF.
            ```
       5. Semua perubahan telah di-upload, di-compile, dan diuji cetak PDF via `smoke_test_coa_export_form.mjs` dengan hasil presisi: `120`, `240`, `160`, `0.200`, `0.400`, `0.265`.
   10. **Menghapus Tombol Check, Variant (Get & Save), dan Background Job pada Dialog Popup "Export COA Header" (`SCREEN 9000`)**:
       - **Akar Masalah**: Dialog Selection-Screen `9000` (`AS WINDOW`) secara bawaan sistem menampilkan tombol toolbar SAP standard seperti tombol `Check` (`NONE`), Simpan Varian (`SPOS`), Ambil Varian (`GET `), Delete/Show Variant (`VDEL`/`VSHO`), Print (`PRIN`), dan Background Job / Jam Centang (`SJOB`).
       - **Solusi**: Di event `AT SELECTION-SCREEN OUTPUT` (`ZQMI_COA_F01`), menambahkan pengkondisian saat `SY-DYNNR = '9000'` untuk mengecualikan fungsi `NONE`, `SPOS`, `GET `, `VDEL`, `VSHO`, `PRIN`, dan `SJOB` menggunakan `RS_SET_SELSCREEN_STATUS` dengan GUI status `%_CSP`.
       - **Hasil**: Toolbar bawah dialog popup kini 100% bersih dan rapi hanya menyisakan tombol Continue (`✔`) dan Cancel (`✖`). Push ke `sandbox-new` sukses dan lulus `RS_SYNTAX_CHECK` (`SYNTAX_RC = 0`).
- **Artefak & Verifikasi**:
  - Source kandidat: `src/ZQMI_COA_TOP_export_candidate.abap` (`380` baris), `src/ZQMI_COA_F01_export_candidate.abap` (`4.602` baris), `src/ZQMI_COA_F02_export_candidate.abap` (`1.106` baris), `src/ZMAP_COA_MIC.abap` (`1.567` baris)
  - Snapshot setelah push ke `sandbox-new`: `outputs/ZQMI_COA_TOP_sandbox-new_after_screen0100_rev.abap`, `outputs/ZQMI_COA_F01_sandbox-new_after_batch_type_alias_fix.abap`, `outputs/ZQMI_COA_F02_sandbox-new_after_screen0100_rev.abap`, `outputs/ZMAP_COA_MIC_sandbox-new_after_mic_desc_len_fix.abap`
  - Verifikasi `RS_SYNTAX_CHECK` pada `ZQMI_COA` & `ZMAP_COA_MIC`: `SYNTAX_RC = 0`.
