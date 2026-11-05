# Compare ZMMI_WMS vs ZBMBC baseline (17 kolom WMS)

- Sistem: Development AIX (TRD)
- ZMMI_WMS parameter: Created On 31.10.2024-31.10.2026, MAGRV BOX/PLT, Screen
- ZMMI_WMS runtime SUBMIT: 7 s; baris ALV: 1175; baris material SR*: 1175
- Baseline ZBMBC: ZBMBC_ALV_DEV_20261031_SR_wms17.md (71269 baris, SR*, capture 31.10.2026)
- Key match: WERKS MATNR CHARG LGORT VBELN POSNR

## Ringkasan

- Baris ZMMI_WMS (SR*) ketemu key di ZBMBC: 1175
- Identik 17 kolom: 1173
- Batch ada di ZBMBC tapi key beda (Sloc/SO berubah): 0
- Batch tidak ada di baseline ZBMBC: 0

## Selisih per kolom (baris yang key-nya match)

| Kolom | Beda | Contoh (Batch, ZBMBC, ZMMI_WMS) |
|---|---|---|
| Plant | 0 |  |
| Material No | 0 |  |
| Type | 0 |  |
| Thick | 0 |  |
| Batch | 0 |  |
| Width | 0 |  |
| Length | 0 |  |
| TipeAlias | 0 |  |
| CriteriaGrade | 0 |  |
| Sloc | 0 |  |
| Storage Bin | 0 |  |
| SO No | 0 |  |
| SO Item | 0 |  |
| Sales Doc Type | 0 |  |
| HU Box | 1 | 0000398281: `` vs `1000035210` |
| HU Pallet | 2 | 0000398217: `` vs `6000035713`; 0000398281: `` vs `6000035708` |
| Customer Name | 0 |  |

## Key beda (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

## Batch tidak ada di baseline (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

## Analisa (31.10.2026, setelah data dibenarkan)

- Batch 0000062481, 0000406157, 0000397787: HU sekarang status 0050 (posted GI), stok habis -> tidak muncul di ZBMBC maupun ZMMI_WMS (sama).
- Batch 0000402167: tidak ada stok -> tidak muncul di kedua program (sama).
- Sisa beda 2 batch, stok terbagi 2 Sloc, HU di VEPO Sloc 1305:

| Batch | Sloc stok | Unrest (Kg) | HU VEPO (Sloc) | ZBMBC | ZMMI_WMS |
|---|---|---|---|---|---|
| 0000398217 | 1305 | 440.400 | Pallet 6000035713 (1305) | 6000035713 | 6000035713 |
| 0000398217 | 1308 | 13.210 | - | kosong | 6000035713 |
| 0000398281 | 1305 | 1.000 | Box 1000035210 / Pallet 6000035708 (1305) | 1000035210 / 6000035708 | sama |
| 0000398281 | 1308 | 439.400 | - | kosong | 1000035210 / 6000035708 |

Penyebab: ZBMBC match HU dengan Sloc stok (VEPO-LGORT); ZMMI_WMS match MATNR WERKS CHARG saja. Menunggu keputusan Baginda.
