# Rancangan Duplikasi Data Uji COA ke QA untuk UAT dan EUT (26 Nov 2026)

Status: **rancangan, belum dieksekusi**. Dianalisa oleh Opus, eksekusi oleh Sonnet per fase dengan izin user per tahap tulis.

Sumber referensi: `outputs/MASTER_TESTING_COA_SEMUA_SKENARIO.xlsx` dan `outputs/gui_test_all_20261118/GUI_TEST_COA_SEMUA_SKENARIO_DEV_20261118.xlsx` (21 DO, satu sheet per DO), `docs/MATRIX_DO_SKENARIO_COA.md`, `docs/STANDAR_SKENARIO_TESTING_COA.md` §0. Hasil probe mentah: `outputs/qa_prep_20261126/`.

---

## 1. Tujuan

Menyediakan di QA (TRQ, client 320) satu set DO uji yang mencakup ke-21 skenario COA di DEV (L-QM, ML-QM, AL-*, TTA-*), supaya tim QA/functional bisa menjalankan UAT dan EUT lewat ZQM002/ZQM003 dan mencocokkan nilainya dengan ZQM005.

## 2. Hasil analisa (probe read-only 26 Nov 2026)

| No | Temuan | Dampak |
|:-:|:--|:--|
| 1 | QA = `TRQ`, client **320 "QAS System Training"** (kategori T). Ada juga client 360 (copy TRP999). Koneksi SAP GUI "QA" 192.168.2.7 sudah ada di server :99. | Pastikan dengan user bahwa UAT/EUT memang di client 320. |
| 2 | Program **ZQMI_COA tidak ada** di QA. Tcode ZQM002 di QA masih menunjuk program lama `ZQMI_CERTIFICATE` (2012). ZQM001 dan ZQM003 tidak ada. (Koreksi: tcode `ZEQM015` = ZQMR_TRACEABILITY_TTE ada dan versinya sama.) | Blocker. Transport dulu: `CHECKLIST_TRANSPORT_COA_QA_20261126.md`. Data konkret: `RANCANGAN_DATA_UJI_QA_PER_SKENARIO_20261126.md`. |
| 3 | Tabel `ZMAP_COA`, `ZMAP_COA_GRP_COL`, `ZMAP_COA_GRP_CST`, `ZLOG_COA` **tidak ada** di QA. `ZQM_LOG_GS` ada. | Blocker. Tabel dan isi mapping harus masuk QA. |
| 4 | **0 dari 266** batch DO uji DEV ada di QA (MCH1). Data DEV tidak bisa disalin apa adanya. | Data uji QA harus dicari dari data QA sendiri atau dibangun ulang. |
| 5 | Nomor DO `0085006234`…`0085006286` di QA sudah dipakai DO lama tahun 2013 (customer lain). Nomor DO terakhir QA `0085051547` (25 Nov 2026). | DO QA pasti bernomor baru. Wajib tabel padanan DO DEV → DO QA. |
| 6 | KUNNR beda: `1141000514` di QA = PT. TOYOBO TRIAS ECOSYAR (DEV = Canopus), `1141000512` tidak ada di QA, `1141100304` beda nama. Yang lain sama. | Customer per skenario dicari ulang di QA berdasarkan **nama**, bukan nomor DEV. |
| 7 | 14 material FG uji ada di QA plant 2000. MIC (QPMK) seperti PCADELMD, PACBTH00, PAABTH00, PCADSTNT ada. `PEYASTNT` tidak ada (sama dengan DEV). | Master material cukup. |
| 8 | QA aktif dipakai (lot 2025–2026, DO November 2026). Lot dengan hasil (QAMR) sejak 2025 di plant 2000: **100 dari 736**. JR Z02 yang punya hasil antara lain JRAABI (7), JRACBI (2, 10 Nov 2026), JREWEI (2), JRCGAI (2), JRCADI, JRGIDI, JREASI, JRVC2I, JRGLAI, JRAC2I (masing-masing 1). Z05 SRCBUX 2 lot punya hasil. | Jalur "cari dulu" layak untuk sebagian besar skenario base film/converting. |
| 9 | Pengalaman DEV: hasil inspeksi lewat RFC sulit (BAPI_INSPOPER_RECORDRESULTS ditolak untuk lot UD, CHAR_RESULTS menutup karakteristik tanpa nilai, UD stock posting tidak bisa lewat RFC). | Skenario yang butuh nilai harus memakai lot QA yang **sudah** punya hasil, atau hasilnya diinput tim QA lewat QE51N di GUI. |

## 3. Prasyarat (harus beres sebelum fase tulis)

Semua langkah ini dikerjakan user/Basis, bukan Claude.

