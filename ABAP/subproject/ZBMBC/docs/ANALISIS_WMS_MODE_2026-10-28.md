# Analisis — ZBMBC Execution Type "WMS" (2026-10-28)

Sumber request: email Rasyid Febriansah "RE: Terjadi kesalahan Pengiriman Barang" (28-10-2026).
Server analisis: `sandbox-new` (TRS). Source identik dengan `Development AIX` (TRD) — diff 0.

## Objek

| Objek | Baris | Isi |
|---|---|---|
| `ZBAP_STOCK_BY_CHAR1` (T-Code `ZBMBC`) | 146 | Event: INITIALIZATION, AT SELECTION-SCREEN (OUTPUT), START-OF-SELECTION |
| `ZBAP_STOCK_BY_CHAR1_TOP` | 453 | Tipe `TYPES_ZBMBC`, selection screen, radio `LRB1` (Screen) / `LRB2` (OLAP), FORM `CONNECT_SQL` |
| `ZBAP_STOCK_BY_CHAR1_F01` | 2397 | `GT_DATA`, `GT_HU`, `INSERT_SQL`, `SET_ALV`, enrichment forms |

Snapshot: `outputs/*_sandbox-new.abap`, `outputs/*_dev.abap`.

## Mapping Kolom WMS → Field Internal

