# Mapping COA Group — Batch List (draft migrasi)

Sumber: gambar mapping user (DOM-G / DOM-01 / DOM-02) dicocokkan dengan isi `ZQM_COA_CUST_COL` saat ini
(Development AIX & sandbox-new, 2026-11-11). Nomor customer dari `KNA1` **Production AIX** (2026-11-11).

> Catatan: KUNNR di non-prod (sandbox/QA) tidak selalu sama dengan PRD (mis. 1141000697 di QA = Penjalindo, di PRD = Indoprinting). Pakai nomor PRD di bawah ini.

Target tabel:
- `ZMAP_COA_GRP_COL` (`COA_GRP`, `FIELD_NAME`, `FIELD_LABEL`, `SEQ_NO`, `COL_SIZE`, `ACTIVE`)
- `ZMAP_COA_GRP_CST` (`KUNNR`, `COA_GRP`)

## 1. Kolom per group (`ZMAP_COA_GRP_COL`)

### DOM-G — General (default, pengganti `DOMESTIC` / `DOM_DEFAUL`)

| SEQ | FIELD_NAME | FIELD_LABEL | SIZE |
|---|---|---|---|
| 01 | HU_NUMBER | No Palet / HU | M |
| 02 | TYPE | Type | S |
| 03 | ROLL_NUMBER | Roll Number | L |
| 04 | WIDTH | Width (mm) | S |
| 05 | LENGTH | Length (m) | S |
| 06 | WEIGHT_PER_ROL | Weight (kg) | S |

### DOM-01

| SEQ | FIELD_NAME | FIELD_LABEL | SIZE |
|---|---|---|---|
| 01 | TYPE | Type | S |
| 02 | ROLL_NUMBER | Roll Number | L |
| 03 | BATCH_NUMBER | Batch Number | M |
| 04 | WIDTH | Width (mm) | M |
| 05 | LENGTH | Length (m) | M |
| 06 | WEIGHT_PER_ROL | Weight per rol (kg) | M |
| 07 | EXPIRED_DATE | Expired Date | M |
| 08 | PRODUCTION_DATE | Production Date | M |

### DOM-02 — Gudang Garam

| SEQ | FIELD_NAME | FIELD_LABEL | SIZE |
|---|---|---|---|
| 01 | DO_NUMBER | DO Number | M |
| 02 | PO_NUMBER | PO Number | L |
| 03 | HU_NUMBER | HU Number | M |
| 04 | TYPE | Type | S |
| 05 | ROLL_NUMBER | Roll Number | L |
| 06 | WIDTH | Width | M |
| 07 | LENGTH | Length | M |
| 08 | WEIGHT_PER_ROL | Weight per rol | M |
| 09 | GG_PART_NUMBER | GG Part Number (OPR) | L |
| 10 | EXPIRED_DATE | Expired Date | M |
| 11 | PRODUCTION_DATE | Production Date | M |

### EXP-G — General export (default DO ZELF, pengganti `EXPORT`)

| SEQ | FIELD_NAME | FIELD_LABEL | SIZE |
|---|---|---|---|
| 01 | NO_PALET | No Palet | M |
| 02 | TYPE | Type | S |
| 03 | HU_NUMBER | HU Number | M |
| 04 | ROLL_NUMBER | Roll Number | L |
| 05 | BATCH_NUMBER | Batch Number | M |
| 06 | WIDTH | Width | M |
| 07 | LENGTH | Length | M |

### EXP-01

| SEQ | FIELD_NAME | FIELD_LABEL | SIZE |
|---|---|---|---|
| 01 | NO_PALET | No Palet | M |
| 02 | TYPE | Type | S |
| 03 | ROLL_NUMBER | Roll Number | L |
| 04 | BATCH_NUMBER | Batch Number | M |
| 05 | WIDTH | Width | M |
| 06 | LENGTH | Length | M |
| 07 | WEIGHT_PER_ROL | Weight per rol | M |
| 08 | JOINT | Joint | S |
| 09 | NUMBER_OF_JOINT | Number of Joint (Splice) | S |
| 10 | TOTAL_ROLL | Total Rol | M |
| 11 | TOTAL_WEIGHT_PALET | Total Weight per palet | M |

`NUMBER_OF_JOINT` adalah field baru (2026-11-11): jumlah karakteristik splice 1–3 yang terisi pada batch (0–3).


## 2. Customer per group (`ZMAP_COA_GRP_CST`) — KUNNR PRD

