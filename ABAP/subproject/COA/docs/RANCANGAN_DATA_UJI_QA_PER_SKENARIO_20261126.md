# Rancangan Data Uji COA di QA per Skenario (UAT/EUT) — 26 Nov 2026

Status: **rancangan data konkret, belum ada yang dibuat di QA**. Sistem QA = TRQ client 320. Program COA belum ada di QA; transport mengikuti `CHECKLIST_TRANSPORT_COA_QA_20261126.md`. Pembuatan SO/DO tidak menunggu transport (dokumen SD tidak butuh program COA), tapi verifikasi nilai menunggu.

Dasar: penelusuran genealogi QA dengan program sementara read-only (`outputs/qa_prep_20261126/gen.abap`, hasil `gen_qa.txt` / `gen_qa.json` / `gen_summary.txt`, stok `stk_qa.txt`). Pola skenario dari Excel `MASTER_TESTING_COA_SEMUA_SKENARIO.xlsx` dan `MATRIX_DO_SKENARIO_COA.md`.

## 1. Cara genealogi QA (sudah dibuktikan)

Sama dengan yang ditelusuri program COA:

```
JR batch (lot Z02 + QAMR)
  └─ AUFM 261 di order gabungan ZCA2 (1000007xxxxx)
       └─ AFPO-MILL_OC_AUFNR_U = order referensi P29xxxxxxxxx
            └─ MSEG 101 AUFNR = P29… → batch SR (MCH1-LICHA = P29…)
Converting: order JR converting punya 261 SR base film perantara (SREWEA, SREASA, SRGIDA, SRGLAA, …)
```

Catatan: hasil (QAMR) di QA hanya ada di sebagian JR. Lot SR (Z04/Z05) jarang punya hasil.

## 2. Customer QA (padanan nama dari DEV)

| Customer DEV | Nama | KUNNR QA |
|:--|:--|:--|
| 1141000004 | AJINOMOTO INDONESIA | 1141000004 (sama) |
| 1141000026 | ATLANTIC BIRURAYA (mapping khusus L-QM11) | 1141000026 (sama; ada juga 1141000235 "PT. ATLANTIC BIRURAYA") |
| 1141000131 | JASUINDO TIGA PERKASA | 1141000131 (sama) |
| 1141000265 | SARIGUNA PRIMATIRTA | 1141000265 (sama) |
| 1141000514 | PT. CANOPUS KONVERTA (DEV) | **1141000584** (QA 514 = TOYOBO TRIAS ECOSYAR, jangan dipakai) |
| 1141000512 | PT. CANOPUS KONVERTA (DEV, override limit) | **1141000585** (tidak ada di QA) |
| 1141100081 | UPM RAFLATAC (export) | 1141100081 (sama) |
| 1141100236 | AMCOR FLEXIBLES PHETCHABURI | 1141100236 (sama) |
| 1141100239 | HUHTAMAKI (VIETNAM) | 1141100239 (sama) |
| 1141100304 | KT&G TÜTÜN MAMULLERI | **1141100516** (QA 304 = JOLIVETTE) |
| 1800000002 | NAVIS INDUSTRIES | 1800000002 (sama) |

Sebelum dipakai, cek KNVV (sales area 1000/00/00 seperti DO QA yang ada) untuk 1141000584/585 dan 1141100516.

## 3. Data per skenario

Kode jalur: **A** = data QA sudah ada, cukup buat SO + DO (+ klasifikasi batch/mapping). **A\*** = A, tapi perlu satu langkah data tambahan. **B** = rantai produksi belum ada di QA, harus dibangun ulang (order, GR, slitting, hasil inspeksi oleh tim QA).

