---
name: qm-analisa-production
description: Gunakan saat menganalisa kasus modul QM (inspection lot, MIC, result recording, usage decision, barrier WVTR/OTR, Certificate of Analysis/COA) dengan membaca data dan program di Production AIX secara read-only.
---

# Skill: Analisa Modul QM di Production AIX (Read-Only)

## 1. Guardrail

- `set_active_server` → `prod`. **Read-only.**
- Dilarang result recording, usage decision, atau cetak ulang COA ke customer dari Production dalam rangka training.
- `QAMR`/`QASE`/`QAVE` difilter `PRUEFLOS`. Maks 200 baris.

## 2. Peta Proses QM

```
GR 101 (JR/SR) -> Inspection Lot otomatis (QALS)
  -> Result Recording per MIC (QE51N / ZQM004 barrier)
  -> Usage Decision (QA11) -> stok release
  -> Delivery Order (SD) -> COA (ZQMI_COA -> Smart Form ZQMF_COA + lampiran batch)
```

## 3. Tabel Kunci

| Tabel | Isi |
|---|---|
| `QALS` | Inspection lot (PRUEFLOS, MATNR, CHARG, ART lot type, OBJNR) |
| `QAMV` | Karakteristik per lot (MIC yang diuji) |
| `QAMR` | Hasil uji summary per karakteristik |
| `QASE` | Hasil uji per sampel |
| `QAVE` | Usage Decision (VCODE, VDATUM) |
| `QPMK` / `QPMT` | Master Inspection Characteristic / teks |
| `ZQM_COA_CUST_COL` | Konfigurasi kolom lampiran COA per customer (jumlah & urutan kolom) |
| `ZMAP_COA` | Mapping formula MIC untuk COA |

## 4. TCODE

Standar: `QA03` (display lot), `QE53`/`QE51N`, `QA32` (lot list), `QS23` (MIC), `QC51`.
Z: `ZQM002`/`ZQM003` (COA), `ZQM004` (`ZQMI_PENDING_BARRIER`, barrier), `ZQM001` (setup kolom COA).

## 5. Arsitektur COA (ringkas)

- `ZQMF_COA` = halaman 1 (sertifikat + MIC), selalu portrait.
- Lampiran batch: jumlah kolom ≤ 8 → `ZQMF_COA_BATCH_P1..P8` (portrait), 9–14 → `ZQMF_COA_BATCH_L9..L14` (landscape).
- Jumlah kolom ditentukan `ZQM_COA_CUST_COL` per customer/DO type.
- Contoh: DO `0085000140` (10 kolom, `SRACLI`) → halaman 1 portrait + lampiran landscape.

Detail: [ARCHITECTURE_COA_DYNAMIC.md](../../05_REFERENSI/COA/ARCHITECTURE_COA_DYNAMIC.md).

## 6. Resep Analisa

**A. Nilai di COA tidak sesuai**
1. Dari DO → batch (`LIPS`) → inspection lot (`QALS` by MATNR+CHARG).
2. `QAMR` per `PRUEFLOS`: bandingkan nilai dengan yang tercetak.
3. Cek mapping MIC (`ZMAP_COA`) dan kolom (`ZQM_COA_CUST_COL`).

**B. Lot barrier pending**
1. `QALS` lot tanpa UD (`QAVE` kosong).
2. Cek MIC barrier (WVTR/MVTR, OTR/O2TR) sudah ada hasil di `QAMR`.
3. Baca logic `ZQMI_PENDING_BARRIER` untuk kriteria pending.

## 7. Format Laporan

Ringkasan awam → jejak DO→batch→lot→hasil uji → letak selisih (data / mapping / form) → rekomendasi.
