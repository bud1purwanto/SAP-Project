# Panduan Praktis Eksekusi Enterprise Structure di SAP S/4HANA (ADB)
**Target: Membuat Company Code 9999 & Plant 1000/2000 dalam 5-10 Menit via Standard SAP GUI**

---

## PENTING: Mengapa Wajib Menggunakan EC01 & EC02 di S/4HANA?
Di SAP S/4HANA, Company Code terikat erat dengan **Universal Journal (ACDOCA)** dan **Mandatory Material Ledger**.
Dengan menyalin dari template bawaan SAP (`0001` atau `COPY`):
- Seluruh tabel turunan akuntansi (Ledger `0L`, Currency Type, Document Type, Field Status Group) otomatis ter-generate dan sinkron.
- Terhindar dari error runtime fatal *FINS_ACDOC_POSTING* atau *FINS_ML_CHECK*.

---

## Langkah 1: Copy Company Code 9999 (T-Code: EC01)
1. Masuk ke SAP GUI pada sistem **S/4HANA (ADB Client 130)**.
2. Ketik transaksi **`EC01`** pada command box, tekan Enter.
3. Klik tombol **Copy org. object** (ikon dua lembar kertas atau `F6`).
4. Pada popup copy:
   - **From Company Code:** `0001` (atau `COPY`)
   - **To Company Code:** `9999`
5. Tekan Enter / centang hijau. Jika muncul konfirmasi copy G/L accounts, pilih **Yes**.
6. Masukkan Transport Request (TR) baru jika diminta (misal: *Setup Enterprise Structure Trias Sentosa*).
7. Selesai (proses copy memakan waktu ~1-2 menit).

## Langkah 2: Edit Detail Nama & Alamat Company Code 9999 (T-Code: OX02)
1. Buka transaksi **`OX02`**.
2. Pilih Company Code **`9999`**, klik tombol **Details** (kaca pembesar).
3. Sesuaikan parameter berikut:
   - **Company Name:** `PT Trias Sentosa, Tbk.`
   - **City:** `Sidoarjo`
   - **Country:** `ID`
   - **Currency:** `IDR`
   - **Language:** `EN`
4. Klik **Address** (ikon amplop/surat) untuk melengkapi nama legal perusahaan.
5. Klik **Save** (`Ctrl + S`).

## Langkah 3: Copy Plant 1000 & Plant 2000 (T-Code: EC02)
1. Ketik transaksi **`EC02`**, tekan Enter.
2. Klik tombol **Copy org. object** (`F6`).
3. Buat Plant 1000:
   - **From Plant:** `0001`
   - **To Plant:** `1000`
   - Tekan Enter -> Lanjutkan sampai selesai.
4. Ulangi untuk Plant 2000:
   - **From Plant:** `0001`
   - **To Plant:** `2000`
   - Tekan Enter -> Selesai.

## Langkah 4: Edit Nama Plant (T-Code: OX10)
1. Buka transaksi **`OX10`**.
2. Pilih Plant **`1000`** -> Ubah nama menjadi: **`Waru`**, Country: `ID`, City: `Sidoarjo`. Simpan.
3. Pilih Plant **`2000`** -> Ubah nama menjadi: **`Krian`**, Country: `ID`, City: `Sidoarjo`. Simpan.

## Langkah 5: Hubungkan Plant ke Company Code (T-Code: OX18)
1. Buka transaksi **`OX18`**.
2. Klik **New Entries**:
   - CoCode: `9999` | Plant: `1000`
   - CoCode: `9999` | Plant: `2000`
3. Klik **Save** (`Ctrl + S`).

## Langkah 6: Hubungkan CoCode 9999 ke Controlling Area (T-Code: OX19)
1. Buka transaksi **`OX19`**.
2. Buat assignment CoCode `9999` ke Controlling Area (misal `0001` atau `TSCO` jika sudah didefinisikan di `OX06`).
3. Klik **Save**.

## Langkah 7: Setup Purchasing Organization (T-Code: OX08, OX01, OX17)
1. **`OX08`**: Buat Pur Org `TPOL` (Local) dan `TPOI` (Import).
2. **`OX01`**: Assign `TPOL` dan `TPOI` ke Company Code `9999`.
3. **`OX17`**: Assign `TPOL` dan `TPOI` ke Plant `1000` dan `2000`.

---

## Verifikasi Otomatis Pasca-Setup
Setelah langkah 1–5 selesai dilakukan di SAP GUI, kami dapat langsung memvalidasi dari backend menggunakan query RFC via MCP SAP ke tabel:
- `T001` (Company Code 9999)
- `T001W` (Plant 1000 & 2000)
- `T001K` (Valuation Area 1000 & 2000 ke 9999)

Begitu terverifikasi valid, sistem langsung siap untuk injeksi **Master Data Pilot (Material FG, Work Center, BOM, Routing, Production Version)** via BAPI otomatis!