| No | Skenario | DO DEV | Material | Customer QA | Data QA yang dipakai (JR → roll SR stok) | Jalur | Tambahan |
|:-:|:--|:--|:--|:--|:--|:-:|:--|
| 1 | L-QM01 + L-QM15 (BF, 1 JR) | 6234 | SRAABI *(pengganti SRCADI)* | 1141000584 | JR 0003885615 (lot 040000140842) → SR 0003885659, 0003885660, 0003885661 | A | SRCADI: JR 0003884634 punya hasil tapi belum di-slit (B). Pakai SRAABI supaya pola tetap. L-QM15 diuji tester (edit value). |
| 2 | L-QM02 (BF, beda JR) | 6235 | SRAABI | 1800000002 | JR 0003883654 (lot 140420) → SR 0003883662, 0003883663; JR 0003885615 → SR 0003885662, 0003885663 | A | — |
| 3 | L-QM03 (Conv, 1 JR) | 6240 | SRGIDI | 1800000002 | JR conv 0003884918 (lot 140803, input SRGIDA) → SR 0003885098, 0003885099, 0003885100 | A | — |
| 4 | L-QM04 (Conv, beda JR) | 6241 | SREWEI | 1800000002 | JR conv 0003884735 (lot 140749) → SR 0003885126, 0003885127 + **JR kedua**: cari SREWEI stok terbaru (12 Nov 2026) asal JR lain | A\* | JR 0003884248 punya hasil tapi SR-nya habis. Kalau JR kedua tanpa hasil → aturan saudara lot (lebih lama) tetap berlaku, catat. |
| 5 | L-QM05/06 (BF + change grade) | 6242 | SRVC2I | 1141000004 | JRVC2I 0003884650 (lot 140735) punya hasil, belum di-slit. 2 batch SRVC2I stok (02 Sep 2026) asal belum ditelusuri | B | Slitting + change grade (309 / MSC) oleh functional. |
| 6 | L-QM07/08 (Conv + change grade) | 6243 | SREASI | 1141000004 | JR conv 0003884762 (lot 140762) → SR 0003885210…214 | A\* | Change grade 2 roll (satu inspeksi dulu, satu change grade dulu) oleh tim QA/functional. Tanpa change grade = skenario conv 1 JR. |
| 7 | L-QM09 (BF secondary slitting) | 6244 | SRAABI | 1141000004 | SR 0003884165 (dari JR 0003883652, lot 140418) dipakai 261 di order **100000778527** → roll hasil order itu | A\* | Verifikasi output order 100000778527 masih stok. |
| 8 | L-QM10 (Conv secondary slitting) | 6245 | SRGJBI | 1141000004 | tidak ada JR SRGJ* dengan hasil | B | — |
| 9 | L-QM11 (join 2 JR + mapping customer) | 6270 | SRAABI | 1141000026 | tidak ada order slitting dengan ≥2 komponen JR di data 2025–2026 | B | Mapping khusus customer di ZMAP_COA (KUNNR 1141000026). |
| 10 | L-QM12 (join, 1 DO 2 JR, seq ≥ 20) | 6271 | SRAABI | 1141100516 | sama, tidak ada join | B | — |
| 11 | L-QM13 (1 DO 3 JR beda line) | 6272 | SREASI | 1141000265 | hanya 1 JR SREASI dengan stok | B | Alternatif murah: SRAABI 3 JR (0003883654, 0003885615, 0003884196) bila beda ZZPRODLINE — cek dulu. |
| 12 | ML-QM01 (alias 1) | 6276 | SRACBI | 1141100239 | JR 0003885608 (lot 140835) → SR 0003885794…799 | A\* | Klasifikasi batch ZZALIAS = HSB-18 di 6 roll (MSC2N / BAPI_OBJCL_CHANGE). |
| 13 | ML-QM02 (multi alias) | 6277 | SRACBI | 1141100081 | JR 0003885625 (lot 140852) → SR 0003885818…823 | A\* | ZZALIAS HSS-18 (4 roll) + HSP-18 (2 roll). |
| 14 | ML-QM03 (4 tahap) | 6278 | SRGLBI | 1141000131 | baru sampai SRGLAI (JR 0003884894 → SR 0003885242…). SRGLBI tidak ada stok | B | Coat → Metz → Coat di atas SRGLAI. |
| 15 | ML-QM04 (outsource SR*X) | 6279 | SREC7I | 1141100236 | SREC7I/SREC7X tidak ada stok | B | — |
| 16 | AL-STRUKTUR (2 material, value 0) | 6280 | SRAABI + SRAAAI *(SRABDI hanya 4 stok, 2014)* | 1141000584 | SRAABI 0003883666, 0003883667 + SRAAAI 2 roll stok apa saja | A\* | ZZALIAS PLE-22 → SRAACI (mapping alias di ZMAP_COA). |
| 17 | AL-MIXED | 6281 | SRAABI | 1141000585 | SRAABI 0003883679 (ZZALIAS PLE-22) + 0003883680 (tanpa alias) | A\* | Override limit customer 1141000585 seperti DEV (PAACTSTD 26–34). |
| 18 | AL-VALUE1 (3 JR, ada nilai) | 6282 | SRAABI | 1141000584 | 3 JR dengan hasil: 0003883654 → SR 0003883682; 0003885615 → SR 0003885664; 0003884196 → SR 0003884197 | A\* | ZZALIAS PLE-22 di 3 roll. |
| 19 | AL-VALUE2 (2 material, ada nilai) | 6284 | SRAABI + SRAC2I *(pengganti SRAAAI, tidak ada JR SRAAAI berhasil)* | 1141000584 | SRAABI 0003885665 (JR 0003885615) + SRAC2I 0003884267 (JR 0003884225, lot 140448) | A\* | ZZALIAS PLE-22 kedua roll; 2 baris ZB per item. Cek mapping alias menerima SRAC2I; kalau tidak, cari JR SRAAAI. |
| 20 | TTA-OUTSOURCE | 6285 | SRCBUX | 1141000584 | 75 batch SRCBUX 9* stok sloc 2804 (mis. 9003864618…), lot Z05 SRCBUX berhasil 100000088703/88710 | A\* | Cek batch 9* + Z3 punya jejak PO/vendor batch ke lot JR plant TTA2 (MCH1-LICHA kosong di sampel → telusuri lewat PO komponen seperti ZEQM015). |
| 21 | TTA-CONVERTING | 6286 | SREYAI | 1141000584 | SREYAI stok hanya batch 2018 | B | Rantai SRCBUX TTA → JR conv → SR conv seperti DEV. |

Ringkas: **jalur A/A\* = 14 skenario** (1, 2, 3, 4, 6, 7, 12, 13, 16–20), **jalur B = 7 skenario** (5, 8, 9, 10, 11, 14, 15, 21). L-QM14 = jalankan semua DO QA sekaligus.

Material pengganti (No 1, 16, 19) dipilih supaya **pola skenario** sama dengan DEV walau material beda. Kalau user/QA mau material persis, skenario itu pindah ke jalur B.

## 4. Langkah pembuatan (untuk eksekutor, per izin user)

### 4.1 Cek sebelum tulis (read-only)
1. Roll di tabel §3 masih stok tidak terblokir (MCHB CLABS) dan tidak dipakai DO terbuka lain (LIPS tanpa PGI).
2. Sales area, doc type SO, item category: tiru DO QA yang sudah ada untuk material sama (mis. DO 0085051525 SRAABI, 4 Nov 2026).
3. KNVV customer QA di §2.

