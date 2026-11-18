# Data Uji COA Outsource TTA — Development AIX (17 Nov 2026)

Perintah user: "Ya, buat data uji". Rancangan: `docs/ANALISIS_OUTSOURCE_TTA_20261117.md`. Program belum diubah; data ini untuk menguji logika TTA nanti.

**DO uji: `0085006285`** (SO `0000007209`, customer 1141000514).

## Rantai data (sudah ada di DEV, tidak diubah)

| Level | Material | Batch | Plant | Lot |
|---|---|---|---|---|
| Roll DO | SRCBUX | 9000377390 / 391 / 392 | 2000 | – |
| Komponen (PO, vendor batch) | SRCBUO | 0000379729 / 730 / 731 | 2000 | – |
| SR TTA (material I) | SRSEFI | (vendor batch) | TTA2 | **tidak ada** (SR Base Film → 0) |
| JR TTA (material I) | JRSEFI | 0000371969 | TTA2 | **040000015885** (Z02/Z03, 19 MIC `PSEF*`) |

Klasifikasi roll DO: ZZPRODLINE `Z3`, token pertama ZZNOMORROLL `Z3`, batch berawalan `9`, ZZCODE `CBU`, ZZALIAS `AZ-12` (alias → MAKT → SREZAI, **tanpa mapping** → NOMAP → fallback as-is SRCBUX).

## Log perubahan

| Tahap | Waktu | Objek | Isi | Cara rollback |
|---|---|---|---|---|
| 13 | 17 Nov 2026 | ZMAP_COA SRCBUX (KUNNR kosong) | 10 baris baru: PCADTH00, TSMD, TSTD, ELMD, ELTD, SHMD, SHTD, HZ00, G400 (JR Base Film, SEQ 001–009) + PCADSTNT (SR Base Film, SEQ 010), tanpa limit. MIC dari inspection plan SRCBUX (grup EP12X, MIC `PCAD*`). USNAM TRSTDEV | `DELETE FROM ZMAP_COA WHERE MATNR = 'SRCBUX'` (sebelumnya kosong) |
| 14a | 17 Nov 2026 | Sales order `0000007209` | ZDOR, sales office 0002, customer 1141000514, PO "UJI COA OUTSOURCE TTA", item 10 SRCBUX 1.2 KG (simulasi TESTRUN dulu, lalu commit). Incompletion V1 555 | Hapus SO setelah DO dihapus |
| 14b | 17 Nov 2026 | Outbound delivery `0085006285` | ZDLF, shipping point 2000, item 10 dari SO 7209 | Hapus DO (VL02N), tanpa PGI |
| 14c | 17 Nov 2026 | Batch split DO `0085006285` | 900001 9000377390, 900002 9000377391, 900003 9000377392 @0.4 KG, item ZB, sloc 2813 | Ikut hapus DO |

Script: `outputs/test_data_tta_20261117/` (st13_zmap_srcbux, st14a_so, st14b_dlv, st14c_split).

## Baseline program DEV sekarang (sebelum logika TTA)

Source DEV = sandbox (alias + Opsi D + kolom Material asli). Output `outputs/test_data_tta_20261117/MT_do6285_baseline.txt`:
- 3 roll alias AZ-12 → SREZAI **NOMAP** → as-is mapping SRCBUX, 10 MIC.
- Semua value **0**, INSLOT kosong (trace tidak sampai lot TTA).
- Limit dari master MIC (QPMK) `PCAD*`: TH00 11.64–12.35, TSMD 16.00–26.00, TSTD 18.00–30.00, ELMD 70–150, ELTD 60–120, SHMD 1.00–3.00, SHTD 0.00–0.50, HZ00 1.50–3.00, G400 120–140, STNT 44–50.
- EXEC header `AZ-12` (header lama memakai ZZALIAS), width 100.

## Harapan setelah logika TTA

Semua roll dari JR TTA yang sama → value = nilai lot `040000015885`:

