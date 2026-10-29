# Day 09 — Develop Aplikasi Z: Tabel Custom, Lock Object & Log

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★★ | PP / ABAP | `sandbox-new` (write) + `prod` (read-only) | 4 jam | abap-dev-sandbox-new, pp-analisa-production |

## Tujuan

1. Membuat **objek Data Dictionary** sendiri: tabel Z, lock object, table maintenance (SM30).
2. Membuat program yang **mengubah tabel Z dengan aman**: lock (`ENQUEUE`/`DEQUEUE`), validasi, commit, dan **log audit**.
3. Belajar dari kasus nyata `ZPP090`: parsing nomor roll dengan `SPLIT`, bukan offset hardcode.

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Tabel `ZTRN_<INISIAL>_SEQ` (counter), `ZTRN_<INISIAL>_LOG` (log), lock object `EZTRN_<INISIAL>_SEQ`, maintenance SM30 untuk tabel counter |
| 2 | Program `ZTRN_<INISIAL>_D09` — tampil counter, ambil nomor berikutnya, mundurkan nomor (dengan alasan), lihat log |
| 3 | Flow A (koreksi nomor roll oleh operator) + Flow B (lock → validasi → update → log → commit) |

## Cerita Kasus (dari project `ZPP090`)

Nomor Jumbo Roll di Trias dibentuk dari counter per line produksi dan bulan, contoh `7 W1B 096 039` atau `P1 VAX 096 340`
(`<line> <kode> <tgl/bulan> <sequence>`). Counter disimpan di tabel Z (`ZSEQNUM`), setiap koreksi dicatat di log (`ZLOG_JRNO`).
Jika operator salah input, nomor perlu **dimundurkan** lewat `ZPP090`.

Bug nyata yang pernah terjadi: program memakai offset tetap (`P_ROLJR+6(2)`) yang hanya cocok untuk line 1 karakter,
sehingga line CPP (`P1`, 2 karakter) selalu ditolak. Hari ini Anda membangun versi mini aplikasi ini **dengan benar sejak awal**.

## Konsep Kunci

| Objek | TCODE | Fungsi |
|---|---|---|
| Tabel transparan Z | `SE11` | Menyimpan data custom (boleh di-`UPDATE` program, berbeda dengan tabel standar SAP) |
| Lock object `EZ...` | `SE11` | Menghasilkan FM `ENQUEUE_EZ...` / `DEQUEUE_EZ...` agar dua user tidak mengubah baris yang sama bersamaan |
| Table Maintenance Generator | `SE11` → Utilities → `SE54` | Layar `SM30` untuk maintain data |
| Log tabel | – | Siapa, kapan, nilai lama → baru, alasan |

- Urutan aman: `ENQUEUE` → `SELECT SINGLE ... FOR UPDATE`/baca ulang → validasi → `UPDATE` + `INSERT` log → `COMMIT WORK` → `DEQUEUE`.
- `sy-subrc` dari `ENQUEUE` ≠ 0 → baris sedang dipakai user lain (`sy-msgv1` = user pemegang lock).
- Semua dibuat di `sandbox-new`, package `$TMP`.

## Spesifikasi

**Tabel `ZTRN_<INISIAL>_SEQ`** (key: `MANDT, WERKS, ZLINE, ZYEAR, ZMONTH`): `SEQNO` (NUMC 3), `AEDAT`, `AENAM`.

**Tabel `ZTRN_<INISIAL>_LOG`** (key: `MANDT, LOGNO`): `LOGNO` (NUMC 10), `DATUM`, `UZEIT`, `UNAME`, `WERKS`, `ZLINE`, `ZYEAR`, `ZMONTH`, `OLD_SEQ`, `NEW_SEQ`, `AKSI` (`NEXT`/`BACK`), `REASON` (CHAR 80).

**Program `ZTRN_<INISIAL>_D09`:**

| Bagian | Isi |
|---|---|
| Radio | `R_DISP` tampil counter + log · `R_NEXT` ambil nomor berikutnya · `R_BACK` mundurkan nomor |
| Input | `P_WERKS`, `P_LINE` (1–2 karakter), atau `P_ROLL` (nomor roll lengkap, di-`SPLIT` jadi line/kode/tgl/seq), `P_REASON` (wajib untuk `R_BACK`) |
| Validasi `R_BACK` | Hanya bulan berjalan; sequence minimal 1 (tidak boleh ke 000); nomor roll yang dimundurkan harus sama dengan counter saat ini |
| Proses | Lock → baca ulang counter → validasi → update counter → insert log → commit → unlock |
| Output | Pesan hasil + ALV log (filter line/bulan) |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | Operator input nomor roll → salah → minta koreksi → `ZPP090` → counter mundur → log tercatat → nomor berikutnya benar |
| B — Program | Radio → (Next/Back) ENQUEUE → terkunci? → baca ulang → validasi (bulan, min 1, cocok) → UPDATE + INSERT log → COMMIT → DEQUEUE → output |

Ikuti [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md).

## Langkah dengan AI

**Langkah 1 — pelajari aslinya (read-only).**
```
Server prod (read-only). read_table_structure ZSEQNUM dan ZLOG_JRNO. Baca 10 baris terakhir masing-masing.
Jelaskan arti field dan bagaimana nomor roll dibentuk. Baca juga 05_REFERENSI/ZPP090/CHECKPOINT.md bagian root cause.
```

