# Day 08 — Batch Characteristic (CABN / AUSP / Class 023)

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★★ | PP / QM | `prod` (read-only) + `sandbox-new` (write) | 3–4 jam | pp-analisa-production, abap-dev-sandbox-new |

## Tujuan

1. Memahami bagaimana atribut batch (panjang, line produksi, nomor roll) disimpan di SAP Classification.
2. Membaca nilai karakteristik dari `CABN` + `AUSP`.
3. Mengatasi masalah format angka (scientific notation) di ALV.

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D08` — karakteristik batch dalam bentuk pivot (1 baris per batch) |
| 2 | Flow A (dari upload Slit Roll `ZPP003P` sampai karakteristik tersimpan) + Flow B (resolve ATINN → baca AUSP → pivot → format angka) |
| 3 | Tabel definisi karakteristik dari Production |

## Cerita Kasus

Report `ZPPR_PLANNING_SLITROLL` menampilkan karakteristik batch Slit Roll hasil upload `ZPP003P`
(`ZPPC_UPLOAD_SLITROLL`). Versi awal menampilkan panjang roll sebagai `1.2000000000000000E+04`, bukan `12.000`.
User bingung. Developer harus memperbaiki format angka sesuai jumlah desimal karakteristik.

## Konsep Kunci

```
CABN  (definisi karakteristik)  ATNAM = 'ZZPRODLINE'  ->  ATINN = 0000000857 (nomor internal)
                                  ATFOR = CHAR / NUM,  ANZDZ = jumlah desimal
AUSP  (nilai karakteristik)     OBJEK = kunci batch, ATINN, KLART = '023' (class type batch)
                                  ATWRT = nilai karakter,  ATFLV = nilai numerik (FLOAT)
```

- Class type **023** = batch class.
- Karakteristik penting Trias: `ZZPRODLINE` (line produksi, CHAR 2), `ZZNOMORROLL` (nomor fisik roll), `ZZLENGTH`/`ZZLENGTHSHT` (panjang, numerik), `ZZWEIGHTEL`.
- `ATFLV` bertipe FLOAT → jika ditulis langsung ke kolom CHAR menjadi notasi ilmiah. Solusi: pindahkan ke **packed decimal** (`TYPE p DECIMALS n`), lalu `WRITE ... TO` dengan desimal dari `CABN-ANZDZ`.
- Resolusi `ATNAM → ATINN` dilakukan **sekali** di awal (bukan per baris).

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | PPIC upload planning SR (`ZPP003P`) → batch SR dibuat → karakteristik terisi (`AUSP`) → dipakai report & COA |
| B — Program | Input → resolve `ATINN` sekali → ambil batch → baca `AUSP` bulk → pivot → konversi `ATFLV` → ALV |

Ikuti [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md).

## Langkah dengan AI

**Langkah 1 — definisi.**
```
Pakai skill pp-analisa-production, server prod read-only.
Baca CABN untuk ATNAM IN ('ZZPRODLINE','ZZNOMORROLL','ZZLENGTH','ZZLENGTHSHT').
Tampilkan ATINN, ATNAM, ATFOR, ANZST, ANZDZ dan jelaskan artinya.
```

**Langkah 2 — nilai untuk 1 batch.**
```
Ambil 1 batch Slit Roll dari MCH1 (filter MATNR + CHARG yang saya berikan).
Jelaskan bagaimana OBJEK di AUSP dibentuk untuk batch (cek dulu di sistem, jangan menebak),
lalu baca AUSP untuk OBJEK tsb dengan KLART = '023'. Tampilkan ATNAM, ATWRT, ATFLV.
```

**Langkah 3 — report di Sandbox.**
```
Pakai skill abap-dev-sandbox-new. Buat ZTRN_<INISIAL>_D08:
- Input: P_MATNR, S_CHARG
- Resolve ATINN dari CABN sekali
- Baca AUSP bulk (FOR ALL ENTRIES) untuk semua batch
- Pivot: 1 baris per batch, kolom = karakteristik
- Angka: ATFLV -> packed decimal -> WRITE dengan DECIMALS dari ANZDZ
- Tampilkan ALV
```

## Potongan Kode Kunci

```abap
DATA: lv_pack TYPE p LENGTH 16 DECIMALS 3,
      lv_text TYPE char30.

lv_pack = gs_ausp-atflv.                 " FLOAT -> packed, hilangkan E+04
WRITE lv_pack TO lv_text DECIMALS gs_cabn-anzdz.
CONDENSE lv_text.
```

**Langkah tambahan — flow.**
```
Buatkan Flow A dan Flow B (Mermaid) sesuai tabel "Flow yang Dibuat", berdasarkan kode program saya. Cek silang: setiap tabel dan keputusan di kode harus muncul di Flow B.
```

## Tugas

1. Tabel definisi 4 karakteristik di atas (dari Production).
2. Program `ZTRN_<INISIAL>_D08` tampil tanpa notasi ilmiah.
3. Jelaskan dengan kata sendiri: mengapa `ATINN` di-resolve sekali di awal?

## Checklist Selesai

- [ ] Paham relasi `CABN` ↔ `AUSP`, class type 023.
- [ ] Bisa membedakan `ATWRT` vs `ATFLV`.
- [ ] Format angka benar di ALV.

- [ ] Program `ZTRN_<INISIAL>_D08` berjalan di `sandbox-new` dan bisa dijelaskan baris per baris.
- [ ] Flow A & B selesai dan cocok dengan kode.

## Kuis

1. Class type berapa untuk batch?
2. Field `AUSP` mana yang menyimpan nilai numerik?
3. Apa risiko jika program me-SELECT `CABN` di setiap baris loop?

<details>
<summary>Kunci jawaban</summary>

1. `023`.
2. `ATFLV` (FLOAT).
3. Ribuan query kecil ke database (N+1 query) → lambat; padahal definisi karakteristik hanya beberapa baris dan cukup dibaca sekali.
</details>

## Referensi

- [TECHNICAL_NOTES.md](../05_REFERENSI/PLANNING_SLITROLL/TECHNICAL_NOTES.md) — bagian *Batch characteristics*.
- [FS_ZPPR_GI_JR_CLOSING.md](../05_REFERENSI/GI_JR_CLOSING/FS_ZPPR_GI_JR_CLOSING.md) — `ZZPRODLINE` ATINN 857.