### 4.2 Klasifikasi batch (A\*)
`BAPI_OBJCL_CHANGE` kelas batch roll SR, karakteristik ZZALIAS (nilai mentah, bukan teks tampilan) + `BAPI_TRANSACTION_COMMIT` dalam satu program sementara. Catat nilai sebelum (kosong) untuk rollback.

### 4.3 SO + DO
1. SO: `BAPI_SALESORDER_CREATEFROMDAT2` + commit, satu program sementara (jebakan sesi RFC di memory `coa-dev-order-creation-howto`).
2. DO: `BAPI_OUTB_DELIVERY_CREATE_SLS`, lalu batch split ZB per roll (VL02N BDC atau `WS_DELIVERY_UPDATE`). **Tanpa PGI.** Program COA hanya membaca baris PSTYV ZB.
3. Log tiap dokumen di `docs/DATA_UJI_UAT_QA_20261126.md`: skenario, DO DEV, SO/DO QA, roll, customer, waktu.

### 4.4 Mapping (setelah tabel ZMAP_COA ada di QA)
Isi entri yang dipakai skenario: mapping umum material uji, mapping customer khusus 1141000026 (L-QM11), alias PLE-22 → SRAACI, HSB-18/HSS-18/HSP-18, override limit 1141000585, SRCBUX PCAD*. KUNNR pakai nomor QA (§2).

### 4.5 Jalur B (7 skenario)
Butuh order produksi, GR, slitting (ZPP003P / MILL_OC / MSC1), dan **hasil inspeksi diinput tim QA lewat QE51N + UD** (RFC tidak bisa, terbukti di DEV). Susun daftar langkah per skenario dan minta konfirmasi user + jadwal tim QA sebelum mulai. Resep: `outputs/test_data_tta_20261118/` (cor1_bdc.mjs, slit_order.mjs, mill_oc.mjs, msc1_batch.mjs).

### 4.6 Nilai harapan
Setelah DO jadi: nilai harapan per MIC = rata-rata QAMR lot sumber (aturan ZQM002: rata-rata per INSLOT unik, lot JR kosong pakai saudara lebih lama, SR converting 1x per grup). Hitung dari QA, bukan dari Excel DEV. Setelah program ditransport: harness read-only + uji GUI server :99 koneksi "QA".

## 5. Rollback

DO dihapus (VL02N delete), SO di-reject/hapus, ZZALIAS dikembalikan kosong, entri ZMAP_COA uji dihapus. Semua dari log §4.3.

---

## 6. Hasil verifikasi §4.1 (read-only, 26 Nov 2026) dan daftar final jalur A

Bukti: `outputs/qa_prep_20261126/chk41_qa.txt`, `tbd2_qa.txt`, `tbd_qa_full.txt`, `sample.mjs`.

### 6.1 Koreksi terhadap §3
- **Skenario 7 (L-QM09) pindah ke jalur B.** Order secondary slitting 100000778527 menghasilkan SRAABI 0003884567 yang stoknya sudah 0.
- **Skenario 20 (TTA-OUTSOURCE) pindah ke jalur B.** SRCBUX 9003864618 di QA dibuat order 100000771932 dari komponen SRCBUO (batch 0003864914), tanpa vendor batch plant TTA dan tanpa PO komponen. Itu bukan pola TTA (LICHA + 601 + 543) seperti DEV. Lot SRCBUX Z05 yang punya hasil (100000088703/88710) tidak punya batch.
- Hitungan di §3 yang tertulis "14 skenario jalur A" salah hitung. Yang benar sebelum koreksi 13, setelah koreksi **11 jalur A/A\*** dan **10 jalur B** (5, 7, 8, 9, 10, 11, 14, 15, 20, 21).
- Skenario 18: roll 0003884197 diganti **0003884166** (JR 0003883652, lot 040000140418, ada hasil), karena 0003884197 muncul di DO lama 160036107–109 (tipe HSTP, status selesai).
- Skenario 16: SRAAAI = **0003632666** dan **0003632667** (sloc 2302, 149,39 kg). Nilai 0 memang diharapkan (struktur saja).
- Skenario 4: JR kedua = JREWEI 0003884733 (roll 0003885122–125). JR ini tidak punya hasil, jadi program memakai lot saudara; catat sebagai perilaku yang diuji.

### 6.2 Semua roll jalur A: stok ada, tidak terblokir, tidak ada di DO terbuka
Plant 2000. Sloc roll menentukan sloc item ZB di DO.

| No | Skenario | Material | Customer QA | Roll (batch @ sloc) |
|:-:|:--|:--|:--|:--|
| 1 | L-QM01 | SRAABI | 1141000584 | 0003885659, 0003885660, 0003885661 @2302 |
| 2 | L-QM02 | SRAABI | 1800000002 | 0003883662, 0003883663 @2322; 0003885662, 0003885663 @2302 |
| 3 | L-QM03 | SRGIDI | 1800000002 | 0003885098, 0003885099, 0003885100 @2310 |
| 4 | L-QM04 | SREWEI | 1800000002 | 0003885126, 0003885127 @2310; 0003885122, 0003885123 @2310 |
| 6 | L-QM07/08 | SREASI | 1141000004 | 0003885210–0003885214 @2310 |
| 12 | ML-QM01 | SRACBI | 1141100239 | 0003885794–0003885799 @2302 (ZZALIAS HSB-18) |
| 13 | ML-QM02 | SRACBI | 1141100081 | 0003885818–0003885823 @2302 (HSS-18 ×4: 818–821, HSP-18 ×2: 822–823) |
| 16 | AL-STRUKTUR | SRAABI + SRAAAI | 1141000584 | SRAABI 0003883666 @2073, 0003883667 @2074; SRAAAI 0003632666, 0003632667 @2302 (ZZALIAS PLE-22) |
| 17 | AL-MIXED | SRAABI | 1141000585 | 0003883679 (PLE-22), 0003883680 (tanpa alias) @2322 |
| 18 | AL-VALUE1 | SRAABI | 1141000584 | 0003883682 @2322, 0003885664 @2302, 0003884166 (sloc cek) (ZZALIAS PLE-22) |
| 19 | AL-VALUE2 | SRAABI + SRAC2I | 1141000584 | SRAABI 0003885665 @2302, SRAC2I 0003884267 @2302 (3,96 kg saja) (ZZALIAS PLE-22) |