| MIC COA | Stage | MIC lot (RULE) | Nilai lot | **Value harapan** | Spec lot (Opsi D, mapping kosong) |
|---|---|---|---|---|---|
| PCADTH00 | JR Base Film | PSEFTH00 | 12.0000 | **12.00** | 11.64 – 12.35 |
| PCADTSMD | JR Base Film | PSEFTSMD | 23.0000 | **23.00** | 16 – 26 |
| PCADTSTD | JR Base Film | PSEFTSTD | 27.0000 | **27.00** | 18 – 30 |
| PCADELMD | JR Base Film | PSEFELMD | 132.6667 | **133** | 70 – 150 |
| PCADELTD | JR Base Film | PSEFELTD | 122.6667 | **123** (di atas upper 120) | 60 – 120 |
| PCADSHMD | JR Base Film | PSEFSHMD | 2.0000 | **2.00** | 1 – 3 |
| PCADSHTD | JR Base Film | PSEFSHTD | 0.3000 | **0.30** | 0 – 0.5 |
| PCADHZ00 | JR Base Film | PSEFHZ00 | 2.0000 | **2.00** | 1.5 – 2.5 |
| PCADG400 | JR Base Film | PSEFG400 | 127.6667 | **128** | 120 – 140 |
| PCADSTNT | **SR Base Film** | – (SRSEFI tanpa lot) | – | **0** (keputusan §7 no. 1; nilai 47 di lot JR **tidak** dipakai) | – |

## Hasil setelah logika TTA (harness DEV, 17 Nov 2026)

Semua value **sama dengan tabel harapan di atas** (9/9 JR Base Film + PCADSTNT 0), ZQM002 = EXEC = ZQM003. Rincian: `docs/RANCANGAN_PROGRAM_TTA_OUTSOURCE.md` §8.

## Data converting TTA di DEV (18 Nov 2026) — JR converting selesai, SR converting belum

Tujuan: SRCBUX TTA sebagai SR Base Film → JR converting → SR converting → DO (lihat `docs/RANCANGAN_PROGRAM_TTA_OUTSOURCE.md` §9). Script/log: `outputs/test_data_tta_20261118/`.

| Tahap | Objek | Isi | Cara rollback |
|---|---|---|---|
| 15 | Order **100000073548** (ZP04, JREYAI, plant 2000) | Dibuat lewat COR1 BDC (`ABAP4_CALL_TRANSACTION`, `cor1_bdc.mjs`): versi produksi 0002, **1 ROL**, base qty **2.52 KG** (UMREZ/UMREN 63/25), ZFILM EYA / 2500 / 35000 / NONO / G / 124, status REL. BOM sekarang menjadwalkan komponen SRCBBI (bukan SRCBUX seperti order lama 100000070188) | Cancel GR/GI di bawah, lalu TECO/hapus order (COR2 / `BAPI_PROCORD_SET_DELETION_FLAG`) |
| 15x | Order **100000073547** (ZRR2, JRGARI) | Terbentuk **tidak sengaja** saat uji `BAPI_PROCORD_CREATE` (pemanggilan FM langsung ternyata tersimpan). Tanpa komponen/mutasi | Sudah diberi **flag deletion** (I0076) |
| 16 | GI 261 dok **4900436247** | 3 roll TTA lengkap SRCBUX `9000377412`, `413`, `414` (@0.84 KG, sloc 2804) ke order 100000073548. (Roll di sloc 2801 = gudang WM/HU, GI dari sana membuat delivery otomatis; dihindari) | Cancel dok material (MBST) |
| 17 | GR 101 dok **5000077820** | Batch JR converting baru **JREYAI `0000407417`** 2.4 KG, sloc 2052; lot QM **Z02 `040000021140`** (12 MIC `PEYA*`) terbentuk otomatis, **hasil belum diinput** | Cancel dok material (MBST) |
| 19 | Klasifikasi batch `0000407417` (kelas `ZZJRMETZ`) | Klasifikasi tidak terbentuk otomatis; diisi lewat `BAPI_OBJCL_CHANGE`: nilai mentah (ZZCODE `EYA`, ZZPRODLINE `G`, ZZINSIDE/OUTSIDE `NO`, ZZTREATMENT `NONO`, ZZTYPE `KEZ`, ZZGRADEJR `OK`, ZZMONTHYEAR `124`, ZZSEQUENCENBR `901`, ZZNOMORROLL `G EYA 124 901`) dan numerik **persis batch asli** `0000397806` (skala berat sendiri melanggar konsistensi klasifikasi) | Hapus nilai klasifikasi (CL20N) |

Rantai TTA: JREYAI `0000407417` ← 261 SRCBUX `9000377412`–`414` (SR Base Film, batch ZZPRODLINE Z3) → vendor batch SRSEFI → JRSEFI lot `040000015885`.

