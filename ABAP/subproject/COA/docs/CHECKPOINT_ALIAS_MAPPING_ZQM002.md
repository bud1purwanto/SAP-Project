# CHECKPOINT — Mapping ZMAP_COA Berbasis Alias (ZQM002)

| Atribut | Isi |
|---|---|
| Tanggal | 2026-11-11 |
| Status | **Rencana / desain — belum ada perubahan program** (menunggu konfirmasi QA, lalu perintah "execute" dari Baginda) |
| Program terdampak (rencana) | `ZQMI_COA_F01` (versi `_group`, sandbox-new) — bagian pembacaan `ZMAP_COA` & `LT_COA_MAP` |
| Data dicek | Development AIX (TRD) & Production AIX — **read-only** |
| Bukti data | `outputs/alias_mapping_20261111/` (`prd_alias_to_material_sample.json`, `prd_mic_compare.json`, `prd_alias_counts_sample50k.json`) |
| Deck QA | `docs/Alias_Mapping_ZQM002_QA.pptx` |

## 1. Permintaan User

- **Alias** (karakteristik batch `ZZALIAS`) menjadi patokan utama pencarian mapping di `ZMAP_COA`.
- Alias biasanya berisi `FTYPE + THICKNESS`. Alias dikonversi ke material, lalu dari material itu diambil mappingnya.
- **Material atau FTYPE berbeda tetapi alias sama → 1 mapping yang sama.**

## 2. Kondisi Sekarang (as-is)

Mapping dibaca per **DO item** dengan kunci material DO + Sold-to (`ZQMI_COA_F01_group.abap:399-444`):

1. `ZMAP_COA` dengan `MATNR = material DO`, `KUNNR = LIKP-KUNAG`, dan `DELETION <> 'X'` (mapping customer)
2. `ZMAP_COA` dengan `MATNR = material DO`, `KUNNR = ' '`, dan `DELETION <> 'X'` (mapping umum)
3. Override per MIC: customer menimpa umum. Lower/Upper/SEQ_NO hanya ditimpa kalau terisi.
4. Hasilnya disimpan di `LT_COA_MAP` dengan kunci `VBELN + MATNR + MIC`.

Alias saat ini **hanya dipakai untuk Product Name** di header COA, tidak untuk mapping.

## 3. Temuan Data

### 3.1 FTYPE + THICKNESS tersimpan di material (DEV)

| Material | MAKT | ZZCODE | CAWNT-ATWTB (ZZCODE) |
|---|---|---|---|
| SRACBI | SLITT ROLL HSB4-18 | ACB | HSB4-18 |
| SRCASI | SLITT ROLL EPB-12 | CAS | EPB-12 |
| SREASI | SLITT ROLL MZOB-50 | EAS | MZOB-50 |
| SRALZI | SLITT ROLL PWLMI7-70 | – | – |

FTYPE-THICK pada material tersedia dari dua sumber: **ZZCODE-ATWTB** (terstruktur) dan **MAKT** (teks dengan awalan `SLITT ROLL `).

### 3.2 Hanya sebagian alias yang cocok dengan FTYPE material (DEV)

| Alias | ZZCODE-ATWTB / MAKT |
|---|---|
| HSS-18 | ✅ SRACJI (`SLITT ROLL HSS-18`) |
| HSB-18, HSP-18, `HS - 18 M` | ❌ tidak ditemukan |

### 3.3 PRD: alias sama, material beda

Sampel 50.000 nilai `ZZALIAS` (AUSP, ATINN 0000000844) berisi 131 alias unik. Dari 45 alias teratas diambil 8 batch per alias dan ditelusuri materialnya lewat INOB:

| Alias | Material (MAKT) |
|---|---|
| GLOSS | SRIBRI (LCAT-24), SRIARI (LC01-22) |
| LC02 | SRIARI (LC01-22), SRIASI (LC02-20) |
| LF01 | SRICRI (LF01-25), SRKYGI (TLF01-25) |
| KZMB-9 | SREWCI (ZMB-9), SRKPKI (TZMB-9), SREUAI (ZB-9) |
| VMPET-9 | SRKPKI (TZMB-9), SREUAI (ZB-9) |

Ditemukan juga kebalikannya: **satu material dipakai banyak ejaan alias**. Contoh: SRCADI dipakai oleh `KTM-12`, `KTM`, `GP/FDW`, `PPF-12`, `IF-12`. SRCAHI dipakai oleh `KTM.12` dan `KTM.`. Isi alias tidak konsisten (ada titik, spasi, dan versi dengan/tanpa ketebalan).

### 3.4 PRD: perbandingan MIC antar material dengan alias sama

Sumber: QAMV dari lot Z04 terakhir per material.

| Alias | Kode MIC | Deskripsi MIC | Limit |
|---|---|---|---|
| GLOSS (SRIBRI vs SRIARI) | `SIBR*` vs `SIAR*` → **beda** | Sama (Seal to Paper, Surface Tension Non Th/Thermal) | **Beda**: Seal to Paper 3.5–6.5 vs 3.0–5.5 |
| LC02 (SRIARI vs SRIASI) | `SIAR*` vs `SIAS*` → **beda** | Sama | Sama |
| LF01 (SRICRI vs SRKYGI) | `SICR*` vs `SKYG*` → **beda** | Sama | Sama |
| KZMB-9 (SREWCI vs SRKPKI) | `SEWC*` vs `SKPK*` → **beda** | Sama | **Beda**: Optical Density 2.7–3.3 vs 3.0–3.5 |

