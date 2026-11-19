# Blueprint Konfigurasi Enterprise Structure SAP S/4HANA
**Referensi: Sistem DEV AIX (TRD Client 130) -> Target: S/4HANA (ADB Client 130)**

---

## 1. Ringkasan Eksekutif
Sebelum Master Data manufaktur (Material, Work Center, BOM, Routing, Production Version) dapat dibuat dan diuji coba di SAP S/4HANA, struktur organisasi (*Enterprise Structure*) dan konfigurasi dasar modul MM/PP/CO/FI harus siap.

Dokumen ini menyajikan parameter konfigurasi riil yang diekstrak langsung dari SAP DEV AIX (TRD) sebagai blueprint resmi untuk implementasi di SAP S/4HANA (ADB).

---

## 2. Struktur Finansial & Pengendalian (FI & CO)

### 2.1 Company Code (FI)
- **Tabel Acuan:** `T001`
- **T-Code SPRO:** `OX02` (Definisi) / `EC01` (Copy Template Org)

| Parameter | Nilai DEV AIX (TRD) | Rekomendasi S/4HANA (ADB) | Keterangan |
|---|---|---|---|
| Company Code (`BUKRS`) | `9999` | `9999` | Kode Perusahaan Utama |
| Company Name (`BUTXT`) | `PT Trias Sentosa, Tbk.` | `PT Trias Sentosa, Tbk.` | Nama Resmi Legal |
| City (`ORT01`) | `Sidoarjo` | `Sidoarjo` | Lokasi Kantor / Pabrik |
| Country (`LAND1`) | `ID` | `ID` | Indonesia |
| Currency (`WAERS`) | `IDR` | `IDR` | Mata Uang Dasar Pembukuan |
| Language (`SPRAS`) | `E` | `E` | English |
| Chart of Accounts (`KTOPL`) | `TSCA` | `TSCA` | Bagan Akun Standar Trias |
| Fiscal Year Variant (`PERIV`) | `K4` | `K4` | Jan-Des + 4 Periode Khusus |
| Credit Control Area (`KKBER`) | `TSCC` | `TSCC` | Pengendalian Kredit (USD) |

### 2.2 Controlling Area (CO)
- **Tabel Acuan:** `TKA01` (Definisi) & `TKA02` (Assignment BUKRS -> KOKRS)
- **T-Code SPRO:** `OX06` (Definisi) / `OX19` (Assignment)

| Parameter | Nilai DEV AIX (TRD) | Rekomendasi S/4HANA (ADB) | Keterangan |
|---|---|---|---|
| Controlling Area (`KOKRS`) | `TSCO` | `TSCO` | Trias Controlling Area |
| CoAr Name | Trias Controlling Area | Trias Controlling Area | Deskripsi |
| Currency Type | `20` | `20` | Controlling Area Currency |
| Currency (`WAERS`) | `USD` | `USD` | Mata Uang Operasional CO |
| Chart of Accounts (`KTOPL`) | `TSCA` | `TSCA` | Sinkron dengan FI |
| Assignment | `BUKRS 9999 -> TSCO` | `BUKRS 9999 -> TSCO` | Relasi Company Code ke CO |

---

## 3. Struktur Pabrik & Logistik (Logistics General / MM / PP)

### 3.1 Plants (Pabrik / Werk)
- **Tabel Acuan:** `T001W` (Definisi) & `T001K` (Assignment ke Company Code)
- **T-Code SPRO:** `OX10` (Definisi) / `EC02` (Copy Plant) / `OX18` (Assign ke BUKRS)

| Plant (`WERKS`) | Nama Pabrik (`NAME1`) | Valuation Area (`BWKEY`) | Company Code (`BUKRS`) | Factory Calendar (`FABKL`) | Val. Grouping Code (`BWMOD`) |
|---|---|---|---|---|---|
| `1000` | Waru | `1000` | `9999` | `ZT` (Trias Calendar) | `0002` |
| `2000` | Krian | `2000` | `9999` | `ZT` (Trias Calendar) | `0002` |

### 3.2 Storage Locations (Gudang / SLoc Kunci)
- **Tabel Acuan:** `T001L`
- **T-Code SPRO:** `OX09`

#### Plant 1000 (Waru):
- `1001`: SP Spare/St.Item (Sparepart Umum)
- `1011`: Feed OPP WR (Bahan Baku / Feed OPP)
- `1021` s/d `1023`: Feed OPP1, OPP2, OPP3
- `1041` s/d `1043`: Feed & Infeed COAT1
- `1051` s/d `1054`: Feed & Infeed MET1, MET2
- `1061` s/d `1063`: Feed & Infeed LAM
- `1151` s/d `1155`: Raw Recycle (OPP, COAT, MET, CPP, LAM)
- `1813`: FGS (Finished Goods Store)

