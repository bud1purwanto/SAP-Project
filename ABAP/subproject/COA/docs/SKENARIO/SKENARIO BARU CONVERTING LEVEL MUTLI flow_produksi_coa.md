# Alur Produksi End-to-End & Mapping Nilai Rata-Rata (Average) COA

Dokumen ini merangkum alur produksi dari tahap awal (**Basefilm BOPP**) hingga tahap akhir (**Converting Coating**), beserta detail nomor batch/lot pada setiap tahapan dan nilai **Average** yang diambil ke dalam **Certificate of Analysis (COA)**.

## Ringkasan Alur Produksi & Sumber Data COA

Alur produksi melewati 7 tahapan berurutan, di mana hanya tahapan **JR (Jumbo Roll)** dan **SR (Slit Roll)** tertentu yang memiliki mapping pengujian untuk ditarik nilai rata-ratanya (*Average*) ke dalam COA:

| Tahap | Proses Produksi | Kode Material | Jumlah Roll / Lot | Rentang Nomor Batch / Lot | Status Mapping COA | Parameter yang Diambil ke COA (Nilai Average) |
| :--- | :--- | :--- | :---: | :--- | :--- | :--- |
| **1** | **JR Basefilm (BOPP)** | `JRAH8I` | 2 (JR 1 – JR 2) | `0000406686` – `0000406687` | **Aktif** | Tensile Strength MD (`0.00`), Tensile Strength TD (`0.00`), Elongation MD (`0`), Elongation TD (`0`) |
| **2** | **SR Basefilm (BOPP)** | `SRAH8I` | 10 (JR 1 – JR 10) | `0000406711` – `0000406720` | *Tidak Ada Mapping* | — |
| **3** | **JR Conv (Coat)** | `JRGKAI` | 10 (JR 1 – JR 10) | `0000406727` – `0000406745` *(Ganjil)* | *Tidak Ada Mapping* | — |
| **4** | **SR Conv (Coat)** | `SRGKAI` | 10 (JR 1 – JR 10) | `0000406756` – `0000406765` | *Tidak Ada Mapping* | — |
| **5** | **JR Conv (Metz)** | `JRGLAI` | 10 (JR 1 – JR 10) | `0000406781` – `0000406799` *(Ganjil)* | **Aktif** | Shrinkage MD (`2.62`), Shrinkage TD (`0.34`), Gloss 60° Coated Side (`636`) |
| **6** | **SR Conv (Metz)** | `SRGLAI` | 10 (JR 1 – JR 10) | `0000406810` – `0000406819` | **Aktif** | Surface Tension Coated Side (`42`), Surface Tension Metz Side (`52`) |
| **7** | **JR Conv (Coat)** | `JRGLBI` | 10 (JR 1 – JR 10) | `0000406821` – `0000406839` *(Ganjil)* | **Aktif** | Optical Density (`2.378`) |

## Detail Data Produksi per Tahapan

### 1. JR Basefilm (BOPP) — `JRAH8I`

Tahap awal pembuatan Jumbo Roll Basefilm BOPP dengan pengambilan parameter mekanis dasar untuk COA.

| Properties | JR 1 (`0000406686`) | JR 2 (`0000406687`) | **Average (COA)** |
| :--- | :---: | :---: | :---: |
| **Tensile Strength MD** | - | - | **0.00** |
| **Tensile Strength TD** | - | - | **0.00** |
| **Elongation MD** | - | - | **0** |
| **Elongation TD** | - | - | **0** |

### 2. SR Basefilm (BOPP) — `SRAH8I`

Tahap *slitting* Basefilm BOPP menjadi 10 roll (`0000406711` s/d `0000406720`).

> **Catatan Mapping COA:** Tidak ada Mapping COA yang mengambil **SR Basefilm**.

| Properties | JR 1 | JR 2 | JR 3 | JR 4 | JR 5 | JR 6 | JR 7 | JR 8 | JR 9 | JR 10 | **Average (COA)** |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Nomor Batch / Lot** | `0000406711` | `0000406712` | `0000406713` | `0000406714` | `0000406715` | `0000406716` | `0000406717` | `0000406718` | `0000406719` | `0000406720` | — |
| *Status COA* | — | — | — | — | — | — | — | — | — | — | *Tidak ada mapping* |

### 3. JR Conv (Coat) — `JRGKAI`

Tahap *converting coating* pertama pada Jumbo Roll (`0000406727` s/d `0000406745`).

> **Catatan Mapping COA:** Tidak ada Mapping COA yang mengambil **JR Converting (Coat)** pada kode `JRGKAI`.

| Properties | JR 1 | JR 2 | JR 3 | JR 4 | JR 5 | JR 6 | JR 7 | JR 8 | JR 9 | JR 10 | **Average (COA)** |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Nomor Batch / Lot** | `0000406727` | `0000406729` | `0000406731` | `0000406733` | `0000406735` | `0000406737` | `0000406739` | `0000406741` | `0000406743` | `0000406745` | — |
| *Status COA* | — | — | — | — | — | — | — | — | — | — | *Tidak ada mapping* |

### 4. SR Conv (Coat) — `SRGKAI`

