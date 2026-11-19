guide_path = '/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/STEP_BY_STEP_IMPLEMENTATION_GUIDE.md'

with open(guide_path, 'r', encoding='utf-8') as f:
    content = f.read()

target = "--- \n\n## 9. Matriks Troubleshooting & Solusi Lengkap"
if "## 9. Matriks Troubleshooting" not in content:
    # Try alternate search
    target = "## 9. Matriks Troubleshooting & Solusi Lengkap"

new_section_8_6 = """### 8.6 Resolusi Penampilan Data pada Fiori Elements List Report (BAS)
Setelah data 10 PO berhasil dibuat di S/4HANA dan query OData terverifikasi mengembalikan HTTP 200 OK, pengujian awal pada preview SAP BAS sempat menampilkan tabel dengan hanya 1 kolom (*Display Currency*) dan berstatus *"No data found"*. Investigasi mendalam mengungkap 2 temuan arsitektural krusial:

1. **Akar Masalah Tabel 1 Kolom (`Display Currency`): Parameter vs Results Entity Set**
   - **Analisis Metadata OData:** CDS View `C_PurchaseOrderItemMoni` adalah view berparameter (`sap:semantics="parameters"`). Entitas `C_PurchaseOrderItemMoni` pada hakikatnya hanyalah *wadah penampung parameter mata uang input* (`P_DisplayCurrency`), sehingga propertinya hanya ada 1.
   - Seluruh 60+ kolom Purchase Order sesungguhnya (*PurchaseOrder*, *PurchaseOrderItem*, *Supplier*, *Material*, *NetPriceAmount*, *OrderQuantity*, *ScheduleLineDeliveryDate*, dll) berada pada entity set anak bernama **`C_PurchaseOrderItemMoniResults`** (yang diakses via relasi navigasi `/Results`).
   - Ketika List Report pada `manifest.json` di-bind ke `entitySet: "C_PurchaseOrderItemMoni"`, SmartTable menganggap entitas tersebut hanya tabel mata uang dengan 1 kolom, sehingga dialog *Define Column Properties* hanya menampilkan `(1/1) Display Currency` dan tidak dapat menarik baris PO.
   - **Solusi Arsitektural di `manifest.json`:**
     - Target entity set pada `pages` diubah langsung ke entity set hasil data: `"entitySet": "C_PurchaseOrderItemMoniResults"`.
     - Ditambahkan properti `"considerAnalyticalParameters": true` di dalam `component.settings` List Report.
     - Dengan konfigurasi ini, framework SAP Fiori Elements secara otomatis mengenali relasi parameter dari OData metadata, memunculkan input wajib `Display Currency` pada SmartFilterBar, dan mengikat SmartTable ke `C_PurchaseOrderItemMoniResults` yang memuat seluruh 60+ kolom PO lengkap!

2. **Sinkronisasi Filter Tanggal Default Fiori vs Tanggal Server S/4HANA**
   - Di `manifest.json` terkonfigurasi `"filterSettings": { "dateSettings": { "useDateRange": true } }`, yang secara default membatasi pencarian ke dokumen tahun berjalan (**2026**).
   - Dokumen PO di S/4HANA awalnya tersimpan dengan tanggal sistem demo `10.12.2020`, sehingga query filter tahun 2026 menghasilkan 0 baris (*No data found*).
   - **Solusi:** Tanggal dokumen (`BEDAT`, `AEDAT`, `EINDT`) ke-10 PO diperbarui langsung menjadi tanggal berjalan (`19.11.2026`). Begitu tanggal diselaraskan, query filter tahun 2026 langsung berhasil mengembalikan 10 baris PO secara utuh.

3. **Status Akhir (Milestone Verified OK):**
   - Aplikasi Fiori Elements List Report `zpoitems` di SAP BAS sukses besar memuat dan menampilkan ke-10 baris Purchase Order dari core ERP S/4HANA On-Premise secara real-time via SAP Cloud Connector & BTP Destination!

---

## 9. Matriks Troubleshooting & Solusi Lengkap"""

content = content.replace("## 9. Matriks Troubleshooting & Solusi Lengkap", new_section_8_6)

# Now append new rows to Troubleshooting table
table_end = "| **Tabel Fiori kosong (0 rows) padahal data di EKKO/EKPO sudah ada** | CDS View `IMMPURCHORDRITEM` mewajibkan `EKPO-BSTYP = 'F'` dan `EKPO-MFRNR = Vendor`, serta konversi mata uang `P_DisplayCurrency` membutuhkan rate aktif di `TCURR` & `TCURF`. | Pastikan kolom `EKPO-BSTYP = 'F'`, `EKPO-MFRNR` terisi nomor vendor, dan tabel `TCURF`/`TCURR` memiliki entry konversi EUR. |"

new_table_rows = table_end + """
| **Tabel Fiori hanya punya 1 kolom "Display Currency" (Define Column Properties: 1/1)** | List Report pada `manifest.json` terikat ke entitas parameter `C_PurchaseOrderItemMoni`, bukan ke entitas data `C_PurchaseOrderItemMoniResults`. | Ubah `entitySet` menjadi `C_PurchaseOrderItemMoniResults` dan tambahkan `"considerAnalyticalParameters": true` pada `component.settings` di `manifest.json`. |
| **Menjalankan preview `start-noflp` (`index.html`) menghasilkan layar putih polos (*blank screen*)** | Aplikasi SAP Fiori Elements wajib berjalan di dalam shell container Fiori Launchpad (`sap.ushell`) untuk me-render SmartFilterBar dan SmartTable. Membuka `index.html` langsung menyebabkan *bootstrapping crash*. | Selalu jalankan preview menggunakan opsi default: `start fiori run --open "test/flp.html#app-preview"`. |
| **Preview aplikasi Fiori menampilkan layar putih pada port berbeda (misal port 8084)** | Perintah `fiori run` dijalankan ulang saat proses sebelumnya masih aktif di port 8083, atau port yang diakses pada URL browser tidak sesuai dengan port yang sedang listening di terminal BAS. | Periksa terminal BAS untuk memastikan nomor port yang aktif (misal port 8083), atau klik popup *"Open in New Tab"* resmi dari BAS. |"""

content = content.replace(table_end, new_table_rows)

with open(guide_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated STEP_BY_STEP_IMPLEMENTATION_GUIDE.md successfully.")
