# Rancangan Program — COA Outsource TTA (ZQMI_COA)

Status: **rancangan, belum di-execute** (17 Nov 2026). Dasar: `docs/ANALISIS_OUTSOURCE_TTA_20261117.md` (§5–8), data uji `docs/DATA_UJI_TTA_DEV_20261117.md` (DO `0085006285`). Base source = DEV/sandbox sekarang (alias + Opsi D + kolom Material asli: TOP alias_v2, F01 `tests/matasli`, F02 alias_v2, ALV alias_v2).

## 1. Aturan (keputusan QA)

| Aturan | Isi |
|---|---|
| Deteksi roll TTA | `CHARG(1) = '9'` **dan** (`ZZPRODLINE = 'Z3'` **atau** token pertama `ZZNOMORROLL = 'Z3'`) |
| Cakupan | Hanya stage **base film** (mapping `SR Base Film` / `JR Base Film`). Stage converting tetap logika sekarang |
| Trace | Ikut ZEQM015: roll → order (101) → komponen (261) dari PO → **vendor batch (MCH1-LICHA)** di plant TTA → SR TTA (material I) → order SR TTA → komponen **JR material I** → berhenti |
| Lot | SR Base Film = lot Z04 SR TTA (boleh kosong → value 0). JR Base Film = lot Z02/Z03 JR TTA. Tidak saling mengisi |
| MIC | Mapping material Trias (contoh `PCADTH00`) diterjemahkan ke MIC lot TTA dengan urutan alias: EXACT → RULE → SUFFIX → DESC, dicocokkan ke inspection plan material lot TTA. Tampilan tetap MIC mapping |
| Alias | Alias diproses lebih dulu (menentukan material COA dan mapping); jalur TTA hanya menentukan lot dan MIC lot |
| Limit | Opsi D (sudah ada): mapping material asli bila diisi, sisi kosong dari spec lot (lot TTA hasil trace) |

## 2. Perubahan per include

| Include | Perubahan |
|---|---|
| TOP | `GV_ATINN_PRODLINE`; flag/material TTA per roll (`GV_TTA`, `GV_TTA_SRMAT`, `GV_TTA_JRMAT`) |
| F01 | `TY_TRACE_DATA` +3 field cache; `GET_TRACED_LOTS` (cek TTA + timpa lot base film); `GET_MIC` (terjemahan MIC base film); FORM baru `TTA_CHECK`, `TTA_TRACE`, `TTA_MAP_MIC` |
| F02, ALV | Tidak berubah |

## 3. Titik sisip

### 3.1 `TY_TRACE_DATA` (F01 ±2366) — cache per mother roll

```abap
         TTA                 TYPE C LENGTH 1,          " baru
         TTA_SRMAT           TYPE MARA-MATNR,          " baru
         TTA_JRMAT           TYPE MARA-MATNR,          " baru
```
Dibaca ulang saat cache ketemu (blok `READ TABLE GT_TRACE_DATA ...`) dan diisi saat simpan cache.

### 3.2 `GET_TRACED_LOTS` (F01 ±2389)

1. Setelah `L_MOTHER_ROLL` dibentuk: `PERFORM TTA_CHECK CHANGING GV_TTA.` (pakai `IT_DATA-CHARG`, `IT_DATA-NOMSR`, AUSP ZZPRODLINE). Kosongkan `GV_TTA_SRMAT/JRMAT`.
2. Logika trace sekarang tetap jalan apa adanya (SR Conv / JR Conv tidak disentuh).
3. Sebelum simpan cache, kalau `GV_TTA = 'X'`:
   ```abap
   PERFORM TTA_TRACE CHANGING L_SR_BASE_BATCH LOT_SR_BASE
                              L_JR_BASE_BATCH LOT_JR_BASE
                              GV_TTA_SRMAT GV_TTA_JRMAT.
   ```
   Kalau `TTA_TRACE` menemukan vendor batch TTA, lot base film **diganti** hasil TTA (lot SR boleh kosong). Kalau tidak ketemu, hasil trace sekarang dipakai (tidak ada perubahan perilaku).

### 3.3 `GET_MIC` (F01 ±1014, `LOOP AT IT_ZMAP`)

- Variabel baru `LV_QMIC` (MIC untuk baca lot), default `IT_ZMAP-MIC`.
- Setelah `INS` ditentukan dari stage mapping: kalau `GV_TTA = 'X'` dan stage `SR Base Film` / `JR Base Film`:
  ```abap
  PERFORM TTA_MAP_MIC USING IT_ZMAP-MIC <material TTA stage> INS
                      CHANGING LV_QMIC.
  ```
  (`GV_TTA_SRMAT` untuk SR Base Film, `GV_TTA_JRMAT` untuk JR Base Film.)
