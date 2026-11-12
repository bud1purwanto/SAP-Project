# 02 — Master Data, Tabel Kunci & TCODE QM

> Peta master data, tabel utama, dan transaksi standar untuk modul QM.
> Kembali ke [AGENTS.md](../AGENTS.md).

## Ruang Lingkup Modul QM
Master Data MIC/Sampling/Inspection Plan, Inspection Lot Generation (GR 101, Goods Issue, In-process), Results Recording (QE11), Usage Decision (QA11), Certificate of Analysis (COA - QC20/QC21).

---

## Tabel Kunci

| Tabel | Deskripsi | Field Kunci |
|---|---|---|
| `QALS` | Inspection Lot Record | PRUEFLOS, MATNR, WERKS, ART, CHARG, ENTMNG, STAT35 (UD), STAT02 (Release), VCODE |
| `QAPO` | Inspection Operations | PRUEFLOS, VORNR, ARBEIT, KATALG |
| `QAMV` | Characteristic Specifications in Inspection Lot | PRUEFLOS, VORNR, MERKNR, VERWMERKM, KURZTEXT, SOLLWERT, TOLERANZOB, TOLERANZUN |
| `QAMR` | Characteristic Results (Inspection Lot) | PRUEFLOS, VORNR, MERKNR, MITTELWERT, ANZWERTE, SATZSTATUS |
| `QASE` | Single Results per Characteristic | PRUEFLOS, VORNR, MERKNR, PROBEMNR, EINZELWERT |
| `QAVE` | Usage Decision Data | PRUEFLOS, VCODE, VBEWERTUNG, VNAME, VDATUM, VZEIT |
| `QCVK` | Certificate of Analysis Header | VORLNR, VERSION, VKORG, VTWEG, MATNR, KUNNR |
| `QCVM` | Certificate of Analysis Characteristics | VORLNR, VERSION, MERKNR, CHARG, MERKBEZ |
| `QCVV` | Certificate Characteristic Values / Mapping | VORLNR, VERSION, MERKNR, ORIGIN, FORMULA |
| `QPAC` | Inspection Method Selection | KATALOGART, CODEGRUPPE, CODE, KURZTEXT |
| `ZHMS_COA` / `ZMAP_TYPE` | Custom Trias COA Mapping & Configuration | PROG, MAP_KEY, CHAR_NAME, ALIAS |

---

## TCODE Standar QM

| Kategori | TCODE | Keterangan |
|---|---|---|
| Master Data | `QS21` / `QS23` | Create / Display Master Inspection Characteristic (MIC) |
| Master Data | `QP01` / `QP03` | Create / Display Inspection Plan |
| Inspection Lot | `QA01` / `QA02` / `QA03` | Create / Change / Display Inspection Lot |
| Inspection Lot | `QA32` / `QA33` | Inspection Lot Selection / Worklist |
| Results | `QE11` / `QE12` / `QE13` | Record / Change / Display Results per Inspection Lot |
| Results | `QE51N` | Results Recording Worklist |
| Usage Decision | `QA11` / `QA12` / `QA13` | Record / Change / Display Usage Decision (UD) |
| Certificate | `QC20` / `QC21` / `QC22` | Quality Certificate for Delivery / Insp Lot |
| Certificate | `QC01` / `QC02` / `QC03` | Certificate Profile (COA Layout & Characteristics) |