Skenario 6 (L-QM07/08) butuh change grade pada 2 roll untuk menguji urutan; tanpa itu hanya menguji converting 1 JR.

### 6.3 Konfigurasi SO/DO (dari DO QA 0085051525, SO 0000015804, 4 Nov 2026)
- SO: tipe **ZEOR** (ekspor) pada contoh, VKORG 1000, VTWEG 02, SPART 00, VKBUR 0002, partner AG/RE/RG/WE, term DA30/DDU.
- DO: tipe ZELF, VSTEL 2000. Item induk PSTYV **ZP** qty 0, item batch **ZB** (900001) dengan CHARG + LFIMG + LGORT roll.
- Semua customer di §2 hanya punya sales area 1000/00/00 (kecuali 1141000584 juga 1800/00/00). Karena itu **ZEOR/VTWEG 02 tidak bisa dipakai apa adanya**. Pakai **ZDOR** (domestik, VTWEG 00) lebih dulu dan validasi lewat `BAPI_SALESORDER_SIMULATE` (tidak menulis). Program COA hanya membaca PSTYV ZB, jadi tipe dokumen tidak mempengaruhi hasil.
- `ZZALIAS` bukan field di SO/DO. Ia karakteristik klasifikasi batch (CABN), diisi lewat `BAPI_OBJCL_CHANGE`.

### 6.4 Urutan tulis ke QA (menunggu izin user)
1. `BAPI_SALESORDER_SIMULATE` per skenario (tidak menulis) → pastikan sales area, tipe, item category valid.
2. Klasifikasi batch ZZALIAS pada roll skenario 12, 13, 16, 17, 18, 19 (simpan nilai awal untuk rollback).
3. SO (`BAPI_SALESORDER_CREATEFROMDAT2` + commit) → DO (`BAPI_OUTB_DELIVERY_CREATE_SLS`) → batch split ZB per roll. Tanpa PGI.
4. Catat setiap dokumen di `docs/DATA_UJI_UAT_QA_20261126.md` (skenario, DO DEV, SO/DO QA, roll, customer, waktu).

---

## 7. Revisi: jumlah roll per DO lebih banyak (26 Nov 2026, usulan, belum dieksekusi)

Pemicu: tim UAT (Aisyah) menilai 1 DO hanya sekitar 2 roll rata-rata, padahal saat UAT user akan print Batch List dari DO dengan roll lebih banyak. Rancangan §3 dan §6.2 memakai 2–6 roll per DO.

Batas fisik: jalur A hanya bisa memakai roll yang sudah ada di QA. Jumlah roll tersedia per JR (sumber `gen_qa.json`, stok > 0):

| JR (batch) | Material | Roll stok | Dipakai rancangan lama | Sisa |
|:--|:--|:-:|:-:|:-:|
| 0003883654 | SRAABI | 14 | 662, 663, 666, 667, 679, 680, 682 | 665, 729–732, 745, 746 (7) |
| 0003885615 | SRAABI | 9 | 659–665 | 666, 667 (2) |
| 0003884225 | SRAC2I | 19 | 267 | 268–285 (18) |
| 0003884918 | SRGIDI | 6 | 098–100 | 101, 104, 105 (3) |
| 0003884735 | SREWEI | 4 | 126, 127 | 128, 129 (2) |
| 0003884762 | SREASI | 5 | 5 | 0 |
| 0003885608 / 0003885625 | SRACBI | 6 + 6 | 6 + 6 | 0 |

Catatan: satu roll tidak boleh ada di dua DO terbuka. Skenario SRAABI berebut roll dari kolam yang sama (25 roll total).

### 7.1 Jumlah roll usulan per skenario (jalur A)

| No | Skenario | Roll lama | Roll usulan | Tambahan roll |
|:-:|:--|:-:|:-:|:--|
| 1 | L-QM01 | 3 | 5 | SRAABI 0003885666, 0003885667 |
| 2 | L-QM02 | 4 | 10 | JR 0003883654: 0003883729–732, 0003883745, 0003883746 (tambah 6) |
| 3 | L-QM03 | 3 | 6 | SRGIDI 0003885101, 0003885104, 0003885105 |
| 4 | L-QM04 | 4 | 8 | SREWEI 0003885128, 0003885129 + 2 roll lagi dari JR 0003884733 (cek stok) |
| 6 | L-QM07/08 | 5 | 5 | sudah batas JR |
| 12 | ML-QM01 | 6 | 6 | sudah batas JR |
| 13 | ML-QM02 | 6 | 6 | sudah batas JR |
| 16 | AL-STRUKTUR | 4 | 4 | struktur saja, tidak perlu lebih |
| 17 | AL-MIXED | 2 | 2 | pola 1 alias + 1 tanpa alias, tidak perlu lebih |
| 18 | AL-VALUE1 | 3 | 3 | 1 roll per JR (aturan 3 JR) |
| 19 | AL-VALUE2 | 2 | 12 | SRAC2I 0003884268–0003884277 (10 roll tambahan, ZZALIAS PLE-22) |

