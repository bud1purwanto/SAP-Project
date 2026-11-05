# 03 — Push Program & Smart Form (sandbox-new)

> Aturan write hanya ke sandbox-new, mekanisme RFC push program, enhancement, dan Smart Form.
> Sumber: dipecah dari `AGENTS.md` (backup: `_backup/AGENTS_20261105.md`). Kembali ke [AGENTS.md](../AGENTS.md).

#### Update Program ABAP — ATURAN WAJIB
- Update/save source code program ke SAP **HANYA boleh di server `sandbox-new`** (Sandbox New Company, SID: TRS, Host: 192.168.6.243)
- **DILARANG** melakukan update program di server lain (dev, dev-win, qa, prod, prod-win, sandbox)
- Sebelum update, selalu `set_active_server` ke `sandbox-new` terlebih dahulu
- **PRIORITAS UTAMA push/update program: SELALU gunakan `Z_RFC_PROGRAM_UPDATE` via `call_function`** — sudah verified berfungsi di sistem TRS. Jangan gunakan mekanisme lain kecuali ada error spesifik dari FM ini.

#### Mekanisme Push/Update Program ABAP — STATUS RFC (PENTING!)

| RFC / FM | Status | Keterangan |
|---|---|---|
| `Z_RFC_PROGRAM_UPDATE` | ✅ **GUNAKAN INI — CARA PALING MUDAH** | Custom FM, kirim full source langsung. Parameter: `IV_PROGRAM_NAME`, `IV_PACKAGE`, `IV_CORRNUMBER` (optional), `IT_SOURCE` (ABAPTXT255) |
| `READ_REPORT` | ❌ **Tidak tersedia** | Function module not found / not RFC-enabled di sistem ini |
| `RFC_ABAP_INSTALL_AND_RUN` | ✅ Berfungsi | Bootstrap: kirim temp ABAP program sebagai text, SAP compile & execute. Gunakan jika perlu patch logic kompleks |
| `RPY_PROGRAM_READ` | ✅ Berfungsi | Baca source via TABLES `SOURCE_EXTENDED` (TYPE C LENGTH 255) |
| `RPY_PROGRAM_UPDATE` | ✅ Berfungsi | Simpan source — parameter wajib: `TRANSPORT_NUMBER = ' '`, `DEVELOPMENT_CLASS = '$TMP'` |

**Alur paling mudah — pakai `Z_RFC_PROGRAM_UPDATE` langsung:**
1. `set_active_server` → `sandbox-new`
2. Baca source program (via `read_program` atau `RPY_PROGRAM_READ`)
3. Modifikasi source di sisi client (array of lines)
4. Panggil `Z_RFC_PROGRAM_UPDATE`:
   ```
   IV_PROGRAM_NAME = 'ZNAMA_PROGRAM'
   IV_PACKAGE      = '$TMP'
   IV_CORRNUMBER   = ' '   (optional, isi space)
   IT_SOURCE       = [ {LINE: '...'}, ... ]   (ABAPTXT255, max 255 char/line)
   ```
5. Cek `EV_SUCCESS = 'X'` dan `EV_MESSAGE` untuk konfirmasi

**Alur alternatif — Bootstrap via `RFC_ABAP_INSTALL_AND_RUN`** (untuk patch kompleks):
1. `set_active_server` → `sandbox-new`
2. Buat patch ABAP program yang di dalamnya: baca via `RPY_PROGRAM_READ` → loop & patch → simpan via `RPY_PROGRAM_UPDATE`
3. Kirim via `call_function` FM = `RFC_ABAP_INSTALL_AND_RUN`, PROGRAM = array of {LINE} (max **72 char/line**)

#### Batasan Teknis PROGTAB (Hanya untuk RFC_ABAP_INSTALL_AND_RUN)
- Setiap LINE dalam tabel PROGRAM maksimal **72 karakter**
- **REPLACE syntax** — WAJIB gunakan NEW syntax:
  - ✅ `REPLACE FIRST OCCURRENCE OF 'X' IN field WITH 'Y'.`
  - ❌ `REPLACE 'X' WITH 'Y' IN field.` → error "Specification WITH ... is not expected"

#### Enhancement Program — ATURAN WAJIB
- Setiap permintaan **enhancement program** (modifikasi, tambah fitur, perbaikan bug, dll) **WAJIB menggunakan server `sandbox-new`** (Sandbox New Company, SID: TRS)
- Alur wajib: baca source dari server asal (dev) → kembangkan/edit kode → set server ke `sandbox-new` → simpan hasil enhancement
- Jangan pernah langsung enhancement di server dev, qa, atau prod
- **Default server: Jika user meminta perubahan/modifikasi program tanpa menyebutkan server secara eksplisit → otomatis gunakan `sandbox-new` sebagai target. Tidak perlu konfirmasi, langsung set ke `sandbox-new`.**

#### Aturan Universal Perubahan Program — TIDAK ADA PENGECUALIAN
- **Analisis boleh di server mana saja** (dev, qa, prod, sandbox, dll) sesuai kebutuhan investigasi.
- **Namun SETIAP perubahan / modifikasi / update program — tanpa terkecuali — WAJIB dilakukan di `sandbox-new`.**
- Tidak peduli server mana yang sedang dianalisis, tidak peduli user menyebut server lain: **target save/push program selalu `sandbox-new`**.
- Sebelum setiap `call_function` yang bersifat write (update program), wajib `set_active_server` ke `sandbox-new` terlebih dahulu.

---

### Panduan Push Smart Form via RFC — TERVERIFIKASI TRS

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
3. Source lama sudah dibaca dan **backup** disimpan di `subproject/<NAMA>/outputs/`.
4. Bangun hanya yang ada di brief. Butuh objek lain / desain tidak cocok dengan kenyataan → berhenti, kembali ke brainstorm. Tidak ada penyimpangan diam-diam.
5. Objek di luar daftar brief (FM shared, include milik program lain, tabel Z, objek SAP standar): minta persetujuan Baginda **per objek** dengan info: jenis + nama, alasan, perubahan (diff), dampak (`get_where_used`). Persetujuan umum ("kerjakan saja semua") tidak berlaku.
6. Write ditolak / gagal (`EV_SUCCESS <> 'X'`) → laporkan pesan apa adanya. Jangan cari jalan pintas (server lain, mekanisme lain) tanpa izin.

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
