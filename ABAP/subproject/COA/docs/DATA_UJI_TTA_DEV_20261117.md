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