Sisa kolam: SRAABI JR 0003883654 masih ada 0003883665 (hasil lot Z05 sudah ada). Dua JR SRAABI tidak bisa membuat DO 20 roll. Untuk satu DO "banyak roll" yang menguji batas tampilan, kandidat terbaik: **SRAC2I JR 0003884225, 18 roll sisa** (satu material, satu JR), pilih skenario 19 atau DO tambahan terpisah. Maksimum roll per DO di jalur A kira-kira 10–19, sesuai output slitting satu JR; DO > 20 roll butuh jalur B.

Catatan cost: setiap roll tambahan di skenario alias (12, 13, 16–19) butuh klasifikasi ZZALIAS lewat `BAPI_OBJCL_CHANGE` dan satu baris ZB di DO. Rollback tinggal menambah roll ke log §4.3.

### 7.2 Belum diverifikasi: tampilan Batch List dengan roll banyak

Belum diperiksa bagaimana layout Batch List (`ZQM_COA_DYN_ROLL` / `ZQM_COA_DYN_HDR`, smartform `ZQMF_COA_BATCH`) menangani 10–20 roll: pindah halaman, header berulang, kolom terpotong. Itu perlu diuji di DEV atau sandbox dengan DO banyak roll sebelum UAT, bukan hanya di QA. Ini juga yang perlu dijawab ke Aisyah.

### 7.2a Hasil cek stok roll tambahan (read-only di QA, 26 Nov 2026)

Bukti: `outputs/qa_prep_20261126/chk71.abap` dan `chk71_qa.txt` (program sementara read-only lewat RFC_ABAP_INSTALL_AND_RUN, tanpa tulis).

- Semua 27 roll tambahan §7.1 ada di stok plant 2000 dan tidak diblokir.
- **Pengecualian:** SREWEI 0003885122 sudah ada di DO terbuka 0085051557 (item ZB, belum PGI). Dikeluarkan dari skenario 4. Roll tambahan skenario 4 menjadi 0003885128, 129, 123, 124, 125, jadi total 7 roll, bukan 8.
- Sloc: SRAABI tambahan @2322 (0003883729–746) dan @2302 (0003885666–667); SRGIDI dan SREWEI @2310; SRAC2I @2302.
- SRAC2I 0003884268–277 stoknya hanya 3,96 kg per roll (sama dengan 0003884267). Cukup untuk uji jumlah baris, tapi bukan roll berat normal.

### 7.2b Hasil baca dokumentasi layout Batch List

`ARCHITECTURE_COA_DYNAMIC.md` hanya menjelaskan lebar kolom (P1–P8 portrait, L9–L14 landscape). Tidak ada keterangan jumlah roll per halaman atau perilaku pindah halaman. Jadi pertanyaan Aisyah tentang roll banyak masih terbuka sampai diuji di layar. Cara termurah: cari DO di DEV client 130 dengan item ZB paling banyak, lalu print Batch List lewat GUI server (baca saja, tidak mengubah apa pun).

### 7.3 Keputusan menunggu user

1. Apakah jumlah roll usulan §7.1 sudah sesuai, atau target UAT berbeda (misal minimal 10 roll per DO)?
2. Apakah perlu satu DO "volume" tambahan dari SRAC2I 18 roll, di luar 21 skenario?

---

## 8. Data referensi dari user: `00_Data.xlsx` (26 Nov 2026)

File: `/home/abap/.claude/uploads/local_58665913-7b8d-4014-9f51-bd97fd917769/00_Data.xlsx`, dua sheet: **Film Makking** (order 100000778905, JR → 9 roll SR per JR) dan **BF - CONV** (order converting + kolom "Inspeksi"). Instruksi user: pakai data ini sebagai referensi di QA, kalau tidak ada baru cari.

Bukti cek read-only di QA: `outputs/qa_prep_20261126/chk72.abap` / `chk72_qa.txt` (ada/stok/DO) dan `chk73.abap` / `chk73_qa.txt` (hasil inspeksi lot Z02). Daftar batch: `xl_batches.json`.

### 8.1 Hasil
- Dari 368 nomor di Excel, **361 batch ada di QA**. 7 yang tidak ada (5000770663–669, kolom SRVLCO) adalah nomor 10 digit awalan 5, bukan batch hasil produksi QA; perlu konfirmasi user nomor itu apa (PO/vendor batch?).
- Jadi data Excel ini **sudah ada di QA**. Stok roll bebas (stok > 0 dan belum pernah di DO): SRAABI 90 dari 99, SRACBI 52 dari 54, SRVLCX 3. JRCADI 12 JR dan JRVC2I 7 JR ada stok tapi belum di-slit (tanpa roll SR).
- **Hanya 15 dari 138 JR yang punya hasil inspeksi (QAMR)**, persis yang bertanda "Inspeksi": 0003885615 (SRAABI, 9 roll), 0003885608 dan 0003885625 (SRACBI, 6 roll masing-masing), 0003884634 (JRCADI, belum slit), 0003884650 (JRVC2I, belum slit), converting: 0003884608, 0003884624, 0003884644, 0003884673, 0003884735, 0003884762, 0003884786, 0003884836, 0003884894, 0003884918.
- Alias di Excel pada JRACBI: 3885607 HSB4-18, 3885609 HSB-18, 3885610 HSP-18, 3885611 HSS-18 (sheet Film Makking), tambahan terhadap rancangan skenario 12 dan 13.

