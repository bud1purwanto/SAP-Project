---
name: sd-analisa-production
description: Gunakan saat menganalisa kasus modul SD (Sales Order, pending order, delivery order, billing, document flow) dengan membaca data dan program di Production AIX secara read-only.
---

# Skill: Analisa Modul SD di Production AIX (Read-Only)

## 1. Guardrail

- `set_active_server` → `prod`. **Read-only.**
- Dilarang membuat/mengubah SO, delivery, PGI, billing.
- Data customer (nama, alamat, harga) tidak disalin ke luar sistem.

## 2. Peta Proses SD

```
Inquiry/Quotation -> Sales Order (VA01) -> Production (PP) / Stock
  -> Delivery Order (VL01N) -> Picking/PGI (601) -> COA (QM) -> Billing (VF01) -> FI
```

## 3. Tabel Kunci

| Tabel | Isi |
|---|---|
| `VBAK` / `VBAP` | Header / item Sales Order |
| `VBEP` | Schedule line |
| `VBUK` / `VBUP` | Status header / item (ECC) |
| `LIKP` / `LIPS` | Header / item delivery (batch di `LIPS-CHARG`) |
| `VBRK` / `VBRP` | Header / item billing |
| `VBFA` | Document flow (SO → DO → billing) |
| `KNA1` | Master customer |

## 4. TCODE

`VA03`, `VL03N`, `VF03`, `VA05` (list SO), `VL06O`, `VF05`.
Z: `ZPP005N` (`ZPPR_PENDING_ORDER_ALF`, pending order SO vs production order), `ZQM002`/`ZQM003` (COA per DO).

## 5. Resep Analisa

**A. SO terlihat pending padahal sudah dikirim**
1. `VBUP` status delivery item (`LFSTA`, `GBSTA`).
2. `VBFA` cari dokumen penerus (VBTYP_N = J delivery, M invoice).
3. Bandingkan logic `ZPPR_PENDING_ORDER_ALF` (kriteria pending) dengan status nyata.

**B. Delivery → batch → COA**
1. `LIPS` per `VBELN` → `CHARG`.
2. Hubungkan ke QM (skill qm-analisa-production).

## 6. Format Laporan

Ringkasan awam → document flow (tabel) → status per dokumen → root cause → rekomendasi.