### DOM-01 (34 KUNNR)

| Customer (gambar) | KUNNR | Nama KNA1 PRD | Catatan |
|---|---|---|---|
| Bintang Indah Gemilang | 1141000040 | BINTANG INDAH GEMILANG, PT. |  |
| Buana Chandra Mandiri | 1141001105 | PT. BUANA CHANDRA MANDIRI |  |
| Canopus Konverta Industri | 1141000869 | PT. CANOPUS KONVERTA INDUSTRI |  |
| Canopus Konverta Industri | 1141000870 | PT. CANOPUS KONVERTA INDUSTRI |  |
| International Packaging Manufacturing | 1141000127 | INTERNATIONAL PACKAGING MANUFACTURI |  |
| International Packaging Manufacturing | 1141000945 | INTERNATIONAL PACKAGING MANUFACTURI |  |
| International Packaging Manufacturing | 1141001265 | INTERNATIONAL PACKAGING MANUFACTURI | Banten |
| Indofood | 1141000110 | INDOFOOD CBP SUKSES MAKMUR Tbk, PT. |  |
| Indofood | 1141000111 | INDOFOOD CBP SUKSES MAKMUR Tbk, PT. |  |
| Indofood | 1141000112 | INDOFOOD CBP SUKSES MAKMUR Tbk, PT. |  |
| Indofood | 1141000113 | INDOFOOD CBP SUKSES MAKMUR Tbk, PT. |  |
| Indoprinting Sukses Makmur | 1141000697 | PT. INDOPRINTING SUKSES MAKMUR |  |
| Induksarana Kemasindo | 1141000119 | PT. INDUK SHRAYA KEMASINDO | Nama KNA1 PRD: Induk Shraya |
| Induksarana Kemasindo | 1141001292 | PT. INDUK SHRAYA KEMASINDO | Bogor |
| Kalbe Farma | 1141000141 | KALBE FARMA TBK, PT. |  |
| Kalbe Farma | 1141000142 | KALBE FARMA TBK, PT. |  |
| Karunia Selaras Abadi | 1141000143 | KARUNIA SELARAS ABADI, PT. |  |
| Karunia Selaras Abadi | 1141000939 | KARUNIA SELARAS ABADI, PT. |  |
| Lawangmas Primapack Indonesia | 1141000165 | PT. LAWANGMAS PRIMAPACK INDONESIA |  |
| Lawangmas Primapack Indonesia | 1141000166 | LAWANGMAS PRIMAPACK, PT. |  |
| Lumina Packaging | 1141000345 | LUMINA PACKAGING, PT. |  |
| Supernova | 1141000295 | SUPERNOVA FLEXIBLE PACKAGING, PT. |  |
| Supernova | 1141000296 | PT. SUPERNOVA FLEXIBLE PACKAGING |  |
| Supernova | 1141000297 | PT. SUPERNOVA |  |
| Supernova | 1141000942 | PT. SUPERNOVA FLEXIBLE PACKAGING |  |
| Supernova | 1141001025 | PT. SUPERNOVA |  |
| Supernova | 1141001026 | PT. SUPERNOVA |  |
| Surya Multi Indopack | 1141000299 | SURYA MULTI INDOPACK, PT. |  |
| Surya Multi Indopack | 1141000940 | SURYA MULTI INDOPACK, PT. |  |
| Toppan Plasindo | 1141000226 | PT. TOPPAN PLASINDO LESTARI | Surabaya |
| Toppan Plasindo | 1141000310 | PT. TOPPAN PLASINDO LESTARI | Bekasi |
| Toppan Plasindo | 1141001112 | PT. TOPPAN PLASINDO LESTARI | Belum punya mapping kolom saat ini |
| Tri Sakti | 1141000391 | PT. TRI SAKTI PURWOSARI MAKMUR |  |
| Tri Sakti | 1141001296 | PT. TRI SAKTI PURWOSARI MAKMUR |  |

### DOM-02 (3 KUNNR)

| Customer (gambar) | KUNNR | Nama KNA1 PRD | Alamat |
|---|---|---|---|
| Gudang Garam | 1142000000 | PERUSAHAAN ROKOK TJAP GUDANG GARAM | Jl. Semampir II/1 (Kediri) |
| Gudang Garam | 1142000001 | PERUSAHAAN ROKOK TJAP GUDANG GARAM | Jl. Letjen Sutoyo 55 Medaeng, Waru |
| Gudang Garam | 1142000002 | PERUSAHAAN ROKOK TJAP GUDANG GARAM | Sumber Suko (Gempol) |