### 8.2 Dampak ke rancangan
1. **Banyak roll per DO bisa dicapai tanpa membangun baru.** SRAABI punya 11 JR × 9 roll (sampai 90 roll bebas), SRACBI 52 roll bebas. DO banyak roll (misal 18–27 roll lintas 2–3 JR SRAABI) cukup dengan SO/DO dari stok ini.
2. **Nilai QAMR hanya ada di 15 JR di atas.** Roll dari JR tanpa hasil memakai aturan saudara lot (lot lebih lama yang punya hasil). Itu perilaku sah dan bisa diuji, tapi nilai di Batch List/COA berasal dari lot saudara, jadi untuk skenario "ada nilai" pilih roll dari JR bertanda Inspeksi dulu.
3. Roll 0003885659–667 (JR 0003885615) dan 0003885794–799, 0003885818–823 (JRACBI) sama dengan yang sudah dipakai di §3 dan §6.2. Skenario 1, 2, 18, 19 berebut 9 roll JR 0003885615; roll dari JR lain tanpa hasil dipakai hanya sebagai tambahan jumlah.
4. Material converting (SRGIDI, SREASI, SREWEI dst.) yang di Excel tertulis sebagai kolom JR: roll SR-nya sebagian sudah dicek di §7; belum dihitung ulang per Excel.

### 8.3 Langkah berikut (usulan, belum dijalankan)
1. Update tabel §3 dan §6.2 memakai Excel sebagai sumber utama, dengan prioritas JR yang punya QAMR; tambah roll bebas dari JR tanpa QAMR hanya untuk memperbanyak jumlah.
2. Konfirmasi user soal 7 nomor SRVLCO dan ke mana nilai alias HSB4-18 / HSB-18 / HSP-18 / HSS-18 dipakai.
3. Fase tulis (klasifikasi ZZALIAS, SO/DO) tetap menunggu izin user.

---

## 9. Susun ulang: DO uji yang SUDAH ada di QA (cek read-only 26 Nov 2026)

Bukti: `outputs/qa_prep_20261126/chk74_qa.txt`, `chk75_qa.txt`, `chk76_qa.txt`.

### 9.1 Temuan: DO uji sudah dibuat user di QA hari ini
Ada 17 DO baru (dibuat 26.11.2026 oleh user TRST-BUDI, status belum PGI), masing-masing **hanya 1–2 roll ZB**. Inilah "1 DO cuma 2 roll" yang disebut Aisyah. Rancangan §3–§7 (membuat SO/DO baru) **digantikan**: yang dikerjakan adalah **menambah roll ke DO yang sudah ada**.

| DO | Tipe | Customer | Material | Roll sekarang |
|:--|:-:|:--|:--|:--|
| 0085051549 | ZDLF | 1141000004 | SRAABI | 3885641, 3885642 |
| 0085051551 | ZELF | 1800000002 | SRAABI | 3885650, 3885651 |
| 0085051555 | ZDLF | 1141000004 | SRCADI | 3817915, 3817916 |
| 0085051556 | ZDLF | 1141000026 | SRGIDI | 3885074, 3885075 |
| 0085051557 | ZDLF | 1141000488 | SREWEI | 3885060, 3885122 |
| 0085051562 | ZDLF | 1141000494 | SRVC2I | 3884850, 3885919 |
| 0085051563 | ZDLF | 1141000516 | SREASI | 3885202, 3885920 |
| 0085051564 | ZDLF | 1141000131 | SRIA5I | 3885336, 3885337 |
| 0085051565 | ZDLF | 1141000265 | SRACBI | 3885788, 3885800 |
| 0085051570 | ZDLF | 1141000004 | SRGJBI | 3758344, 3758354 |
| 0085051571 | ZDLF | 1141000004 | SRGLAI | 3885234, 3885235 |
| 0085051572 | ZDLF | 1141000026 | SRVLCX | 3883090, 3883091 |
| 0085051573 | ZDLF | 1141000004 | SRAABI | 3885659, 3885660 |
| 0085051577 | ZDLF | 1141000004 | SRAABI | 3885661, 3885662 |
| 0085051578 | ZDLF | 1141000004 | SREYAI | 3203767 (1 roll) |
| 0085051579 | ZDLF | 1141000004 | SRWCNI | 3879068 (1 roll) |
| 0085051582 | ZDLF | 1141000004 | SRAABI | 3885659, 3871415 |
| 0085051583 | ZELF | 1800000002 | SRCBUX | 9003874855 (1 roll) |

DO 0085051544–047 (ZELF, 25 Nov, customer 1141100005) belum punya item ZB.

### 9.2 Masalah yang perlu dibereskan
- Roll **3885659 dipakai di dua DO** (0085051573 dan 0085051582). Satu harus diganti roll lain.
- Roll **3885122** di DO 0085051557 sudah kita keluarkan dari rencana lama, tapi sekarang bagian dari DO itu.
- Semua DO ini customer 1141000004 / 1800000002 dll., bukan customer padanan skenario §2. Customer yang dipilih user dianggap sah; tidak diubah.