**Pelajaran teknis:** (1) `call_function` langsung: tiap panggilan = sesi terpisah, `BAPI_*` + `BAPI_TRANSACTION_COMMIT` harus satu sesi (program sementara); (2) format angka sesi RFC memakai **titik desimal**, tanggal `DD.MM.YYYY`; (3) BAPI_PROCORD_CREATE gagal CO 029 untuk ZP04, COR1 BDC berhasil; (4) klasifikasi batch JR tidak otomatis.

**Belum:** hasil inspeksi lot JR conv `040000021140`; SR converting (order ZCA2 + PPA2, link `AFPO-MILL_OC_AUFNR_U`), lot Z04 + hasil, mapping SR conv, SO/DO. Blocker: cara menghubungkan order ZCA2 dan PPA2 (field `MILL_OC_AUFNR_U` tidak tampak di layar yang bisa saya baca).

### Lanjutan 18 Nov 2026 — SR converting dibuat dengan meniru ZPP003P

**Resep asli ZPP003P** (program `ZPPC_UPLOAD_SLITROLL`, upload Excel): (1) per order sumber (tipe PPA2, nomor eksternal `A29…`) COR1 BDC dengan qty ROL (BMENGE = jumlah roll), versi produksi, sloc, ZFILM width/length; (2) tcode **MILL_OC** (preselect plant + tipe order + rentang order) menggabungkan order sumber menjadi order **ZCA2** (nomor internal) yang menunjuk order sumber lewat `AFPO-MILL_OC_AUFNR_U`; (3) **MSC1** per roll: LICHA = nomor order sumber + karakteristik klasifikasi (ZZCODE, ZZTREATMENT, ZZCORE, ZZWIDTH, ZZGRADE, ZZDERIVATIVEMS/SS, ZZPACKING, ZZLABEL, ZZPACKINGCODE, ZZEXLENGTH, ZZPRODLINE, ZZPOSITIONMS/SS, ZZLENGTH, ZZALIAS, ZZTYBCOMBINATIONNO). GR 101 dan GI 261 dikerjakan terpisah.

| Tahap | Objek | Isi | Cara rollback |
|---|---|---|---|
| 20 | Order sumber **A29000009001** (PPA2, SREYAI, plant 2000) | `slit_order.mjs` (COR1 BDC meniru ZPP003P): 2 ROL, versi 0001 (BOM alt 01: JREYAI → SREYAI), sloc 2310, ZFILM 920 / 11500. Released | TECO/hapus order |
| 21 | Order **ZCA2 100000073549** | `mill_oc.mjs` (MILL_OC BDC), unloading point MS; `AFPO-MILL_OC_AUFNR_U` = A29000009001; komponen JREYAI + SREYAI. Released (`BAPI_PROCORD_RELEASE`) | TECO/hapus order |
| 22 | Batch SR conv **SREYAI 0000407419** dan **0000407420** | `msc1_batch.mjs` (MSC1 BDC): LICHA = A29000009001, ZZCODE EYA, ZZTREATMENT MENO, ZZCORE 6, ZZWIDTH 460, ZZGRADE CC, ZZPRODLINE H, posisi 01 dan 02, ZZALIAS **kosong** (agar jalur alias tidak ikut). Nilai turunan (ZZ numerik) terbentuk otomatis; ZZNOMORROLL / ZZMONTHYEAR / ZZSEQUENCENBR belum ada (kemungkinan dibentuk saat GR) | Hapus klasifikasi / flag deletion batch (MSC2) |
| 23 | Lot JR conv `040000021140` | Hasil karakteristik tercatat **tertutup tanpa nilai** (percobaan pertama `CHAR_RESULTS`; pengisian nilai lewat `SAMPLE_RESULTS` ditolak QI 108/128). **Usage decision P1** (grup 0-UD-PRD) sukses dengan force completion, tetapi **stock posting belum jalan**: stok JR 0000407417 masih 2.400 KG di QI | — |

**Blocker:** GI 261 JR 0000407417 ke order ZCA2 ditolak (QA 495 "Change the inspection stock of material JREYAI in QM only") karena stok JR masih QI; stock posting UD belum terjadi (status SPCO I0220 belum ada, I0203 SPRQ); `QEVA_UD_POSTING` tidak RFC-enabled dan panggil ulang BAPI UD ditolak (QV 181). Butuh stock posting UD lot `040000021140` (QA11 / QA12) — usul: dilakukan user.

**Belum:** GI 261 JR ke ZCA2, GR 101 batch SR ke A29000009001 (lot Z04 + hasil), mapping SR conv, SO/DO, perubahan program TTA converting.

