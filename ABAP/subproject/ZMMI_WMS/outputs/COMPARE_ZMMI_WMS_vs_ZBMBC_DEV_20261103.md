# Compare ZMMI_WMS vs ZBMBC baseline (17 kolom WMS)

- Sistem: Development AIX (TRD)
- ZMMI_WMS parameter: Created On 03.11.2024-03.11.2026, MAGRV BOX/PLT, Screen
- ZMMI_WMS runtime SUBMIT: 0 s; baris ALV: 1181; baris material SR*: 1181
- Baseline ZBMBC: ZBMBC_ALV_DEV_20261103_SR_wms17.md (71281 baris, SR*)
- Key match: WERKS MATNR CHARG LGORT VBELN POSNR

## Ringkasan

- Baris ZMMI_WMS (SR*) ketemu key di ZBMBC: 1181
- Identik 17 kolom: 1181
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
| HU Box | 0 |  |
| HU Pallet | 0 |  |
| Customer Name | 0 |  |

## Key beda (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

## Batch tidak ada di baseline (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
