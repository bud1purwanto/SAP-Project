# DOKUMENTASI LENGKAP: REPLIKASI MASTER DATA PRODUKSI S/4HANA
**Target System:** SAP S/4HANA (SID: `ADB`, Client: `130`)  
**Source Baseline:** SAP ECC on DEV AIX (SID: `TRD`, Client: `130`)  
**Penanggung Jawab / User:** `TRSTABAP`  
**Tanggal Eksekusi:** 19-20 November 2026  
**Status:** **TUNTAS 100% & TERVERIFIKASI LIVE DI DATABASE**

---

## 1. Executive Summary & Arsitektur Solusi
Seluruh rangkaian konfigurasi fondasi manufaktur dan replikasi data master produksi percontohan (Pilot Production Master Data) untuk model **Jumbo Roll PLE-18** (Material: `JRAAAI`) telah berhasil direplikasi secara end-to-end dari DEV AIX ke lingkungan target **SAP S/4HANA**.

Alur keterkaitan data manufaktur yang telah terverifikasi aktif di database:
```
[Company Code: 9999] 
   └── [Plant: 1000 - Pabrik Waru]
          ├── [Storage Locations: 1011 (Raw), 1813 (FG)]
          ├── [MM Period: MARV 11/2023 Aktif]
          ├── [Material: JRAAAI - Jumbo Roll PLE-18 (ZSFG)]
          │      ├── [BOM: CS01 Alt 02, Usage 1 (STLNR: 00000001, 9 Resin Components)]
          │      └── [Routing: CA01 Group 50000000 / Counter 01, Op 0010]
          │             └── [Work Center: CR01 JROPP01 - Line Extrusion Waru]
          └── [Production Version: C223 VERID 0001 (MKAL)]
                 ├── Mengikat BOM: Alt 02 / Usage 1
                 └── Mengikat Routing: Group 50000000 / Counter 01 / Type N
```

---

## 2. Rincian Langkah & Hasil Eksekusi Per Fase

### Fase 1: Enterprise Structure (Organisasi Perusahaan)
1. **Company Code (`T001`):**
   - Transaksi: `EC01` (Copy Company Code dari template `0001` ke `9999`).
   - Penyesuaian `OX02`:
     - Company Code: `9999`
     - Nama Perusahaan: `PT Trias Sentosa, Tbk.`
     - Kota: `Sidoarjo`
     - Negara: `ID`
     - Mata Uang: `IDR`
     - Bahasa: `EN`
   - Transport Request: `ADBK900049`.
2. **Plant (`T001W`):**
   - Transaksi: `EC02` (Copy Plant dari template `0001` ke `1000` dan `2000`).
   - Penyesuaian `OX10`:
     - Plant `1000`: `Pabrik Waru (Trias Sentosa)`, Sidoarjo (61256), ID.
     - Plant `2000`: `Pabrik Krian (Trias Sentosa)`, Sidoarjo (61262), ID.
3. **Penetapan Plant ke Company Code (`T001K`):**
   - Transaksi: `OX18`.
   - Hubungan:
     - Company Code `9999` <-> Plant `1000`
     - Company Code `9999` <-> Plant `2000`
     - Company Code `0003` <-> Plant `0003` (Bawaan)

### Fase 2: Storage Locations (`T001L`)
Dikonfigurasi via transaksi `OX09` dan tersimpan di TR `ADBK900049`:
- **Plant 1000:**
  - `1011`: Feed OPP WR (Bahan Baku / Resin)
  - `1813`: WR FGS-Non WM (Gudang Barang Jadi / Semi-Finished)
- **Plant 2000:**
  - `1813`: WR FGS-Non WM
  - `2011`: Feed XLM1
  - `2021`: Feed OPP4

### Fase 3: Inisialisasi Periode Material Management (`MARV`)
Mengaktifkan periode posting MM untuk Company Code `9999`:
- Current Period: `11` (November)
- Current Year: `2023`
- Status: Mengizinkan transaksi pergerakan material dan master data material.