### Status 18 Nov 2026 (akhir sesi, batas pemakaian tercapai)

Dibuat: GI 261 JR 0000407417 ke ZCA2 100000073549, GR 101 batch SR (dok 5000077822), ZZNOMORROLL + klasifikasi SR lengkap (`st29`; `st25` sempat menghapus karakteristik lain karena BAPI_OBJCL_CHANGE menganggap daftar = set lengkap), mapping SREYAI (`st26`), SO 7210, **DO 0085006286** (2 roll SREYAI, `st27*`). Dokumen GI dicancel dan diposting ulang (4900436266, 4900436267) karena BKTXT harus sama dengan dokumen GR-nya (`GV_TRACE_BKTXT`). UD lot JR 040000021140 + stock posting oleh user.
Trace DO 6286 (sebelum perubahan program): lot JR conv 040000021140 ketemu, lot SR/JR base 0 (SRCBUX 9* belum dikenali TTA karena cek TTA hanya pada roll DO).
Belum: baseline DO 6286 ulang setelah klasifikasi pulih, ubah program (cek TTA pada `L_SR_BASE_BATCH`, rancangan §9), regresi, push sandbox.

## Status akhir 18 Nov 2026 (rantai converting, DO 0085006286)

- Rantai DEV lengkap: SRCBUX TTA (9*, Z3) -> JR converting JREYAI (order 100000073548, batch 0000407417, lot Z02 040000021140) -> SR converting SREYAI (order PPA2 A29000009001 + ZCA2 100000073549, batch 0000407419/0000407420) -> SO 7210 -> DO 0085006286.
- Temuan: pasangan GR 101 dan GI 261 dicocokkan program lewat MKPF-BKTXT yang sama. Level JR: BKTXT = nomor roll JR. Level SR: BKTXT = nomor order gabungan (ZCA2). Header GI/GR harus diisi sesuai.
- Klasifikasi batch: kirim hanya karakteristik input (termasuk ZZWIDTH, ZZLENGTH). Karakteristik numerik turunan memicu konflik E 842.
- Program (patch converting): TTA juga dideteksi pada batch SR Base Film di dalam rantai converting (TTA_CHECK/TTA_TRACE dipanggil ulang dengan L_SR_BASE_BATCH).
- Regresi harness 21 DO: 20 DO lama 0 selisih (value dan limit). DO 6286 value 10/10 cocok (ZQM002 = EXEC = ZQM003), sumber JR TTA lot 040000015885, PEYASTNT 0.
- Selisih limit 6 baris DO 6286 (ZQM002 tampil bulat 2|3, ZQM003/EXEC 1.50|2.50): bukan bug patch. MIC PEYAHZ00, PEYATH00, PEYASHMD, PEYASHTD, PEYATSMD, PEYATSTD tidak ada di QPMK DEV, jadi STELLEN = 0 dan print dibulatkan. DO lama memakai MIC yang ada di QPMK (STELLEN 2) dan tetap desimal.
- Push sandbox-new 18 Nov: TOP 486, F01 5923 baris, RS_SYNTAX_CHECK RC 0, readback identik. Backup pra-push: outputs/bak_20261118/ (sama dengan versi DEV).
- DEV belum memuat patch converting. Deploy F01/TOP dari tests/tta adalah langkah user, lalu regresi ulang 20 DO lama + 6285 + 6286.

## Regresi program DEV apa adanya setelah deploy ZEQM015 (18 Nov 2026)

User deploy versi `tests/tta` (TTA_TRACE sama dengan ZEQM015, termasuk 601 dan 543) ke DEV AIX. Source DEV dicek identik: TOP 486, F01 6042 baris. Program DEV apa adanya, 21 DO: `outputs/MT_20261118_dev_after_543.txt`, `outputs/LIMIT_20261118_dev_after_543.txt`.

- Tanpa error atau dump.
- 20 DO lama: value dan limit 0 selisih vs DEV TTA 17 Nov (`MT_20261117_dev_after_tta.txt`, `LIMIT_20261117_dev_after_tta.txt`).
- Identik dengan hasil harness (`MT_20261118_tta_543.txt`, `LIMIT_20261118_tta_543.txt`).
- DO 0085006285 dan 0085006286: value 10/10 = lot JR TTA 040000015885 (12.00, 23.00, 27.00, 133, 123, 2.00, 0.30, 2.00, 128, 0).
