import re

path = 'subproject/BTP_HYBRID_INTEGRATION/docs/STEP_BY_STEP_IMPLEMENTATION_GUIDE.md'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace Section 8 with Section 8 (Seeding) + Section 9 (Troubleshooting)
old_section_8 = "## 8. Matriks Troubleshooting & Solusi Lengkap"

new_content_to_insert = """## 8. Langkah 8: Provisioning Master Data & Seeding 10 Data Purchase Order (Opsi A)

Setelah integrasi hybrid Fiori Elements terhubung dan merespons HTTP 200 OK (*No data found*), langkah selanjutnya adalah mengisi database SAP S/4HANA On-Premise Client 130 dengan 10 dokumen Purchase Order real agar tabel Fiori terisi secara penuh dan interaktif.

### 8.1 Pembuatan Business Partner (Vendor Master)
1. **BAPI Execution:**
   - Dijalankan BAPI `BAPI_BUPA_CREATE_FROM_DATA` untuk membuat Business Partner:
     - Nomor BP: `0000000102`
     - Nama: `PT TECH SOLUTIONS INDONESIA`
     - Alamat: Jakarta, ID
2. **Penambahan Role Supplier (CVI):**
   - Dijalankan BAPI `BAPI_BUPA_ROLE_ADD_2` dengan role `FLVN01` (Supplier/Vendor).
   - Sinkronisasi otomatis Customer-Vendor Integration (CVI) di S/4HANA menghasilkan Vendor Master di tabel `LFA1` dengan nomor vendor: **`0000100000`**.

### 8.2 Konfigurasi Purchasing Organization Data (`LFM1`)
- Agar vendor dapat digunakan dalam transaksi pembelian di Purchasing Org `0001`, data `LFM1` dimaintain:
  - `LIFNR`: `0000100000`
  - `EKORG`: `0001`
  - `WAERS`: `EUR`
  - `ZTERM`: `0001`
  - `EKGRP`: `001`

### 8.3 Pemeliharaan Exchange Rate (`TCURR` & `TCURF`)
- CDS View `C_PurchaseOrderItemMoni` menggunakan kalkulasi konversi mata uang dinamis (`currency_conversion`).
- Untuk memastikan konversi ke parameter wajib `P_DisplayCurrency='EUR'` berjalan sempurna tanpa mengeliminasi baris:
  - Dimaintain faktor konversi pada `TCURF` untuk rate type `M` (`EUR -> EUR`, `USD -> EUR`, `EUR -> USD`).
  - Dimaintain nilai tukar pada `TCURR` untuk rate type `M` (`EUR -> EUR` rasio `1.00000`).

### 8.4 Seeding 10 Dokumen Purchase Order (`EKKO`, `EKPO`, `EKET`)
Dibuat 10 dokumen Purchase Order bernilai bisnis nyata untuk demonstrasi arsitektur hybrid BTP:
- **Rentang Dokumen:** `4500000001` s/d `4500000010`
- **Header (`EKKO`):** CoCode `0001`, PurchOrg `0001`, PurchGroup `001`, Vendor `0000100000`, Currency `EUR`, DocType `NB`, DocDate `20201210` (tanggal sistem S/4HANA).
- **Item (`EKPO`) & Schedule Line (`EKET`):**
  1. `4500000001` / `00010`: Cloud Connector Bridge Adapter - Enterprise Edition | Qty: 50 ROL | Net: 450.00 EUR
  2. `4500000002` / `00010`: S/4HANA On-Premise Integration Gateway Module | Qty: 25 ROL | Net: 850.00 EUR
  3. `4500000003` / `00010`: BTP Fiori Launchpad User License - Annual | Qty: 100 ROL | Net: 120.00 EUR
  4. `4500000004` / `00010`: Business Technology Platform Custom Extension Kit | Qty: 10 ROL | Net: 1,200.00 EUR
  5. `4500000005` / `00010`: Hybrid Architecture Security Token Hardware Key | Qty: 80 ROL | Net: 75.00 EUR
  6. `4500000006` / `00010`: SAP Build Work Zone Advanced Runtime Instance | Qty: 5 ROL | Net: 3,500.00 EUR
  7. `4500000007` / `00010`: Destination Service High-Performance Router | Qty: 15 ROL | Net: 620.00 EUR
  8. `4500000008` / `00010`: S/4HANA CDS View Data Replication Accelerator | Qty: 30 ROL | Net: 480.00 EUR
  9. `4500000009` / `00010`: Enterprise OData Connectivity Middleware Appliance | Qty: 20 ROL | Net: 950.00 EUR
  10. `4500000010` / `00010`: Cloud Foundry Microservice Application Container | Qty: 40 ROL | Net: 310.00 EUR

### 8.5 Temuan Kritis Arsitektur CDS View S/4HANA (`IMMPURCHORDRITEM`)
- **Akar Masalah Awal (Data 0 Baris di OData):**
  Saat PO dibuat di `EKKO`/`EKPO`, query OData awalnya masih menghasilkan 0 baris. Analisis mendalam struktur DDIC database view `IMMPURCHORDRITEM` mengungkap 2 kondisi wajib berikut:
  1. `IMMPURCHORDRITEM` mewajibkan join `I_SUPPLIER_CDS-SUPPLIER = IMMPURGDOCITEM-MANUFACTURER`. Field `MANUFACTURER` bersumber dari kolom `EKPO-MFRNR`. Jika `EKPO-MFRNR` kosong, join supplier akan gagal (*dropped*). Solusi: Kolom `EKPO-MFRNR` dimaintain sama dengan nomor vendor (`0000100000`).
  2. `IMMPURCHORDRITEM` memiliki kriteria filter wajib `IMMPURGDOCITEM-PURCHASINGDOCUMENTCATEGORY = 'F'`. Kolom ini dipetakan langsung ke `EKPO-BSTYP`. Solusi: Kolom `EKPO-BSTYP` dimaintain dengan nilai `'F'` (Purchase Order).
- **Hasil Verifikasi OData:**
  Query ke endpoint `/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/C_PurchaseOrderItemMoni(P_DisplayCurrency='EUR')/Results?$top=15&$format=json` langsung mengembalikan **10 baris PO secara utuh dan presisi (HTTP 200 OK)**.

---

## 9. Matriks Troubleshooting & Solusi Lengkap"""