- `SELECT ... FROM QAMV WHERE PRUEFLOS = INS AND VERWMERKM = LV_QMIC` (ganti `IT_ZMAP-MIC` dengan `LV_QMIC`), lalu **`IT_MIC-MIC = IT_ZMAP-MIC`** sebelum `APPEND` (tampil MIC mapping, `MERKNR` tetap dari lot sehingga value QAMR terbaca dari lot TTA).
- Blok multi-level (`GT_MT_LOT`) dan pengecualian MVTR/OTR tidak diubah.

## 4. FORM baru

### `TTA_CHECK CHANGING P_TTA`
`CHECK IT_DATA-CHARG(1) = '9'`. Token pertama `IT_DATA-NOMSR` = `Z3` → `X`; kalau tidak, baca AUSP ZZPRODLINE batch (INOB 023 MCH1) = `Z3` → `X`.

### `TTA_TRACE CHANGING P_SRB P_SRLOT P_JRB P_JRLOT P_SRMAT P_JRMAT`
1. Roll: MSEG `101` (tidak dibatalkan, `AUFNR` terisi) → order → MSEG `261` order itu → komponen (material, batch).
2. Komponen: `MCH1-LICHA` → vendor batch; `MCHA` dengan `WERKS LIKE 'TTA%'` → material SR TTA. Tidak ketemu → `RETURN` tanpa mengubah apa pun.
3. SR TTA: `P_SRB` = vendor batch, `P_SRMAT` = materialnya, `P_SRLOT` = QALS `Z04` batch itu (bisa kosong).
4. JR TTA: dari batch SR TTA → MSEG `101`/`531` → order → MSEG `261` komponen `JR*`. Kalau materialnya berakhiran `I` → selesai; kalau tidak, ulangi dari batch JR itu (maks. 5 level). `P_JRB`, `P_JRMAT`, `P_JRLOT` = QALS `Z02`/`Z03` (sama dengan pola program sekarang), fallback `GET_JR_SIBLING_LOT`.

### `TTA_MAP_MIC USING P_MIC P_MATNR P_LOT CHANGING P_QMIC`
Urutan sama dengan `ALIAS_TRANSLATE_GROUP`, sumber = inspection plan `P_MATNR` (`ALIAS_LOAD_PLAN`, cache `GT_APLAN`):
EXACT (MIC ada di plan) → RULE (`P_MIC(1)` + `P_MATNR+2(3)` + `P_MIC+4(4)`) → SUFFIX (huruf awal + 4 huruf akhir sama, tepat 1) → DESC (deskripsi QPMT `P_MIC` = deskripsi plan, level S/P/A sama, tepat 1). Hasil dicek ada di QAMV `P_LOT`; tidak ketemu → `P_QMIC` kosong → MIC tampil value 0 (sama seperti sekarang).

## 5. Yang tidak berubah

Jalur non-TTA (semua skenario lama, batch tidak berawalan 9), alias, Opsi D, rata-rata, ZLOG_COA, EXEC, ZQM003, F02, ALV.

## 6. Rencana uji (harness DEV, in-memory)

| Uji | Harapan |
|---|---|
| Regresi 19 DO (15 skenario + AL-*) | Identik dengan `outputs/MT_20261117_dev_after_limitD.txt` / live test (batch skenario tidak berawalan 9) |
| DO `0085006285` | 9 MIC JR Base Film = lot `040000015885` (12.00, 23.00, 27.00, 133, 123, 2.00, 0.30, 2.00, 128); PCADSTNT (SR Base Film) = 0; lot ZQM003 per roll = `040000015885`; ELTD out limit (123 > 120) |
| Trace 23 rantai DEV | Semua menemukan SRSEFI → JRSEFI → `040000015885` |
| Roll 9* bukan Z3 / Z3 bukan 9* | Tidak masuk jalur TTA |

## 7. Catatan terbuka

- 383 roll DEV ber-Z3 sampai TTA2 tetapi pencarian sederhana belum menemukan JR (kemungkinan SR TTA dari proses lain / change grade). Dicek saat implementasi `TTA_TRACE`; kalau polanya berbeda, dilaporkan dulu.
- Pemilihan lot JR Z02/Z03 memakai pola program sekarang (bug laten Z02/Z03 tidak diubah, sesuai keputusan 16 Nov).

