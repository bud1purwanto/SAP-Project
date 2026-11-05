# 04 — Grounding Rules & Minimal Diff

> Self-check wajib sebelum mengeluarkan kode ABAP.
> Sumber: dipecah dari `AGENTS.md` (backup: `_backup/AGENTS_20261105.md`). Kembali ke [AGENTS.md](../AGENTS.md).

## Grounding Rules — Kode ABAP (WAJIB Self-Check Sebelum Output)

### 1. Batasan Sintaks Keras (Syntax Guardrails)
- **Dilarang Inline Declaration:** Jangan gunakan `DATA(...)` atau `FIELD-SYMBOL(...)`. Semua variabel wajib dideklarasikan eksplisit di blok `DATA:` / `TYPES:`.
- **Dilarang New Constructor Operators:** Jangan gunakan `NEW`, `VALUE`, `REDUCE`, `CORRESPONDING`, `FILTER`. Gunakan cara klasik: `CLEAR`, `MOVE-CORRESPONDING`, `APPEND`, `INSERT`.
- **Open SQL Klasik:** Tanpa `@` untuk host variables. Gunakan spasi (bukan koma) sebagai pemisah field pada `SELECT`.
- **String Manipulation Klasik:** Gunakan `CONCATENATE`, `SPLIT`, `REPLACE`, `CONDENSE`. Dilarang string template `|...|`.

### 2. Fase Analisis RAG & Kesesuaian Bisnis
- **Validasi Proses Bisnis:** Baca RAG Business Process (FS) terlebih dahulu. Petakan ke struktur tabel standar ECC (seperti `MARA`, `VBAK`, `EKKO`).
- **Verifikasi DDIC:** Pastikan tipe data yang dideklarasikan sesuai dengan Data Element standar SAP untuk mencegah *type mismatch*.

### 3. Optimasi Performa Database (Oracle & Open SQL 7.31)
- **Cek Index Oracle:** Susun `WHERE` clause mengikuti urutan indeks tabel agar Oracle Query Optimizer menggunakan *Index Scan*, bukan *Full Table Scan*.
- **Aturan Ketat FOR ALL ENTRIES:**
  - Wajib pasang `IF lt_table IS NOT INITIAL.` sebelum `FOR ALL ENTRIES IN lt_table`.
  - Lakukan `SORT` dan `DELETE ADJACENT DUPLICATES` pada tabel pengontrol sebelum digunakan di `FOR ALL ENTRIES`.
- **Seleksi Field Spesifik:** Hindari `SELECT *`. Sebutkan field secara eksplisit; gunakan `INTO CORRESPONDING FIELDS OF TABLE` jika struktur berbeda.

### 4. Efisiensi Memori & Pemrosesan Internal
- **Strategi READ TABLE:** Wajib gunakan `BINARY SEARCH` + pastikan tabel sudah di-`SORT` sesuai key. Sarankan `SORTED TABLE` atau `HASHED TABLE` untuk volume besar.
- **Work Area yang Aman:** Lakukan `CLEAR <work_area>` sebelum `APPEND` atau `READ TABLE` untuk mencegah kontaminasi data lama.
- **Manajemen Memori:** Sisipkan `REFRESH` atau `FREE` setelah tabel internal selesai digunakan pada pemrosesan data masif.

### 5. Standardisasi Ekstensi & Error Handling
- **Teknologi Enhancement Valid (7.31):** Enhancement Framework, Classic/New BAdIs, User Exits (`EXIT_...`), BTE. Jangan sarankan RAP atau AMDP.
- **Error Handling Konsisten:** Cek `IF sy-subrc <> 0` setelah operasi database, `READ TABLE`, atau pemanggilan FM. Gunakan `TRY ... CATCH ... ENDTRY` untuk ABAP OO.

