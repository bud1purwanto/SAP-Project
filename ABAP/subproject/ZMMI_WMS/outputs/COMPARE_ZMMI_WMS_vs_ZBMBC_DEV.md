# Compare ZMMI_WMS vs ZBMBC baseline (17 kolom WMS)

- Sistem: Development AIX (TRD)
- ZMMI_WMS parameter: Created On 30.10.2024-30.10.2026, MAGRV BOX/PLT, ALV
- ZMMI_WMS runtime SUBMIT: 1 s; baris ALV: 1182; baris material SR*: 1182
- Baseline ZBMBC: ZBMBC_ALV_DEV_before_SR_wms17.md (71296 baris, SR*, capture 28.10.2026)
- Key match: WERKS MATNR CHARG LGORT VBELN POSNR

## Ringkasan

- Baris ZMMI_WMS (SR*) ketemu key di ZBMBC: 1182
- Identik 17 kolom: 1175
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
| HU Pallet | 7 | 0000062481: `6000030206` vs `6000036514`; 0000406157: `` vs `6000036489`; 0000062481: `6000018897` vs `6000036514`; 0000402167: `` vs `6000036182`; 0000397787: `` vs `6000035547` |
| Customer Name | 0 |  |

## Key beda (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

## Batch tidak ada di baseline (max 30)

| Plant | Material No | Type | Thick | Batch | Width | Length | TipeAlias | CriteriaGrade | Sloc | Storage Bin | SO No | SO Item | Sales Doc Type | HU Box | HU Pallet | Customer Name | ZBMBC (Sloc/SO/HU Box/HU Pallet) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|

## Analisa 7 baris beda HU (cek VEPO/VEKP dev, 30.10.2026)

ZBMBC `GT_HU`: SELECT SINGLE VEPO+VEKP dengan MATNR CHARG WERKS **LGORT = sloc stok** dan **SOBKZ = SOBKZ stok**, tanpa filter tanggal/status.
ZMMI_WMS: HU dari VEKP Created On, match isi VEPO hanya MATNR WERKS CHARG (tanpa LGORT/SOBKZ), status 0060 dibuang.

| Batch | Stok (Sloc/SOBKZ) | HU di VEPO (Sloc/SOBKZ, HU, ERDAT) | ZBMBC | ZMMI_WMS | Penyebab |
|---|---|---|---|---|---|
| 0000062481 | 2810/E | 2810/E 6000030206 (2017, status 0010); blank/E 6000036514 (30.10.2026) | 6000030206 | 6000036514 | HU baru dibuat 30.10.2026 (setelah baseline 28.10); ZMMI hanya ambil HU 2 tahun |
| 0000062481 | 2813/E | (HU 6000018897 sudah tidak ada di VEPO) | 6000018897 | 6000036514 | Data HU berubah setelah baseline + ZMMI tanpa match Sloc |
| 0000406157 | 2810/E | 3817/E 6000036489 | kosong | 6000036489 | Sloc VEPO beda dengan sloc stok |
| 0000402167 | 2802/E | 2802/blank 6000036182 | kosong | 6000036182 | SOBKZ VEPO kosong, stok E |
| 0000397787 | 2054/- | 2055/- 6000035547 | kosong | 6000035547 | Sloc VEPO beda |
| 0000398217 | 1308/E | 1305/E 6000035713 | kosong | 6000035713 | Sloc VEPO beda |
| 0000398281 | 1308/- | 1305/- Box 1000035210 di Pallet 6000035708 | kosong | 1000035210 / 6000035708 | Sloc VEPO beda |