## 8. Implementasi dan uji (17 Nov 2026, perintah user "Ya, execute")

Patch `tests/tta/` (generator `make_patch.py`, base TOP alias_v2 + F01 matasli). TOP +16 baris, F01 5582 → 5884.

**Penyesuaian dari rancangan (tanpa mengubah hasil yang diharapkan):**
- MIC lot TTA (`PSEF*`) dipakai selama baca value (`GET_JR_AVG`, rata-rata, `GT_AVGKEY` membaca berdasarkan MIC lot); relabel ke MIC mapping (`PCAD*`) dilakukan di titik `COA_MIC` (sama dengan alias) lewat tabel `GT_TTAMIC` (VBELN, CHARG, MIC lot, MIC mapping). Method juga dicari dengan `COA_MIC`; pencarian `GT_AMIC_B` alias memakai `COA_MIC`.
- Fallback multi-level (`GT_MT_LOT`) tidak dipakai untuk stage base film roll TTA (supaya SR TTA tanpa lot tetap 0).
- `TTA_MAP_MIC`: kandidat = inspection plan material TTA + MIC lot (plan JRSEFI `A_EP12J` ada; MIC lot jadi cadangan kalau plan tidak ada).
- **Perbaikan bug lama** di blok "Pastikan semua MIC ZMAP_COA masuk" (GET_MIC): `READ TABLE IT_MIC2 ... BINARY SEARCH` padahal di loop yang sama baris di-APPEND (urutan rusak) → MIC berikutnya dianggap tidak ada → baris ganda tanpa lot. Diganti tanpa `BINARY SEARCH`. Regresi 19 DO tetap 0 selisih.

**Uji harness DEV (in-memory, base DEV `after_matasli`):**

| Uji | Hasil |
|---|---|
| Regresi 19 DO (15 skenario + AL-STRUKTUR/MIXED/VALUE1/VALUE2), value + limit (`outputs/MT_20261117_tta.txt`, `outputs/LIMIT_20261117_tta.txt`) | **0 selisih** vs `MT_20261117_dev_after_limitD.txt` / `LIMIT_20261117_dev_after_limitD.txt` |
| DO `0085006285` (`outputs/test_data_tta_20261117/MT_do6285_tta.txt`) | ZQM002 = EXEC = ZQM003: PCADTH00 12.00, TSMD 23.00, TSTD 27.00, ELMD 133, ELTD 123, SHMD 2.00, SHTD 0.30, HZ00 2.00, G400 128 (lot 040000015885), PCADSTNT **0** (SR Base Film, tanpa lot). Terjemahan RULE PCAD* → PSEF*. ZQM003 30 baris (3 roll × 10 MIC) |
| Limit DO 6285 (Opsi D, mapping SRCBUX kosong → spec lot TTA) | TH00 11.64–12.35, TSMD 16.00–26.00, TSTD 18.00–30.00, ELMD 70–150, ELTD 60–120 (123 out limit), SHMD 1.00–3.00, SHTD 0.00–0.50, HZ00 1.50–2.50, G400 120–140, STNT 44–50 (QPMK, tanpa lot) |
| `TTA_CHECK` + `TTA_TRACE` 4.154 batch DEV (`outputs/test_data_tta_20261117/TTA_unit_trace.txt`) | 23 lengkap SRSEFI → JRSEFI lot 040000015885; 383 TTA tapi JR tidak ada (order TTA `E…` ZPE2 tanpa 261 di DEV); 11 TTA tanpa vendor batch (tidak diubah); 23 batch 9* tanpa Z3 → bukan TTA; 3.714 batch TTA2 bukan 9* → bukan TTA |

**Push sandbox-new:** backup `outputs/ZQMI_COA_{TOP,F01}_sandbox-new_backup_before_tta_20261117.abap`; push TOP 486, F01 5884, syntax RC 0, readback identik. F02/ALV tidak berubah. DEV AIX belum (transport/deploy oleh user).

**Catatan:** alias + TTA bersamaan: limit Opsi D mencari ZMAP_COA material asli dengan `BATCH_MIC` = MIC lot TTA, sehingga limit mapping material asli tidak terbaca (pakai spec lot). Belum ada data uji untuk kombinasi ini.

## 9. Kasus SRCBUX sebagai SR Base Film di alur converting (temuan 17 Nov 2026)

User: SRCBUX (roll X dari TTA) sebenarnya **SR Base Film** yang dijadikan input JR converting → SR converting → DO. Contoh DO 6285 (SRCBUX dijual langsung) hanya kasus traceability.