Di PRD tidak ada nama "Gudang Garam Grafika"; kemungkinan salah satu dari 3 KUNNR di atas. Ketiganya masuk DOM-02, jadi hasil print tetap benar.
Batch list 1 / Batch list 2 di gambar memakai kolom yang sama (1 set kolom DOM-02).

### Tidak dimasukkan

| KUNNR | Nama KNA1 PRD | Alasan |
|---|---|---|
| 1141000227 | PT. PLASINDO LESTARI | Bukan Toppan Plasindo |

### EXP-01 (28 KUNNR)

| Customer (gambar) | KUNNR | Nama KNA1 PRD |
|---|---|---|
| Achilles | 1141100299 | ACHILLES VEREDELT GmbH |
| Achilles | 1141100699 | ACHILLES FILMS GMBH |
| Bagdaco | 1141100394 | BACDACO |
| Huhtamaki | 1141100255 | HUHTAMAKI (THAILAND) LIMITED |
| Huhtamaki | 1141100239 | HUHTAMAKI (VIETNAM) LIMITED |
| Amcor Thailand | 1141100236 | AMCOR FLEXIBLES PHETCHABURI, CO., L |
| Amcor Thailand | 1141100264 | AMCOR FLEXIBLES CHONBURI CO., LTD |
| Amcor Thailand | 1141100502 | AMCOR FLEXIBLES BANGKOK (PUBLIC)CO. |
| Amcor Thailand | 1141100490 | AMCOR FLEXIBLES RAYONG CO., LTD. |
| Amcor Thailand | 1141100695 | AMCOR FLEXIBLES BANGKOK PCL |
| Thai KK | 1141100441 | THAI KK INDUSTRY CO., LTD |
| Yenom | 1141100208 | YENOM PTE. LTD. |
| Beiling | 1141100592 | BEILING ENTERPRISE CO., LTD. |
| Amcor Philipines | 1141100551 | AMCOR FLEXIBLES PHILIPPINES CORP. |
| Siam Nomura | 1141100181 | SIAM NOMURA, LTD |
| Primaplas | 1800000005 | PRIMAPLAS PTY LTD. (AU) |
| Primaplas | 1141100319 | PRIMAPLAS LTD (NZ) |
| Primaplas | 1141100353 | PRIMAPLAS PRIVATE LIMITED (SG) |
| Sanyo | 1600000053 | SANYO CORPORATION OF AMERICA |
| Sanyo | 1141100041 | SANYO CORPORATION OF AMERICA |
| UPM Raflatac | 1141100081 | UPM RAFLATAC (CHINA) CO., LTD |
| UPM Raflatac | 1141100082 | UPM RAFLATAC SDN BHD |
| UPM Raflatac | 1141100083 | UPM RAFLATAC PTY. LTD. (flag hapus KNA1) |
| UPM Raflatac | 1141100084 | UPM RAFLATAC SAS |
| Avery Dennison | 1141100603 | AVERY DENNISON KOREA LTD |
| Avery Dennison | 1141100280 | AVERY DENNISON ( THAILAND ) LTD., |
| Avery Dennison | 1141100311 | AVERY DENNISON MATERIALS SDN. BHD. |
| Avery Dennison | 1141100588 | AVERY DENNISON GUANGZHOU CO.,LTD. |

Tidak dimasukkan: 1141001094 PRIMAPLAST INDONESIA (bukan Primaplas), 1141100063 Amcor Flexibles China dan 1141000010 Amcor Flexibles Indonesia (tidak ada di gambar → ikut jenis DO: ZELF = EXP-G, lainnya = DOM-G).

## 3. Dampak terhadap data saat ini

- Semua KUNNR di atas yang sudah punya mapping kolom saat ini (layout 8 kolom) **identik dengan DOM-01** → print tidak berubah.
- KUNNR yang mapping-nya saat ini tidak aktif (1141000110, 1141000119, 1141000143, 1141000165, 1141000299, 1141000869, 1141000945, 1142000000) → setelah migrasi **berubah** dari default ke layout DOM-01/DOM-02 (sesuai gambar).
- Export mengikuti gambar kedua (EXP-G 7 kolom, EXP-01 11 kolom). Layout export lama (13 kolom, ada CORE dan LENGTH_OF_SPLICE) tidak dipakai lagi.