if old_section_8 in content:
    content = content.replace(old_section_8, new_content_to_insert)
    # Also update table of contents if present
    content = content.replace("| **Error saat klik Go: \"Unknown entity MM_PUR_POITEMS_MONI~*C_PurchaseOrderItemMoni\" / \"The entity was not found\"** | `C_PurchaseOrderItemMoni` adalah CDS View berparameter (`P_DisplayCurrency`). Backend SADL mewajibkan navigasi `Results` untuk mengambil data barisnya (`C_PurchaseOrderItemMoni(P_DisplayCurrency=...)/Results`). | Tambahkan `\"navigationProperty\": \"Results\"` pada `\"settings\"` di `webapp/manifest.json`, refresh browser, isi Display Currency pada filter, lalu klik **Go**. |",
                            "| **Error saat klik Go: \"Unknown entity MM_PUR_POITEMS_MONI~*C_PurchaseOrderItemMoni\" / \"The entity was not found\"** | `C_PurchaseOrderItemMoni` adalah CDS View berparameter (`P_DisplayCurrency`). Backend SADL mewajibkan navigasi `Results` untuk mengambil data barisnya (`C_PurchaseOrderItemMoni(P_DisplayCurrency=...)/Results`). | Tambahkan `\"navigationProperty\": \"Results\"` pada `\"settings\"` di `webapp/manifest.json`, refresh browser, isi Display Currency pada filter, lalu klik **Go**. |\n| **Tabel Fiori kosong (0 rows) padahal data di EKKO/EKPO sudah ada** | CDS View `IMMPURCHORDRITEM` mewajibkan `EKPO-BSTYP = 'F'` dan `EKPO-MFRNR = Vendor`, serta konversi mata uang `P_DisplayCurrency` membutuhkan rate aktif di `TCURR` & `TCURF`. | Pastikan kolom `EKPO-BSTYP = 'F'`, `EKPO-MFRNR` terisi nomor vendor, dan tabel `TCURF`/`TCURR` memiliki entry konversi EUR. |")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated STEP_BY_STEP_IMPLEMENTATION_GUIDE.md successfully!")
else:
    print("Section 8 not found!")