**Cakupan program sekarang: belum.** `TTA_CHECK` hanya memeriksa roll di DO (`IT_DATA-CHARG`). Pada alur converting, roll DO adalah SR converting (tidak berawalan 9); batch SRCBUX 9* baru muncul di tengah trace sebagai `L_SR_BASE_BATCH` (komponen order JR converting, F01 ±2627–2635). Di titik itu: lot Z04 SRCBUX tidak ada, dan pencarian JR base lewat `ZQM_GET_BATCH_JR_BY_SR` tidak masuk ke rantai TTA, sehingga MIC base film bernilai 0 / salah lot.

**Usulan perubahan:** jalankan cek TTA juga pada **batch SR Base Film hasil trace** (`L_SR_BASE_BATCH`): batch berawalan 9 + Z3 (klasifikasi batch itu). Kalau ya, `TTA_TRACE` dimulai dari batch itu (bukan dari roll DO) dan mengganti lot SR Base / JR Base dengan lot TTA. Stage SR/JR converting tetap dari logika sekarang. Kasus roll DO langsung TTA (DO 6285) tetap seperti sekarang.

**Data DEV:** hanya 3 roll SR\*X 9* yang dikonsumsi order (261): SRCBUX `9000374179` → JR conv **JREYAI `0000397806`** (lot `040000019000` Z02); SRCJQX `9000393318` → JREZLI `0000394906` (tanpa lot); SRCBUX `9000375133` → order `M10000000080`. **Tidak ada** yang berlanjut ke SR converting / DO. Untuk uji end-to-end perlu dibuat data (order slitting JR conv → SR conv + lot SR conv, lalu SO/DO), atau uji parsial di harness.

### 9.1 Temuan persiapan data converting TTA (18 Nov 2026, read-only)

1. **Rantai JREYAI tidak bisa dipakai.** Roll SRCBUX `9000374179` (input JR conv JREYAI `0000397806`) memang TTA (9*, Z3, vendor batch SRSEFI), tetapi order TTA-nya `E29000156540` tidak punya komponen JR di DEV (261 kosong), jadi lot JR TTA tidak terjangkau (base film tetap 0). JREYAI masih punya stok 162.93 KG (status QI) dan belum pernah diproses jadi SR conv. Lot JR conv `040000019000` (Z02) punya 12 MIC `PEYA*` tapi **belum ada hasil**.
2. **Roll TTA yang lengkap** (JRSEFI lot `040000015885`): 23 roll SRCBUX `9000377390`–`425`; yang masih ada stok dan belum di DO: `9000377410`–`417` (0.76–0.84 KG, sloc 2801/2804). Belum ada yang dikonsumsi order converting.
3. **Cara SR converting dibentuk di DEV (contoh DO 6240):** batch SR di-GR 101 pada order tipe **PPA2** (`A29000002540`, LICHA batch = nomor order), sedangkan konsumsi JR (261) dan scrap (531) berada di order tipe **ZCA2** (`100000072913/918/926`) yang terhubung lewat **`AFPO-MILL_OC_AUFNR_U`** = order PPA2. `ZQM_GET_BATCH_JR_BY_SR` (function group ZBARRIER): SR → AUFM 101 → order → AFPO.MILL_OC_AUFNR_U → AUFM 261 → JR. JR conv dibuat order tipe **ZP04** (261 SRCBUX + komponen lain, 101 JR).
4. **Konsekuensi:** data uji converting penuh = 3 order (JR conv ZP04 yang mengonsumsi roll TTA lengkap; SR conv pasangan ZCA2 + PPA2 dengan link MILL_OC), klasifikasi batch baru (ZZNOMORROLL, ZZPRODLINE dll.), lot Z04 + hasil, lalu SO/DO. Melibatkan GR/GI di DEV, medan custom MILL_OC, dan kemungkinan exit pembentukan batch; belum dicoba.

### 9.2 Percobaan membuat order di DEV (18 Nov 2026) — blocker

Script uji: `outputs/test_data_tta_20261118/st15_order_zp04_try*.abap` (semua tanpa commit, tidak ada order terbentuk).

