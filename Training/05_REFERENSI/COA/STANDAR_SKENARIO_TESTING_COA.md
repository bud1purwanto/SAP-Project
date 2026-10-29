# Knowledge Base & Baseline Skenario Testing COA (Certificate of Analysis)

Dokumen ini merupakan referensi resmi (*Golden Knowledge Base*) skenario pengujian Program Cetak COA (`ZQMI_COA` / `ZQMI_COA_F01` / `ZQM002`), mencakup **Skenario Baseline Komprehensif (QM01 – QM15)** serta **Skenario Multi-Tier Converting End-to-End (7 Tahap)**.

Setiap pembaruan kode ABAP wajib mengacu pada dokumen ini untuk memastikan **Zero Regression** pada skenario lama dan akurasi pada skenario baru.

---

## 📌 BAGIAN 1: Skenario Multi-Tier Converting End-to-End (7 Tahapan Produksi)

### Ringkasan Alur Produksi Multi-Tier
Alur produksi melewati 7 tahapan berurutan dari **Basefilm BOPP** hingga **Converting Coating**, dengan mapping pengambilan nilai rata-rata (*Average*) ke COA:

| Tahap | Proses Produksi | Kode Material | Jumlah Roll / Lot | Rentang Batch / Lot | Status Mapping COA | Parameter yang Diambil ke COA (Nilai Average) |
| :---: | :--- | :--- | :---: | :--- | :---: | :--- |
| **1** | **JR Basefilm (BOPP)** | `JRAH8I` | 2 (JR 1 – JR 2) | `0000406686` – `0000406687` | **Aktif** | Tensile Strength MD (`0.00`), Tensile Strength TD (`0.00`), Elongation MD (`0`), Elongation TD (`0`) |
| **2** | **SR Basefilm (BOPP)** | `SRAH8I` | 10 (JR 1 – JR 10) | `0000406711` – `0000406720` | *Tidak Ada Mapping* | — |
| **3** | **JR Conv (Coat 1)** | `JRGKAI` | 10 (JR 1 – JR 10) | `0000406727` – `0000406745` *(Ganjil)* | *Tidak Ada Mapping* | — |
| **4** | **SR Conv (Coat 1)** | `SRGKAI` | 10 (JR 1 – JR 10) | `0000406756` – `0000406765` | *Tidak Ada Mapping* | — |
| **5** | **JR Conv (Metz)** | `JRGLAI` | 10 (JR 1 – JR 10) | `0000406781` – `0000406799` *(Ganjil)* | **Aktif** | Shrinkage MD (`2.62`), Shrinkage TD (`0.34`), Gloss 60° Coated Side (`636`) |
| **6** | **SR Conv (Metz)** | `SRGLAI` | 10 (JR 1 – JR 10) | `0000406810` – `0000406819` | **Aktif** | Surface Tension Coated Side (`42`), Surface Tension Metz Side (`52`) |
| **7** | **JR Conv (Coat 2)** | `JRGLBI` | 10 (JR 1 – JR 10) | `0000406821` – `0000406839` *(Ganjil)* | **Aktif** | Optical Density (`2.378`) |

---

### Nilai Karakteristik Riil per Tahapan Multi-Tier

#### 1. Tahap 1: JR Basefilm (`JRAH8I`)
- **Roll**: JR 1 (`0000406686`), JR 2 (`0000406687`)
- **Hasil COA**: Tensile MD = `0.00`, Tensile TD = `0.00`, Elongation MD = `0`, Elongation TD = `0`.

#### 2. Tahap 5: JR Conv Metz (`JRGLAI`)
- **Roll**: `0000406781` s/d `0000406799` (Pengujian di JR 4 s/d JR 10).
- **Hasil Rata-Rata (COA)**:
  - Shrinkage MD: `2.62`
  - Shrinkage TD: `0.34`
  - Gloss 60° (Coated Side): `636`

#### 3. Tahap 6: SR Conv Metz (`SRGLAI`)
- **Roll 10 Sibling**: `0000406810` s/d `0000406819` (Lot `050000014288` s/d `050000014297`).
- **Data Uji Laboratorium**:
  - Roll 1 (`...810`): Surface Tension Coated = `38`, Metz = `52`
  - Roll 2–8 (`...811` s/d `...817`): Surface Tension Coated = `42`, Metz = (`48`, `48`, `48`, `42`, `56`, `56`, `56`)
  - Roll 9–10 (`...818` s/d `...819`): Surface Tension Coated = `44`, Metz = `58`
- **Hasil Rata-Rata (COA)**:
  - **Surface Tension Coated Side**: `42`
  - **Surface Tension Metz Side**: `52`

#### 4. Tahap 7: JR Conv Coat 2 (`JRGLBI`)
- **Roll**: `0000406821` s/d `0000406839`.
- **Hasil Uji**: JR 1–7 = `2.33`, JR 8–10 = `2.49`.
- **Hasil Rata-Rata (COA)**: **Optical Density = `2.378`**.

---

## 📌 BAGIAN 2: Skenario Baseline Komprehensif (QM01 – QM15)
*Sumber: Copy of Scenario Test COA v3.xlsm*

