# Analisis Migrasi TCode ZPP041 -> ZJR_EXEC (DEV AIX ke S/4HANA)

## 1. Ringkasan Eksekutif
- **Permintaan Baginda:** Salin transaksi `ZPP041` beserta program dasarnya dari SAP DEV AIX (`192.168.2.8`, Client 130) ke SAP S/4HANA (`192.168.1.199`, Client 130).
- **Ketentuan Khusus:** Nama TCode di S/4HANA **bukan `ZPP041`**, melainkan **`ZJR_EXEC`**.
- **Hasil Pemetaan DEV AIX:**
  - TCode `ZPP041` memanggil program utama **`ZPPI_JR_EXEC`** (Execution Jumbo Roll, Screen 1000).
  - Tipe transaksi: Report Transaction (`CINFO = 80`).

---

## 2. Struktur Objek Program ZPPI_JR_EXEC
Program ini merupakan modul eksekusi lantai produksi (Production Floor Execution - Jumbo Roll) berskala penuh dengan total **7.421 baris kode ABAP**:

| Objek | Tipe | Baris | Status Ekstraksi Remote |
|---|---|---|---|
| `ZPPI_JR_EXEC` | Main Program | 51 | Tersimpan di `src/ZPPI_JR_EXEC.abap` |
| `Z_PROG_INFO` | Include | 88 | Tersimpan di `src/Z_PROG_INFO.abap` |
| `ZABAPALV` | Include | 660 | Tersimpan di `src/ZABAPALV.abap` |
| `ZPPI_JR_EXEC_TOP` | Include | 293 | Tersimpan di `src/ZPPI_JR_EXEC_TOP.abap` |
| `ZPPI_JR_EXEC_F01` | Include | 4.344 | Tersimpan di `src/ZPPI_JR_EXEC_F01.abap` |
| `ZPPI_JR_EXEC_LYT` | Include | 410 | Tersimpan di `src/ZPPI_JR_EXEC_LYT.abap` |
| `ZPPI_JR_EXEC_FTE` | Include | 1.575 | Tersimpan di `src/ZPPI_JR_EXEC_FTE.abap` |
| **Total** | | **7.421** | |

### Layar Dynpro (D020S)
Terdapat 6 layar interaktif:
1. `0800` (Main Screen: Production Execution Jumbo Roll)
2. `0900` (Modal Dialog BTNTDK)
3. `1000` (Selection Screen)
4. `1100` (Modal Dialog)
5. `1200` (Main Screen)
6. `1300` (Modal Dialog BTNOK)

### CUA Interface (GUI Status & Titles)
- Status menu, application toolbar, function keys, dan dynamic titles berhasil diekstrak ke `src/cua.json`.

---

## 3. Analisis Dependensi pada S/4HANA

### A. Tabel Transparan Kustom (9 Z-Tables Belum Ada di S/4HANA)
Program `ZPPI_JR_EXEC` menggunakan 9 tabel Z di database. Seluruh struktur tabel telah diekstrak ke `src/tables.json`:
1. `ZCORER` (13 field - Core Return/Tracking)
2. `ZMAP_INDICATOR` (2 field - Mapping Indicator)
3. `ZMAP_TYPE` (19 field - Mapping Type Configuration)
4. `ZMRTYB` (16 field - Material / Batch Recycling)
5. `ZPROGINFO` (4 field - Program Version & Info)
6. `ZSEQNUM` (3 field - Sequence Number Generation)
7. `ZTMAP_MATRECYCLE` (6 field - Mapping Material Recycle)
8. `ZTMAP_SLOCRR` (13 field - Mapping Storage Location RR)
9. `ZTMAP_SLOC_JR_GR` (9 field - Mapping Storage Location JR Goods Receipt)

### B. Data Elements Kustom (7 DTEL Belum Ada di S/4HANA)
Struktur data element telah diekstrak ke `src/dtels.json`:
1. `ZLDESC` (Domain TEXT30 - Domain sudah ada di S/4HANA)
2. `ZMATFA` (Domain MATNR - Domain sudah ada di S/4HANA)
3. `ZMATRA` (Domain MATNR - Domain sudah ada di S/4HANA)
4. `ZSLOCDESC` (Domain TEXT30 - Domain sudah ada di S/4HANA)
5. `ZSLOCJR` (Domain TEXT04 - Domain sudah ada di S/4HANA)
6. `ZZFILM` (Direct Type CHAR 3)
7. `ZCODE` (Direct Type CHAR 3)

### C. Function Modules
- **Custom FM:** `Z_MMUR_ROUND_FOR_FRACT5` (Function Pool `ZMMCHAR`, 144 baris kode untuk rounding float/fraksi) belum ada di S/4HANA. Sumber kode telah diekstrak ke `src/Z_MMUR_ROUND_FOR_FRACT5.abap`.
- **Standard SAP FMs:** Seluruh 18 modul standar SAP yang dipanggil (seperti `REUSE_ALV_GRID_DISPLAY`, `POPUP_TO_CONFIRM`, `CONVERSION_EXIT_ALPHA_INPUT`, `READ_TEXT`, `SAPGUI_PROGRESS_INDICATOR`) **sudah tersedia lengkap di S/4HANA**.

---

## 4. Rencana Kerja Replikasi (Step-by-Step)
1. **Fase 1: DDIC Data Elements & Tables**
   - Buat 7 Data Elements kustom di S/4HANA.
   - Buat & aktifkan 9 Tabel Transparan Z di S/4HANA.
2. **Fase 2: Function Module Helper**
   - Buat Function Pool `ZMMCHAR` dan FM `Z_MMUR_ROUND_FOR_FRACT5` di S/4HANA.
3. **Fase 3: ABAP Program & Includes**
   - Unggah dan aktifkan 6 includes: `Z_PROG_INFO`, `ZABAPALV`, `ZPPI_JR_EXEC_TOP`, `ZPPI_JR_EXEC_F01`, `ZPPI_JR_EXEC_LYT`, `ZPPI_JR_EXEC_FTE`.
   - Unggah dan aktifkan program utama `ZPPI_JR_EXEC`.
4. **Fase 4: Dynpro Screens & GUI Status**
   - Sinkronisasi layar dynpro 0800, 0900, 1100, 1200, 1300 beserta Flow Logic & Containers.
   - Sinkronisasi GUI Status & Titles (CUA).
5. **Fase 5: Pembuatan TCode ZJR_EXEC**
   - Buat Transaction Code `ZJR_EXEC` di `SE93` mengarah ke program `ZPPI_JR_EXEC`, screen `1000`.
6. **Fase 6: Validasi Live GUI & Pengujian**
   - Eksekusi `/nZJR_EXEC` di SAP GUI live S/4HANA dan verifikasi tampilan serta dump check (ST22).