**Langkah 2 — rancang DDIC.**
```
Bantu saya membuat tabel ZTRN_<INISIAL>_SEQ dan ZTRN_<INISIAL>_LOG di SE11 (sandbox-new, $TMP), sesuai spesifikasi:
<tempel>. Beri langkah klik demi klik di SE11: delivery class, data browser, technical settings, activate.
Lalu langkah membuat lock object EZTRN_<INISIAL>_SEQ dan table maintenance generator.
```
Kerjakan sendiri di SAP GUI Sandbox. Setelah aktif, minta AI memverifikasi: `read_table_structure ZTRN_<INISIAL>_SEQ` di sandbox-new.

**Langkah 3 — program.**
```
Pakai skill abap-dev-sandbox-new. Buat ZTRN_<INISIAL>_D09 sesuai spesifikasi: <tempel>.
Wajib: ENQUEUE/DEQUEUE, baca ulang setelah lock, SPLIT nomor roll (tidak boleh offset tetap), log setiap perubahan.
Nomor LOGNO ambil dari MAX(LOGNO)+1 di dalam lock (jelaskan kelemahannya dan alternatif number range SNRO).
```

**Langkah 4 — uji.**

| # | Skenario | Hasil diharapkan |
|---|---|---|
| T1 | `R_NEXT` line `7` | SEQ naik 1, log `NEXT` |
| T2 | `R_BACK` nomor `P1 VAX 096 005` (line 2 karakter) | Diterima bila cocok dengan counter, SEQ turun, log `BACK` + alasan |
| T3 | `R_BACK` ke sequence 000 | Ditolak |
| T4 | Dua session: session 1 berhenti di breakpoint setelah lock, session 2 jalankan `R_NEXT` | Session 2 ditolak "sedang dipakai user X" |
| T5 | `R_BACK` tanpa alasan | Ditolak |

**Langkah 5 — flow** (Flow A & B).

## Tugas

1. Objek DDIC aktif (screenshot SE11) dan SM30 bisa dipakai.
2. Lima skenario uji terdokumentasi, termasuk T4 (bukti lock bekerja).
3. Jelaskan dengan kata sendiri: kenapa tabel Z boleh di-`UPDATE` program, tetapi tabel standar SAP tidak?
4. Flow A & B selesai.

## Checklist Selesai

- [ ] Tabel, lock object, dan SM30 aktif di sandbox-new (`$TMP`).
- [ ] Program `ZTRN_<INISIAL>_D09` berjalan dan bisa dijelaskan baris per baris.
- [ ] Lock terbukti mencegah update bersamaan.
- [ ] Nomor roll line 1 dan 2 karakter sama-sama benar.
- [ ] Flow A & B selesai.

## Kuis

1. Apa yang terjadi bila program tidak memakai lock dan dua user menekan "Next" bersamaan?
2. Mengapa data dibaca ulang **setelah** `ENQUEUE`?
3. Mengapa `SPLIT` lebih aman daripada `P_ROLL+6(2)`?
4. Apa kelemahan `MAX(LOGNO)+1` dibanding number range (`SNRO`)?

<details>
<summary>Kunci jawaban</summary>

1. Keduanya bisa membaca SEQ yang sama dan menulis nilai sama → nomor roll ganda.
2. Data yang dibaca sebelum lock bisa sudah diubah user lain; setelah lock, data dijamin terbaru dan tidak berubah sampai unlock.
3. Panjang segmen line berbeda (1 atau 2 karakter); offset tetap bergeser, `SPLIT` memisah berdasarkan spasi.
4. Butuh lock seluruh tabel agar aman dan lambat pada volume besar; number range dikelola SAP, aman untuk banyak user.

Potongan kode acuan — pola lock & update:

```abap
CALL FUNCTION 'ENQUEUE_EZTRN_XX_SEQ'
  EXPORTING
    mode_ztrn_xx_seq = 'E'
    mandt            = sy-mandt
    werks            = p_werks
    zline            = gv_line
    zyear            = gv_year
    zmonth           = gv_month
  EXCEPTIONS
    foreign_lock     = 1
    system_failure   = 2
    OTHERS           = 3.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'E'.
  RETURN.
ENDIF.

SELECT SINGLE * FROM ztrn_xx_seq INTO gs_seq          " baca ulang setelah lock
  WHERE werks = p_werks AND zline = gv_line
    AND zyear = gv_year AND zmonth = gv_month.

" ... validasi ...

gs_log-old_seq = gs_seq-seqno.
gs_seq-seqno   = gs_seq-seqno - 1.
gs_seq-aedat   = sy-datum.
gs_seq-aenam   = sy-uname.
UPDATE ztrn_xx_seq FROM gs_seq.                       " tabel Z: boleh
IF sy-subrc = 0.
  gs_log-new_seq = gs_seq-seqno.
  INSERT ztrn_xx_log FROM gs_log.
ENDIF.
IF sy-subrc = 0.
  COMMIT WORK AND WAIT.
ELSE.
  ROLLBACK WORK.
ENDIF.

CALL FUNCTION 'DEQUEUE_EZTRN_XX_SEQ'
  EXPORTING
    mode_ztrn_xx_seq = 'E'
    mandt            = sy-mandt
    werks            = p_werks
    zline            = gv_line
    zyear            = gv_year
    zmonth           = gv_month.
```

Nama parameter FM `ENQUEUE_...` mengikuti lock object yang Anda buat — cek di SE37.
</details>

## Referensi

- [CHECKPOINT.md](../05_REFERENSI/ZPP090/CHECKPOINT.md) — kasus nyata offset hardcode ZPP090.
- [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md)
