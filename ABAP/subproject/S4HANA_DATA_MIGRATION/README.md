# S4HANA_DATA_MIGRATION — Migrasi & Penyiapan Master Data SAP S/4HANA

| Atribut | Isi |
|---|---|
| Program utama | Migrasi Master Data PP/MM/CO |
| TCODE | SPRO, MM01, CS01, CA01, C223 |
| Modul | PP / MM / CO / FI / S4HANA |
| Server analisa | dev-aix (TRD, 192.168.2.8, Client 130) |
| Server write | S4-HANA (ADB, 192.168.1.199, Client 130) |
| Dokumen status | [CHECKPOINT.md](CHECKPOINT.md) |
| Terakhir diperbarui | 2026-11-18 |

## 1. Tujuan
Mempersiapkan fondasi konfigurasi Enterprise Structure dan migrasi Master Data manufaktur (Material, Work Center, BOM, Routing, Production Version) di SAP S/4HANA 1909 On-Premise mengacu pada blueprint sistem DEV AIX (TRD).

## 2. Isi Folder

| Folder | Isi |
|---|---|
| \src/\ | Program ABAP / BAPI loader / function modules pendukung migrasi |
| \scripts/\ | Skrip automasi data extraction & checking via MCP SAP / RFC |
| \docs/\ | Blueprint arsitektur, panduan SPRO, mapping data, checklist migrasi |
| \	ests/\ | Skrip verifikasi dan testing integritas data master |
| \outputs/\ | Dump data ekstraksi dari DEV AIX, template upload Excel, log migrasi |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/BLUEPRINT_ENTERPRISE_STRUCTURE.md](docs/BLUEPRINT_ENTERPRISE_STRUCTURE.md) | Blueprint lengkap Enterprise Structure Trias Sentosa untuk S/4HANA |
| [CHECKPOINT.md](CHECKPOINT.md) | Status checkpoint dan riwayat pengerjaan subproject |

## 4. Objek SAP Terkait

| Objek | Jenis | Keterangan |
|---|---|---|
| T001, T001W, T001K, T001L | Tabel Konfigurasi | Company Code, Plant, Valuation Area, Storage Location |
| T024E, T024W, TVKO, TVKWZ | Tabel Konfigurasi | Purchasing Org, Sales Org, Plant Assignment |
| T134, T134T | Tabel Konfigurasi | Material Types (ZFGS, ZSFG, ZRAW, ZPCK) |
| MARA, MARC, MARD, MBEW | Tabel Master Data | Material Master MM |
| CRHD, CRCA, CRCO | Tabel Master Data | Work Center PP |
| MAST, STKO, STPO | Tabel Master Data | Bill of Materials (BOM) PP |
| PLKO, PLPO, MAPL | Tabel Master Data | Routing PP |
| MKAL | Tabel Master Data | Production Version (Mandatory di S/4HANA) |
