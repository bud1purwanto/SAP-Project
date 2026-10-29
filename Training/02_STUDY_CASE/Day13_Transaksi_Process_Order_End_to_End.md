# Day 13 — Transaksi Sulit: Process Order End-to-End via BAPI (+ Cancel)

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★★★ | PP / MM | `sandbox-new` (write) + `prod` (read-only) | 5 jam | abap-dev-sandbox-new, pp-analisa-production |

## Tujuan

1. Menjalankan **siklus Process Order lengkap** dengan BAPI: create → release → GI bahan → GR produk → confirmation → TECO.
2. Mengelola transaksi **multi-langkah** dengan benar: urutan, commit per langkah, cek status sebelum langkah berikutnya.
3. Membuat **pembatalan (kompensasi)** dengan urutan terbalik, dan **guard** agar proses tidak dijalankan dua kali.
4. Belajar dari insiden nyata **GR duplikat ZPP001** (2026-10-15).

> Ini persiapan langsung Day 14: BAPI yang dipakai sama dengan `ZPP001L` (`ZPPI_SR_EXEC`).

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D13` — mode **Proses** (6 langkah) dan mode **Cancel** (urutan terbalik), log per langkah di ALV |
| 2 | Flow A (siklus process order & dokumen yang terbentuk) + Flow B (langkah, commit, guard, kompensasi) |
| 3 | Bukti di Sandbox: 1 order lengkap sampai TECO, 1 order dibatalkan bersih, 1 percobaan proses ganda yang ditolak guard |

## Cerita Kasus

Program slitting (`ZPP001`/`ZPP001L`) menjalankan banyak BAPI berurutan, masing-masing commit sendiri.
Pada **15-10-2026**, satu proses yang gagal di langkah confirmation diulang user tiga kali → **GR tercatat 3x** (target 4 roll, GR 12 roll), interface OLAP error.
Akar masalah: (1) langkah yang sudah commit tidak dibatalkan saat langkah berikutnya gagal, (2) tidak ada cek "GR sudah ada?", (3) log tidak tersimpan.

Hari ini Anda membangun versi kecil siklus tersebut **dengan benar**.

## Konsep Kunci

| Langkah | BAPI (dipakai juga di `ZPPI_SR_EXEC`) | Dokumen / status |
|---|---|---|
| 1 Create | `BAPI_PROCORD_CREATE` (`ORDERDATA`: `ORDER_TYPE`, `MATERIAL`, `PLANT`, `QUANTITY`, `PROD_VERSION`, tanggal) | `AUFK`/`AFKO`/`AFPO`, status CRTD |
| 2 Release | `BAPI_PROCORD_RELEASE` (`ORDERS`) | REL |
| 3 GI bahan | `BAPI_GOODSMVT_CREATE` GM code `03`, movement `261` + `ORDERID` | `MSEG`/`AUFM` |
| 4 GR produk | `BAPI_GOODSMVT_CREATE` GM code `02`, movement `101` + `ORDERID` | `MSEG`/`AUFM`, `AFPO-WEMNG` |
| 5 Confirmation | `BAPI_PROCORDCONF_CREATE_TT` (`TIMETICKETS`: `ORDERID`, `PHASE`, `FIN_CONF`, qty) | `AFRU`, CNF |
| 6 TECO | `BAPI_PROCORD_COMPLETE_TECH` (`ORDERS`) | TECO |

**Cancel (urutan terbalik):** revoke TECO → cancel confirmation (`BAPI_PROCORDCONF_CANCEL`) → cancel GR & GI (`BAPI_GOODSMVT_CANCEL`) → tandai order (deletion flag / dibiarkan + log).

Aturan penting:
- **Cek `RETURN` sebelum commit.** Contoh nyata di `ZPPI_SR_EXEC` FORM `RELEASE_ORDERS`: `PERFORM COMMIT` dipanggil walaupun `RETURN` berisi error — jangan ditiru.
- **Guard**: sebelum GR, cek GR aktif (101 tanpa 102) untuk order + batch; jika ada → stop.
- **Status terbaru**: baca status order langsung dari `JEST` setelah commit; buffer `STATUS_READ` bisa basi (temuan insiden).
- **Lock**: order terkunci selama diproses; `COMMIT WORK AND WAIT` (`WAIT = 'X'`) sebelum langkah berikutnya.
- **Log**: simpan setiap langkah (sukses/gagal, dokumen, pesan) — minimal di ALV + tabel Z dari Day 09, ideal Application Log (`SLG1`).

## Spesifikasi Program `ZTRN_<INISIAL>_D13`

| Bagian | Isi |
|---|---|
| Mode | Radio `R_PROC` (Proses) / `R_CANC` (Cancel) / `R_STAT` (Lihat status & dokumen) |
| Input Proses | `P_MATNR`, `P_WERKS`, `P_AUART`, `P_VERID`, `P_QTY`, `P_LGORT`, `P_CHARG` (batch produk, opsional), komponen GI: `P_COMP`, `P_CBAT`, `P_CQTY`, `P_STOP` (berhenti setelah langkah ke-n, untuk uji) |
| Input Cancel/Status | `P_AUFNR` |
| Proses | 6 langkah berurutan; tiap langkah: cek prasyarat (status/guard) → BAPI → cek `RETURN` → commit/rollback → log. Langkah gagal → berhenti + tawarkan kompensasi otomatis untuk langkah yang sudah commit |
| Cancel | Baca dokumen dari `AUFM`/`AFRU`/status → batalkan urutan terbalik, lewati yang sudah batal |
| Output | ALV log: langkah, status, dokumen, pesan, waktu |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | Order dibuat → release → bahan diambil (261) → produk masuk (101) → konfirmasi → TECO; dokumen & status di tiap langkah; cabang pembatalan |
| B — Program | Untuk tiap langkah: prasyarat? → BAPI → error? → (ya) rollback + kompensasi langkah sebelumnya (terbalik) → (tidak) commit + log → langkah berikutnya; plus guard "GR sudah ada?" |

Ikuti [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md).

## Langkah dengan AI

**Langkah 1 — pelajari pola nyata (read-only).**
```
Baca 05_REFERENSI/ZPP001L_PACKING/ANALISA_ZPP001L_DAN_ZHU5SO_FS.md dan
05_REFERENSI/AUTO_TECO_ZPP001/2026-10-16_ANALISA_ZPP001_GR_DUPLIKAT_SRAAOI.md (bagian Root Cause).
Ringkas: urutan langkah, letak commit, dan 3 pelajaran dari insiden.
```

**Langkah 2 — siapkan data Sandbox.**
```
Set sandbox-new. Cari 1 material di plant 2000 yang punya production version aktif (MKAL) dan master recipe,
order type process order yang valid (T003O / dari ZMAP_TYPE PROG ZPPI_COHVPI), serta komponen BOM yang punya stok (MCHB).
Cek tanggal sistem dengan GET_SYSTEM_TIME_REMOTE.
```

**Langkah 3 — pelajari BAPI.**
```
read_function_module BAPI_PROCORD_CREATE, BAPI_PROCORD_RELEASE, BAPI_PROCORDCONF_CREATE_TT, BAPI_PROCORDCONF_CANCEL,
BAPI_PROCORD_COMPLETE_TECH di sandbox-new. Buat tabel parameter wajib masing-masing.
```

**Langkah 4 — kode bertahap.** Langkah 1–2 dulu (create + release) → uji → tambah 3–4 (GI/GR, pakai pola Day 03) → uji → tambah 5–6 → uji → tambah Cancel.
```
Pakai skill abap-dev-sandbox-new. Buat ZTRN_<INISIAL>_D13 tahap <n> sesuai spesifikasi: <tempel>.
Setiap langkah dalam FORM sendiri, mengembalikan flag sukses + nomor dokumen. COMMIT hanya jika RETURN tanpa E/A.
```

**Langkah 5 — uji.**

| # | Skenario | Hasil diharapkan |
|---|---|---|
| T1 | Proses lengkap | Order TECO; log 6 langkah sukses; dokumen cocok di `COR3`, `MB51` |
| T2 | `P_STOP = 4` lalu Proses lagi untuk order yang sama | Guard menolak GR kedua |
| T3 | Paksa error di confirmation (mis. phase salah) | Langkah 5 gagal, kompensasi membatalkan GR & GI; stok kembali |
| T4 | Cancel order dari T1 | Semua dokumen batal berurutan, status order kembali |
| T5 | Cancel dua kali | Langkah yang sudah batal dilewati, tidak error |

**Langkah 6 — flow** (Flow A & B).

## Tugas

1. Lima skenario uji terdokumentasi (dokumen & status sebelum/sesudah).
2. Tabel: langkah → BAPI → dokumen → cara membatalkan.
3. Tulis 3 aturan yang Anda terapkan agar kasus GR duplikat tidak terjadi di program Anda.
4. Flow A & B selesai.

## Checklist Selesai

- [ ] Order lengkap sampai TECO di Sandbox.
- [ ] Guard GR ganda terbukti bekerja.
- [ ] Kompensasi urutan terbalik terbukti bekerja.
- [ ] Program `ZTRN_<INISIAL>_D13` berjalan di `sandbox-new` dan bisa dijelaskan baris per baris.
- [ ] Flow A & B selesai.

## Kuis

1. Mengapa kompensasi harus berurutan terbalik?
2. Apa bedanya rollback dan kompensasi?
3. Mengapa status order harus dibaca ulang setelah commit, bukan dari buffer?
4. Apa yang salah dengan pola "panggil BAPI → langsung COMMIT" tanpa cek `RETURN`?

<details>
<summary>Kunci jawaban</summary>

1. Langkah berikutnya bergantung pada langkah sebelumnya (mis. confirmation bergantung GR); membatalkan dari yang terakhir menjaga konsistensi dan menghindari error "dokumen masih dipakai".
2. Rollback membatalkan perubahan yang **belum** di-commit; kompensasi membuat transaksi pembalik untuk perubahan yang **sudah** di-commit.
3. Buffer dalam session bisa berisi status lama (contoh insiden: TECO tidak terbaca), sehingga keputusan program salah.
4. Sebagian perubahan yang berhasil sebelum error bisa ikut tersimpan, atau commit dijalankan dalam kondisi error yang tidak terdeteksi → data setengah jadi.

Potongan kode acuan — pola satu langkah:

```abap
FORM step_release USING pv_aufnr TYPE aufnr
                  CHANGING pv_ok TYPE c.
  DATA: lt_ord TYPE STANDARD TABLE OF bapi_order_key,
        ls_ord TYPE bapi_order_key,
        ls_ret TYPE bapiret2.

  CLEAR pv_ok.
  ls_ord-order_number = pv_aufnr.
  APPEND ls_ord TO lt_ord.
  CALL FUNCTION 'BAPI_PROCORD_RELEASE'
    EXPORTING
      release_control = '1'
    IMPORTING
      return          = ls_ret
    TABLES
      orders          = lt_ord.
  IF ls_ret-type CA 'EA'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    PERFORM log_add USING 'RELEASE' 'E' pv_aufnr ls_ret-message.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    pv_ok = 'X'.
    PERFORM log_add USING 'RELEASE' 'S' pv_aufnr 'Order released'.
  ENDIF.
ENDFORM.
```

Tipe yang dipakai di `ZPPI_SR_EXEC`: `BAPI_PI_ORDER_CREATE` (create), `BAPI_ORDER_KEY` (release/TECO), `BAPI_PI_TIMETICKET1` (confirmation). Tetap cek di SE37 sebelum coding.
</details>

## Referensi

- [ANALISA_ZPP001L_DAN_ZHU5SO_FS.md](../05_REFERENSI/ZPP001L_PACKING/ANALISA_ZPP001L_DAN_ZHU5SO_FS.md)
- [2026-10-16_ANALISA_ZPP001_GR_DUPLIKAT_SRAAOI.md](../05_REFERENSI/AUTO_TECO_ZPP001/2026-10-16_ANALISA_ZPP001_GR_DUPLIKAT_SRAAOI.md)
- [2026-10-16_USULAN_ENHANCEMENT_ZPP001_ANTI_GR_DUPLIKAT.md](../05_REFERENSI/AUTO_TECO_ZPP001/2026-10-16_USULAN_ENHANCEMENT_ZPP001_ANTI_GR_DUPLIKAT.md)
- [Day 03](Day03_Program_Transfer_Posting.md) — pola `BAPI_GOODSMVT_CREATE`.
- [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md)