1. **Transport ke QA**: program `ZQMI_COA` (+ TOP/F01/F02/ALV, versi DEV terakhir 25 Nov), smartform/form COA, `ZEQM015`, tabel `ZMAP_COA`, `ZMAP_COA_GRP_COL`, `ZMAP_COA_GRP_CST`, `ZLOG_COA`, program `ZMAP_COA`, tcode ZQM001/ZQM002 (ubah ke ZQMI_COA)/ZQM003.
2. **Isi mapping**: entri `ZMAP_COA` untuk material uji (umum + customer khusus, termasuk alias PLE-22/SRAACI, HSB-18/HSS-18/HSP-18, SRCBUX PCAD*), plus `ZMAP_COA_GRP_*`. Kalau delivery class tabel = A, isi tidak ikut transport: export dari DEV dan upload ke QA lewat ZQM001 atau program upload (Fase 4).
3. **Otorisasi** user TRSTDEV (atau user yang dipakai) di QA 320 untuk VA01/VL01N/COR1/MSC1N/QE51N, dan izin RFC_ABAP_INSTALL_AND_RUN (harness).
4. **Keputusan user** atas pertanyaan di §9.

Sebelum prasyarat 1 dan 2 selesai, Sonnet hanya boleh menjalankan Fase 0–2 (read-only).

## 4. Strategi

Per skenario dipakai dua jalur, berurutan:

- **Jalur A, pakai data QA (utama)**: cari rantai yang sudah ada di QA (JR dengan hasil → SR hasil slitting → stok SR), yang polanya sama dengan skenario DEV. Claude hanya membuat **SO dan DO** (plus mapping khusus bila skenario butuh). Nilai acuan = rata-rata QAMR lot QA (ZQM005), bukan angka DEV.
- **Jalur B, bangun ulang (cadangan)**: bila pola tidak ada di QA, bangun ulang rantai dengan resep DEV (`memory coa-dev-order-creation-howto`, script `outputs/test_data_tta_20261118/`: COR1 BDC, MILL_OC, MSC1, GR/GI). Hasil inspeksi diisi tim QA lewat QE51N, bukan lewat RFC.

Aturan umum: DO dibuat tanpa PGI (sama seperti DEV), satu DO per skenario, item batch split PSTYV ZB.

## 5. Peta skenario → kriteria pencarian di QA

Kolom "Kandidat awal" adalah petunjuk dari probe (lot JR dengan hasil). Sonnet wajib memverifikasi genealogi maju (JR → SR → stok) sebelum dipakai.

| No | Skenario | DO DEV | Material FG | Pola yang harus ditemukan di QA | Kandidat awal QA | Jalur |
|:-:|:--|:--|:--|:--|:--|:-:|
| 1 | L-QM01 + L-QM15 | 6234 | SRCADI | BF normal: semua roll DO dari **1 JR** yang punya hasil. L-QM15 = edit value di print (ZLOG_COA), uji manual | JRCADI lot 040000140719 (batch 0003884634) | A |
| 2 | L-QM02 | 6235 | SRAABI | BF normal, roll dari **≥2 JR berbeda**, semua JR punya hasil | JRAABI 7 lot (mis. 040000140418/140419) | A |
| 3 | L-QM03 | 6240 | SRGIDI | Converting: SR dari JR converting, JR converting dari SR base film; 1 JR converting | JRGIDI 040000140803 | A |
| 4 | L-QM04 | 6241 | SREWEI | Converting, roll dari ≥2 JR converting | JREWEI 040000140500, 040000140749 | A |
| 5 | L-QM05/06 | 6242 | SRVC2I | BF, SR punya lot Z05/Z06 dan **change grade** (inspeksi dulu → change grade, dan sebaliknya) | JRVC2I 040000140735 | A, cek change grade; kalau tidak ada → B |
| 6 | L-QM07/08 | 6243 | SREASI | Converting + change grade | JREASI 040000140762 | A/B |
| 7 | L-QM09 | 6244 | SRAABI | BF, SR dari **secondary slitting** (SR → SR) | turunan JRAABI | A/B |
| 8 | L-QM10 | 6245 | SRGJBI | Converting + secondary slitting | belum ada JRGJ* berhasil | B |
| 9 | L-QM11 | 6270 | SRAABI | **Join 2 input JR** (1 roll dari 2 JR) + mapping khusus customer ATLANTIC BIRURAYA (cek nomor di QA) | turunan JRAABI | A/B + mapping |
| 10 | L-QM12 | 6271 | SRAABI | Join, 1 DO 2 JR, lot inspeksi seq ≥ 20 | turunan JRAABI | A/B |
| 11 | L-QM13 | 6272 | SREASI | 1 DO, roll dari **3 JR beda line** | JREASI | B kemungkinan besar |
| 12 | ML-QM01 | 6276 | SRACBI | Alias 1 (HSB-18), customer export | JRACBI 040000140835/140852 (10 Nov 2026) | A + alias |
| 13 | ML-QM02 | 6277 | SRACBI | >1 alias per batch (HSS-18, HSP-18) dalam 1 DO | JRACBI | A + alias |
| 14 | ML-QM03 | 6278 | SRGLBI | Produksi **4 tahap** BF → Coat → Metz → Coat | JRGLAI 040000140791 (cek rantai sampai SRGLBI) | A/B |
| 15 | ML-QM04 | 6279 | SREC7I | Outsource base film SR*X (tanpa JR BF di SAP) | cari SR*X di QA | A/B |
| 16 | AL-STRUKTUR | 6280 | SRAABI+SRABDI | Alias PLE-22 → SRAACI, 2 material, boleh value 0 | roll SRAABI/SRABDI apa saja | A (mudah) |
| 17 | AL-MIXED | 6281 | SRAABI | 1 roll alias PLE-22 + 1 roll tanpa alias | roll SRAABI | A (mudah) |
| 18 | AL-VALUE1 | 6282 | SRAABI | 3 roll dari 3 JR, semua punya hasil (Z02 saja), alias PLE-22 | JRAABI 3 lot berhasil | A |
| 19 | AL-VALUE2 | 6284 | SRAABI+SRAAAI | 2 material, masing-masing JR punya hasil, alias PLE-22, 2 baris ZB per item | JRAABI + cari JRAAAI/SRAAAI (Z05 SRAAAI 3 lot berhasil) | A |
| 20 | TTA-OUTSOURCE | 6285 | SRCBUX | Roll batch 9* + Z3, vendor batch ke lot JR TTA (plant TTA2) | Z05 SRCBUX 100000088703/88710; cek lot TTA2 | A/B |
| 21 | TTA-CONVERTING | 6286 | SREYAI | SRCBUX TTA → JR converting → SR converting SREYAI | tidak ada | B |