### 9.3 Roll tambahan yang tersedia (baru terverifikasi untuk DO SRAABI)
Dari JR 0003885615 (punya hasil QAMR), roll bebas dan belum di DO: **3885663, 3885664, 3885665, 3885666, 3885667** (stok @2302). Dari Excel, JR SRAABI lain (tanpa QAMR) menyediakan 9 roll per JR: 3885641–649, 650–658, 668–676, 677–685, 686–694, 695–703, 704–712, 713–721, 722–730, 731–739 (3885648 stok 0; 3885641/642/650/651 sudah di DO 0085051549/551). SRACBI bebas 52 roll.
Untuk DO bermaterial lain (SRGIDI, SREWEI, SREASI, SRVC2I, SRIA5I, SRGLAI, SRACBI dst.), daftar roll bebas per JR belum dihitung karena roll awalnya di luar genealogi yang saya telusuri (`gen_qa.json`).

### 9.4 Usulan susun ulang (belum dijalankan)
1. Pertahankan 17 DO user. Untuk tiap DO, tambah roll dari **JR yang sama dengan roll yang sudah ada** sampai jumlah mendekati DEV (±9–12 roll; SRACBI/SRAABI bisa lebih).
2. Jalankan cek read-only per DO (JR asal roll, stok, tidak di DO lain) sebelum menambah, untuk DO non-SRAABI.
3. Tambah item ZB di DO (VL02N BDC atau `WS_DELIVERY_UPDATE`, tanpa PGI). **Mengubah DO milik user, jadi butuh izin eksplisit per DO.**
4. Klasifikasi ZZALIAS dan mapping ZMAP_COA tetap sesuai §4.2 dan §4.4 setelah transport.


---

## 10. Hitung roll tambahan per DO (read-only, 26 Nov 2026)

Bukti: `outputs/qa_prep_20261126/gen78.abap`, `gen78_qa.txt`, `chk79_qa.txt`, `do_free.json`. Cara: roll DO → order P29 (MSEG 101) → order ZCA (AFPO-MILL_OC_AUFNR_U) → JR (MSEG 261) → semua order slitting JR itu → roll saudara bermaterial sama, stok > 0, tidak ada di DO mana pun. Angka di kolom "roll bebas" nomor batch 7 digit terakhir (awalan 000).

| DO | Material | JR asal | Roll bebas | Daftar |
|:--|:--|:--|:-:|:--|
| 0085051549 | SRAABI | 0003885613 | 6 | 3885643, 3885644, 3885645, 3885646, 3885647, 3885649 |
| 0085051551 | SRAABI | 0003885614 | 7 | 3885652, 3885653, 3885654, 3885655, 3885656, 3885657, 3885658 |
| 0085051555 | SRCADI | 0003844097 (QAMR) | 0 | - |
| 0085051556 | SRGIDI | 0003884912 | 4 | 3885076, 3885077, 3885080, 3885081 |
| 0085051557 | SREWEI | 0003884733, 0003885059 | 3 | 3885123, 3885124, 3885125 |
| 0085051563 | SREASI | 0003884760 | 4 | 3885203, 3885204, 3885205, 3885206 |
| 0085051564 | SRIA5I | 0003884784 | 10 | 3885338, 3885339, 3885340, 3885341, 3885342, 3885343, 3885344, 3885345, 3885346, 3885347 |
| 0085051565 | SRACBI | 0003885607, 0003885609 | 10 | 3885789, 3885790, 3885791, 3885792, 3885793, 3885801, 3885802, 3885803, 3885804, 3885805 |
| 0085051570 | SRGJBI | 0003761724 (QAMR), 0003761847 (QAMR) | 0 | - |
| 0085051571 | SRGLAI | 0003884892 | 5 | 3885236, 3885237, 3885238, 3885328, 3885329 |
| 0085051573 | SRAABI | 0003885615 (QAMR) | 5 | 3885663, 3885664, 3885665, 3885666, 3885667 |
| 0085051577 | SRAABI | 0003885615 (QAMR) | 5 | 3885663, 3885664, 3885665, 3885666, 3885667 |
| 0085051578 | SREYAI | 0003516347 (QAMR) | 0 | - |
| 0085051579 | SRWCNI | 0003879043 | 0 | - |
| 0085051582 | SRAABI | 0003885615 (QAMR) | 5 | 3885663, 3885664, 3885665, 3885666, 3885667 |

Tidak bisa dilacak (belum ada hitungan): DO 0085051562 (SRVC2I; roll 3885919 tanpa order 101, 3884850 tanpa JR di ZCA 100000778610), 0085051572 (SRVLCX, tanpa order 101), 0085051583 (SRCBUX, order 100000775274 tanpa ZCA). Roll 3871415 di DO 0085051582 juga tanpa order 101.

### 10.1 Kesimpulan
- **Roll bebas dari JR yang sama hanya 3–10 per DO.** Hanya SRIA5I dan SRACBI mencapai 10. Target ±9–12 roll per DO tercapai hanya untuk SRAABI (kalau memakai JR lain dari Excel), SRIA5I dan SRACBI.
- DO 0085051555 (SRCADI), 0085051570 (SRGJBI), 0085051578 (SREYAI), 0085051579 (SRWCNI) **tidak punya roll saudara bebas**: data lama QA, hasil QAMR ada tapi stok tersisa hanya roll di DO tersebut. Untuk banyak roll, harus bangun rantai baru (jalur B) atau terima 1–2 roll.
- **DO SRAABI 0085051573 / 0085051577 / 0085051582 berebut 5 roll bebas** dari JR 0003885615 (663–667; ini satu-satunya JR SRAABI di Excel dengan QAMR). Tambahan jumlah roll harus dari JR SRAABI lain di Excel (tanpa QAMR, 9 roll per JR), dengan nilai dari lot saudara.
- **Hanya JR dengan QAMR yang punya nilai sendiri**: 0003844097 (SRCADI), 0003761724 / 0003761847 (SRGJBI), 0003885615 (SRAABI), 0003516347 (SREYAI). JR lain (SRAABI 3885613/3885614, SRGIDI, SREWEI, SREASI, SRIA5I, SRACBI 3885607/3885609, SRGLAI) tanpa QAMR, jadi nilai Batch List/COA dari lot saudara atau kosong.
- Dua dari DO ini memakai roll dari dua JR sekaligus (SREWEI, SRACBI, SRGJBI), cocok untuk skenario "beda JR".