Tahap *slitting* hasil *converting coating* pertama (`0000406756` s/d `0000406765`).

> **Catatan Mapping COA:** Tidak ada Mapping COA yang mengambil **SR Converting (Coat)**.

| Properties | JR 1 | JR 2 | JR 3 | JR 4 | JR 5 | JR 6 | JR 7 | JR 8 | JR 9 | JR 10 | **Average (COA)** |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Nomor Batch / Lot** | `0000406756` | `0000406757` | `0000406758` | `0000406759` | `0000406760` | `0000406761` | `0000406762` | `0000406763` | `0000406764` | `0000406765` | — |
| *Status COA* | — | — | — | — | — | — | — | — | — | — | *Tidak ada mapping* |

### 5. JR Conv (Metz) — `JRGLAI`

Tahap *converting metallizing* pada Jumbo Roll (`0000406781` s/d `0000406799`). Nilai *Average* diambil dari pengujian roll JR 4 hingga JR 10 untuk masuk ke COA.

| Properties | JR 1 (`0000406781`) | JR 2 (`0000406783`) | JR 3 (`0000406785`) | JR 4 (`0000406787`) | JR 5 (`0000406789`) | JR 6 (`0000406791`) | JR 7 (`0000406793`) | JR 8 (`0000406795`) | JR 9 (`0000406797`) | JR 10 (`0000406799`) | **Average (COA)** |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Shrinkage MD** | - | - | - | 2.62 | 2.62 | 2.62 | 2.62 | 2.62 | 2.62 | 2.62 | **2.62** |
| **Shrinkage TD** | - | - | - | 0.34 | 0.34 | 0.34 | 0.34 | 0.34 | 0.34 | 0.34 | **0.34** |
| **Gloss 60° ( Coated Side )** | - | - | - | 636 | 636 | 636 | 636 | 636 | 636 | 636 | **636** |

### 6. SR Conv (Metz) — `SRGLAI`

Tahap *slitting* setelah *metallizing* (`0000406810` s/d `0000406819`). Mengukur tegangan permukaan (*Surface Tension*) pada sisi *Coated* dan sisi *Metz* untuk COA.

| Properties | JR 1 (`0000406810`) | JR 2 (`0000406811`) | JR 3 (`0000406812`) | JR 4 (`0000406813`) | JR 5 (`0000406814`) | JR 6 (`0000406815`) | JR 7 (`0000406816`) | JR 8 (`0000406817`) | JR 9 (`0000406818`) | JR 10 (`0000406819`) | **Average (COA)** |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Surface Tension Coated Side** | 38 | 42 | 42 | 42 | 42 | 42 | 42 | 42 | 44 | 44 | **42** |
| **Surface Tension Metz Side** | 52 | 48 | 48 | 48 | 42 | 56 | 56 | 56 | 58 | 58 | **52** |

### 7. JR Conv (Coat) — `JRGLBI`

Tahap akhir *converting coating* (`0000406821` s/d `0000406839`). Mengukur *Optical Density* dari JR 1 hingga JR 10 untuk masuk ke COA.

| Properties | JR 1 (`0000406821`) | JR 2 (`0000406823`) | JR 3 (`0000406825`) | JR 4 (`0000406827`) | JR 5 (`0000406829`) | JR 6 (`0000406831`) | JR 7 (`0000406833`) | JR 8 (`0000406835`) | JR 9 (`0000406837`) | JR 10 (`0000406839`) | **Average (COA)** |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Optical Density** | 2.33 | 2.33 | 2.33 | 2.33 | 2.33 | 2.33 | 2.33 | 2.49 | 2.49 | 2.49 | **2.378** |

## Rekapitulasi Nilai Akhir untuk COA (Dari Kolom Average)

Tabel berikut menampilkan konsolidasi seluruh parameter kualitas beserta nilai **Average** yang ditarik ke dokumen **COA** dari awal hingga akhir proses produksi:

| No | Parameter Pengujian (Properties) | Sumber Tahapan Proses | Kode Material | Nilai Average (COA) |
| :---: | :--- | :--- | :--- | :---: |
| 1 | **Tensile Strength MD** | JR Basefilm (BOPP) | `JRAH8I` | **0.00** |
| 2 | **Tensile Strength TD** | JR Basefilm (BOPP) | `JRAH8I` | **0.00** |
| 3 | **Elongation MD** | JR Basefilm (BOPP) | `JRAH8I` | **0** |
| 4 | **Elongation TD** | JR Basefilm (BOPP) | `JRAH8I` | **0** |
| 5 | **Shrinkage MD** | JR Conv (Metz) | `JRGLAI` | **2.62** |
| 6 | **Shrinkage TD** | JR Conv (Metz) | `JRGLAI` | **0.34** |
| 7 | **Gloss 60° ( Coated Side )** | JR Conv (Metz) | `JRGLAI` | **636** |
| 8 | **Surface Tension Coated Side** | SR Conv (Metz) | `SRGLAI` | **42** |
| 9 | **Surface Tension Metz Side** | SR Conv (Metz) | `SRGLAI` | **52** |
| 10 | **Optical Density** | JR Conv (Coat) | `JRGLBI` | **2.378** |
