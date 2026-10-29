# 03 — Glosarium

Istilah yang sering muncul selama 14 hari. Urut abjad.

| Istilah | Arti singkat |
|---|---|
| **ABAP** | Bahasa pemrograman SAP. Sistem ini versi 7.31. |
| **ALV** | ABAP List Viewer — tampilan tabel interaktif (sort, filter, export Excel). |
| **AUFNR** | Nomor order (Production/Process Order). |
| **BAPI** | Function Module standar SAP untuk membuat/mengubah data dengan aman (contoh `BAPI_GOODSMVT_CREATE`). |
| **Batch (CHARG)** | Nomor lot fisik material. Di Trias: nomor Jumbo Roll / Slit Roll. |
| **Batch Characteristic** | Atribut batch (panjang, lebar, line produksi). Disimpan di `AUSP`, definisinya di `CABN`. |
| **COA** | Certificate of Analysis — sertifikat hasil uji kualitas untuk customer. |
| **Combine Order** | Order gabungan beberapa original order dengan spesifikasi sama (Slit Roll). |
| **COMMIT WORK** | Menyimpan permanen perubahan dalam satu LUW. |
| **DDIC** | Data Dictionary (SE11): definisi tabel, struktur, data element, domain. |
| **FM (Function Module)** | Fungsi yang bisa dipanggil ulang (SE37). |
| **FOR ALL ENTRIES (FAE)** | Teknik SELECT berdasarkan isi internal table. Wajib cek tabel tidak kosong. |
| **FS / TS** | Functional Spec (apa yang diminta bisnis) / Technical Spec (bagaimana dibuat). |
| **GI / GR** | Goods Issue (barang keluar, mvt 261) / Goods Receipt (barang masuk, mvt 101). |
| **Include** | Potongan source program yang terpisah (`_TOP` = deklarasi, `_F01` = FORM). |
| **Inspection Lot** | Lot pemeriksaan QM (tabel `QALS`). |
| **JR / SR** | Jumbo Roll (roll besar hasil mesin) / Slit Roll (roll hasil potong). |
| **LUW** | Logical Unit of Work — sekumpulan perubahan yang sukses semua atau batal semua. |
| **MIC** | Master Inspection Characteristic — parameter uji QM. |
| **Movement Type (BWART)** | Kode jenis pergerakan stok: 101 GR, 102 batal GR, 261 GI, 262 batal GI, 411 transfer, 531 by-product. |
| **MCP** | Model Context Protocol — jembatan agar AI bisa membaca SAP/RAG. |
| **RAG** | Retrieval Augmented Generation — AI mencari dokumen knowledge sebelum menjawab. |
| **Reversal / Storno** | Pembatalan dokumen. Di `MSEG` ditandai `SMBLN` (nomor dokumen yang dibatalkan). |
| **Selection Screen** | Layar input parameter sebelum report dijalankan. |
| **Smart Form** | Desain form cetak (SMARTFORMS). Contoh `ZQMF_COA`. |
| **ST22 / SM21 / ST05** | Short dump / System log / SQL trace. |
| **TCODE** | Transaction code, jalan pintas ke program (contoh `ZPP090`). Mapping di `TSTC`. |
| **TECO** | Technically Completed — status order yang sudah selesai teknis. |
| **UD** | Usage Decision — keputusan akhir inspection lot (diterima/ditolak). |
| **Z program** | Program custom buatan perusahaan, namanya diawali `Z` atau `Y`. |
| **`ZMAP_TYPE`** | Tabel Z konfigurasi/mapping umum, dipakai banyak program (PROG/TYPE/OPT/VALUE). |