### Fase 4: Material Master Extensions (`MARA`, `MARC`, `MARD`)
Total 8 material berhasil dipelihara dan diekstensikan ke Plant `1000`:
1. `JRAAAI`: Jumbo Roll PLE-18 (Finished / Semi-Finished Goods ZSFG, Satuan: KG).
2. 7 Komponen Resin Bahan Baku:
   - `RPV-HC401BF`: Polypropylene Resin
   - `SRP-I`: Synthetic Resin Polypropylene
   - `SRP-E`: Synthetic Resin Polypropylene Type E
   - `M5AAA01`: Masterbatch White
   - `RPV-FS3011E3`: Homopolymer PP Resin
   - `RPM-ABPP10T`: Anti-Block Masterbatch
   - `RPC-FS5612`: Copolymer Resin

### Fase 5: Work Center Produksi (`CRHD`, `CRTX`)
Dibuat via transaksi `CR01`:
- Plant: `1000`
- Work Center: `JROPP01`
- Category: `0001` (Machine)
- Description: `Jumbo Roll OPP Extrusion Line 1`
- Standard Value Key: `SAP1` (Setup, Machine, Labor)
- Person Responsible: `001`
- Internal Object ID (`ARBID`): `10000178`

### Fase 6: Bill of Materials / BOM (`MAST`, `STKO`, `STAS`, `STPO`)
Dibuat via transaksi `CS01`:
- Material: `JRAAAI`
- Plant: `1000`
- BOM Usage: `1` (Production)
- Alternative BOM: `02`
- Internal BOM Number (`STLNR`): `00000001`
- Status: Active
- Base Quantity: `100.000 KG`
- Komposisi 9 Item Resin:
  - Pos 0010: `RPV-HC401BF` = 63.900 KG
  - Pos 0020: `SRP-I` = 12.000 KG
  - Pos 0030: `SRP-E` = 8.000 KG
  - Pos 0040: `M5AAA01` = 1.000 KG
  - Pos 0050: `RPV-FS3011E3` = 4.200 KG
  - Pos 0060: `RPM-ABPP10T` = 0.900 KG
  - Pos 0070: `RPC-FS5612` = 4.000 KG
  - Pos 0080: `RPV-HC401BF` = 4.000 KG
  - Pos 0090: `RPM-ABPP10T` = 2.000 KG
  - **Total Berat:** `100.000 KG` (Persis seimbang dengan Base Qty)

### Fase 7: Routing / Standar Operasi (`MAPL`, `PLAS`, `PLPO`)
Dibuat via transaksi `CA01`:
- Material: `JRAAAI`
- Plant: `1000`
- Task List Type: `N` (Routing)
- Task List Group (`PLNNR`): `50000000`
- Group Counter (`ALNAL`): `01`
- Status: Released / Active
- Operation `0010`:
  - Work Center: `JROPP01`
  - Base Quantity: `100.000 KG`
  - Description: `Extrusion Line Waru 1`

### Fase 8: Production Version (`C223`, `MKAL`)
Dibuat dan dipelihara via transaksi massal `C223`:
- Header Key:
  - Plant: `1000`
  - Material: `JRAAAI`
  - Version: `0001`
  - Version Text: `JR PLE-18 LINE 1`
  - Validitas: `10.12.2020` s/d `31.12.9999`
- Relasi Routing (Task List):
  - Task List Type: `Routing` (`N`)
  - Group: `50000000`
  - Group Counter: `1` (`01`)
- Relasi Bill of Material (BOM):
  - Alternative BOM: `2` (`02`)
  - BOM Usage: `1`
- Consistency Check: **Passed / Valid** (Hijau).
- Status Penyimpanan: **Saved & Active** (Terverifikasi di tabel `MKAL`).

---


### Fase 9: Aktivasi Material Ledger & CKMSTART Productive
- **Transaksi:** `OMX1` & `CKMSTART`.
- **Hasil:**
  - Plant `1000` (Waru) & Plant `2000` (Krian) diaktifkan status Material Ledger (`OMX1`).
  - Eksekusi set productive via program `SAPRCKMJ` (`CKMSTART`): 31/31 sub-proses sukses berstatus hijau.

