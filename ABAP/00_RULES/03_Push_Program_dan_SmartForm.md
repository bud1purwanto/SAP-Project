# 03 — Push Program & Smart Form (sandbox-new)

> Aturan write hanya ke sandbox-new, wajib pull terbaru sebelum push, mekanisme RFC push program, Smart Form, start gate, delete rule.
> Kembali ke [AGENTS.md](../AGENTS.md). Daftar server: [01 §Server](01_Landscape_dan_Server.md#daftar-server-sap). Backup versi lama: `_backup/rules_20261105_optimasi/`.

## Aturan target write — TIDAK ADA PENGECUALIAN

- **Analisa boleh di server mana saja** (dev, qa, prod, sandbox, dll) sesuai kebutuhan investigasi. Prod tetap butuh konfirmasi Baginda sebelum query.
- **Setiap write** (update program, include, FM, Smart Form) — termasuk enhancement, bug fix, tambah fitur — **hanya ke `sandbox-new`** (SID TRS, client 130). Dilarang write ke dev, dev-win, qa, prod, prod-win, sandbox.
- Baginda menyebut server lain untuk write → tetap `sandbox-new`, beri tahu alasannya.
- Permintaan perubahan tanpa sebut server → target otomatis `sandbox-new`, **tetapi tetap konfirmasi ke Baginda sebelum write** (sebut objek, server, ringkasan perubahan). Pilihan server otomatis ≠ izin write; izin write tetap lewat [Start gate](#start-gate-wajib-sebelum-write-apa-pun).
- Sebelum setiap `call_function` write: `set_active_server` → `sandbox-new`.
- Alur enhancement: baca source di server asal (dev) untuk analisa → kembangkan → write di `sandbox-new`. Jangan pernah enhancement langsung di dev/qa/prod.

## Wajib pull source terbaru sebelum push

File lokal `src/*.abap` **bukan sumber kebenaran**. Baginda bisa mengubah program manual di SE38/SE80 kapan saja, jadi file lokal bisa sudah basi. Push dari file basi = menimpa perubahan Baginda.

1. **Tepat sebelum edit dan lagi tepat sebelum push**: pull source terbaru dari `sandbox-new` (`read_program` / `RPY_PROGRAM_READ`, semua include yang akan diubah). Simpan sebagai backup `outputs/<PROGRAM>_sandbox_new_TRS_before_<perubahan>_<YYYYMMDD>.abap`.
2. Bandingkan hasil pull dengan base yang dipakai untuk edit lokal (`diff`):
   - **Sama** → lanjut push.
   - **Beda** (ada perubahan manual / sesi lain) → **STOP**. Laporkan baris yang berubah ke Baginda. Terapkan ulang patch di atas source hasil pull terbaru, jangan timpa. Push hanya setelah Baginda konfirmasi.
3. Patch selalu dibangun di atas hasil pull terbaru, lalu disalin ke `src/<PROGRAM>.abap` (salinan kerja untuk `git diff` & cek panjang baris).
4. `git diff` / `diff` patch vs hasil pull harus hanya berisi baris yang diminta (lihat [04 Minimal Diff](04_Grounding_dan_Review_Kode.md#strict-scope--minimal-diff-rule--wajib-dipatuhi)).
5. Setelah push: pull ulang, bandingkan jumlah baris & isi dengan file yang dikirim. Beda → laporkan, jangan klaim sukses.
6. Script push (`scripts/push*.mjs/js`) yang membaca `src/*.abap` langsung tanpa langkah 1–2 **tidak boleh** dipakai apa adanya; jalankan pull + diff dulu.

Alur ringkas:
```
pull TRS -> backup outputs/ -> edit -> pull TRS lagi -> diff (beda? STOP) -> konfirmasi Baginda -> push -> pull ulang -> bandingkan
```

## Mekanisme push program — status RFC

**Prioritas: `Z_RFC_PROGRAM_UPDATE` via `call_function`** (verified di TRS). Tool MCP `write_program` atau mekanisme lain hanya jika FM ini error, dan laporkan error-nya dulu.

| RFC / FM | Status | Keterangan |
|---|---|---|
| `Z_RFC_PROGRAM_UPDATE` | ✅ **Prioritas** | Custom FM, kirim full source. Parameter: `IV_PROGRAM_NAME`, `IV_PACKAGE`, `IV_CORRNUMBER` (optional), `IT_SOURCE` (ABAPTXT255, max 255 char/line). Cek `EV_SUCCESS = 'X'` + `EV_MESSAGE` |
| `RPY_PROGRAM_READ` | ✅ Berfungsi | Baca source via TABLES `SOURCE_EXTENDED` (TYPE C LENGTH 255) |
| `RFC_ABAP_INSTALL_AND_RUN` | ✅ Berfungsi | Bootstrap: kirim temp program sebagai text, compile & execute. Untuk patch kompleks |
| `RPY_PROGRAM_UPDATE` | ✅ Berfungsi | Parameter wajib: `TRANSPORT_NUMBER = ' '`, `DEVELOPMENT_CLASS = '$TMP'` |
| `READ_REPORT` | ❌ Tidak tersedia | Not found / not RFC-enabled |

**Alur utama — `Z_RFC_PROGRAM_UPDATE`:**
1. `set_active_server` → `sandbox-new`
2. Pull terbaru + backup + diff (bagian di atas)
3. Panggil:
   ```
   IV_PROGRAM_NAME = 'ZNAMA_PROGRAM'
   IV_PACKAGE      = '$TMP'
   IV_CORRNUMBER   = ' '   (optional, isi space)
   IT_SOURCE       = [ {LINE: '...'}, ... ]
   ```
4. Cek `EV_SUCCESS = 'X'` dan `EV_MESSAGE`, lalu pull ulang & bandingkan.

**Alur alternatif — bootstrap `RFC_ABAP_INSTALL_AND_RUN`** (patch kompleks):
1. `set_active_server` → `sandbox-new`
2. Temp program: baca via `RPY_PROGRAM_READ` → loop & patch → simpan via `RPY_PROGRAM_UPDATE`
3. Kirim via `call_function` FM = `RFC_ABAP_INSTALL_AND_RUN`, PROGRAM = array of {LINE}

Batasan PROGTAB (hanya `RFC_ABAP_INSTALL_AND_RUN`): setiap LINE maksimal **72 karakter**; `REPLACE` wajib bentuk `REPLACE FIRST OCCURRENCE OF ... IN ... WITH ...`.

---

## Push Smart Form via RFC — TERVERIFIKASI TRS

Untuk update Smart Form, target write hanya `sandbox-new` (TRS client 130).
Gunakan `RFC_ABAP_INSTALL_AND_RUN` sebagai bootstrap ABAP. Setiap baris `PROGRAM`
maksimum 72 karakter.

Alur upload/save XML terbukti:
1. Export form aktif dengan `FB_CONVERT_FORM_TO_XML`; simpan XML lokal untuk rollback.
2. Parse XML memakai `CL_IXML`.
3. Buat `CL_SSF_FB_SMART_FORM`; `ENQUEUE` dengan `MODE = 'MODIFY'`.
   Nilai `EDIT` tidak valid.
4. `LOAD` dengan `IM_ACTIVE = 'X'`.
5. Buat object upload terpisah. Panggil `LO_UPLOAD->XML_UPLOAD`.
   `DOM = LO_DOC->GET_ROOT_ELEMENT( )`; `SFORM = LO_CURRENT` hasil `LOAD`.
6. `LO_UPLOAD->STORE` dengan `IM_ACTIVE = 'X'`, lalu `COMMIT WORK AND WAIT`,
   kemudian `DEQUEUE`.
7. Generate dengan `FB_GENERATE_FORM`; cek FM memakai
   `SSF_FUNCTION_MODULE_NAME`.

Contoh inti ABAP 7.31:
```abap
CALL METHOD LO_CURRENT->ENQUEUE
  EXPORTING
    AUTHORITY_CHECK         = 'X'
    SUPPRESS_CORR_CHECK     = 'X'
    SUPPRESS_LANGUAGE_CHECK = 'X'
    LANGUAGE_UPD_EXIT       = ' '
    MODE                    = 'MODIFY'
    FORMNAME                = 'ZFORM'.

CALL METHOD LO_UPLOAD->XML_UPLOAD
  EXPORTING
    DOM      = LO_DOC->GET_ROOT_ELEMENT( )
    FORMNAME = 'ZFORM'
    LANGUAGE = SY-LANGU
  CHANGING
    SFORM    = LO_CURRENT.

CALL METHOD LO_UPLOAD->STORE
  EXPORTING
    IM_ACTIVE   = 'X'
    IM_FORMNAME = 'ZFORM'
    IM_LANGUAGE = SY-LANGU.

COMMIT WORK AND WAIT.
```

Catatan: `FB_COPY_FORM` tetap memanggil dialog pada RFC headless. Jangan dipakai
untuk backup otomatis; gunakan XML export aktif. Bila `FB_GENERATE_FORM` gagal,
form bisa sudah tersimpan. Cek `SMARTFORMS`, `ST22`, dan `SM21`. Simpan hasil
`SY-SUBRC` generate sebelum `DEQUEUE`, karena `DEQUEUE` dapat menimpa nilainya.

---

## Start gate wajib sebelum write apa pun

(merge dari ADT AGENTS, 2026-11-05 — alur lengkap: [07_Workflow_Development.md](07_Workflow_Development.md))

Sebelum push/update pertama, semua harus terpenuhi. Jika tidak, berhenti dan sebutkan yang kurang:
1. Ada Design Brief berstatus `AGREED` (atau, untuk bug fix kecil, instruksi Baginda yang eksplisit di chat).
2. Target server = `sandbox-new` (`set_active_server`), objek yang akan diubah ada di daftar objek brief.
3. Source **terbaru** sudah di-pull dari `sandbox-new` tepat sebelum push, **backup** disimpan di `subproject/<NAMA>/outputs/`, dan diff vs base lokal sudah dicek ([Wajib pull](#wajib-pull-source-terbaru-sebelum-push)). Beda → berhenti, lapor Baginda.
4. Baginda sudah konfirmasi write (objek + server + ringkasan perubahan).
5. Bangun hanya yang ada di brief. Butuh objek lain / desain tidak cocok dengan kenyataan → berhenti, kembali ke brainstorm. Tidak ada penyimpangan diam-diam.
6. Objek di luar daftar brief (FM shared, include milik program lain, tabel Z, objek SAP standar): minta persetujuan Baginda **per objek** dengan info: jenis + nama, alasan, perubahan (diff), dampak (`get_where_used`). Persetujuan umum ("kerjakan saja semua") tidak berlaku.
7. Write ditolak / gagal (`EV_SUCCESS <> 'X'`) → laporkan pesan apa adanya. Jangan cari jalan pintas (server lain, mekanisme lain) tanpa izin.

## Delete rule: hapus hanya dengan perintah eksplisit

(diadaptasi dari "Delete guard" ADT AGENTS, 2026-11-05)

- **Default: agent tidak menghapus** objek (program, include, FM, tabel Z, Smart Form), data tabel, maupun file di project.
- Penghapusan **boleh** hanya jika Baginda memberi **perintah eksplisit** di chat yang menyebut objek/data yang dihapus (contoh: "hapus program ZTMP_PATCH01 di sandbox-new").
- Sebelum eksekusi hapus, wajib:
  1. Sebut ulang objek/data, server, dan dampak (`get_where_used` untuk objek; jumlah baris + WHERE untuk data).
  2. Simpan backup (source/XML/isi tabel) di `outputs/`.
  3. Konfirmasi sekali lagi jika dampaknya lebih luas dari yang disebut Baginda.
- Production (`prod`) dan tabel standar SAP: **tidak pernah** dihapus, walau ada perintah. Arahkan ke proses standar / tim Basis.
- Tanpa perintah eksplisit: berikan **saran penghapusan** (objek, alasan, bukti where-used, urutan, langkah manual) dan biarkan Baginda yang memutuskan.
