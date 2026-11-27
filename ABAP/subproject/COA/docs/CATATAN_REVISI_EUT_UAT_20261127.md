# Catatan Revisi Blueprint → EUT/UAT COA (27 Nov 2026)

Sumber: `01_Blueprint_Confrimation_Final_-_SAP_Enhancement_for_COA_Automation_v3.pptx` (159 slide)
Hasil: `02_EUT_UAT_SAP_Enhancement_for_COA_Automation_v1.pptx` (128 slide). Generator: `../scripts/build_eut_deck.py`.

## Struktur baru (Agenda)
1. Ringkasan Program & Alur Penggunaan (slide baru: tabel T-Code/peran, prasyarat, alur 5 langkah)
2. Master Data – ZQM001 (Skenario 1 Mapping COA, Skenario 2 Mapping Batch List) — dipindah ke depan
3. Barrier Inspection – ZQM004 (Skenario 3–5)
4. Certificate of Analysis – ZQM002 (Skenario 6–11)
5. Report COA – ZQM003 (Skenario 12)
6. Checklist Skenario UAT (3 slide) & Berita Acara UAT

## Slide yang dihapus (31)
- 3–4 As-Is / To-Be business process, 6 tabel business process blueprint
- 24–25 (hidden) dampak rata-rata sampel barrier
- 46–58 penjelasan tracing & perhitungan → diganti 1 slide "Cara Sistem Mengisi Nilai COA"
- 78–79 penjelasan limit alias, 90 & 92–104 tracing 4 step (disisakan 1 contoh), 110 traceability TTA ke-2
- 129–130 contoh mapping customer khusus tambahan, 148 catatan finalisasi template batch list

## Perubahan isi
- Cover: "BLUEPRINT CONFIRMATION FINAL" → "END USER TRAINING & UAT"
- Judul sub-slide → "T-Code · Skenario N – nama"; divider diberi tabel T-Code, User, Data uji (diisi saat UAT)
- "Berdasarkan Konfirmasi Tim QA / Pak Abram / Confirmation" → "Catatan Penting"
- Slide pembuka ZQM002 & ringkasan nilai: aturan JR tanpa inspeksi diperbarui sesuai program terbaru
  (maks. 20 sequence JR **sebelumnya**, bulan sama lalu bulan sebelumnya), bukan "+20 ke atas"
- Typo: menginpukan, diinpeksi, kegenerate, Delate, submite, ourtcource, manikkan, undeletetion, Inspcetion, Lanscape, Potrait, Backgroud

## Perlu dicek user sebelum dipakai
- Kolom Department / End User Role / R/I/C/E/F di slide Ringkasan Program (asumsi: QA; E/E/F/R)
- Lingkungan uji ditulis "SAP QAS" di Berita Acara
- Nama T-Code transaksi Gun Scanner SR tidak ada di blueprint, ditulis "Gun Scanner + UD"
- Isi data uji (DO/batch) di tabel divider tiap skenario

## v2 (27 Nov 2026, masukan Aisyah – QA)
File: `02_EUT_UAT_SAP_Enhancement_for_COA_Automation_v2.pptx` (111 slide). Master Data, Barrier, Report tetap.
Bagian COA jadi 4 skenario, masing-masing dari Print COA sampai Print Batch List:
- Skenario 6 COA Base Film: selection, data COA, cara sistem mengisi nilai, tracing & rata-rata JR Base Film, Print → Print COA → Preview/Print, Batch List (Open/Save, portrait, landscape)
- Skenario 7 COA Converting: tracing & rata-rata SR Converting; print & batch list sama dengan Skenario 6
- Skenario 8 Out Limit → Change → Print: tanda X, print diblok, edit, Save, Print COA
- Skenario 9 Print COA dari TTA: selection, mapping TTA, traceability Trias → TTA
- Report COA jadi Skenario 10
Dihapus dari v1: 1 DO > 1 type film, type film alias, 4 step produksi, outsource vendor (Material X), Batch List sebagai skenario sendiri (sekarang bagian Skenario 6).
Nomor langkah dan callout di slide COA sudah dimulai dari 1 per skenario (Skenario 6: 1–11, Skenario 8: 1–4, Skenario 9: 1–3).