| Kolom WMS | Field `IT_ZBMBC` | Sumber |
|---|---|---|
| Plant | WERKS | MCHB/MSKA/MSKU/MSLB |
| Material No | MATNR | idem |
| Type | ZZTYPE | AUSP (query char #1) |
| Thick | ZZTHICKNESS | AUSP #1 |
| Batch | CHARG | base select |
| Width | ZZWIDTH | AUSP #1 |
| Length | ZZLENGTH | AUSP #1 |
| TipeAlias | ZZALIAS | AUSP #1 |
| Crit.Grade | ZZCRITERIA (perlu konfirmasi, bukan ZZGRADE) | AUSP+CAWN+CAWNT (query char #2) |
| Sloc | LGORT | base select |
| Storage Bin | LGPLA | LQUA (per baris) |
| SO No / SO Item | VBELN / POSNR | MSKA |
| Sales Doc Type | AUART | VBAK (loop per VBELN) |
| HU Box | HUBOX | `GT_HU 'BOX'` (VEPO+VEKP) |
| HU Pallet | HUPLT | `GT_HU 'PLT'` (VEPO+VEKP, fallback UNVEL) |
| Customer Name | NAME1 | VBPA+ADRC (SO) / KNA1+MSKU (consignment) |

## Step `GT_DATA` — Dipakai vs Di-skip untuk WMS

| Step | Baris F01 | WMS |
|---|---|---|
| `SET_ATINN` | 107 | Pakai |
| Filter MARA ZFGS/ZSFG, Combination No | 111–162 | Pakai |
| Base select MCHB / MSKA(+VBUP) / MSKU | 164–318 | Pakai (row set wajib sama dengan OLAP) |
| AUART per SO | 236–248, 322–334 | Pakai |
| MSLB collect | 364–396 | Pakai (row set sama) |
| Delete filter selection screen | 491–509 | Pakai |
| LQUA LGPLA | 529 | Pakai |
| GT_HU BOX + PLT + ALPHA_OUTPUT | 535–557 | Pakai |
| AUSP char #1 (13 ATINN) | 581–590 | Kurangi → TYPE, THICKNESS, WIDTH, LENGTH, ALIAS (+COMBNO bila S_ATWRT7 diisi) |
| AUSP+CAWN+CAWNT char #2 (8 ATINN) | 592–606 | Kurangi → CRITERIA (+CORE/CORETYPE/TREATMENT bila S_ATWRT5/6 diisi) |
| LROLL/IROLL/BROLL/EINMEROLL | 673–687 | Pakai (assignment memori, murah) |
| BEZEI (TVAGT+VBAP) | 691–697 | **Skip** |
| NAME1 | 699–709 | Pakai |
| `Z_GET_PRODUCTION_DATE` + DEXDT + PDATE | 712–723 | **Skip** (FM per baris) |
| LICHA (MCH1) | 727–728 | **Skip** |
| Post-filter char S_ATWRT1–7 | 732–762 | Pakai |
| GET_TOYOBO / GET_KTNG / GET_SUBCONTRACTING | 781–791 | **Skip** (paksa, abaikan checkbox) |
| F_GETCOREID | 795 | **Skip** |
| GET_PRODUCTGROUP | 799 | **Skip** (catatan: juga isi DLTIME) |
| Barrier Judgement / HU & Batch QA Reason + filter | 803–824 | **Skip** |

Hemat per baris: 1 FM + 2 SELECT SINGLE + kolom AUSP lebih sedikit. Hemat global: 5–7 FORM enrichment.

## Risiko Ditemukan di Program Utama

`START-OF-SELECTION` memakai logika negatif:

```abap
IF LRB1 IS INITIAL.        " dianggap OLAP
  ... CONNECT_SQL / INSERT_SQL
ELSEIF LRB2 IS INITIAL.    " dianggap Screen
```

Jika radio `LRB3` ditambah tanpa ubah blok ini, pilihan WMS (LRB1 & LRB2 kosong) akan masuk cabang OLAP
dan **menghapus serta menulis ulang tabel `XZBMBC` di SQL OLAP**. Blok ini wajib diubah ke cek positif.

Hal yang sama di `AT SELECTION-SCREEN OUTPUT`: field DBCO (`MODIF ID CON`) hanya aktif saat `LRB2`.

## Rancangan Perubahan Minimal (belum diterapkan)

1. TOP: tambah `PARAMETER LRB3 RADIOBUTTON GROUP LBR.` + comment `TXT21 = 'WMS'`.
2. Main: `START-OF-SELECTION` ubah ke `IF LRB2 = 'X' ... ELSEIF LRB3 = 'X' ... ELSE (Screen)`.
   Cabang Screen dan OLAP tetap memanggil form yang sama persis.
3. Main: `AT SELECTION-SCREEN OUTPUT` aktifkan grup CON untuk `LRB2` atau `LRB3`.
4. F01 `GT_DATA`: bungkus step "Skip" dengan `IF LRB3 IS INITIAL. ... ENDIF.`;
   query char #1/#2 pakai `IF LRB3 = 'X'. <versi ringkas> ELSE. <asli> ENDIF.`
   Jalur Screen/OLAP tidak berubah secara logika.
5. F01: form baru `INSERT_SQL_WMS` (17 kolom) ke tabel target WMS. Form `INSERT_SQL` lama tidak disentuh.

Estimasi diff: ±60–90 baris tambahan, 2 statement existing diubah (IF di START-OF-SELECTION dan OUTPUT).

## Keputusan Baginda (2026-10-28)

1. DBCO: `WMS` (MSS). Ada di TRD, **belum ada di TRS** → uji insert di sandbox-new butuh DBCO `WMS` dibuat di TRS (Basis) atau uji di TRD.
2. Pola tulis: staging table + Stored Procedure MERGE (lihat bawah).
3. Crit.Grade = `ZZCRITERIA`.
4. Mode WMS hanya kirim ke SQL, tanpa ALV.
5. Authorization WMS = `Z_OLAP` (sama dengan OLAP).
6. Parameter selection screen tetap; WMS murni turunan data ZBMBC.
7. `DLTIME` ditambahkan ke output WMS (diisi langsung di jalur WMS, bukan via GET_PRODUCTGROUP).

## Pola Tulis Staging + SP MERGE

Alur:
1. SAP `DELETE FROM <staging> WHERE RUN_ID = :run_id` (bukan full delete).
2. SAP insert baris ke staging + kolom `RUN_ID`, lalu `COMMIT`.
3. SAP `EXECUTE PROCEDURE <sp_merge> ( IN :run_id )`.
4. SP: MERGE staging → tabel WMS dalam 1 transaksi SQL, lalu hapus baris staging run tsb.

Alasan dibanding pola OLAP sekarang (`DELETE FROM XZBMBC` lalu insert per baris):
- Selama jeda delete→insert, WMS baca tabel kosong/parsial → PDA bisa dapat "no data". Dengan MERGE, tabel WMS tidak pernah kosong.
- Gagal di tengah insert tidak merusak tabel WMS; hanya staging yang kotor.

Syarat penting SP MERGE:
- `WHEN NOT MATCHED BY SOURCE THEN DELETE` wajib dibatasi ke scope run (Plant/Material yang dikirim). Tanpa batas, run parsial (mis. 1 material) menghapus data material lain.
- `RUN_ID` mencegah 2 run paralel (job + manual) saling timpa di staging.
- Key MERGE usulan: MATNR, WERKS, LGORT, CHARG, SOBKZ, VBELN, POSNR (granularitas baris ZBMBC).
- Kepemilikan tabel staging, tabel WMS, dan SP: tim WMS (Rasyid). Kontrak nama kolom perlu disepakati.

## Pertanyaan Terbuka (sisa)

1. Nama tabel staging, tabel WMS, SP, dan urutan kolom (dari tim WMS).
2. DBCO `WMS` di TRS: dibuat oleh Basis, atau uji koneksi dilakukan di TRD.

## Pertanyaan Awal (sudah dijawab)

1. Target WMS: DBCO name + nama tabel SQL WMS + urutan/nama kolom. DBCO WMS belum ada di TRS
   (yang ada: TRIASDB..TRIASDB04, ERP, DB01, dll).
2. Strategi tulis: full replace (`DELETE FROM` lalu insert, seperti OLAP) atau delete per Plant/Material?
3. Crit.Grade = `ZZCRITERIA` (label ALV "Criteria") atau `ZZGRADE`?
4. Mode WMS hanya kirim ke SQL, atau juga tampil ALV?
5. Authorization: WMS pakai object `Z_OLAP` seperti radio OLAP?
6. Refresh manual by HU Pallet / Created Date HU (usulan email poin 3) — masuk scope sekarang atau fase berikut?
   Saat ini Material `OBLIGATORY`, tidak ada filter HU.
7. Timestamp download (`DLTIME`) dibutuhkan WMS? Saat ini diisi di `GET_PRODUCTGROUP` yang akan di-skip.

## Catatan Performa — Index (diverifikasi 2026-10-28)

Sumber: DDIC `DD12L`/`DD17S` (TRD) + cek fisik `DB_EXISTS_INDEX` di DB TRS (temp program read-only).

| Akses per baris | WHERE | Index terpakai | Fisik TRS |
|---|---|---|---|
| GT_HU #1 VEPO⋈VEKP | VEPO MATNR, CHARG, WERKS, LGORT, SOBKZ + VEKP MAGRV | VEPO~Z02 (WERKS, LGORT, MATNR, CHARG); VEKP via PK VENUM | Ada |
| GT_HU #2 VEPO (fallback PLT) | MATNR, CHARG, WERKS, LGORT | VEPO~Z02 / Z01 (CHARG) | Ada |
| GT_HU #3 VEKP⋈VEPO | VEPO UNVEL + VEKP MAGRV | VEPO~A (MANDT, UNVEL); VEKP via PK | Ada |
| LQUA LGPLA | MATNR, WERKS, CHARG | LQUA~Z01 (MANDT, MATNR, WERKS, CHARG) | Ada |
| AUSP⋈MCH1 | MCH1 MATNR+CHARG, AUSP OBJEK | MCH1 PK, AUSP PK prefix OBJEK | PK |
| VBPA⋈ADRC (NAME1) | VBELN, PARVW | VBPA PK prefix | PK |
| KNA1⋈MSKU (NAME1) | MSKU MATNR, WERKS, CHARG | MSKU PK prefix | PK |
| VBAK AUART | VBELN | PK | PK |

Koreksi analisis awal: **GT_HU tidak full table scan.** VEPO~M (standar) memang tidak dibuat di DB
(`DBSTATE = O`, RC=4), tetapi custom index VEPO~Z02 menutup kombinasi field yang sama.
Biaya GT_HU berasal dari jumlah panggilan (2–3 SELECT SINGLE per baris), bukan dari scan.
Index fisik di TRD/PRD belum dicek langsung (FM tidak RFC-enabled; cek SE11 > Database Object > Check atau DB02).

## Transport

Perubahan menyentuh 3 include (main, TOP, F01) → 1 TR. Program dipakai semua user: uji regresi Screen & OLAP
(bandingkan isi `XZBMBC` sebelum/sesudah) wajib sebelum release ke PRD.

## Status Patch — sandbox-new (TRS) 2026-10-28

Di-push via `Z_RFC_PROGRAM_UPDATE` ($TMP). `SYNTAX-CHECK` program utama: OK. Re-fetch live == `src/`.

| Objek | Perubahan |
|---|---|
| `ZBAP_STOCK_BY_CHAR1_TOP` | Radio `LRB3` + comment `TXT21` (+5 baris) |
| `ZBAP_STOCK_BY_CHAR1` | Label `TXT21 = 'WMS'`; hide `LRB3` tanpa auth `Z_OLAP`; field DBCO Name (grup CON) tampil untuk WMS, wajib diisi; cabang `IF LRB3 = 'X'. PERFORM INSERT_SQL_WMS.` sebelum cabang OLAP |
| `ZBAP_STOCK_BY_CHAR1_F01` | `GT_DATA`: char #1 6 ATINN & char #2 4 ATINN saat WMS; skip BEZEI; `CONTINUE` sebelum `Z_GET_PRODUCTION_DATE`/LICHA; `EXIT` setelah `SORT` (skip TOYOBO/KTNG/SUBCON/COREID/PRODUCTGROUP/Barrier/QA Reason). Form baru `INSERT_SQL_WMS` |

`INSERT_SQL_WMS`: DBCO dari input `S_CONN` (contoh: `WMS`) → `DELETE FROM Y_ZBMBCSR` → insert 17 kolom sesuai urutan tim WMS → `COMMIT` →
`EXECUTE PROCEDURE dbo.SP_Merge_ZBMBCSR_WMS` → `COMMIT`. Error native SQL → `ROLLBACK`.

Rollback: `outputs/*_sandbox-new_backup_before_wms.abap`.

Belum final:
- Nama SP final dari tim WMS: `[dbo].[SP_Merge_ZBMBCSR_WMS]` (dikonfirmasi 28.10.2026).
- `DLTIME` tidak dikirim: tabel `Y_ZBMBCSR` tidak punya kolom timestamp.
- Staging tanpa `RUN_ID` (sesuai struktur tabel) → run paralel job + manual bisa saling timpa staging.
- Bracket identifier `[Material No]` di Native SQL belum diuji runtime; uji di TRD (DBCO `WMS` ada di sana).

## Update 28.10.2026 — Preload CAWNT (pola ZPPR_BARRIER_PROD_LIST), hanya WMS

Dasar: SAT di PRD (TRP, ZBMBC) -> `DB: Fetch MCH1` (SELECT MCH1+AUSP+CAWN+CAWNT per baris) 6.06 s / 48% runtime, 2958 hits.

Perubahan F01 `GT_DATA` (hanya saat `LRB3 = 'X'`):
1. Sebelum `LOOP AT IT_ZBMBC`: SELECT CAWN JOIN CAWNT sekali, ATINN IN (ZZCRITERIA, ZZCORE, ZZCORETYPE, ZZTREATMENT), SPRAS 'E' -> `LT_CHAR_DESC`, SORT ATINN ATWRT.
2. Di dalam loop: 2 SELECT WMS digabung jadi 1 SELECT AUSP JOIN MCH1 (10 ATINN, tanpa CAWN/CAWNT).
3. ATWTB diisi lewat READ TABLE BINARY SEARCH. Baris tanpa teks dihapus, jadi hasilnya sama dengan inner join CAWNT.

Efek: DB round-trip karakteristik per baris turun dari 2 jadi 1, dan join CAWN/CAWNT per baris hilang. Path Screen/OLAP tidak berubah (SELECT asli tetap di cabang ELSE).
Status: dipush ke sandbox-new, SYNTAX OK, live == src. Runtime test menunggu TRD.

## Analisis SAT Dev AIX (TRD, 28.10.2026 14:14, mode Screen, 71,290 baris IT_ZBMBC)

GT_DATA gross 367 s. Mapping hit list ke statement dan nasibnya di WMS:

| Hit list | Hits | Net (s) | Statement | WMS saat ini |
|---|---|---|---|---|
| Fetch AUSP | 71,290 | 107.3 | SELECT AUSP JOIN MCH1 (13 ATINN) per baris | Tetap (merged 10 ATINN) -> **target #1** |
| Fetch MCH1 | 71,290 | 102.2 | MCH1+AUSP+CAWN+CAWNT per baris | Hilang (preload CAWNT) |
| Fetch VEPO + Select Single VEPO | 142,580 | 22.9 + 6.7 | GT_HU BOX/PLT (VEPO JOIN VEKP) | Tetap -> target #3 |
| Fetch MSEG | 71,290 | 21.1 | Z_GET_PRODUCTION_DATE | Skip |
| Fetch LQUA | 71,290 | 10.0 | SELECT SINGLE LGPLA | Tetap -> target #2 |
| Fetch MCH1 | 71,290 | 8.2 | LICHA | Skip |
| GET_PRODUCTGROUP | 1 | 7.8 | enrichment | Skip |
| Fetch TVAGT | 40,917 | 6.1 | BEZEI | Skip |
| Fetch VBPA | 40,917 | 5.6 | NAME1 SO stock | Tetap -> target #4 |
| Fetch VEPO | 45,089 | 4.7 | GT_HU PLT fallback VENUM | Tetap -> target #3 |
| Fetch VEKP | 26,277 | 4.0 | GT_HU parent UNVEL | Tetap -> target #3 |

Estimasi WMS saat ini: sekitar 155-165 s. Sekitar 2/3-nya adalah AUSP per baris.
Biaya per hit sekitar 1.4-1.5 ms, jadi ini masalah round-trip, bukan plan Oracle.

Parameter FAE (TRS): rsdb/max_blocking_factor = 5, rsdb/max_in_blocking_factor = 5, prefer_in_itab_opt = 1.
Tanpa hint, FAE 71k key menghasilkan sekitar 14k round trip. Dengan `%_HINTS ORACLE '&max_in_blocking_factor 100&&max_blocking_factor 100&'` jadi sekitar 700.

### Rekomendasi fine tune (hanya cabang LRB3)
1. Karakteristik bulk (pola ZPPR_BARRIER):
   - Key MATNR+CHARG distinct -> MCH1 FAE (PK) -> CUOBJ_BM sebagai OBJEK.
   - AUSP FAE OBJEK + KLART 023 + 10 ATINN (PK prefix OBJEK, IN-list hint).
   - ATWTB dari LT_CHAR_DESC.
   - Di loop: READ BINARY SEARCH + LOOP FROM index, isi IT_CHAR. Assignment IT_CHAR yang ada tidak diubah.
2. LQUA bulk: FAE MATNR WERKS CHARG (index Z01) + READ BINARY.
3. GT_HU bulk: VEPO JOIN VEKP FAE WERKS LGORT MATNR CHARG (index Z02), lalu parent VEKP FAE UNVEL (index A). Logika BOX/PLT/fallback disalin ke form WMS baru. GT_HU asli tidak disentuh.
4. NAME1: cache per VBELN (VBPA/ADRC) dan per MATNR+WERKS+CHARG (MSKU/KNA1), atau bulk FAE.

Risiko: SELECT SINGLE tanpa ORDER BY bersifat arbitrary. Kalau satu key punya >1 baris (bin/HU ganda), hasil bulk bisa memilih baris lain. Memory AUSP bulk sekitar 700k baris (perkiraan 70-100 MB) -> FREE setelah loop. Bisa dipaket per 10k key kalau perlu.

## Implementasi Fine Tune #1 + #2 (28.10.2026) — FORM khusus WMS

TOP: tambah TYPES `TY_WMS_OBJ`, `TY_WMS_AUSP`, `TY_WMS_LQUA` dan buffer global `GT_WMS_DESC/OBJ/AUSP/LQUA`.

F01, FORM baru:
- `GT_WMS_PRELOAD`: dipanggil sekali sebelum loop.
  - CAWNT.
  - Key MATNR+CHARG dan MATNR+WERKS+CHARG di-SORT/dedup.
  - MCH1 FAE (PK) -> CUOBJ_BM.
  - AUSP FAE OBJEK + KLART 023 + 10 ATINN.
  - LQUA FAE (index Z01).
  - Semua dengan hint `&max_blocking_factor 100&` (AUSP juga `&max_in_blocking_factor 100&`).
- `GT_WMS_CHAR`: isi IT_CHAR dari buffer (BINARY SEARCH + LOOP FROM). Value ZZCRITERIA/CORE/CORETYPE/TREATMENT tanpa teks CAWNT di-skip, sama dengan inner join.
- `GT_WMS_LGPLA`: LGPLA dari buffer.
- `GT_WMS_FREE`: FREE buffer sebelum EXIT WMS.

GT_DATA hanya berisi `IF LRB3 = 'X'. PERFORM ... ELSE. <asli> ENDIF.`. Tidak ada baris asli yang terhapus (diff vs backup_before_wms).

Validasi runtime TRS (`scripts/compare_wms_bulk.mjs`, read-only temp program, 2,500 baris):
- Karakteristik lama vs bulk: 10,207 vs 10,207 -> EQUAL.
- LGPLA: 0 beda (710 quant).
- Waktu: 6.40 s -> 1.34 s (4.8x). Hint Oracle diterima DB.

Rollback: `outputs/*_before_bulk.abap` (versi sebelum bulk), `outputs/*_sandbox-new_backup_before_wms.abap` (versi asli).

## Revisi hint & guard (28.10.2026)

- Guard FAE pakai `LT_KEY[]`, `LT_OBJ[]`, `LT_KEY3[]` (tabel tanpa header line; `[]` dipakai agar eksplisit). Driver kosong tidak akan memicu full scan.
- Key kosong dibuang: `DELETE LT_KEY/LT_KEY3 WHERE MATNR IS INITIAL OR CHARG IS INITIAL`. Batch dengan `CUOBJ_BM` initial di-skip (tidak punya AUSP).
- Index per tabel (DDIC Dev AIX, fisik ada di Dev AIX & TRS via DB_EXISTS_INDEX):
  - MCH1~0 (MANDT MATNR CHARG) -> `INDEX("MCH1" "MCH1~0")`
  - AUSP~N3 (MANDT OBJEK KLART ATINN ATWRT ...) -> `INDEX("AUSP" "AUSP~N3")`; WHERE OBJEK + KLART + ATINN = prefix 4 kolom.
  - LQUA~Z01 (MANDT MATNR WERKS CHARG) -> `INDEX("LQUA" "LQUA~Z01")`
- `&max_blocking_factor 100&` / `&max_in_blocking_factor 100&` adalah DBSL hint (bukan index). Ini mengubah pemecahan FAE dari 5 key per statement (default) jadi 100.
- Bukti V$SQL TRS: `/*+ INDEX("AUSP" "AUSP~N3") */ ... "OBJEK" IN (:A1 ... :A100)`. MCH1: `/*+ INDEX("MCH1" "MCH1~0") */ ... MATNR=:A1 AND CHARG=:A2 OR ...`.
- Benchmark warm (2,500 baris): lama ~0.8 s, bulk ~0.07 s. Variasi N3/PK/tanpa index hint setara di TRS. Hint index dipakai untuk konsistensi dan stabilitas plan di PRD.
- Hasil: CHAR_EQUAL (10,207), LGPLA 0 beda.