Pola kode MIC: `S` + kode film material (3–4 huruf) + akhiran properti 4 huruf (`SPTH`, `STNE`, `STTH`, `ODMZ`, …). MIC umum (`DATBERAT`, `HARDNESS`, `STATIC*`, `THERMALS`, …) sama di semua material.

`ZMAP_COA` di PRD untuk 8 material di atas: **0 baris** (belum ada mapping di PRD).

### 3.5 Dampak ke desain

> **Kode MIC berbeda per material.** Kalau mapping material alias (misalnya SRIARI, MIC `SIARSPTH`) dipakai untuk batch SRIBRI, maka MIC itu **tidak ada di inspection lot batch** (yang ada `SIBRSPTH`). Program sekarang mencocokkan nilai dengan kode MIC persis, sehingga hasilnya Value kosong dan limit jatuh ke QPMK.

Artinya, mapping berbasis alias **wajib** punya aturan pencocokan MIC antar material, misalnya berdasarkan akhiran properti atau deskripsi.

## 4. Traceability

- **Tidak berubah.** Batch, material, inspection lot, dan genealogi tetap memakai material asli batch (`LIPS-MATNR` / `MCH1`). Nilai hasil (Value) tetap dibaca dari lot batch itu sendiri.
- Yang berubah hanya **tampilan COA**: daftar MIC, urutan (SEQ_NO), deskripsi, method, UOM, dan limit diambil dari mapping alias.
- **Risiko:** limit spec material asli bisa berbeda dengan limit di mapping alias (contoh GLOSS: 3.5–6.5 vs 3.0–5.5). Kalau mapping alias tidak mengisi Lower/Upper, limit akan ikut MIC material asli batch. Perlu keputusan QA: limit mana yang tercetak di COA.

## 5. Desain (rencana)

### 5.1 Konversi alias → material (pendekatan A, disetujui Baginda)

1. `CAWNT-ATWTB = alias` dengan ATINN = ZZCODE → nilai ZZCODE → material lewat `AUSP`/`INOB` (KLART 023, OBTAB MARA).
2. Kalau tidak ketemu: `MAKT-MAKTX = <awalan MAKT material DO> + alias` (contoh `SLITT ROLL HSS-18`).
3. Kalau ketemu lebih dari satu material: batasi ke awalan MATNR yang sama dengan material DO (SR/JR). Kalau masih lebih dari satu, pilih yang punya `ZMAP_COA`. Kalau masih lebih dari satu juga, ambil MATNR terkecil dan tampilkan warning.
4. Hasil di-cache per alias.

### 5.2 Hierarki mapping (per batch, disetujui Baginda)

```
Batch punya alias & berhasil dikonversi → MATNR_ALIAS
  ├─ ZMAP_COA ada untuk MATNR_ALIAS → pakai (KUNNR override per MIC → umum)
  └─ tidak ada                       → fallback ↓
Material DO (logic sekarang): MATNR_DO + KUNNR → MATNR_DO umum
```

- Alias kosong atau gagal dikonversi → pakai logic material DO, ditambah **warning** kalau alias ada tetapi gagal dikonversi (disetujui Baginda).
- Mapping material alias dan mapping material DO **tidak digabung**.
- Batch dengan alias berbeda dalam 1 DO → mapping **per batch** (disetujui Baginda). Kunci `LT_COA_MAP` ditambah `CHARG`.

### 5.3 Pencocokan MIC antar material (baru, dari temuan 3.4)

Mapping MIC material alias diterjemahkan ke MIC milik batch:
- MIC sama persis → langsung dipakai (MIC umum).
- MIC berbeda → dicocokkan lewat **akhiran properti** (4 karakter terakhir), dengan cadangan pencocokan **deskripsi** (QPMT-KURZTEXT).
- Kalau tidak ada padanan → MIC tetap tampil dengan nilai kosong, ditambah warning.

### 5.4 Yang tidak berubah

Struktur `ZMAP_COA`, program `ZMAP_COA_MIC`, aturan per-field limit (kosong berarti ikut MIC), filter `DELETION <> 'X'`, dan traceability lot.

## 6. Pertanyaan Konfirmasi ke QA

1. Alias sama tetapi limit spec material asli berbeda (GLOSS, KZMB-9): COA mencetak **limit mapping alias** atau **limit material asli batch**?
2. Ejaan alias tidak konsisten (`KTM-12`, `KTM.12`, `KTM`, `KTM.`): apakah dianggap **alias yang sama**? Kalau ya, perlu aturan normalisasi atau master alias.
3. Alias yang tidak cocok dengan FTYPE material mana pun (misalnya HSB-18): cukup fallback ke material DO + warning?
4. Apakah pencocokan MIC lewat akhiran properti (`SIBRSPTH` ↔ `SIARSPTH`) bisa diterima?
5. Material "acuan" untuk satu alias: siapa yang menentukan kalau satu alias dipakai beberapa material (misalnya KZMB-9 dipakai 3 material)?

## 7. Next Step

- [ ] Konfirmasi QA atas pertanyaan di bagian 6 (pakai deck `docs/Alias_Mapping_ZQM002_QA.pptx`)
- [ ] Revisi desain sesuai jawaban QA
- [ ] Tulis spec final + rencana implementasi
- [ ] **Execute hanya setelah Baginda bilang "execute"**
- [ ] Regresi L-QM01–15 + ML-QM01–04 + skenario alias baru
