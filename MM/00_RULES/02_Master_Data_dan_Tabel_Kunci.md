# 02 — Master Data, Tabel Kunci & TCODE MM

> Peta master data, tabel utama, dan transaksi standar untuk modul MM.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Ruang Lingkup Modul MM
Master Data Material/Vendor/PIR/Source List, Procurement PR/PO/Outline Agreement, Inventory GR/GI/Transfer/Stock Opname, Logistics Invoice Verification (MIRO/MRBR), Account Determination OBYC.

---

## Tabel Kunci

| Tabel | Deskripsi | Field Kunci |
|---|---|---|
| `MARA` / `MAKT` | General Material Data / Description | MATNR, MTART, MATKL, MEINS, MAKTX |
| `MARC` / `MARD` | Plant Data for Material / Storage Location Data | MATNR, WERKS, LGORT, DISPO, EKGRP, LABST |
| `MBEW` | Material Valuation (harga & valuation class) | MATNR, BWKEY, BWTAR, VPRSV, VERPR, STPRS, BKLAS |
| `MCH1` / `MCHA` | Batches (lintas plant / per plant) | MATNR, CHARG, WERKS, LICHA, VFDAT, HSDAT |
| `MCHB` | Batch Stocks per Storage Location | MATNR, WERKS, LGORT, CHARG, CLABS, CUMLM, CINSM, CEINM |
| `MKPF` / `MSEG` | Material Document Header / Segment (Movement) | MBLNR, MJAHR, BUDAT, CPUDT, BWART, MATNR, WERKS, LGORT, CHARG, MENGE, AUFNR, SMBLN |
| `EKKO` / `EKPO` | Purchase Order Header / Item | EBELN, BUKRS, BSTYP, BSART, LIFNR, FRGKE, FRGZU, EBELP, MATNR, WERKS, LGORT, MENGE, NETPR |
| `EKBE` | Purchasing Document History (GR / IR per PO) | EBELN, EBELP, ZEKKN, VGABE, GJAHR, BELNR, BUZEI, BWART, BUDAT, MENGE, DMBTR |
| `EBAN` | Purchase Requisition | BANFN, BNFPO, BSART, MATNR, WERKS, MENGE, BADAT, LFDAT, FRGKZ, EBELN |
| `LFA1` / `LFB1` | Vendor General Data / Company Code Data | LIFNR, NAME1, LAND1, BUKRS, AKONT, ZTERM |
| `RBKP` / `RSEG` | Invoice Receipt Header / Item (LIV) | BELNR, GJAHR, BLDAT, BUDAT, LIFNR, WAERS, RMWWR, EBELN, EBELP, WRBTR |
| `T156` / `T156T` | Movement Type Definition / Text | BWART, BTEXT |
| `T030` | Standard Accounts Table (OBYC Account Determination) | KTOPL, KTOSL, BWMOD, KOMOK, BKLAS, KONTS, KONTH |

---

## TCODE Standar MM

| Kategori | TCODE | Keterangan |
|---|---|---|
| Master Data | `MM01` / `MM02` / `MM03` | Create / Change / Display Material Master |
| Master Data | `XK01` / `XK02` / `XK03` | Vendor Master (Central) |
| Master Data | `ME11` / `ME12` / `ME13` | Purchasing Info Record (PIR) |
| Master Data | `ME01` / `ME03` | Maintain / Display Source List |
| Purchasing | `ME51N` / `ME52N` / `ME53N` | Purchase Requisition |
| Purchasing | `ME21N` / `ME22N` / `ME23N` | Purchase Order |
| Purchasing | `ME28` / `ME29N` | Release Purchase Order (Mass / Single) |
| Inventory | `MIGO` / `MB03` | Goods Movement (GR 101, GI 261, Transfer 311) |
| Inventory | `MMBE` / `MB52` / `MB5B` | Stock Overview / Warehouse Stock / Stock on Date |
| Inventory | `MB51` | Material Document List |
| Inventory | `MI01` / `MI04` / `MI07` | Physical Inventory (Create / Count / Post Diff) |
| Invoice | `MIRO` / `MIR4` / `MRBR` | Enter Invoice / Display / Release Blocked Invoice |
