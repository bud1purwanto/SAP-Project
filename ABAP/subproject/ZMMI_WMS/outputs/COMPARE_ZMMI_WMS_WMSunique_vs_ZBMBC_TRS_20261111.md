# Compare ZMMI_WMS vs ZBMBC baseline (17 kolom WMS)

- Sistem: sandbox-new (TRS)
- ZMMI_WMS parameter: TRS, Created On 2000-2099, BOX/PLT/TRS, mode WMS (copy test tanpa insert SQL), setelah patch 003
- ZMMI_WMS runtime SUBMIT: 13 s; baris ALV: 50821; baris material SR*: 50821
- Baseline ZBMBC: ZBMBC_ALV_TRS_20261111_wms17.md (81666 baris, SR*)
- Key match: WERKS MATNR CHARG LGORT VBELN POSNR

## Ringkasan

- Baris ZMMI_WMS (SR*) ketemu key di ZBMBC: 50821
- Identik 17 kolom: 50820
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
| Storage Bin | 1 | 0000036833: `K1FO-INTR` vs `K1F200111` |
| SO No | 0 |  |
| SO Item | 0 |  |
| Sales Doc Type | 0 |  |
| HU Box | 0 |  |
| HU Pallet | 0 |  |
| Customer Name | 0 |  |

## Key beda (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

## Batch tidak ada di baseline (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