#### Plant 2000 (Krian):
- `2001`: SP Spare/St.Item
- `2011` s/d `2013`: Feed & Input XLM1
- `2021` s/d `2024`: Feed OPP4, OPP5, OPP6, OPP7
- `2031` s/d `2032`: Feed PET1, PET2
- `2041` s/d `2048`: Feed & Input COAT2, COAT3
- `2051` s/d `205F`: Feed & Input MET3 s/d MET11
- `2061` s/d `2063`: Feed & Input LAM1
- `2071` s/d `2074`: Feed & Input TML1, TML2
- `2150` s/d `2157`: Raw Recycle (XLM, OPP, PET, COAT, MET, LAM, TML, SCM)
- `1813`: WR FGS (Non WM)

---

## 4. Struktur Pengadaan & Penjualan (Purchasing & Sales)

### 4.1 Purchasing Organizations (MM)
- **Tabel Acuan:** `T024E` (Definisi), `T024W` (Assign ke Plant), `T024` (Purchasing Groups)
- **T-Code SPRO:** `OX08` (Definisi) / `OX01` (Assign BUKRS) / `OX17` (Assign Plant)

| Pur. Org (`EKORG`) | Deskripsi (`EKOTX`) | Company Code (`BUKRS`) | Plants (`WERKS`) |
|---|---|---|---|
| `TPOL` | Trias Pur Org Local | `9999` | `1000`, `2000` |
| `TPOI` | Trias Pur Org Import | `9999` | `1000`, `2000` |
| `TSTO` | Trias Stock Trns Ord | `9999` | `1000`, `2000` |

*Purchasing Groups (`EKGRP`):* `P01` s/d `P07` (Buyer team).

### 4.2 Sales Organizations (SD)
- **Tabel Acuan:** `TVKO` (Definisi), `TVTW` (Distr Channel), `TSPA` (Division), `TVKWZ` (Assign ke Plant)
- **T-Code SPRO:** `OVX5` (Definisi) / `OVX6` (Assign Plant)

| Sales Org (`VKORG`) | Company Code (`BUKRS`) | Distribution Channels (`VTWEG`) | Assigned Plants (`WERKS`) |
|---|---|---|---|
| `1000` | `9999` | `00` (Internal), `01` (Domestik), `02` (Ekspor), `03` (Other) | `1000`, `2000` |

---

## 5. Tipe Material MM (Material Types)
- **Tabel Acuan:** `T134`, `T134T`
- **T-Code SPRO:** `OMS2`

| Material Type (`MTART`) | Deskripsi (`MTBEZ`) | Penggunaan di PP / MM |
|---|---|---|
| `ZFGS` | Finished Products | Produk Jadi hasil Slitting/Converting/Produksi Akhir |
| `ZSFG` | Semifinished Prod | Produk Antara (Jumbo Roll / Film Primer) |
| `ZRAW` | Raw Materials | Bahan Baku Resin (PP, PET, Additives, dll.) |
| `ZPCK` | Packaging Materials | Kemasan (Pallet, Core, Bubble Wrap, Box) |
| `ZRTP` | Returnable Pack | Pallet / Packaging yang dapat dikembalikan |
| `ZRSN` | Chemical | Bahan Kimia Coater / Primer |
| `ZNCM` | Non Chemical | Bahan Penolong Non-Kimia |
| `ZOPS` | Operating Supplies | Perlengkapan Operasional Pabrik |
| `ZSME`, `ZSEL`, `ZSGE` | Spareparts Mechanic / Electric / General | Suku Cadang Mesin & Fasilitas Pabrik |

---

## 6. Action Plan & Eksekusi di S/4HANA
1. **Pembuatan Customizing Transport Request (TR)** di S/4HANA (misal via SE09/SE10).
2. **Definisi Entity**:
   - Copy/create Company Code `9999` via `EC01` / `OX02`.
   - Setup Chart of Accounts `TSCA` & Fiscal Year Variant `K4`.
   - Setup Controlling Area `TSCO` via `OX06`.
   - Copy/create Plant `1000` & `2000` via `EC02` / `OX10`.
   - Setup Storage Locations via `OX09`.
   - Setup Purchasing Orgs (`TPOL`, `TPOI`, `TSTO`) via `OX08` & Sales Org `1000` via `OVX5`.
3. **Assignment (Relasi)**:
   - Assign Plants ke BUKRS 9999 (`OX18`).
   - Assign BUKRS 9999 ke Controlling Area TSCO (`OX19`).
   - Assign Purchasing Orgs ke BUKRS (`OX01`) dan ke Plants (`OX17`).
   - Assign Sales Org ke BUKRS & Plants (`OVX6`).
4. **Verifikasi Otomatis**:
   - Menjalankan skrip RFC check via MCP SAP untuk memvalidasi bahwa tabel `T001`, `T001W`, `T001K`, `T024E`, `TVKO`, dan `T134` di S/4HANA sudah terisi sesuai blueprint.
