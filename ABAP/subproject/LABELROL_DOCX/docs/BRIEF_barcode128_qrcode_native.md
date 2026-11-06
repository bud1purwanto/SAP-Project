# Design Brief — Encode Code128 & QR Code native ABAP (tanpa labelutils/Python)

| Atribut | Isi |
|---|---|
| Status | DRAFT |
| Tanggal | 2026-11-06 |
| FS / sumber | Permintaan Baginda (chat 2026-11-06); source dev-aix `ZMMR_LABELROL_DOCX` (UDAT 2025-04-25), `ZMMR_LABELROL_DOCX_INCL`, `ZCL_LABEL_DOCX` |
| Sub-project | `subproject/LABELROL_DOCX/` |
| Server analisa | dev-aix (TRD/130), read-only |
| Server write | `sandbox-new` |
| Release | SAP_BASIS **731 SP4**, SAP_APPL 606 → **tidak boleh** inline declaration `DATA(...)`, `NEW`, `VALUE #( )`, `COND/SWITCH` |

## 1. Tujuan
Program label roll `ZMMR_LABELROL_DOCX` bisa membuat isi barcode Code128 dan gambar QR code **sendiri di ABAP**, tanpa memanggil `labelutils` (Python) di PC user.

**Kesimpulan kelayakan: dua-duanya MUNGKIN.**
- **Code128: mudah (effort S).** Yang dikerjakan Python sekarang hanya mengubah teks menjadi karakter font (start + data + checksum + stop). Itu cukup satu FORM ABAP ±80 baris.
- **QR: bisa, tapi effort M–L.** Belum ada di program sekarang, dan SAP 731 ini tidak punya class barcode standar (`CL_RSTX_BARCODE_RENDERER` tidak ada; sudah dicek di SEOCLASS). Encoder harus ditulis sendiri (±700–900 baris), lalu hasilnya disisipkan ke DOCX sebagai gambar PNG.

## 2. Analisa Kondisi Sekarang (As-Is)

Alur barcode sekarang (`ZMMR_LABELROL_DOCX` baris 252, 376–395 + include baris 124–183):

```
GET_DATA_MAIN
 └─ GET_ENCODE128(ITAB-VBATCH) → ITAB-VBARCODETRIAS
      ├─ EXEC_UTIL: CL_GUI_FRONTEND_SERVICES=>EXECUTE
      │     C:\tslabel\docx\<active_version>  "barcode128 -S <batch>"
      ├─ WAIT UP TO '0.5' SECONDS
      └─ READ_LOG_UTIL: GUI_UPLOAD C:\tslabel\docx\log\labelutils.log → string
PRINT_DATA
 └─ ZCL_LABEL_DOCX=>GET_DOCUMENT  (template /spare/saplabel/saplabeldocx/<LABEL>.docx)
      └─ XSLT ZDOCX_FILL_TEMPLATE mengisi teks → font barcode di template menggambar bar
```

Yang perlu dicatat:
1. Barcode di DOCX berupa **teks yang ditulis dengan font barcode**, bukan gambar. Jadi pengganti Code128 cukup menghasilkan string yang sama persis.
2. Saat startup ada ketergantungan ke PC: exe `labelutils` di-download dari `/spare/saplabel/saplabeldocx/utils` (`DOWNLOAD_FE`). Setelah itu exe dijalankan, ditunggu, dan file log-nya dibaca.
3. **Ada risiko bug yang sudah ada sekarang:** kalau exe butuh lebih dari 0,5 detik (PC lambat atau kena antivirus), `GUI_UPLOAD` bisa membaca log kosong atau log batch sebelumnya. Akibatnya barcode bisa salah isi atau kosong. Selain itu `SY-SUBRC` dicek **setelah** `CONCATENATE` dan `MOVE`, sehingga cek gagal/sukses tidak benar-benar jalan.
4. QR: belum ada sama sekali, baik di program, class, maupun transformation.
5. `ZCL_LABEL_DOCX` hanya dipakai oleh `ZMMR_LABELROL_DOCX` (where-used WBCROSSGT/D010INC), jadi aman untuk ditambah parameter.
6. Ada 13 template di `/spare/saplabel/saplabeldocx/`: A153, A154, A155, A156, A157, A159, B101, C109, D128, E127, E128, E133, PLB101.