### 6. Integritas Data & Validasi Proses Bisnis
- **Filter Dokumen Batal (Reversal/Storno):** Saat query dokumen logistik/finansial, wajib filter dokumen yang sudah dibatalkan. Contoh: cek field `SMBLN`/`SJAHR` di `MSEG`, atau indikator Storno `STFLG`.
- **Validasi Status Transaksional:** Untuk program yang memproses Production Order (interface ke MES), wajib validasi System Status order via `STATUS_READ` atau tabel `JEST`. Dilarang memproses order berstatus **TECO**, **DLV**, atau **CLSD**.
- **Larangan Direct Update Tabel Standar:** Dilarang menggunakan `UPDATE`, `INSERT`, atau `DELETE` langsung pada tabel standar SAP (`MARA`, `EKKO`, `VBAK`, `MSEG`, dll). Wajib gunakan **BAPI** atau FM standar (contoh: `BAPI_GOODSMVT_CREATE`).
- **Manajemen Kuncian (Lock Objects / SAP LUW):** Sebelum modifikasi data krusial, terapkan *Enqueue*/*Dequeue* Function Modules untuk mencegah *race condition*.
- **Authority Check Proaktif:** Sertakan `AUTHORITY-CHECK` di awal program/proses sensitif. Validasi berdasarkan level organisasional: Plant (`WERKS`), Company Code (`BUKRS`), atau Purchasing Org (`EKORG`).
- **Penanganan Transaksi BAPI:** Setelah BAPI yang mengubah data, cek return parameter. Jika ada error (`TYPE = 'E'`) → jalankan `BAPI_TRANSACTION_ROLLBACK`. Jika sukses → jalankan `BAPI_TRANSACTION_COMMIT` dengan wait parameter = `abap_true`.

---

## Strict Scope & Minimal Diff Rule — WAJIB DIPATUHI

1. **Fokus Murni Sesuai Permintaan (Zero Scope Creep):** HANYA ubah bagian kode, logika, atau baris yang secara eksplisit diminta oleh user.
2. **Dilarang Menghapus/Mengubah Formatting Tanpa Izin:** Dilarang menghapus baris kosong (blank lines), mengubah indentasi, whitespace, atau komentar di luar area yang diminta.
3. **No Unsolicited Logic / Refactoring:** Dilarang menambahkan fitur baru, validasi baru, atau merombak struktur kode yang tidak diminta.
4. **Verifikasi Diff Bersih:** Selalu verifikasi `git diff` sebelum push ke SAP TRS dan sebelum memberikan jawaban akhir ke user. Diff harus minimal, bersih, dan 100% tepat sasaran.

---

## Tambahan Review dari ADT AGENTS (2026-11-05)

### Urutan efek & posting
- **Semua aturan blocking dicek SEBELUM BAPI / COMMIT pertama.** Aturan yang baru dicek di step berikutnya meninggalkan data setengah jadi (contoh nyata: GR duplikat ZPP001 karena tiap step `COMMIT` sendiri).
- Proses multi-step dengan COMMIT per step: wajib ada guard idempotensi (cek dokumen sudah ada) atau kompensasi (cancel) bila step berikut gagal.
- BDC / batch input: hasil diverifikasi **di database** (bukan hanya `sy-subrc`), evaluasi TYPE setiap message (bukan hanya message pertama), `MODE 'N'` di kode final, setiap field rekaman ada di dynpro itu.
- Pesan setelah side effect sukses (dokumen dibuat / BAPI commit) = informasi, bukan warning/error.

### Konsistensi
- Komentar, dokumen FS/TS, dan konstanta harus cocok dengan kode. Ditemukan beda → laporkan sebagai temuan.
- Setiap baris aturan di FS diimplementasikan; nilai turunan FS (mis. order type per jenis) diambil dari satu tempat (mis. `ZMAP_TYPE`), bukan konstanta tersebar. Input yang tidak ter-mapping ditolak.
- Nilai org (plant, company code, purchasing org) di satu blok konstanta / mapping, tidak tersebar.

### Format hasil review & QA
- Temuan dikelompokkan **Critical / Major / Minor**: objek + baris, apa yang salah, kenapa penting, perbaikan konkret.
- Laporkan hanya temuan yang terverifikasi dari source; tebakan diberi label "dugaan". Akhiri dengan apa yang **tidak** dicek.
- QA gate memakai status **PASS / WARN / FAIL / NOT RUN**. Dilarang menulis PASS untuk cek yang tidak dijalankan. Vonis: **READY / READY WITH WARNINGS / NOT READY** + langkah berikutnya.
- Data hasil test di server (dokumen dibuat) dicatat key-nya agar bisa dibersihkan Baginda.
