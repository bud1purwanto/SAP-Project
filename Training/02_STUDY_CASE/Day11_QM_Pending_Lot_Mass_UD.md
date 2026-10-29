# Day 11 — QM: Report Pending Inspection Lot + Transaksi Mass Usage Decision

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★★ | QM | `sandbox-new` (write) + `prod` (read-only) | 4 jam | qm-analisa-production, abap-dev-sandbox-new |

## Tujuan

1. Memahami alur QM: GR → **inspection lot** → hasil uji per **MIC** → **Usage Decision (UD)** → stok bisa dipakai.
2. Membuat program **report + transaksi** tingkat menengah: pilih banyak baris di ALV, lalu jalankan BAPI per baris dengan hasil per baris.
3. Mengenal pola dari project nyata `ZQM004` (`ZQMI_PENDING_BARRIER`), termasuk fitur *Auto UD*.

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D11` — daftar lot belum UD + ringkasan hasil uji; pilih baris → set UD massal (dengan test run) |
| 2 | Flow A (GR sampai stok release oleh UD) + Flow B (report → pilih → validasi → BAPI per lot → hasil) |
| 3 | Bukti: 3 lot di Sandbox berubah status (cek `QA03`) + 1 lot yang ditolak validasi |

## Cerita Kasus

Setiap GR Jumbo/Slit Roll membuat inspection lot. Selama UD belum diberikan, stok tertahan di *Quality Inspection* dan tidak bisa dikirim.
QC harus membuka `QA32`, memilih lot satu per satu, lalu `QA11`. Untuk barrier, project `ZQM004` sudah mengotomasi sebagian (upload hasil + *Auto UD*).
QC Supervisor meminta tool umum: **lihat semua lot pending + status hasil uji, centang, beri UD sekaligus**.

## Konsep Kunci

| Tabel | Isi | Field penting |
|---|---|---|
| `QALS` | Inspection lot | `PRUEFLOS`, `WERK`, `ART` (lot type), `HERKUNFT` (origin), `MATNR`, `CHARG`, `ENSTEHDAT`, `OBJNR`, `LOSMENGE` |
| `QAVE` | Usage Decision | `PRUEFLOS`, `VCODE` (kode UD), `VDATUM` |
| `QAMV` / `QAMR` | MIC per lot / hasil | `PRUEFLOS`, `VORGLFNR`, `MERKNR`, `MBEWERTG` (A = accepted, R = rejected) |
| `QPCD` / `QPCT` | Katalog kode UD | kode & teks |

- Lot "pending" = belum ada baris `QAVE` (atau status lot belum UD — cek `JEST` via `OBJNR`).
- UD lewat BAPI `BAPI_INSPLOT_SETUSAGEDECISION` (dipakai juga di `ZQMI_PENDING_BARRIER`). Setelah sukses: `BAPI_TRANSACTION_COMMIT`.
- **Commit per lot**: satu lot gagal tidak membatalkan lot lain; hasil tiap lot ditampilkan.
- ALV dengan pilihan baris: `REUSE_ALV_GRID_DISPLAY` + checkbox, atau `CL_SALV_TABLE` + mode seleksi; tombol custom butuh GUI status (salin `STANDARD` dari program `SAPLKKBL` via `SE41`).

## Spesifikasi Program `ZTRN_<INISIAL>_D11`

| Bagian | Isi |
|---|---|
| Input | `S_WERK`, `S_MATNR`, `S_ENST` (tgl lot), `S_ART` (lot type, default `04` GR produksi), `P_SET` / `P_GROUP` / `P_CODE` (selected set, code group, kode UD), checkbox `P_TEST` |
| Report | Lot tanpa UD; per lot: jumlah MIC, MIC sudah ada hasil, MIC rejected; status: **Siap UD** (semua MIC ada hasil, 0 reject), **Ada reject**, **Hasil belum lengkap** |
| Aksi | Tombol "Set UD" untuk baris terpilih |
| Validasi | Hanya lot **Siap UD** yang boleh diberi kode UD terima; lot "Ada reject" tidak boleh diberi kode terima; `P_CODE` harus ada di katalog |
| Proses | Per lot: `BAPI_INSPLOT_SETUSAGEDECISION` → cek `RETURN` → commit / rollback per lot |
| Output | Kolom hasil per lot (OK / pesan error); refresh ALV |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | GR 101 → lot terbentuk → lab input hasil (`QE51N` / `ZQM004`) → QC beri UD (`QA11`) → stok unrestricted / blocked |
| B — Program | Input → ambil lot tanpa UD → ringkas hasil MIC → ALV → user pilih → validasi per lot → BAPI → commit/rollback per lot → tampil hasil |

Ikuti [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md).

## Langkah dengan AI

**Langkah 1 — pahami data (read-only).**
```
Pakai skill qm-analisa-production, server prod. Ambil 10 lot QALS plant 2000 bulan ini dengan ART = '04'.
Untuk tiap lot cek ada/tidak QAVE dan ringkas QAMR (jumlah MIC, rejected). Jelaskan arti field dalam bahasa awam.
```

**Langkah 2 — pelajari pola ZQM004.**
```
Baca 05_REFERENSI/BARRIER/ZQMI_PENDING_BARRIER.abap: bagian yang memanggil BAPI_INSPLOT_SETUSAGEDECISION (Auto UD P1).
Jelaskan parameter yang diisi dan bagaimana hasil BAPI dicek.
Lalu read_function_module BAPI_INSPLOT_SETUSAGEDECISION di sandbox-new.
```

**Langkah 3 — kode bertahap.** Report dulu (tanpa aksi) → push & uji → tambah tombol + BAPI dengan `P_TEST` → push & uji.
```
Pakai skill abap-dev-sandbox-new. Buat ZTRN_<INISIAL>_D11 tahap 1 (report saja) sesuai spesifikasi: <tempel>.
```

**Langkah 4 — uji di Sandbox.**

| # | Skenario | Hasil diharapkan |
|---|---|---|
| T1 | Lot Siap UD, `P_TEST = X` | Simulasi OK, status lot tidak berubah |
| T2 | 3 lot Siap UD, eksekusi nyata | 3 lot mendapat UD (cek `QA03`) |
| T3 | Lot Ada reject + kode terima | Ditolak validasi program |
| T4 | Campuran 1 sukses + 1 error BAPI | Lot sukses tetap tersimpan, lot error dilaporkan |

**Langkah 5 — flow** (Flow A & B).

## Tugas

1. Empat skenario uji terdokumentasi.
2. Jelaskan: mengapa commit per lot lebih tepat daripada satu commit di akhir untuk kasus ini?
3. Flow A & B selesai.

## Checklist Selesai

- [ ] Report menampilkan status hasil uji per lot dengan benar.
- [ ] UD hanya diberikan pada lot yang lolos validasi.
- [ ] Program `ZTRN_<INISIAL>_D11` berjalan di `sandbox-new` dan bisa dijelaskan baris per baris.
- [ ] Flow A & B selesai.

## Kuis

1. Tabel apa yang menandakan lot sudah punya UD?
2. Apa akibat bisnis jika UD terlambat?
3. Mengapa lot dengan MIC rejected tidak boleh diberi UD terima secara massal?

<details>
<summary>Kunci jawaban</summary>

1. `QAVE` (plus status lot di `JEST`).
2. Stok tertahan di quality inspection → tidak bisa dikirim/dipakai → pengiriman terlambat.
3. Keputusan pada lot bermasalah perlu review manusia (deviasi, rework, konsesi customer); otomasi massal hanya untuk kasus yang jelas.

Potongan kode acuan — UD per lot (pola sama dengan `ZQMI_PENDING_BARRIER`):

```abap
DATA: ls_ud  TYPE bapi2045ud,
      ls_ret TYPE bapireturn1.