## 3. Pertanyaan Terbuka
| # | Pertanyaan | Ditanya ke | Jawaban | Tanggal |
|---|---|---|---|---|
| 1 | Font barcode apa yang dipakai di template (mis. "Code 128" Grand Zebu, "Libre Barcode 128", IDAutomation)? Mapping karakternya tergantung font. Template tidak bisa diunduh via RFC (`ARCHIVFILE_SERVER_TO_TABLE` → NOT_FOUND), jadi perlu dibuka manual di Word. | Baginda / IT label | | |
| 2 | Apakah source Python `labelutils` (opsi `-S`) masih ada? Kalau ada, mapping & pemilihan Code Set bisa disalin 1:1. | Baginda / Oskar | | |
| 3 | QR berisi apa? (batch saja / batch+material+SO / URL / format `ITAB-CODE` HU) dan perkiraan panjang maksimal karakternya. | Baginda / user gudang | | |
| 4 | Template mana yang butuh QR, dan di posisi mana? | Baginda | | |
| 5 | Scanner di lapangan: apakah sudah support QR (2D imager)? | User gudang | | |

## 4. Peta Objek & Sumber Data
| Kebutuhan | Sumber | Sudah ada? | Keputusan |
|---|---|---|---|
| String Code128 untuk font | `labelutils barcode128 -S` | Ada (Python, di PC) | **Ganti** dengan method ABAP |
| Matriks QR | — | Tidak ada (731 tanpa renderer standar) | **Baru**: encoder ABAP |
| Gambar QR di DOCX | `ZCL_LABEL_DOCX->MO_ZIP` (CL_ABAP_ZIP) | ZIP sudah dipegang class | **Ubah**: tambah parameter media |
| PNG writer | — | Tidak ada | **Baru** (deflate *stored*, CRC32, Adler32, tanpa kompresi) |

## 5. Opsi

### 5a. Code128
| Opsi | Ringkasan | Plus | Minus | Effort | Dipilih? |
|---|---|---|---|---|---|
| A | Method ABAP yang menghasilkan string font (start + data + checksum + stop) | Template tidak berubah, hasil identik, tanpa exe | Mapping harus cocok dengan font (Q1) | S | **Ya** |
| B | Render Code128 jadi gambar PNG | Tidak tergantung font | Semua template harus diubah dari teks ke gambar | M | Tidak |

### 5b. QR
| Opsi | Ringkasan | Plus | Minus | Effort | Dipilih? |
|---|---|---|---|---|---|
| A | Encoder QR ABAP + PNG, mengganti **gambar placeholder** di template | Native, tanpa font/exe, template cukup diberi 1 gambar dummy | Paling banyak kode | M–L | **Ya** |
| B | Font QR | — | Font QR tetap butuh encoder lengkap, jadi tidak menghemat apa pun | — | Tidak |
| C | Grid QR sebagai tabel Word (cell hitam/putih) | Tanpa gambar | XML sangat berat, rawan bergeser saat dicetak | M | Tidak |
| D | Pindah ke Adobe Form/SmartForm (barcode QR native) | Native SAP | Mengganti seluruh mekanisme DOCX; QR di SmartForm 731 butuh note/SP | L | Tidak |

## 6. Desain yang Diusulkan

### 6.1 Objek baru: class `ZCL_LABEL_BARCODE` (static, sintaks 731)
```
PUBLIC SECTION.
  CLASS-METHODS encode_code128_font
    IMPORTING iv_text TYPE csequence
    RETURNING VALUE(rv_font) TYPE string.         "siap dipakai font barcode
  CLASS-METHODS qr_matrix
    IMPORTING iv_text TYPE string
              iv_ecc  TYPE char1 DEFAULT 'M'
    EXPORTING et_matrix TYPE ty_t_matrix           "tabel string '0'/'1' per baris
              ev_version TYPE i
    EXCEPTIONS too_long.
  CLASS-METHODS matrix_to_png
    IMPORTING it_matrix TYPE ty_t_matrix
              iv_scale  TYPE i DEFAULT 10          "px per module
              iv_quiet  TYPE i DEFAULT 4           "quiet zone (module)
    RETURNING VALUE(rv_png) TYPE xstring.
```

### 6.2 Code128: `ENCODE_CODE128_FONT`
1. Pilih Code Set: **C** kalau seluruh teks numerik dengan panjang genap (batch numerik, hasilnya separuh lebih pendek). Selain itu **B**. Opsional mixed B/C, mengikuti perilaku labelutils (Q2).
2. Hitung nilai simbol: Set B → `ASCII − 32`; Set C → nilai 2 digit (00–99).
3. Checksum: `(start + Σ nilai_i × i) MOD 103`, dengan `i` mulai dari 1.
4. Petakan nilai ke karakter font. Contoh untuk font Grand Zebu / Libre Barcode 128:
   - nilai 0 → `Â` (194); 1–94 → `CHR(nilai + 32)`; 95–106 → `CHR(nilai + 100)`
   - Start B = 104 → `Ì` (204), Start C = 105 → `Í` (205), Stop = 106 → `Î` (206)
   - Konversi kode ke char di 731: `cl_abap_conv_in_ce=>uccpi( lv_code )`.
