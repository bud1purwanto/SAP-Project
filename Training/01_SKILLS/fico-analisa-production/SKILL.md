---
name: fico-analisa-production
description: Gunakan saat menganalisa kasus modul FI/CO (dokumen akuntansi, faktur pajak, change document, upload Z program ke BKPF/BSEG, settlement order) dengan membaca data dan program di Production AIX secara read-only.
---

# Skill: Analisa Modul FI/CO di Production AIX (Read-Only)

## 1. Guardrail

- `set_active_server` → `prod`. **Read-only.**
- Dilarang posting, reverse, atau mengubah dokumen FI.
- `BSEG` adalah cluster table besar: **wajib** filter `BUKRS` + `BELNR` + `GJAHR`.
- Data finansial bersifat rahasia: tampilkan seperlunya, jangan salin ke luar sistem.

## 2. Peta Proses

```
MM (GR/IR, MIRO) / SD (billing) / Manual (FB50) -> Dokumen FI (BKPF/BSEG)
  -> Faktur pajak (BKPF-XBLNR, upload ZFI106) -> Pelaporan
PP order -> Settlement (KO88/CO88) -> CO
```

## 3. Tabel Kunci

| Tabel | Isi |
|---|---|
| `BKPF` | Header dokumen FI (BUKRS, BELNR, GJAHR, BLART, BUDAT, XBLNR, CPUDT, AEDAT, UPDDT) |
| `BSEG` | Item dokumen FI (cluster) |
| `BSIS`/`BSAS`, `BSID`/`BSAD`, `BSIK`/`BSAK` | Index open/cleared G/L, customer, vendor |
| `CDHDR` / `CDPOS` | Change document header / item (OBJECTCLAS `BELEG` untuk dokumen FI) |
| `T001` | Company code |

## 4. TCODE

`FB03` (display doc), `FB02` (change — **jangan dipakai di training**), `FBL3N`/`FBL1N`/`FBL5N`, `SE16N` untuk `CDHDR`.
Z: `ZFI106` (`ZFIC_UPLOAD_FAKTUR`, upload nomor faktur pajak ke `BKPF-XBLNR`).

## 5. Konsep Penting

- `BKPF-AEDAT` = tanggal perubahan terakhir **oleh transaksi** — diisi oleh transaksi standar (FB02), bukan otomatis oleh setiap FM.
- `BKPF-UPDDT` = tanggal update terakhir.
- Jejak perubahan resmi ada di `CDHDR`/`CDPOS`; jika Z program mengubah dokumen tanpa membuat change document, jejak audit hilang.
- Perubahan dokumen FI harus lewat FM/BAPI resmi (contoh `FI_DOCUMENT_CHANGE`), bukan `UPDATE BKPF` langsung.

## 6. Resep Analisa

**A. Field tidak terupdate setelah Z program jalan**
1. Baca `BKPF` dokumen contoh: nilai field yang diubah vs field tanggal (AEDAT/UPDDT).
2. Cek `CDHDR` (OBJECTCLAS = 'BELEG', OBJECTID = BUKRS+BELNR+GJAHR) — ada change document atau tidak.
3. Baca source Z program: FM apa yang dipakai, field apa yang diisi.
4. Bandingkan dengan perilaku transaksi standar FB02.

## 7. Format Laporan

Ringkasan awam → bukti data (sebelum/sesudah) → lokasi kode → root cause → opsi solusi + risiko audit.