| Kode Skenario | Judul Skenario Testing | Contoh No DO Acuan | Karakteristik / Alur Kunci | Ketentuan Penting (Anti-Regresi) |
| :---: | :--- | :---: | :--- | :--- |
| **QM01** | Sc Normal BF - 1 JR sama dalam 1 DO | `85006234` | 1 JR Basefilm menghasilkan beberapa SR pada 1 DO yang sama. | Inspeksi JR & SR standar. Seluruh roll turunan mengambil data lot JR acuan yang sama. |
| **QM02** | Sc Normal BF - Beda JR dalam 1 DO | `85006235` | Beberapa JR Basefilm berbeda dalam 1 DO pengiriman. | Sistem harus mengagregasi rata-rata per JR atau multi-lot sesuai mapping. |
| **QM03** | Sc Normal Conv - 1 JR Conv Sama dalam 1 DO | `85006240` | 1 JR Converting yang sama untuk seluruh roll dalam 1 DO. | Menelusuri JR Basefilm dan JR Converting. Parameter Basefilm ditarik dari root, Conv ditarik dari stage perantara. |
| **QM04** | Sc Normal Conv - Beda JR Conv dalam 1 DO | `85006241` | Beberapa JR Converting berbeda dalam 1 DO. | Penelusuran independen per roll/lot converting tanpa tumpang tindih. |
| **QM05** | Sc SR BF yang di-Inspeksi SR dulu → Change Grade (1 DO 1 JR) | `85006242` | Inspeksi SR dilakukan sebelum Change Grade (pergerakan `311`/`309`). | Silsilah batch history harus mampu melacak lot inspeksi sebelum transfer grade. |
| **QM06** | Sc SR BF yang Change Grade dulu → Inspeksi SR (1 DO 1 JR) | `85006242` | Change Grade dilakukan terlebih dahulu, baru diinspeksi. | Lot inspeksi melekat pada batch baru; silsilah tetap harus terhubung ke JR asal. |
| **QM07** | Sc SR Conv yang di-Inspeksi SR dulu → Change Grade (1 DO 1 JR) | `85006243` | Skenario Converting: Inspeksi SR sebelum Change Grade. | Memastikan lot converting lama tetap terbaca di tingkat batch baru. |
| **QM08** | Sc SR Conv yang Change Grade dulu → Inspeksi SR (1 DO 1 JR) | `85006243` | Skenario Converting: Change Grade sebelum Inspeksi SR. | Lot inspeksi batch baru terhubung ke silsilah JR Conv dan JR Basefilm. |
| **QM09** | Sc SR BF yang di-Inspeksi di Secondary Slitting (1 DO 1 JR) | `85006244` | Basefilm mengalami proses pemotongan ulang (*Secondary Slitting*). | Silsilah penelusuran bertingkat SR $\to$ SR $\to$ JR Basefilm. |
| **QM10** | Sc SR Conv yang di-Inspeksi di Secondary Slitting (1 DO 1 JR) | `85006245` | Converting mengalami proses pemotongan ulang (*Secondary Slitting*). | Silsilah penelusuran bertingkat SR Conv $\to$ SR Conv $\to$ JR Conv $\to$ JR Basefilm. |
| **QM11** | Sc JOIN 2 Inputan Jumbo Roll (1 DO 1 JR) | — | Proses produksi menggabungkan (*join/splice*) 2 inputan Jumbo Roll menjadi 1 JR baru. | Multi-parent handling: mengambil nilai karakteristik dari kedua parent atau lot acuan yang valid. |
| **QM12** | Sc JOIN 2 Inputan Jumbo Roll (1 DO 2 JR) & Cari Inspeksi 20 ke atas | — | Join 2 JR dalam 1 DO berisi 2 JR berbeda, dengan pencarian inspeksi sample urutan ke-20 ke atas. | Algoritma penarikan sample order tidak boleh terpotong limit index. |
| **QM13** | 1 DO 3 JR Beda Line | — | Pengiriman 1 DO memuat roll dari 3 JR berbeda yang diproduksi di mesin/line berbeda. | Evaluasi per-line dan per-JR tidak boleh saling menimpa nilai parameter. |
| **QM14** | Sc banyak DO sekali Cetak | — | Pemanggilan massal cetak COA untuk banyak DO sekaligus di Layar ALV `ZQM002`. | Bebas memory leak, *refresh global variables* (`CLEAR`, `REFRESH`) pada setiap pergantian DO/Item. |
| **QM15** | Sc Ketika Ubah value di Print Certificate | — | Pengguna mengedit/mengubah nilai karakteristik secara manual di Layar ALV 0200 sebelum cetak. | Nilai editan manual tidak boleh tertimpa kembali oleh kalkulasi ulang database saat tombol Print ditekan. |

---

## 🔒 Standar Kepatuhan Teknis & Aturan Pengubahan Kode
1. **Prinsip Zero Hardcode**: Dilarang melakukan hardcode kode material (misal `SRGLBI`, `JRAH8I`), nomor order, atau nomor batch di dalam logika traversal program.
2. **Harmonisasi Variabel Warisan**: Variabel lama (`LOT_SR_CONV`, `LOT_JR_CONV`, `LOT_SR_BASE`, `LOT_JR_BASE`) wajib tetap terisi agar skenario **QM01 s/d QM15** tidak mengalami regresi.
3. **Penyelarasan Multi-Tier**: Pengambilan MIC bertingkat menggunakan struktur pohon dinamis (`GT_STAGE_LOTS`) dengan proteksi siklus silsilah (`LT_TREE_VISITED`).