5. Di program: isi `FORM GET_ENCODE128` diganti dengan satu baris
   `output = zcl_label_barcode=>encode_code128_font( input ).`
   Setelah itu `EXEC_UTIL`, `READ_LOG_UTIL`, `DOWNLOAD_FE`, `CHECK_FILE_EXISTANCE`, dan `GET_ACTIVE_VERSION` tidak dipakai lagi. Hapus pada tahap terpisah setelah stabil.

### 6.3 QR: `QR_MATRIX` (ISO/IEC 18004)
Ruang lingkup dibatasi supaya kodenya ringkas:
- **Mode byte saja** (UTF-8). Alfanumerik/numerik tidak diperlukan untuk data label.
- **ECC level M** (tahan sekitar 15% rusak, cocok untuk label roll).
- **Version 1–6** (21×21 s/d 41×41). Version ≥ 7 butuh blok *version information* tambahan, jadi tunda dulu sampai Q3 menunjukkan perlu.

| Version | Ukuran | Kapasitas byte (M) | Total codeword | EC per blok | Blok × data |
|---|---|---|---|---|---|
| 1 | 21 | 14 | 26 | 10 | 1 × 16 |
| 2 | 25 | 26 | 44 | 16 | 1 × 28 |
| 3 | 29 | 42 | 70 | 26 | 1 × 44 |
| 4 | 33 | 62 | 100 | 18 | 2 × 32 |
| 5 | 37 | 84 | 134 | 24 | 2 × 43 |
| 6 | 41 | 106 | 172 | 16 | 4 × 27 |

Alignment pattern center: V2 (6,18), V3 (6,22), V4 (6,26), V5 (6,30), V6 (6,34).

Langkah (masing-masing jadi method private):
1. **Data bits**: mode `0100` + panjang (8 bit) + byte data + terminator `0000` + padding sampai kelipatan 8 + pad byte `EC`/`11` bergantian.
2. **Reed-Solomon**: tabel log/antilog GF(256) dengan polinom `0x11D`, generator polynomial per jumlah EC, pembagian polinom per blok. Operasi XOR memakai `BIT-XOR` pada field tipe `X` (tersedia di 731).
3. **Interleave** data & EC antar blok (V4–V6).
4. **Function patterns**: 3 finder + separator, timing row/col 6, alignment, dark module `(4V+9, 8)`, area format info dikosongkan.
5. **Penempatan zig-zag** 2 kolom dari kanan bawah, melewati kolom 6.
6. **Masking**: coba 8 mask, hitung penalty N1–N4, pilih yang terkecil.
7. **Format info**: 5 bit (ECC M = `00` + mask 3 bit), BCH(15,5) XOR `101010000010010`, ditulis di 2 lokasi.

Struktur data matriks: `TYPES ty_t_matrix TYPE STANDARD TABLE OF string` (1 baris = 1 string '0'/'1'), plus tabel "reserved" dengan bentuk yang sama untuk menandai function pattern.

### 6.4 PNG: `MATRIX_TO_PNG`
Ditulis tanpa library kompresi:
- PNG grayscale 1-bit (IHDR: color type 0, bit depth 1).
- Tiap baris pixel diawali filter byte `00`; bit dikemas MSB dulu.
- zlib: header `78 01` + blok deflate **stored** (BTYPE=00, maks 65535 byte per blok, LEN/NLEN little-endian) + Adler32. Tidak perlu algoritma kompresi.
- CRC32 (tabel 256 entry) untuk tiap chunk IHDR/IDAT/IEND.
- Contoh ukuran: V3 + quiet 4 = 37 module × 10 px = 370 px. Data mentah sekitar 18 KB, cukup kecil.
- Scale 10 px per module dipakai supaya Word tidak menghaluskan (blur) tepi module waktu gambar di-resize.

### 6.5 Menyisipkan QR ke DOCX: perubahan `ZCL_LABEL_DOCX`
Pendekatan **placeholder image**, supaya template tidak perlu diedit secara XML:
1. Di Word, pembuat template menyisipkan gambar PNG dummy pada posisi QR. Alt-text (Description) diisi `QR_CODE`.
2. Tambah parameter opsional di `GET_DOCUMENT`: `IT_IMAGES TYPE ty_t_image` (field `TAG` = alt-text, `PNG` = xstring). Karena opsional, pemanggil lama tetap jalan.
3. Method baru `REPLACE_IMAGE( iv_tag, iv_png )`, dijalankan sebelum `MO_ZIP->SAVE( )`:
   - baca `word/document.xml`, cari `<wp:docPr ... descr="QR_CODE">`, ambil `r:embed="rIdN"` dari `<a:blip>` sesudahnya
   - baca `word/_rels/document.xml.rels`, ambil `Target` untuk `rIdN` (mis. `media/image3.png`)
   - `MO_ZIP->DELETE` lalu `MO_ZIP->ADD` untuk `word/media/image3.png` dengan PNG baru
   - Ekstensi tetap `.png`, jadi `[Content_Types].xml` tidak perlu diubah.
