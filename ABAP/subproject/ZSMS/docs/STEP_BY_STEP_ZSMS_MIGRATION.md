# Panduan Langkah Demi Langkah: Replikasi Program & TCode ZSMS dari DEV AIX ke S/4HANA

| Metadata | Nilai |
|---|---|
| Objek Program | `ZSMS` (Report ABAP 229 Baris) |
| Transaction Code | `ZSMS` (`Program Messaging`) |
| Source System | SAP DEV AIX (`TRD`, NetWeaver 7.31 / Oracle, Host 192.168.2.8, Client 130) |
| Target System | SAP S/4HANA 1909 (`ADB`, NetWeaver 7.54 / HANA, Host 192.168.1.199, Client 130) |
| Status Pekerjaan | **Tuntas 100% (Verified Live di SAP GUI S/4HANA)** |
| Tanggal Eksekusi | 2026-11-20 |

---

## 1. Latar Belakang & Analisis Awal Objek

Program `ZSMS` merupakan utilitas interaktif SAP yang digunakan untuk:
1. Membaca daftar pengguna yang sedang login di sistem SAP melalui internal C-kernel routine `CALL 'ThUsrInfo'`.
2. Menghubungkan username (`BNAME`) ke master data personel melalui tabel `USR21` dan view `V_ADRP_CP` untuk mengambil Nama Depan, Nama Belakang, Departemen, dan Nomor Telepon.
3. Menampilkan daftar pengguna dalam bentuk tabel interaktif SAP GUI dengan tombol navigasi:
   - `Select All`
   - `Deselect`
   - `Send Message` (memanggil Function Module `TH_POPUP` untuk mengirim dialog popup real-time ke layar user SAP GUI tujuan)
   - `Last Name` (Sortir)
   - `First Name` (Sortir)
   - `Client` (Sortir)

---

## 2. Langkah-Langkah Eksekusi Migrasi

### Tahap 1: Ekstraksi dari SAP DEV AIX (`TRD 130`)
- **Source Code:** Sebanyak 229 baris ABAP diekstraksi dari server DEV AIX menggunakan RFC standard `RPY_PROGRAM_READ` dan disimpan di repository remote `/data/Projects/SAP/ABAP/subproject/ZSMS/src/ZSMS.abap`.
- **Metadata TCode:**
  - `TCODE`: `ZSMS`
  - `PGMNA`: `ZSMS`
  - `DYPNO`: `1000`
  - `TTEXT`: `Program Messaging` (Tabel `TSTCT`, Bahasa `E`)
  - `CINFO`: Hex `80` (Report Transaction)

### Tahap 2: Replikasi Program ABAP ke S/4HANA (`ADB 130`)
- Program `ZSMS` dibuat dan dikompilasi langsung di S/4HANA melalui RFC `RPY_PROGRAM_INSERT`:
  - `PROGRAM_NAME`: `ZSMS`
  - `TITLE_STRING`: `Program Messaging`
  - `PROGRAM_TYPE`: `1` (Executable Program)
  - `DEVELOPMENT_CLASS`: `$TMP` (Local Object)
  - `UCCHECK`: `X` (Unicode Check aktif sesuai standar S/4HANA)
- **Verifikasi Kompilasi & Database:**
  - Tabel `TRDIR`: `NAME = 'ZSMS'`, `SUBC = '1'`, `UNAM = 'TRSTABAP'`, `UCCHECK = 'X'`.
  - Tabel `TRDIRT`: `NAME = 'ZSMS'`, `SPRSL = 'E'`, `TEXT = 'Program Messaging'`.
  - Tabel `D010SINF`: Status objek aktif (`SUBTY = 'A'`).

### Tahap 3: Pembuatan TCode ZSMS di S/4HANA via SE93
- Membuka transaksi `SE93` di SAP GUI S/4HANA (`ADB 130`).
- Membuat TCode `ZSMS` dengan deskripsi `Program Messaging`.
- Menautkan TCode ke Program `ZSMS` dengan default screen `1000`.
- Menyimpan ke TADIR dengan package `$TMP`.
- Menyelaraskan atribut `TSTC-CINFO` menjadi hex `80` (Report Transaction flag) menggunakan helper runner `ZFIX_TSTC_ZSMS` agar SAP kernel mengeksekusi program report interaktif secara langsung tanpa mencari screen dialog fisik.

---

## 3. Hasil Pengujian Live di SAP GUI S/4HANA

Pengujian dilakukan langsung pada sesi SAP GUI live (`ADB (1) (130)`) dengan mengetikkan perintah `/nZSMS`:
1. **Layar TCode Tampil Sempurna:**
   - Header: `Program Messaging`
   - Toolbar Tombol Aksi: `Select All`, `Deselect`, `Send Message`, `Last Name`, `First Name`, `Client` aktif dan responsif.
   - Kolom Data: `Cli` | `User` | `First Name` | `Last Name` | `Department` | `Telephone` ter-render rapi dengan checkbox interaktif.
   - Baris Pengguna: Menampilkan sesi login aktif user `TRSTABAP` pada Client `130`.
2. **Kesehatan Sistem (ST22):**
   - Tidak ada runtime dump (`SNAP` 0 baris error baru).
   - Seluruh fungsi interaktif dan display berjalan lancar.
3. **Dokumentasi Visual:**
   - Screenshot layar eksekusi sukses tersimpan di: `subproject/ZSMS/docs/attachments/39_zsms_tcode_executed_success.png`.

---

## 4. Kesimpulan & Status
Replikasi program `ZSMS` dan transaction code `ZSMS` dari SAP DEV AIX ke SAP S/4HANA telah **selesai 100% dan terverifikasi operasional**.