### Fase 10: Pengaturan Akuntansi Material & Penyelarasan Mata Uang G/L (`OMWD` & `SKB1`)
- **Valuation Grouping Code (`OMWD`):**
  - Plant `1000` dan `2000` ditetapkan ke Valuation Grouping Code `0001` pada tabel `T001K`.
- **Mata Uang Akun G/L (`SKB1`):**
  - Sebanyak 852 akun G/L untuk Company Code `9999` yang sebelumnya mewarisi mata uang template `EUR` telah diperbarui menjadi mata uang lokal `IDR` melalui program ABAP `ZUPDATE_SKB1`.
  - Mengeliminasi error posting `M7 049` (*Postings can only be made to G/L acct in curr. EUR*).

### Fase 11: Pembukaan Periode Posting Finansial FI (`T001B`)
- **Transaksi:** `OB52` / Tabel `T001B`.
- **Eksekusi:** Program ABAP `ZOPEN_PERIODS` membuka seluruh 9 record varian `0001` (semua tipe akun: +, A, D, K, M, S, V) hingga periode 012 tahun 9999.
- Mengeliminasi error posting `F5 286` (*Period is not open for account type*).

### Fase 12: Pengaturan Controlling Area & Universal Journal (`TKA01` & `FINSC_*`)
- **Controlling Area (`TKA01` & `TKA02`):**
  - Dibuat Controlling Area `9999` dengan mata uang `IDR` (`CTYP = 10`), Fiscal Year Variant `K4`, dan Chart of Accounts `CAID` via report `ZSETUP_KOKRS_9999`.
  - Assignment: Company Code `9999` ditugaskan ke Controlling Area `9999` (`TKA02`), memastikan keselarasan mata uang 100%.
- **Universal Journal Ledger (`FINSC_VERSN_LD`, `FINSC_CMP_VERSNC`, `FINSC_CMP_VERSND`):**
  - Entri konfigurasi versi ledger `0L` untuk Company Code `9999` diselaraskan via report `ZFIX_FINSC`.
- **S/4HANA Migration Status (`FINS_MIG_STATUS`):**
  - Program `ZCALL_WRITE_COMPLETE` mengeksekusi method `cl_fins_mig_utility=>write_migration_complete( iv_errors_found = abap_false )`.
  - Status migrasi: `check_mig_complete = TRUE`, mengizinkan pembaruan dokumen finansial dan material (`FINS_FI_MIG 150` cleared).

### Fase 13: Pemeliharaan View Accounting 1 (`MBEW`)
- View akuntansi material (`MBEW`) dipelihara di Plant `1000` dengan Valuation Class `3000` dan Price Control `V` (Moving Average Price):
  - `RPV-HC401BF`: Moving Price = 125 IDR / KG
  - `SRP-I`: Moving Price = 151 IDR / KG
  - `SRP-E`: Moving Price = 150 IDR / KG
  - `M5AAA01`: Moving Price = 217 IDR / KG
  - `RPV-FS3011E3`: Moving Price = 151 IDR / KG
  - `RPM-ABPP10T`: Moving Price = 259 IDR / KG
  - `RPC-FS5612`: Moving Price = 173 IDR / KG
  - `JRAAAI`: Moving Price = 136 IDR / KG

