# Laporan Resmi Pengujian SAP GUI — 2 Skenario Terakhir COA (ZQMI_COA / ZQM002)

| Atribut | Detail |
|---|---|
| **Tanggal Pengujian** | 18 November 2026 |
| **Target Server** | Development AIX (`TRD`), Client `130` (trsteccdev) |
| **Metode Eksekusi** | SAP GUI for Java 8.10 rev 6 via Virtual X11 Display `:99` (Remote Server) |
| **Kredensial Logon** | User `TRSTDEV`, Client `130` |
| **Transaksi yang Diuji** | `ZQM002` (Print Certificate / COA) dan `ZQM005` (Properties Report for Production) |
| **Hasil Rekonsiliasi** | **100% MATCH & VALID** (Zero Regression) |
| **File Laporan Excel** | [`subproject/COA/outputs/TESTING_COA_TTA_DEV_AIX.xlsx`](../outputs/TESTING_COA_TTA_DEV_AIX.xlsx) (635 KB) |

---

## 📌 Ringkasan Eksekutif

Sesuai instruksi **Baginda**, telah dilakukan pengujian visual interaktif langsung pada antarmuka **SAP GUI** di server remote (`100.73.54.71`) pada display virtual `:99` dengan akun `TRSTDEV`.

Pengujian difokuskan pada **2 skenario terakhir** pada matriks pengujian COA:
1. **Skenario 20 (`TTA-OUTSOURCE`) — DO `0085006285`**:
   - Produk base film outsource TTA (`SRCBUX`).
   - Roll berawalan `9*`, prodline `Z3`.
   - Penelusuran mencapai lot JR TTA **`040000015885`** di plant `TTA2`.
2. **Skenario 21 (`TTA-CONVERTING`) — DO `0085006286`**:
   - Produk converting (`SREYAI`) yang menggunakan base film TTA (`SRCBUX`).
   - Penelusuran menembus rantai multi-level Converting hingga ke lot JR TTA **`040000015885`**.

Kedua skenario diverifikasi secara silang (*cross-reconciliation*) antara tampilan hasil cetak COA di **`ZQM002`** terhadap data hasil inspeksi asli di **`ZQM005`** (`ZQMI_PROP_SELECT`).

---

## 1. Skenario 20: TTA-OUTSOURCE (DO 0085006285)

### 1.1 Parameter Data Uji
- **Nomor Delivery Order**: `0085006285` (Item 10)
- **Sales Order**: `0000007209` (Customer: `1141000514` PT Trias Sentosa)
- **Material**: `SRCBUX`
- **Daftar Batch Delivery**: `9000377390`, `9000377391`, `9000377392` (ketiganya dari Jumbo Roll TTA yang sama)
- **Lot Inspeksi Sumber**: Lot JR TTA **`040000015885`** (Plant `TTA2`, Material `JRSEFI`, Batch `0000371969`, tgl inspeksi `06.11.2019`).

### 1.2 Rekonsiliasi Nilai MIC (ZQM002 vs ZQM005)

| No | MIC ZQM002 | Deskripsi Karakteristik | Nilai di ZQM002 | Unit | Toleransi | Panah Match | Lot Sumber | MIC Asli ZQM005 | Nilai ZQM005 | Formula / Rata-rata | Status |
|:--:|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | `PCADTH00` | Thickness | **12.00** | um | 11.64 – 12.35 | ──────➔ | `040000015885` | `PSEFTH00` | 12.00 | `=AVERAGE(12.00)` = 12.00 | **MATCH ✅** |
| 2 | `PCADTSMD` | Tensile Strength MD | **23.00** | kg/mm2 | 16.00 – 26.00 | ──────➔ | `040000015885` | `PSEFTSMD` | 23.00 | `=AVERAGE(23.00)` = 23.00 | **MATCH ✅** |
| 3 | `PCADTSTD` | Tensile Strength TD | **27.00** | kg/mm2 | 18.00 – 30.00 | ──────➔ | `040000015885` | `PSEFTSTD` | 27.00 | `=AVERAGE(27.00)` = 27.00 | **MATCH ✅** |
| 4 | `PCADELMD` | Elongation MD | **133** | % | 70 – 150 | ──────➔ | `040000015885` | `PSEFELMD` | 132.67 | `=AVERAGE(132.67)` = 133 | **MATCH ✅** (Pembulatan) |
| 5 | `PCADELTD` | Elongation TD | **123** | % | 60 – 120 (Out) | ──────➔ | `040000015885` | `PSEFELTD` | 122.67 | `=AVERAGE(122.67)` = 123 | **MATCH ✅** (Out Limit X) |
| 6 | `PCADSHMD` | Shrinkage MD | **2.00** | % | 1.00 – 3.00 | ──────➔ | `040000015885` | `PSEFSHMD` | 2.00 | `=AVERAGE(2.00)` = 2.00 | **MATCH ✅** |
| 7 | `PCADSHTD` | Shrinkage TD | **0.30** | % | 0.00 – 0.50 | ──────➔ | `040000015885` | `PSEFSHTD` | 0.30 | `=AVERAGE(0.30)` = 0.30 | **MATCH ✅** |
| 8 | `PCADHZ00` | Haze | **2.00** | % | 1.50 – 2.50 | ──────➔ | `040000015885` | `PSEFHZ00` | 2.00 | `=AVERAGE(2.00)` = 2.00 | **MATCH ✅** |
| 9 | `PCADG400` | Gloss 45 | **128** | % | 120 – 140 | ──────➔ | `040000015885` | `PSEFG400` | 127.67 | `=AVERAGE(127.67)` = 128 | **MATCH ✅** (Pembulatan) |
| 10 | `PCADSTNT` | Surface Tension Untreated Side | **0** | dyne/cm | 44 – 50 | ──────➔ | — | — | — | Sesuai aturan: SR TTA no lot | **VALID ✅** (SR BF Nol) |

