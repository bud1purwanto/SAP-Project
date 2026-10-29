---
name: mm-analisa-production
description: Gunakan saat menganalisa kasus modul MM (movement stok, reversal, batch, stok per lokasi, Purchase Order, release strategy, email PO) dengan membaca data dan program di Production AIX secara read-only.
---

# Skill: Analisa Modul MM di Production AIX (Read-Only)

## 1. Guardrail

- `set_active_server` → `prod`. **Read-only.**
- Dilarang memanggil `BAPI_GOODSMVT_CREATE`, `BAPI_GOODSMVT_CANCEL`, `BAPI_PO_CHANGE`, `BAPI_PO_RELEASE`, atau FM tulis lain.
- `MSEG`/`MKPF` wajib difilter (MBLNR/MJAHR, atau MATNR+WERKS+CHARG, atau BUDAT sempit). Maks 200 baris.

## 2. Peta Proses MM

```
PR (ME51N) -> PO (ME21N) -> Release (ME28/ME29N, ZPO_AUTO_RELEASE) -> Email PO (ZMMI_PO_EMAIL)
  -> GR (MIGO 101) -> Stok -> GI produksi (261) / Transfer (311, 411) -> Invoice (MIRO)
```

## 3. Movement Type Penting

| Mvt | Arti | Pembatal |
|---|---|---|
| 101 | GR (dari PO / order) | 102 |
| 261 | GI ke order | 262 |
| 311 | Transfer antar SLoc | 312 |
| 411 | Transfer ke unrestricted (dari special stock) | 412 |
| 531 | GR by-product / waste | 532 |
| 901/902 | Custom movement Trias | — |

Pembatalan via `MBST` / `BAPI_GOODSMVT_CANCEL` mengisi `MSEG-SMBLN` (dokumen asal) + `SJAHR` + `SMBLP`.

## 4. Tabel Kunci

| Tabel | Isi |
|---|---|
| `MKPF` | Header dokumen material (BUDAT, CPUDT, CPUTM, USNAM, BKTXT) |
| `MSEG` | Item dokumen (BWART, MATNR, WERKS, LGORT, CHARG, MENGE, AUFNR, SMBLN) |
| `MCHA` / `MCH1` | Batch per plant / batch lintas plant (`LICHA` = vendor batch) |
| `MCHB` | Stok batch per SLoc |
| `MARA` / `MARC` / `MARD` | Material umum / per plant / per SLoc |
| `EKKO` / `EKPO` / `EKBE` | Header PO / item PO / histori PO |
| `EBAN` | Purchase Requisition |
| `T156T` | Teks movement type |

## 5. TCODE

`MB51` (material doc list), `MB03`/`MIGO` display, `MMBE`, `MB52`, `MSC3N` (display batch), `ME23N`, `ME2N`, `ME28`.
Z: `ZMMI_PO_EMAIL`, `ZPO_AUTO_RELEASE`.

## 6. Resep Analisa

**A. Hitung netto movement per batch**
1. `MSEG` WHERE `MATNR`, `WERKS`, `CHARG`, `BWART IN (101,102,261,262)`.
2. Netto GR = Σ101 − Σ102; netto GI = Σ261 − Σ262.
3. Tandai dokumen yang sudah dibatalkan: cari baris yang `SMBLN` menunjuk ke dokumen tersebut.

**B. Duplikat GR**
1. List 101 per AUFNR+CHARG. Lebih dari satu dokumen aktif (tanpa reversal) = duplikat.
2. Bandingkan `AFPO-WEMNG` vs `PSMNG`.
3. Kronologi `MKPF-CPUTM` + `USNAM`.

**C. PO tidak terkirim email / tidak release**
1. `EKKO-FRGKE`, `FRGZU` (status release).
2. Cek mapping exception di `ZMAP_TYPE` (PROG = `ZMMI_PO_EMAIL`).
3. Cek log SOST (status email) — hanya baca.

## 7. Format Laporan

Ringkasan awam → tabel dokumen (MBLNR, BWART, qty, user, waktu, SMBLN) → analisa netto → root cause → rekomendasi.