- ZP04, ZCA2, PPA2, ZPE2 semuanya **process order (kategori 40)**, jadi `BAPI_PRODORD_CREATE` ditolak ("Order type ZP04 is not maintained for order category 10"). `BAPI_PROCORD_CREATE` dipakai.
- Order asli `100000070188`: ZP04, plant 2000, material JREYAI, versi produksi `0002` (BOM `5669` alt `04`, routing grup `JREYAI` alt `A4`), kuantitas **1 ROL**, kunci jadwal AFKO-TERKZ = `3`, tanggal mulai = selesai = tanggal buat.
- `BAPI_PROCORD_CREATE` selalu gagal dengan **CO 029 "No lead time scheduling (enter start and finish date)"** walau tanggal dan jam awal/akhir, tanggal explosion, prioritas, serta RECIPE_TYPE `2` / RECIPE_GROUP `JREYAI` / RECIPE_COUNTER `A4` sudah diisi (tanggal sama atau berbeda).
- Belum dicoba: BDC `COR1` (rekaman layar), atau order dibuat manual oleh user lalu sisanya (release, GI 261, GR 101, klasifikasi, lot, SO/DO) saya lanjutkan lewat BAPI.

### 9.3 Implementasi dan hasil (18 Nov 2026)

**Data DEV lengkap dibangun** (bukan lagi blocker). Order dibuat lewat BDC `COR1` memakai `ABAP4_CALL_TRANSACTION` (mode N, update S; tanggal DD.MM.YYYY, desimal titik), mengikuti `Solusi_COR1_via_RFC.md`. SR converting dibentuk seperti `ZPP003P` (`ZPPC_UPLOAD_SLITROLL`): COR1 order PPA2 sumber, `MILL_OC` menggabungkan ke ZCA2 dan mengisi `AFPO-MILL_OC_AUFNR_U`, lalu MSC1 per roll. Daftar objek dan rollback: `docs/DATA_UJI_TTA_DEV_20261117.md`.

**Temuan BKTXT.** `GET_VALID_ORDER_FROM_MSEG` dan `GET_VALID_COMPONENT_FROM_MSEG` memasangkan dokumen GR 101 dengan GI 261 lewat `MKPF-BKTXT` yang sama (`GV_TRACE_BKTXT`). Pada data nyata: level JR memakai nomor roll JR (contoh `G EYA 124 011`), level SR memakai nomor order gabungan. Data uji harus memakai teks header yang sama, kalau tidak, trace berhenti.

**Perubahan program** (generator `tests/tta/make_patch.py`; hasil `tests/tta/ZQMI_COA_TOP.abap` dan `ZQMI_COA_F01.abap`):
1. `TTA_CHECK USING P_MATNR P_CHARG P_NOMSR CHANGING P_TTA`: parameter material, batch, dan nomor roll, jadi bisa dipanggil untuk roll DO maupun batch hasil trace. Kalau `P_NOMSR` kosong, `ZZNOMORROLL` dibaca dari AUSP.
2. `TTA_TRACE USING P_MATNR P_CHARG CHANGING P_SRB P_SRLOT P_JRB P_JRLOT P_SRMAT P_JRMAT`.
3. `GET_TRACED_LOTS`: kalau roll DO bukan TTA tetapi `L_SR_BASE_BATCH` terisi dan berbeda dari roll DO, ambil `MATNR` dari `MCH1`, jalankan `TTA_CHECK` pada batch itu; bila TTA, `TTA_TRACE` dimulai dari batch SR Base Film itu dan mengganti lot SR Base / JR Base dengan lot TTA. Stage SR/JR converting tetap dari logika sebelumnya. Bila tidak ada material SR/JR TTA yang ditemukan, flag `GV_TTA` dibersihkan.
4. Cache `GS_TRACE_DATA`: bila `TTA_SRMAT` atau `TTA_JRMAT` terisi, `GV_TTA = 'X'` dipulihkan.

**Hasil uji (harness DEV, 18 Nov 2026)** `outputs/MT_20261118_tta_conv.txt`, `outputs/LIMIT_20261118_tta_conv.txt`:
- 20 DO lama: value dan limit 0 selisih vs `MT_20261117_dev_after_tta.txt` dan `LIMIT_20261117_dev_after_tta.txt`.
- DO 0085006286: value 10/10 = lot JR TTA `040000015885`; ZQM002 = EXEC = ZQM003.
- Tanpa error atau dump.
- Selisih limit enam baris di DO 6286 (ZQM002 bulat) = MIC PEYA* tidak ada di QPMK DEV (STELLEN 0), bukan bug program.

**Status:** sandbox-new sudah dipush 18 Nov 2026 (TOP 486, F01 5923, RS_SYNTAX_CHECK RC 0, readback identik). Backup pra-push: `outputs/bak_20261118/`. DEV belum memuat patch converting; deploy oleh user, lalu regresi ulang di DEV.