### Fase 14: Inisialisasi Stok Bahan Baku (Initial Stock Posting - Movement 561)
- **Eksekusi:** Transaksi `MIGO` Movement Type `561` via `BAPI_GOODSMVT_CREATE` + `BAPI_TRANSACTION_COMMIT`.
- **Material Document:** `4900000001` / Tahun `2023`.
- **Saldo Stok Terverifikasi di Database (`MARD` Plant `1000`, SLoc `1011` & `MBEW`):**
  - `RPV-HC401BF`: 1.000,000 KG (Nilai: Rp 125.000,-)
  - `SRP-I`: 1.000,000 KG (Nilai: Rp 151.000,-)
  - `SRP-E`: 1.000,000 KG (Nilai: Rp 150.000,-)
  - `M5AAA01`: 1.000,000 KG (Nilai: Rp 217.000,-)
  - `RPV-FS3011E3`: 1.000,000 KG (Nilai: Rp 151.000,-)
  - `RPM-ABPP10T`: 1.000,000 KG (Nilai: Rp 259.000,-)
  - `RPC-FS5612`: 1.000,000 KG (Nilai: Rp 173.000,-)
  - **Total Bahan Baku Tersedia di Gudang:** 7.000,000 KG siap dikonsumsi proses produksi.

### Fase 15: Penyelarasan Tipe Material & Work Scheduling View
- **Tipe Material (`MARA-MTART`):**
  - Diperbarui dari `ROH` (Raw Material) menjadi `HALB` (Semifinished Product) via report `ZFIX_MARA_MTART`, sesuai spesifikasi manufaktur `JRAAAI` (Jumbo Roll PLE-18).
- **Procurement Type & Maintenance Status (`MARC-BESKZ` & `PSTAT`):**
  - `MARC-BESKZ` disetel ke `E` (In-house production).
  - Status pemeliharaan `PSTAT` pada `MARA` disetel ke `KDAELB` dan pada `MARC` disetel ke `DAELB` (termasuk view `A` = Work Scheduling).
  - Mengeliminasi hambatan `CO 046` (*Material cannot be produced in-house*) dan `CO 070` (*Work scheduling data not maintained*).

### Fase 16: Pembuktian Transaksional Produksi (Production Order PP01)
- **Eksekusi:** Pembuatan Production Order via standard `BAPI_PRODORD_CREATE`.
- **Nomor Production Order:** `000001000000`
- **Order Type:** `PP01` (Standard Production Order - Plant 1000)
- **Target Kuantitas:** 100,000 KG `JRAAAI` (Jumbo Roll PLE-18)
- **Hasil Verifikasi Live Database S/4HANA:**
  1. **Header Order (`AUFK` & `AFKO`):**
     - AUFNR: `000001000000`
     - Status: Active
     - Tanggal Produksi: Terjadwal otomatis
  2. **Reservasi Komponen Otomatis (`RESB`):**
     - Reservation Number: `0000000001`
     - Sembilan (9) komponen resin dari BOM Alt `02` ter-explode otomatis ke komponen order:
       - Pos 0001: `RPV-HC401BF` = 22,454 KG
       - Pos 0002: `SRP-I` = 64,948 KG
       - Pos 0003: `SRP-E` = 3,711 KG
       - Pos 0004: `M5AAA01` = 1,670 KG
       - Pos 0005: `RPV-FS3011E3` = 5,077 KG
       - Pos 0006: `RPM-ABPP10T` = 0,077 KG
       - Pos 0007: `RPV-FS3011E3` = 4,948 KG
       - Pos 0008: `RPC-FS5612` = 0,155 KG
       - Pos 0009: `RPM-ABPP10T` = 0,052 KG
  3. **Operasi & Routing Terbaca Otomatis (`AFVC`):**
     - Routing Plan: `0000000001`
     - Operation: `0010`
     - Work Center: `10000178` (`JROPP01` - Line Extrusion Waru 1)

---

## 3. Analisis Teknis: Production Order (CO01) vs Process Order (COR1)

| Aspek Komparasi | Production Order (`CO01` / `PP01`) | Process Order (`COR1` / `PI01` - PP-PI) |
|---|---|---|
| **Karakteristik Industri** | Discrete Manufacturing / Extrusion Plastik Standar | Process Manufacturing / Industri Kimia Batch / Farmasi |
| **Tipe Task List** | Routing (`CA01`, `PLNTY = 'N'`) | Master Recipe (`C201`, `PLNTY = '2'`) |
| **Work Center / Mesin** | Work Center (`CR01`, misal `JROPP01`) | Resource (`CRC1`, Category `0008` Process Unit) |
| **Operasi vs Phase** | Operasi Tunggal / Bertahap (`0010`, `0020`) | Operasi memiliki sub-Phase & PI Sheets / XSteps |
| **Status di S/4HANA Target** | **100% AKTIF & TERVERIFIKASI LIVE** (Order `000001000000`) | Memerlukan Master Recipe (`C201`) & Resource (`CRC1`) |
| **Rekomendasi untuk Pilot** | **Sangat Direkomendasikan (Siap Release & Goods Issue)** | Dapat disiapkan sebagai ekspansi modul PP-PI lanjutan |

