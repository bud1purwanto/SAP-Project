# Compare ZBMBC WMS (Y_ZBMBCSR) vs ALV Screen baseline

- Baseline ALV: 52444 baris (outputs/ZBMBC_ALV_DEV_before_SR_full.csv)
- WMS Y_ZBMBCSR: 52444 baris (N=52444); runtime SUBMIT WMS:  s; ZBMBCSR_WMS count setelah SP: 71296
- Hasil: **ADA DIFFERENT**
- Baris hanya di ALV: 1; baris hanya di WMS: 1
- Key ALV tidak ada di WMS: 0; key WMS tidak ada di ALV: 0

## Selisih per kolom (key unik)

| Kolom | Jumlah beda | Contoh (key, ALV, WMS) |
|---|---|---|
| Storage Bin | 1 | (('1000', 'SRAH2I', '0000000260', '1801', '', '000000'), 'W1FO-INTR', 'W1F091422') |

## Hanya di ALV (max 50)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1000 | SRAH2I | MSL | 30.0 | 0000000260 | 1269 | 16500 |  | Second Grade | 1801 | W1FO-INTR |  | 000000 |  |  | 6000004371 |  |

## Hanya di WMS (max 50)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1000 | SRAH2I | MSL | 30.0 | 0000000260 | 1269 | 16500 |  | Second Grade | 1801 | W1F091422 |  | 000000 |  |  | 6000004371 |  |