### 10.2 Keputusan menunggu user
1. Terima jumlah roll terbatas ini (3–10 per DO), atau bangun rantai baru (jalur B) untuk DO yang rollnya habis?
2. DO SRAABI 573/577/582: roll tambahan dari JR SRAABI lain dalam Excel (tanpa QAMR) boleh, atau harus JR dengan QAMR?
3. Boleh ubah DO milik user (VL02N tambah ZB), per DO, setelah daftar roll disetujui?

---

## 11. EKSEKUSI: roll ditambah ke DO uji di QA (26 Nov 2026)

Dijalankan atas perintah user ("selesai, saya ingin banyak data"). Per DO: `BAPI_SALESORDER_CHANGE` (naikkan qty item SO 000010 + schedule line, karena VL 363 "Delivery quantity is greater than target quantity") lalu `BAPI_OUTB_DELIVERY_CHANGE` (tambah item ZB 9000xx, parent 000010), commit. Tanpa PGI. Program dan log: `outputs/qa_prep_20261126/add2_<DO>.abap/.log`; verifikasi akhir `ver_qa.txt`.

| DO | SO | Material | Roll lama | Roll sekarang | SO qty lama → baru (kg) |
|:--|:--|:--|:-:|:-:|:--|
| 0085051549 | 15855 | SRAABI | 2 | 17 | 480,48 → 3.472,58 |
| 0085051551 | 15856 | SRAABI | 2 | 18 | 480,48 → 3.590,52 |
| 0085051573 | 15867 | SRAABI | 2 | 13 | 240,24 → 2.515,98 |
| 0085051577 | 15868 | SRAABI | 2 | 14 | 480,48 → 2.629,56 |
| 0085051582 | 15871 | SRAABI | 2 | 11 | 120,12 → 1.915,38 |
| 0085051556 | 15858 | SRGIDI | 2 | 12 | 1.062,44 → 5.103,88 |
| 0085051557 | 15859 | SREWEI | 2 | 9 | 362,88 → 2.585,52 |
| 0085051563 | 15861 | SREASI | 2 | 11 | 400,00 → 5.330,38 |
| 0085051564 | 15862 | SRIA5I | 2 | 24 | 135,12 → 1.624,16 |
| 0085051565 | 15863 | SRACBI | 2 | 18 | 609,00 → 5.483,82 |
| 0085051571 | 15865 | SRGLAI | 2 | 14 | 1.113,84 → 6.683,04 |

Tidak diubah (rantai tidak bisa dilacak atau tidak ada roll saudara bebas): 0085051555, 562, 570, 572, 578, 579, 583 (1–2 roll). DO 0085051544–047 tanpa item ZB.

Catatan: roll 3885659 tetap ganda di DO 0085051573 dan 0085051582 (tidak diubah). Roll tambahan SRAABI banyak berasal dari JR tanpa QAMR (nilai dari lot saudara). DO 0085051564 SRIA5I: kg lama 135,12 karena roll 67,56 kg. Rollback: hapus item ZB 9000xx tambahan di VL02N dan kembalikan qty SO ke angka lama di tabel.

---

## 12. DO export baru di QA (27 Nov 2026)

Permintaan Aisyah (QA): data UAT harus ada customer export. Dibuat 4 SO ZEOR (VTWEG 02, VKBUR 0002, tanpa sales group) + 4 DO ZELF, tiap DO dengan item ZB per roll, tanpa PGI. SO dibuat lewat `BAPI_SALESORDER_CREATEFROMDAT2` dengan `EXTENSIONIN` BAPE_VBAP (ZDATE = tanggal hari ini, ZLINE = 1, wajib: validasi "Tanggal dan Line produksi harus diisi"), DO lewat `BAPI_OUTB_DELIVERY_CREATE_SLS`, roll lewat `BAPI_OUTB_DELIVERY_CHANGE`. Program dan log: `outputs/qa_prep_20261126/so_E*.abap`, `do_E*.abap`, `sp_E*.abap`, `.log`.

| DO | SO | Customer (negara) | Material | Roll | Sumber roll |
|:--|:--|:--|:--|:-:|:--|
| 0085051584 | 15873 | 1141100081 UPM Raflatac (CN) | SRACBI | 12 | JR 3885625 (QAMR) 818–823 + JR 3885611 812–817 |
| 0085051585 | 15874 | 1141100239 Huhtamaki (VN) | SRACBI | 12 | JR 3885608 (QAMR) 794–799 + JR 3885610 806–811 |
| 0085051586 | 15875 | 1141100236 Amcor Phetchaburi (TH) | SRAABI | 18 | JR 3885627/628 roll 713–730 |
| 0085051587 | 15876 | 1141100516 KT&G (TR) | SRACBI | 12 | JR 3885631/632 roll 830–841 |

Export lama: DO 0085051551 (customer 1800000002, negara US, SRAABI 18 roll) dan 0085051583 (SRCBUX 1 roll) sebenarnya sudah export.
Belum dicek: apakah keempat customer masuk daftar grup EXP-01 (28 KUNNR). Rollback: hapus DO (VL02N) lalu SO (VA02 reject/hapus).