LOOP AT gt_out INTO gs_out WHERE sel = 'X' AND status = 'SIAP UD'.
  CLEAR: ls_ud, ls_ret.
  ls_ud-insplot             = gs_out-prueflos.
  ls_ud-ud_selected_set     = p_set.          " contoh Trias: '0-UD-PRD'
  ls_ud-ud_code_group       = p_group.        " contoh Trias: '0-UD-PRD'
  ls_ud-ud_code             = p_code.
  ls_ud-ud_recorded_by_user = sy-uname.
  ls_ud-ud_recorded_on_date = sy-datum.
  ls_ud-ud_recorded_at_time = sy-uzeit.
  ls_ud-ud_force_completion = 'X'.
  ls_ud-ud_stock_posting    = 'X'.

  CALL FUNCTION 'BAPI_INSPLOT_SETUSAGEDECISION'
    EXPORTING
      number  = ls_ud-insplot
      ud_data = ls_ud
    IMPORTING
      return  = ls_ret.

  IF ls_ret-type CA 'EA' OR p_test = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
  ENDIF.
  IF ls_ret-type CA 'EA'.
    gs_out-hasil = ls_ret-message.
  ELSEIF p_test = 'X'.
    gs_out-hasil = 'Simulasi OK'.
  ELSE.
    gs_out-hasil = 'UD tersimpan'.
  ENDIF.
  MODIFY gt_out FROM gs_out.
ENDLOOP.
```

Tambahkan input `P_SET` dan `P_GROUP` (selected set & code group) di selection screen; nilai valid dicek di katalog (`QPAC`/`QPCD`) di Sandbox.
</details>

## Referensi

- [ZQMI_PENDING_BARRIER.abap](../05_REFERENSI/BARRIER/ZQMI_PENDING_BARRIER.abap) — pola Auto UD.
- [Skill qm-analisa-production](../01_SKILLS/qm-analisa-production/SKILL.md)
- [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md)