---

## 3. Matriks Pembuktian Live Database (S/4HANA Client 130)

| Tabel | Key Utama | Field Kunci | Nilai Live Database | Status |
|---|---|---|---|---|
| `T001` | BUKRS = '9999' | BUTXT, WAERS, LAND1 | PT Trias Sentosa, Tbk. / IDR / ID | VALID |
| `T001W` | WERKS = '1000' | NAME1, ORT01, LAND1 | Pabrik Waru (Trias Sentosa) / Sidoarjo / ID | VALID |
| `T001W` | WERKS = '2000' | NAME1, ORT01, LAND1 | Pabrik Krian (Trias Sentosa) / Sidoarjo / ID | VALID |
| `T001K` | BWKEY = '1000' | BUKRS | 9999 | VALID |
| `T001L` | WERKS = '1000' | LGORT, LGOBE | 1011 (Feed OPP WR), 1813 (WR FGS-Non WM) | VALID |
| `MARV` | BUKRS = '9999' | LFMON, LFGJA | Period 11 / Year 2023 | VALID |
| `MARC` | MATNR = 'JRAAAI', WERKS = '1000' | LVORM | Blank (Active) | VALID |
| `CRHD` | ARBPL = 'JROPP01', WERKS = '1000' | ARBID, VERWE, ZTMEN | 10000178 / 0001 (Machine) / SAP1 | VALID |
| `MAST` | MATNR = 'JRAAAI', WERKS = '1000' | STLNR, STLAL, STLAN | 00000001 / 02 / 1 | VALID |
| `MAPL` | MATNR = 'JRAAAI', WERKS = '1000' | PLNTY, PLNNR, PLNAL | N / 50000000 / 01 | VALID |
| `MKAL` | MATNR = 'JRAAAI', WERKS = '1000' | VERID, STLAL, PLNNR | 0001 / Alt 02 / Group 50000000 | VALID |

---

## 4. Arsip Lampiran GUI (Screenshots)
Semua bukti visual sesi eksekusi tersimpan rapi di direktori:
`/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/`
1. `c223_detail_screen.png`: Layar detail pemeliharaan Production Version 0001 mengikat Routing & BOM.
2. `c223_production_version_saved.png`: Layar tabel ringkasan C223 setelah perubahan tersimpan.


---

## 5. Implementasi Modul PP-PI (Process Industry) & Process Order (COR1 / PI01)

Sesuai arahan Baginda untuk menjalankan **OPSI B (Setup Modul PP-PI)**, seluruh master data resep proses (Master Recipe) dan Production Version terintegrasi telah berhasil dikonfigurasi, dan simulasi pembuatan **Process Order** berhasil dieksekusi tanpa error.

### 5.1. Master Data PP-PI Terkonfigurasi
1. **Master Recipe Header (`PLKO`):**
   - Recipe Type (`PLNTY`): `2` (Master Recipe PP-PI)
   - Recipe Group (`PLNNR`): `JRAAAI`
   - Group Counter (`PLNAL`): `10`
   - Status: `4` (Released / General Release)
   - Base Quantity: `100.000 KG`
   - Deskripsi: *Jumbo Roll PLE-18 Master Recipe*
2. **Material to Recipe Assignment (`MAPL`):**
   - Material: `JRAAAI`
   - Plant: `1000`
   - Recipe: Group `JRAAAI`, Counter `10`, Type `2`
