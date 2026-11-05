# ZMMI_WMS — HU Stock with Characteristic for WMS

Tanggal: 30.10.2026 · Server kerja: sandbox-new (TRS) · Package `$TMP`

## Keputusan (Baginda, 30.10.2026)
1. Output ALV dan WMS.
2. 1 baris = stock line x isi HU (HU Box + HU Pallet). Pallet langsung berisi batch -> HU Box kosong.
3. Stok wajib dicek di MCHB / MSKA (qty > 0); Sloc & SO ikut stok terakhir (sama ZBMBC).
4. Parameter MAGRV: PLT -> turun ke box (VEPO VELIN 3 / UNVEL); BOX -> naik ke pallet (VEKP-UEVEL).
5. Created On: kebutuhan 1 hari; VEKP full scan.
6. Kolom & sumber data sama ZBMBC (17 kolom WMS).
7. Storage Bin sama ZBMBC (LQUA by MATNR WERKS CHARG, quant pertama).
8. 1 program tanpa include; styling performance: mass select di awal.

## Flow
1. `VEKP` WHERE `ERDAT IN S_ERDAT` (hint `VEKP~Z02`) -> DELETE `MAGRV NOT IN S_MAGRV`, DELETE `STATUS = '0060'` (Deleted).
2. `VEPO` FAE VENUM (`VEPO~0`) -> lower HU (`VELIN = '3'`, `UNVEL`) -> `VEKP` + `VEPO` FAE.
3. Higher HU: `VEKP-UEVEL` -> `VEKP` FAE (`VEKP~0`).
4. Isi batch (`VELIN = '1'`) -> HU Box (MAGRV BOX) / HU Pallet (MAGRV PLT).
5. `MARA` FAE MTART ZFGS/ZSFG; `MCHB` FAE (`MCHB~Z05`) & `MSKA` FAE (`MSKA~Z02`), qty > 0.
6. Preload sekali: VBAK, VBPA(AG)+ADRC, MSKU+KNA1, LQUA (`LQUA~Z01`), CABN (`CABN~1`), CAWNT (ZZCRITERIA), MCH1 (`MCH1~0`), AUSP (`AUSP~N3`).
7. Fill output via READ BINARY SEARCH -> ALV (CL_SALV_TABLE) / WMS (EXEC SQL, sama ZBMBC).

## Struktur HU PRD (cek read-only 29.10.2026)
- Pallet: VEPO `VELIN='3'`, `UNVEL` = box. Box: VEPO `VELIN='1'` = batch. Box `UEVEL` = pallet (200/200 sample).
- Ada pallet langsung berisi batch (`VELIN='1'`).
- VEKP 1 hari (29.10.2026): 2.008 HU, RFC_READ_TABLE 6,8 s (full scan, ~5,8 juta baris, VENUM max 5824142).

## Test
- TRS 01–31.12.2028, MAGRV PLT/BOX: 13 baris, 6,7 s. 13/13 identik dengan ZBMBC (Screen) di TRS untuk batch sama.
- WMS mode belum dites ke SQL (SP masih MERGE ON [Batch] saja -> error bila batch duplikat & target terisi).

## Index VEKP Created On (30.10.2026)
- Dibuat Baginda di dev: extension index `R3TR XINX VEKP Z02` (MANDT, ERDAT), package ZTRD, request TRDK924903 / task TRDK924904 (bersama ZMMI_WMS). Bukan modifikasi (SMODILOG kosong); DB dev RC=0.
- Index biasa (`LIMU INDX`) di tabel SAP -> task Repair + SMODILOG + SPDD saat upgrade; dihindari.
- Program: hint `INDEX("VEKP" "VEKP~Z02")`, MAGRV tetap DELETE di memori. TRS belum punya Z02 (hint diabaikan); smoke TRS tetap 13 baris.
- Import PRD: create index di ~5,8 juta baris -> jam sepi / ONLINE + statistik (DB20).

## Parameter HU Number (30.10.2026)
- `S_EXIDV FOR VEKP-EXIDV` (select-option); `S_ERDAT` tidak OBLIGATORY lagi (default tetap SY-DATUM).
- Validasi: Created On atau HU Number minimal 1 terisi (keduanya kosong -> pesan, EXIT).
- Boleh barengan (AND). HU Number terisi -> index `VEKP~C` (MANDT EXIDV), ERDAT jadi filter tambahan; HU kosong -> `VEKP~Z02`.
- Catatan: default Created On = hari ini; cari HU lama -> kosongkan Created On.
- Test TRS: HU saja (2 HU) 4 baris; HU + tanggal cocok 3 baris; HU + tanggal tidak cocok 0 baris; keduanya kosong -> pesan validasi.

## Unique batch sebelum insert SQL (03.11.2026, permintaan Rasyid)
- Hanya mode WMS. Mode Screen tetap semua baris.
- Key unik: CHARG (sesuai SP MERGE ON [Batch]).
- Aturan: 1) Sloc stok = Sloc isi HU (`VEPO-LGORT`); 2) masih double -> tanggal stok terbaru (MCHB `LAEDA`, kosong -> `ERSDA`; MSKA `ERSDA`); 3) masih sama -> baris pertama (urutan output, HU nomor terkecil).
- Form baru: `GT_HU_SLOC` (dari GT_VEPO, di akhir GT_HU), `GT_STOCK_DATE` (setelah GT_STOCK), `GT_UNIQUE_BATCH` (sebelum INSERT_SQL_WMS). Tambah field VEPO-LGORT, MCHB-ERSDA/LAEDA, MSKA-ERSDA ke SELECT yang sudah ada (tanpa SELECT baru).
- Test TRS (copy `ZMMI_WMS_TEST`, WMS -> ALV tanpa insert SQL), Created On 2000-2099, MAGRV BOX/PLT/TRS: Screen 50.885 baris (51 batch double) -> WMS 50.821 baris, 1 baris per batch. Baris batch tidak double identik 100%. Pilihan 51 batch double diverifikasi independen ke VEPO/MCHB/MSKA: 51/51 sesuai (`tests/verify_unique_batch_TRS.txt`).