L-QM14 (banyak DO sekali cetak) tidak butuh DO sendiri: jalankan semua DO QA sekaligus.

## 6. Fase eksekusi (untuk Sonnet)

Semua script di `subproject/COA/outputs/qa_prep_20261126/` (pola probe yang sudah ada: `serverManager.setActiveServer('QA')`, `read_table`). Simpan output tiap fase sebagai JSON + ringkasan markdown.

### Fase 0, inventaris (read-only)
1. Ulangi `probe*.mjs` untuk memastikan status prasyarat §3 (TRDIR ZQMI_COA, DD02L ZMAP_COA, TSTC ZQM002 → ZQMI_COA).
2. Cari customer QA per skenario berdasarkan **nama** customer DEV (KNA1 NAME1 LIKE, huruf besar). Hasil: tabel KUNNR DEV → KUNNR QA. Kalau tidak ada, usulkan customer pengganti (catat).

### Fase 1, cari kandidat per skenario (read-only)
Untuk tiap baris §5:
1. Dari lot JR Z02 yang punya QAMR, telusuri maju: batch JR → order slitting (AFPO/AUFM 261 komponen = batch JR) → batch SR (GR 101) → stok SR tidak terblokir (MCHB CLABS > 0, plant 2000).
2. Untuk converting/multi-level: telusuri juga mundur dari JR converting ke SR base film (komponen 261) sampai lot base film.
3. Cek ciri khusus: change grade (MSEG 309/311 ganti material, atau log change grade), secondary slitting (SR jadi komponen order SR lain), join (1 order dengan ≥2 komponen JR), vendor batch TTA (MCH1-LICHA, plant TTA2), line produksi beda (ZZPRODLINE).
4. Tiap kandidat dicek terhadap trace program: jalankan harness read-only lokal (pool subroutine, `scripts/mt_pool_build2.mjs` pola DEV) **hanya setelah** tabel ZMAP_COA ada di QA. Sebelum itu cukup trace manual.
5. Output: `KANDIDAT_QA_<skenario>.json` + `docs/DATA_UJI_UAT_QA_20261126.md` tabel kandidat (skenario, roll, JR, lot, ada hasil?, stok?, customer QA, jalur A/B).

### Fase 2, review user (berhenti di sini)
Tunjukkan tabel kandidat dan daftar skenario jalur B. Minta izin tertulis untuk Fase 3–5 per kelompok skenario.