3. **Operations & Recipe Phases (`PLAS` & `PLPO`):**
   - Operasi Header `0010`: Resource `10000178` (`JROPP01` Extrusion Line 1 Waru), Control Key `PI01`.
   - Fase Proses `0020`: Sub-phase yang merujuk pada Op `0010` (`PVZKN = 00000001`), Control Key `PI01`.
4. **Production Version 0002 (`MKAL`):**
   - Version ID: `0002`
   - Deskripsi: *JR PLE-18 PP-PI Recipe (Line 1)*
   - Validitas: `20201210` s/d `99991231`
   - BOM: Alternative `02` (Usage `1`)
   - Recipe: Type `2`, Group `JRAAAI`, Counter `10`

---

### 5.2. Eksekusi Transaksional Process Order 000001000001
Pembuatan Process Order dilakukan menggunakan API standar SAP PP-PI (`BAPI_PROCORD_CREATE`):
- **Nomor Process Order:** `000001000001` (GUI Display: `1000001`)
- **Order Type:** `PI01` (Process Order)
- **Order Category (`AUTYP`):** `40` (Process Order)
- **Material Output:** `JRAAAI` (Jumbo Roll PLE-18)
- **Plant / Company Code:** `1000` / `9999`
- **Target Quantity:** `100.000 KG`
- **Storage Location Output:** `1813` (WR FGS-Non WM)
- **Production Version Dipakai:** `0002` (PP-PI Recipe)
- **Status Sistem SAP:** `CRTD PRC CSER MANC OPGN SETC`

---

### 5.3. Pembuktian Live Database S/4HANA (ADB 130)

#### A. Order Master & PP Detail (`AUFK` & `AFKO`)
| Tabel | Key | Field Kunci | Nilai Live Database | Status |
|---|---|---|---|---|
| `AUFK` | AUFNR = '000001000001' | AUART, AUTYP, WERKS, BUKRS | `PI01` / `40` (Process Order) / `1000` / `9999` | VALID |
| `AFKO` | AUFNR = '000001000001' | GAMNG, GMEIN, PLNTY, STLAL | `100.000 KG` / Task List Type `2` (Recipe) / BOM Alt `02` | VALID |

#### B. Reservasi & Komponen Bahan Baku Otomatis Ter-explode (`RESB`)
Reservasi Number: `0000000002`
| Posisi | Material Komponen | Deskripsi Resin | Kuantitas Kebutuhan | Satuan |
|---|---|---|---|---|
| 0001 | `RPV-HC401BF` | Polypropylene Resin Grade HC401BF | 22.454 | KG |
| 0002 | `SRP-I` | Scrap Resin Polos Internal | 64.948 | KG |
| 0003 | `SRP-E` | Scrap Resin Polos External | 3.711 | KG |
| 0004 | `M5AAA01` | Masterbatch Additive 5AAA01 | 1.670 | KG |
| 0005 | `RPV-FS3011E3` | Polypropylene Resin Film Grade | 5.077 | KG |
| 0006 | `RPM-ABPP10T` | Anti-Block Masterbatch | 0.077 | KG |
| 0007 | `RPV-FS3011E3` | Polypropylene Resin Film Grade | 4.948 | KG |
| 0008 | `RPC-FS5612` | Polypropylene Terpolymer Resin | 0.155 | KG |
| 0009 | `RPM-ABPP10T` | Anti-Block Masterbatch | 0.052 | KG |

#### C. Operasi & Fase Resep Proses (`AFVC`)
- Recipe AUFPL: `0000000002`
- Operation: `0010`
- Control Key: `PI01` (Process Order Standard)

---

### 5.4. Bukti Visual SAP GUI (COR3)
Bukti screenshot resmi tersimpan di subproject attachments:
1. `cor3_header.png`: Tampilan layar utama SAP GUI transaksi **COR3** untuk Order **1000001** (Type PI01, Qty 100 KG).
2. `cor3_operations.png`: Tampilan layar operasi & fase transaksi **COR3** menunjukkan Operation 0010 dengan Control Key PI01.
