# Compare ZMMI_WMS vs ZBMBC baseline (17 kolom WMS)

- Sistem: Development AIX (TRD)
- ZMMI_WMS parameter: TRS, Created On 2000-2099, MAGRV BOX/PLT/TRS, Screen
- ZMMI_WMS runtime SUBMIT: 13 s; baris ALV: 50885; baris material SR*: 50885
- Baseline ZBMBC: ZBMBC_ALV_TRS_20261103_SR_wms17.md (81666 baris, SR*)
- Key match: WERKS MATNR CHARG LGORT VBELN POSNR

## Ringkasan

- Baris ZMMI_WMS (SR*) ketemu key di ZBMBC: 50885
- Identik 17 kolom: 50780
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
| HU Box | 4 | 0000360069: `` vs `1000034124`; 0000032966: `` vs `1000033700`; 0000354321: `` vs `1000034081`; 0000366715: `` vs `1000034597` |
| HU Pallet | 104 | 0000129561: `` vs `6000012246`; 0000240416: `` vs `6000021088`; 0000308383: `` vs `6000031054`; 0000308397: `` vs `6000031054`; 0000308404: `` vs `6000031054` |
| Customer Name | 0 |  |

## Key beda (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

## Batch tidak ada di baseline (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