### Fase 3, buat SO + DO di QA (tulis, dengan izin)
1. SO: `BAPI_SALESORDER_CREATEFROMDAT2` + `BAPI_TRANSACTION_COMMIT` dalam **satu program sementara** (jebakan sesi RFC, lihat memory). Doc type, sales area, payment term ditiru dari DO QA yang sudah ada untuk material dan customer yang sama.
2. DO: `BAPI_OUTB_DELIVERY_CREATE_SLS`, lalu batch split ZB per roll (`WS_DELIVERY_UPDATE` / VL02N BDC), tanpa PGI. Program COA hanya membaca PSTYV ZB, jadi tiap roll harus jadi baris ZB.
3. Alias: isi ZZALIAS di item SO sesuai skenario (PLE-22, HSB-18, HSS-18/HSP-18).
4. Setiap dokumen yang dibuat dicatat di log (nomor, waktu, user, data input) supaya bisa dibatalkan.

### Fase 4, mapping (tulis, dengan izin)
1. Bandingkan isi `ZMAP_COA*` DEV dan QA untuk material/customer uji. Selisih yang dibutuhkan skenario (mapping customer khusus L-QM11, alias SRAACI, limit customer, SRCBUX PCAD*) diisi lewat ZQM001 di GUI atau upload, dengan KUNNR QA.
2. Override ZLOG_COA (L-QM15) **tidak** disiapkan; diuji tester saat UAT.

### Fase 5, jalur B (tulis, dengan izin, per skenario)
Bangun ulang rantai dengan resep DEV (COR1 BDC, MILL_OC, MSC1, GR 101 sloc 2804, klasifikasi batch BAPI_OBJCL_CHANGE). Hasil inspeksi lot baru diisi tim QA lewat QE51N + UD di GUI, karena RFC tidak bisa. Sebelum memulai, buat daftar langkah per skenario dan konfirmasi ke user.

### Fase 6, verifikasi dan paket UAT
1. Harness read-only di QA: ZQM002 = EXEC = ZQM003 per DO, simpan `outputs/qa_prep_20261126/MT_QA_<tanggal>.txt`.
2. Nilai acuan per MIC = rata-rata QAMR lot sumber (aturan ZQM002: rata-rata per INSLOT unik, lot JR kosong pakai saudara lebih lama, SR converting dihitung 1x per grup).
3. Uji GUI di server (:99, koneksi "QA", client 320): ZQM002 per DO + ZQM005 per lot, format Excel satu sheet per DO seperti `gui_test_all_20261118` (generator di folder itu). Simpan di `outputs/uat_qa_<tanggal>/`.
4. Paket UAT/EUT: Excel skenario (skenario, DO QA, langkah uji, nilai harapan, kolom hasil tester) + markdown per skenario.

## 7. Output akhir

| Berkas | Isi |
|:--|:--|
| `docs/DATA_UJI_UAT_QA_20261126.md` | Log data uji QA, padanan DO DEV → DO QA, rollback |
| `outputs/qa_prep_20261126/KANDIDAT_QA_*.json` | Kandidat per skenario |
| `outputs/qa_prep_20261126/MT_QA_*.txt` | Hasil harness QA |
| `outputs/uat_qa_<tgl>/UAT_EUT_COA_QA.xlsx` | Satu sheet per DO + sheet ringkasan, siap dipakai tester |
| Update `docs/MATRIX_DO_SKENARIO_COA.md` | Kolom DO QA |

## 8. Aturan main

- DEV dan PRD tidak diubah. PRD hanya baca, dan hanya bila user mengizinkan di sesi itu.
- QA hanya ditulis setelah izin user per fase (Fase 3, 4, 5 masing-masing).
- Tidak ada PGI, UD, atau posting stok tanpa izin eksplisit.
- Password tidak ditulis ke file, script, atau memory.
- Uji GUI di server :99, bukan laptop user. Logout `/nex` setelah selesai.
- Nilai harapan dihitung dari data QA, bukan disalin dari Excel DEV. Excel DEV dipakai sebagai acuan pola skenario dan format laporan.
- Selisih karena perubahan data oleh tim saat UAT dicatat sebelum/sesudah, user, tanggal (aturan §0.6 STANDAR).

## 9. Pertanyaan untuk user sebelum eksekusi

1. UAT/EUT di client **320**, bukan 360?
2. Siapa yang transport program + tabel COA ke QA, dan kapan? Fase 3–6 menunggu ini.
3. Untuk skenario yang tidak ada polanya di QA (perkiraan: L-QM10, L-QM13, TTA-CONVERTING, mungkin change grade dan secondary slitting): bangun ulang (jalur B, butuh tim QA isi hasil inspeksi di QE51N) atau cukup diuji di DEV?
4. Boleh pakai customer QA pengganti bila customer DEV tidak ada di QA (1141000512, 1141000514 = Canopus)?
5. EUT dan UAT pakai DO yang sama, atau EUT butuh set DO terpisah (supaya tester EUT tidak bentrok dengan edit value saat UAT)?