4. Di program, `PRINT_DATA` mengisi `IT_IMAGES` per baris ITAB (1 dokumen per baris, sudah begitu sekarang). Template tanpa placeholder `QR_CODE` dilewati tanpa error.

### 6.6 Di luar scope
- Mengubah tampilan template selain menambah placeholder QR.
- QR version ≥ 7, mode Kanji/alfanumerik, ECC selain M.
- Mengganti mekanisme cetak OLE Word (`PrintOut`).
- Menghapus file `labelutils` di server `/spare/...`.

## 7. Daftar Objek
| Jenis | Nama | Baru / ubah | Server | Backup di `outputs/` |
|---|---|---|---|---|
| Class | `ZCL_LABEL_BARCODE` | Baru | sandbox-new | — |
| Class | `ZCL_LABEL_DOCX` (param `IT_IMAGES`, method `REPLACE_IMAGE`) | Ubah | sandbox-new | `ZCL_LABEL_DOCX_DEV_20261106.abap` |
| Program | `ZMMR_LABELROL_DOCX` (`GET_ENCODE128`, `PRINT_DATA`) | Ubah | sandbox-new | `ZMMR_LABELROL_DOCX_DEV_20261106.abap` |
| Include | `ZMMR_LABELROL_DOCX_INCL` | Ubah (tahap 2: buang util) | sandbox-new | `ZMMR_LABELROL_DOCX_INCL_DEV_20261106.abap` |
| Template | `<LABEL>.docx` yang perlu QR | Ubah (tambah placeholder) | `/spare/saplabel/saplabeldocx/` | salinan template |

## 8. Urutan Build & Strategi Test
**Tahap 1: Code128** (bisa jalan sendiri, langsung bermanfaat)
1. Jawab Q1/Q2 terlebih dahulu.
2. Buat `ENCODE_CODE128_FONT`.
3. **Regression test**: untuk ±50 batch nyata (numerik, alfanumerik, ada `-`), bandingkan output ABAP dengan output `labelutils barcode128 -S` byte per byte. Harus 100% sama.
4. Ganti `GET_ENCODE128`, cetak 1 label, lalu scan dengan scanner gudang.

**Tahap 2: QR**
1. `QR_MATRIX` + `MATRIX_TO_PNG` di class terpisah (unit test lewat program test `ZTMP*` di sandbox-new).
2. **Verifikasi matriks**: untuk teks, version, dan mask yang sama, bandingkan bit per bit dengan library referensi (Python `segno`/`qrcode` di mesin ini, mask dipaksa sama). Lalu decode PNG dengan `zbarimg` dan HP.
3. Kasus uji: 1 karakter, tepat di batas kapasitas tiap version (14/26/42/62/84/106 byte), 107 byte (harus `TOO_LONG`), karakter non-ASCII.
4. `REPLACE_IMAGE` + 1 template dengan placeholder. Buka di Word, cetak, scan.

**Tahap 3: bersih-bersih**: hapus `EXEC_UTIL`/`READ_LOG_UTIL`/`DOWNLOAD_FE` dan pengecekan exe di START-OF-SELECTION.

Lalu QA gate → review → transport.

## 9. Estimasi
| Bagian | Baris ABAP (perkiraan) | Effort |
|---|---|---|
| Code128 font encoder + regression | 80–120 | 0,5–1 hari |
| QR encoder (V1–6, M, byte) | 600–800 | 2–3 hari |
| PNG writer (stored deflate, CRC32, Adler32) | 120–150 | 0,5 hari |
| `REPLACE_IMAGE` di ZCL_LABEL_DOCX + template | 80–100 | 0,5–1 hari |
| Test lapangan (cetak + scan) | — | 0,5–1 hari |

## 10. Log Keputusan
| Putaran | Keputusan | Oleh | Tanggal |
|---|---|---|---|
| 1 | Draft awal: Code128 tetap memakai font (opsi A); QR memakai encoder ABAP + PNG placeholder (opsi A) | Claude | 2026-11-06 |

## 11. Persetujuan
> Belum ada.
