# 01 — Landscape Sistem & Aturan Server

Baca file ini sebelum Day 1. Aturan di sini berlaku untuk **semua** study case.

---

## 1. Sistem yang Dipakai

| Alias MCP | Nama | SID / Host | Fungsi untuk training | Boleh ubah? |
|---|---|---|---|---|
| `sandbox-new` | Sandbox New Company | TRS, client 130, 192.168.6.243 | Latihan coding, membuat & mengubah program | **Ya** (hanya program `ZTRN_*`, package `$TMP`) |
| `dev-aix` / `dev` | Development AIX | TRD, 192.168.2.8 | Membaca source program versi development | Tidak |
| `qa` | QA | TRQ, 192.168.2.7 | Tidak dipakai di training | Tidak |
| `prod` | Production AIX | PRT, 192.168.1.151 | Analisa data & program nyata | **Tidak. Read-only.** |

> Cek alias aktual dengan prompt: *"Jalankan `list_servers` dan tampilkan semua server SAP yang tersedia."*
>
> Catatan: tanggal sistem Sandbox New Company **tidak sinkron** dengan kalender nyata. Jika butuh tanggal server, panggil FM `GET_SYSTEM_TIME_REMOTE` (baca `L_DATE`).

Versi sistem: SAP ECC 6.0 EHP6, NetWeaver 7.31, **ABAP 7.31**, database Oracle.

---

## 2. Alur Transport (Landscape)

```
 Sandbox New (TRS)      Development (TRD)      Quality (QAS)      Production (PRT)
  latihan & prototipe -> develop resmi + TR  -> uji user (UAT) -> dipakai operasional
```

- Training **berhenti di Sandbox**. Tidak ada transport request yang dibuat dari kegiatan training.
- Program resmi berpindah ke Production hanya lewat Transport Request (SE09/SE10, STMS) oleh tim ABAP/Basis.

---

## 3. Aturan Production AIX (Read-Only)

Boleh:
- Membaca tabel (`read_table`, setara SE16N) dengan filter yang jelas dan jumlah baris terbatas (`ROWCOUNT` ≤ 200).
- Membaca source program/FM/class (`read_program`, `read_function_module`, `read_class`).
- Membaca struktur tabel (`read_table_structure`, setara SE11).
- Where-used (`get_where_used`).

Dilarang:
- `call_function` ke FM/BAPI yang **mengubah data** (contoh: `BAPI_GOODSMVT_CREATE`, `BAPI_GOODSMVT_CANCEL`, `Z_RFC_PROGRAM_UPDATE`, `RFC_ABAP_INSTALL_AND_RUN`).
- Menjalankan transaksi posting via GUI (MIGO, CO11N, QA11, dsb.).
- Membaca tabel besar tanpa filter (`MSEG`, `BSEG`, `AUSP`, `JEST` tanpa WHERE = beban berat ke server Production).
- Menyalin data pribadi/sensitif (gaji, NIK, data customer) ke luar sistem.

Setelah selesai sesi GUI di Production: **logout**.

---

## 4. Aturan Sandbox New Company (Write)

1. `set_active_server` → `sandbox-new` **sebelum** setiap operasi tulis.
2. Nama program training: `ZTRN_<INISIAL>_D<NN>` (contoh `ZTRN_BP_D04`). Jangan menimpa program yang bukan milik training.
3. Package: `$TMP` (lokal, tidak ditransport).
4. Push program: FM `Z_RFC_PROGRAM_UPDATE` (parameter `IV_PROGRAM_NAME`, `IV_PACKAGE = '$TMP'`, `IT_SOURCE`). Cek `EV_SUCCESS = 'X'`.
5. Sebelum mengubah program yang sudah ada, **baca dan simpan backup** source lama.

---

## 5. Aturan Sintaks ABAP 7.31

Sistem ini ABAP 7.31. Fitur ABAP 7.40+ **tidak tersedia**. Jika AI memberi kode dengan fitur di kolom kiri, minta AI menulis ulang.

| Dilarang (7.40+) | Gunakan (7.31) |
|---|---|
| `DATA(lv_x) = ...` | Deklarasi di blok `DATA:` dulu |
| `LOOP AT itab INTO DATA(ls)` | `DATA ls TYPE ...` lalu `LOOP AT itab INTO ls` |
| `` |Halo { lv_nama }| `` | `CONCATENATE 'Halo' lv_nama INTO lv_txt SEPARATED BY space.` |
| `NEW`, `VALUE`, `REDUCE`, `CORRESPONDING`, `FILTER` | `CREATE OBJECT`, `APPEND`, `MOVE-CORRESPONDING` |
| `SELECT ... WHERE x = @lv_x` | `SELECT ... WHERE x = lv_x` (tanpa `@`, pemisah field spasi) |

---

## 6. Aturan Integritas Data (penting saat analisa)

- **Dokumen batal (reversal):** saat menghitung movement, selalu perhitungkan pasangan pembatal (101↔102, 261↔262, 531↔532). Cek field `MSEG-SMBLN` / `SJAHR`.
- **Status order:** order berstatus `TECO`, `DLV`, `CLSD` tidak boleh diproses ulang oleh interface/program.
- **Tidak boleh update langsung tabel standar** (`MARA`, `EKKO`, `VBAK`, `MSEG`, `BKPF` ...) — selalu lewat BAPI/FM standar.
- Setelah BAPI yang mengubah data: cek `RETURN`; error → `BAPI_TRANSACTION_ROLLBACK`; sukses → `BAPI_TRANSACTION_COMMIT` dengan `WAIT = 'X'`.
