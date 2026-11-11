# Compare ZMMI_WMS vs ZBMBC baseline (17 kolom WMS)

- Sistem: DEV (TRD-AIX)
- ZMMI_WMS parameter: DEV setelah deploy Ref 003, Created On 2000-2099, BOX/PLT, Screen
- ZMMI_WMS runtime SUBMIT: 126 s; baris ALV: 52745; baris material SR*: 52745
- Baseline ZBMBC: ZBMBC_ALV_DEV_20261111_wms17.md (71298 baris, SR*)
- Key match: WERKS MATNR CHARG LGORT VBELN POSNR

## Ringkasan

- Baris ZMMI_WMS (SR*) ketemu key di ZBMBC: 52745
- Identik 17 kolom: 52734
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
| HU Box | 4 | 0000361572: `1000034120` vs ``; 0000361956: `1000034342` vs ``; 0000361756: `1000034078` vs ``; 0000361757: `1000034079` vs `` |
| HU Pallet | 7 | 0000361572: `6000035390` vs `6000031230`; 0000361956: `6000035390` vs `6000031590`; 0000362622: `6000035390` vs `6000031605`; 0000361856: `6000031133` vs `6000031140`; 0000361637: `6000035390` vs `6000031117` |
| Customer Name | 0 |  |

## Key beda (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

## Batch tidak ada di baseline (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
