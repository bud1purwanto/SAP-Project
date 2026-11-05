# Ringkasan compare ZMMI_WMS vs ZBMBC (03.11.2026)

| Sistem | Mode ZMMI_WMS | Parameter | Baris ZMMI | Identik 17 kolom | Beda |
|---|---|---|---|---|---|
| DEV (TRD) | Screen | Created On 03.11.2024-03.11.2026, BOX/PLT | 1.181 (batch unik semua) | 1.181 (100%) | 0 |
| TRS | Screen | Created On 2000-2099, BOX/PLT/TRS | 50.885 | 50.780 | 105 baris |
| TRS | WMS (unique batch, copy test tanpa insert SQL) | sama | 50.821 | 50.776 | 45 baris |

Baseline ZBMBC: Material SR*, semua plant, Screen. DEV 71.281 baris (367 s), TRS 81.666 baris (154 s).

## Kategori beda TRS
| Kategori | Screen | WMS | Penyebab |
|---|---|---|---|
| ZBMBC HU kosong, ZMMI terisi | 93 | 42 | ZBMBC syarat VEPO-LGORT/SOBKZ = stok; ZMMI match Material+Plant+Batch |
| HU beda | 11 | 2 | Batch di >1 HU. ZBMBC SELECT SINGLE (HU dengan VEPO-LGORT = Sloc stok); ZMMI Screen tampil semua HU, WMS ambil HU nomor terkecil |
| Storage Bin beda | 1 | 1 | Batch 0000036833 punya 3 quant LQUA: K1FO-INTR (+127,68 & -127,68, interim 922) dan K1F200111 (FH1). ZBMBC ambil quant pertama (K1FO-INTR), ZMMI ambil K1F200111 |

Contoh HU beda (WMS):
- 0000032966 Sloc 2810: HU 6000034017 (VEPO 2810, 2027) vs Box 1000033700/Pallet 6000030414 (VEPO Sloc kosong, SOBKZ W, 2017). ZBMBC 6000034017, ZMMI 1000033700/6000030414.
- 0000361856 Sloc 2810: HU 6000031129/31132 (Sloc kosong, W), 31133/31140 (2810). ZBMBC 6000031133, ZMMI 6000031129.
