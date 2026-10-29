---
name: pp-analisa-production
description: Gunakan saat menganalisa kasus modul PP (Production/Process Order, confirmation, GR/GI order, status TECO, BOM, Jumbo Roll/Slit Roll, combine order) dengan membaca data dan program di Production AIX secara read-only.
---

# Skill: Analisa Modul PP di Production AIX (Read-Only)

## 1. Guardrail

- `set_active_server` → `prod` (Production AIX, PRT). **Read-only.**
- Hanya `read_table`, `read_table_structure`, `read_program`, `read_function_module`, `get_where_used`.
- Dilarang memanggil BAPI/FM yang mengubah data (confirmation, GR, TECO, change batch).
- Selalu beri filter (`AUFNR`, `CHARG`, `BUDAT`) dan batasi baris (≤ 200). Tidak membaca `MSEG`/`AUFM`/`JEST`/`AUSP` tanpa filter.
- Rekomendasi perbaikan data diserahkan ke user PP lewat transaksi standar. Perbaikan program dikerjakan di `sandbox-new`.

## 2. Peta Proses PP di Trias

```
Sales Order -> Planning PPIC -> Process Order JR (mesin film)
   -> GR Jumbo Roll (101) + GI bahan baku (261) + by-product/waste (531)
   -> Planning Slit Roll: original order -> combine order (AFPO-MILL_OC_AUFNR_U)
   -> ZPP001 (ZPPI_SR_PROCESS): GR SR 101 -> transfer 411 -> confirmation -> GI JR 261
   -> TECO (ZPPI_COHVPI / auto TECO) -> closing CO
```

Material: BOPP, BOPET, CPP, Metalizing, Coating. Nomor roll JR contoh `7 W1B 096 039` (line 1 digit) atau `P1 VAX 096 340` (line CPP 2 digit).

## 3. Tabel Kunci

| Tabel | Isi |
|---|---|
| `AUFK` | Header order (AUFNR, AUART, WERKS, ERDAT, OBJNR) |
| `AFKO` | Header order PP (GSTRP, GLTRP, PLNBEZ, RSNUM) |
| `AFPO` | Item order (MATNR, PSMNG target, WEMNG GR, CHARG, `MILL_OC_AUFNR_U` combine order) |
| `AFRU` | Confirmation (RUECK, RMZHL, STOKZ = batal) |
| `AUFM` | Goods movement per order |
| `JEST` / `TJ02T` | Status objek (OBJNR + STAT, INACT) / teks status (I0002 REL, I0045 TECO, I0012 DLV, I0046 CLSD) |
| `RESB` | Reservasi komponen |
| `MAST`/`STKO`/`STPO` | BOM link / header / item |
| `MKAL` | Production version |
| `ZMAP_TYPE` | Mapping konfigurasi (PROG, TYPE, OPT, VALUE), contoh order type SR original/combine |
| `ZSEQNUM` / `ZLOG_JRNO` | Counter nomor JR / log perubahan nomor JR |

## 4. TCODE

Standar: `COR3` (display process order), `COHV`/`COHVPI` (mass processing), `CO03`, `COOISPI` (order info system), `CORT`/`CORS` (confirmation display/cancel), `MB51`, `CS03`, `C223`.
Z: `ZPP001` (`ZPPI_SR_PROCESS`, proses SR), `ZPP090` (`ZPPI_CHANGE_JR_NUMBER`), `ZPP005N` (`ZPPR_PENDING_ORDER_ALF`), `ZPP003P` (`ZPPC_UPLOAD_SLITROLL`).

## 5. Resep Analisa

**A. Order tidak bisa / belum TECO**
1. `AUFK` → ambil `OBJNR`.
2. `JEST` WHERE `OBJNR = ...` AND `INACT = ' '` → daftar status aktif; terjemahkan via `TJ02T` (SPRAS = 'E').
3. Bandingkan `AFPO-PSMNG` vs `WEMNG`; cek GI terakhir di `AUFM`.
4. Cek apakah order masuk mapping order type program (`ZMAP_TYPE` PROG = program terkait).

**B. Selisih GR vs GI (closing)**
1. `AUFM`/`MSEG` per order + batch, movement 101/102/261/262/531/532.
2. Hitung netto: 101−102, 261−262. Abaikan dokumen yang sudah dibatalkan (`SMBLN`).
3. Bandingkan dengan toleransi (extra length ±1%).

**C. Duplikasi posting dari Z program**
1. Kronologi `MKPF` (CPUDT, CPUTM, USNAM, BKTXT) untuk order/batch.
2. Cocokkan dengan `AFRU` (ada/tidak confirmation setelah GR).
3. Baca source program, petakan urutan step dan `COMMIT`.
4. Cari guard (cek status/qty sebelum posting) dan mekanisme kompensasi.

## 6. Format Laporan

```
Ringkasan (bahasa awam, 3 kalimat)
Fakta data (tabel: waktu, user, dokumen, keterangan)
Root cause (proses / data / program) + bukti baris kode
Dampak
Rekomendasi: data (oleh user PP) | program (di sandbox-new)
Yang belum pasti
```