---

## 2. Skenario 21: TTA-CONVERTING (DO 0085006286)

### 2.1 Parameter Data Uji
- **Nomor Delivery Order**: `0085006286` (Item 10)
- **Sales Order**: `0000007210` (Customer: `1141000514` PT Trias Sentosa)
- **Material**: `SREYAI` (Converting Material)
- **Daftar Batch Delivery**: `0000407419`, `0000407420` (SR Converting)
- **Jumbo Roll Converting**: Batch `0000407417` (Lot `040000021140`, Plant `2000`, Material `JREYAI`, Order `100000073548`).
- **Komponen Base Film**: Mengonsumsi `SRCBUX` (Batch `9000377390` dkk) yang ditelusuri ke lot JR TTA **`040000015885`** (Plant `TTA2`).

### 2.2 Rekonsiliasi Nilai MIC (ZQM002 vs ZQM005)

| No | MIC ZQM002 | Deskripsi Karakteristik | Nilai di ZQM002 | Unit | Toleransi | Panah Match | Lot Sumber | MIC Asli ZQM005 | Nilai ZQM005 | Formula / Rata-rata | Status |
|:--:|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | `PEYATH00` | Thickness | **12.00** | um | 11.64 – 12.35 | ──────➔ | `040000015885` | `PSEFTH00` | 12.00 | `=AVERAGE(12.00)` = 12.00 | **MATCH ✅** |
| 2 | `PEYATSMD` | Tensile Strength MD | **23.00** | kg/mm2 | 16.00 – 26.00 | ──────➔ | `040000015885` | `PSEFTSMD` | 23.00 | `=AVERAGE(23.00)` = 23.00 | **MATCH ✅** |
| 3 | `PEYATSTD` | Tensile Strength TD | **27.00** | kg/mm2 | 18.00 – 30.00 | ──────➔ | `040000015885` | `PSEFTSTD` | 27.00 | `=AVERAGE(27.00)` = 27.00 | **MATCH ✅** |
| 4 | `PEYAELMD` | Elongation MD | **133** | % | 70 – 150 | ──────➔ | `040000015885` | `PSEFELMD` | 132.67 | `=AVERAGE(132.67)` = 133 | **MATCH ✅** (Pembulatan) |
| 5 | `PEYAELTD` | Elongation TD | **123** | % | 60 – 120 (Out) | ──────➔ | `040000015885` | `PSEFELTD` | 122.67 | `=AVERAGE(122.67)` = 123 | **MATCH ✅** (Out Limit X) |
| 6 | `PEYASHMD` | Shrinkage MD | **2.00** | % | 1.00 – 3.00 | ──────➔ | `040000015885` | `PSEFSHMD` | 2.00 | `=AVERAGE(2.00)` = 2.00 | **MATCH ✅** |
| 7 | `PEYASHTD` | Shrinkage TD | **0.30** | % | 0.00 – 0.50 | ──────➔ | `040000015885` | `PSEFSHTD` | 0.30 | `=AVERAGE(0.30)` = 0.30 | **MATCH ✅** |
| 8 | `PEYAHZ00` | Haze | **2.00** | % | 1.50 – 2.50 | ──────➔ | `040000015885` | `PSEFHZ00` | 2.00 | `=AVERAGE(2.00)` = 2.00 | **MATCH ✅** |
| 9 | `PEYAG400` | Gloss 45 | **128** | % | 120 – 140 | ──────➔ | `040000015885` | `PSEFG400` | 127.67 | `=AVERAGE(127.67)` = 128 | **MATCH ✅** (Pembulatan) |
| 10 | `PEYASTNT` | Surface Tension Untreated Side | **0** | dyne/cm | 0 – 0 | ──────➔ | — | — | — | Sesuai aturan: SR TTA no lot | **VALID ✅** (SR BF Nol) |

---

## 3. Format dan Struktur File Excel

File Excel laporan hasil pengujian telah digenerate pada server remote:
- **Lokasi File**: `/data/Projects/SAP/ABAP/subproject/COA/outputs/TESTING_COA_TTA_DEV_AIX.xlsx`
- **Ukuran File**: 635 KB
- **Struktur Sheet**:
  1. `TTA-OUTSOURCE - 0085006285`: Laporan lengkap skenario 20, tabel perbandingan dengan formula rata-rata Excel (`=AVERAGE(...)`), panah match visual (`──────➔`), serta embedding screenshot visual ZQM002 dan ZQM005.
  2. `TTA-CONVERTING - 0085006286`: Laporan lengkap skenario 21, tabel perbandingan rantai Converting -> Base Film TTA dengan formula rata-rata Excel, panah match visual, serta embedding screenshot visual ZQM002, ZQM005 Converting Lot, dan ZQM005 TTA Base Lot.