### 9.4 Penyelarasan dengan ZEQM015: sambungan lewat MSEG 601 (18 Nov 2026)

Source ZEQM015 (`ZQMR_TRACEABILITY_TR_TTE_F01`, `UPDATEDATA` baris 196-213) dibaca di DEV: untuk material `SR*`, ZEQM015 mengambil `MCH1-LICHA` batch itu, lalu mencari `MSEG` **601** dengan `CHARG = LICHA`. 543 hanya dipakai di cabang yang berlabel SUBCONTRACT (GR tanpa order). Penjelasan 543 sebagai jalur utama di `ANALISIS_OUTSOURCE_TTA_20261117.md` §1 kurang tepat.

Perubahan `TTA_TRACE`: syarat batch vendor berada di plant `TTA%` (`MCHA`) diganti dengan syarat ada `MSEG` 601 pada batch `LICHA`; material batch TTA diambil dari baris 601. Data DEV: batch SRSEFI 0000377412 (TTA2) punya 601 `4900389694`.

Hasil (harness, dasar = source DEV 18 Nov, yang sudah memuat versi converting): 21 DO value dan limit **0 selisih** vs `MT_20261118_tta_conv.txt` / `LIMIT_20261118_tta_conv.txt`. DO 0085006285 dan 0085006286 value 10/10 = lot JR TTA 040000015885. Berkas: `outputs/MT_20261118_tta_601.txt`, `outputs/LIMIT_20261118_tta_601.txt`.

Status: sandbox-new dipush 18 Nov (TOP 486, F01 5924 baris, RS_SYNTAX_CHECK RC 0, readback identik). DEV memuat versi sebelum 601 (F01 5923 baris); deploy versi 601 oleh user.

### 9.5 TTA_TRACE disamakan penuh dengan ZEQM015, termasuk 543 (18 Nov 2026, perintah user)

User: "saya minta sama dengan zeqm015, karna di prd ada kemungkinan gitu". `TTA_TRACE` ditulis ulang mengikuti `UPDATEDATA` ZEQM015, dengan tiga FORM baru:

| FORM | Isi (sama dengan ZEQM015) |
|:--|:--|
| `TTA_GR101` | GR 101/102 batch, pasangan yang dibatalkan dibuang (SMBLN/SJAHR/SMBLP), urut `CPUDT_MKPF`/`CPUTM_MKPF`, ambil yang pertama; tanggal dari MKPF |
| `TTA_COMBINE` | Order gabungan: `AFPO` dengan `MILL_OC_AUFNR_U` = order (VCOMBINE), kalau tidak ada pakai order itu |
| `TTA_SRC` | Batch asal: (1) material `SR*`: `MCH1-LICHA` lalu `MSEG` 601 dengan `CHARG = LICHA`; (2) GR tanpa order (SUBCONTRACT): `MSEG` 543 di dokumen GR itu |

Alur: roll sendiri lewat `TTA_SRC`; kalau kosong, roll ke GR 101 sah, order gabungan, **semua** komponen `AUFM` 261 dicoba lewat `TTA_SRC` sampai ketemu. Batch hasil = SR TTA (lot Z04). Naik ke JR material I: GR 101 sah atau 531 (tambahan di luar ZEQM015, keputusan QA karena nilai hanya ada di lot JR TTA), order gabungan, komponen `AUFM` 261 `JR%`.

Beda yang disengaja: ZEQM015 menampilkan hasil 601 dan 543 bersama di tree; COA butuh satu batch, jadi urutannya 601 dulu, lalu 543.

Uji:
- `TTA_SRC` di DEV (program uji baca saja): dokumen subcontract `5000043037` (SRAQEO 0000314786, 543) menghasilkan SRAHAI 0000000284; SRCBUO 0000379742 (601) menghasilkan SRSEFI 0000377412. Data 543 untuk vendor TTA (2132000001) tidak ada di DEV.
- Harness 21 DO (dasar source DEV 18 Nov): value dan limit 0 selisih vs `MT_20261118_tta_601.txt` / `LIMIT_20261118_tta_601.txt`; DO 0085006285 dan 0085006286 10/10. Berkas: `outputs/MT_20261118_tta_543.txt`, `outputs/LIMIT_20261118_tta_543.txt`.

Status: sandbox-new dipush 18 Nov (TOP 486, F01 6042 baris, RS_SYNTAX_CHECK RC 0, readback identik). DEV masih versi converting sebelum 601 (F01 5923); deploy oleh user.
