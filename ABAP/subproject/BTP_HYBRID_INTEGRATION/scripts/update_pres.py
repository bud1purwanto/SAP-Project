pres_path = '/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/EXECUTIVE_SUMMARY_PRESENTATION.md'

with open(pres_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Update slide 6 to mark Option A complete and next is Option C
old_slide_6 = """## Slide 6: Rencana Lanjutan & Rekomendasi (Next Steps)

1. **Deploy Aplikasi Fiori Perdana:**
   - Memilih business scenario (misalnya: Approval Purchase Order, Monitoring Sales Order, atau Master Data Material).
   - Men-generate Fiori List Report dan mendeploy artifact ke SAP BTP HTML5 Application Repository."""

new_slide_6 = """## Slide 6: Pencapaian Milestone & Rencana Lanjutan (Next Steps)

1. **Milestone Opsi A (SUKSES 100%): Data Real S/4HANA Tampil Live di Fiori Elements**
   - 10 Dokumen Purchase Order otentik (`4500000001` - `4500000010`) telah dibuat di S/4HANA On-Premise Client 130.
   - Aplikasi Fiori Elements List Report di SAP BAS sukses memuat dan menampilkan ke-10 baris PO secara real-time via OData berparameter `C_PurchaseOrderItemMoniResults`.
   - Data mengalir sempurna: Nomor PO, Vendor, Material, Qty, Harga, Net Amount, dan Mata Uang.
2. **Milestone Opsi C (Langkah Berikutnya): Deploy Aplikasi ke SAP BTP HTML5 Repository / Launchpad**
   - Build artifact produksi UI5 (`npm run build`).
   - Deployment ke SAP BTP Cloud Foundry runtime menggunakan HTML5 Application Repository (`cf deploy` / `npm run deploy`).
   - Pemasangan aplikasi pada portal terpadu SAP Build Work Zone / Fiori Launchpad di BTP Cloud."""

content = content.replace(old_slide_6, new_slide_6)

# Update attachments list from 19 to 25
old_attach_header = "## Lampiran: Bukti Visual Integrasi (Screenshots Lengkap 19 File)"
new_attach_header = "## Lampiran: Bukti Visual Integrasi (Screenshots Lengkap 25 File)"
content = content.replace(old_attach_header, new_attach_header)

old_attach_end = "- `19_fiori_app_success_no_data_found.png`: Bukti otentik keberhasilan integrasi end-to-end (HTTP 200 OK, tabel siap pakai)"
new_attach_end = """- `19_fiori_app_success_no_data_found.png`: Bukti otentik keberhasilan integrasi end-to-end (HTTP 200 OK, tabel siap pakai)
- `20_fiori_app_no_data_user_view.png`: Tampilan awal preview aplikasi saat tabel memuat filter mata uang default
- `21_sap_gui_ekko_10_hits.jpg`: Verifikasi otentik SAP GUI SE16 menampilkan 10 dokumen PO di tabel `EKKO`
- `22_bas_manifest_json_inspection.jpg`: Inspeksi konfigurasi `manifest.json` di SAP Business Application Studio
- `23_fiori_blank_screen_noflp.png`: Investigasi crash layar putih saat menjalankan preview mode standalone `no-flp`
- `24_bas_preview_options_dialog.png`: Menu Preview Options di SAP BAS (pemilihan opsi FLP sandbox)
- `25_define_column_properties_1_column.png`: Temuan kunci personalisasi tabel (1/1 kolom) yang mengonfirmasi perlunya entity set `Results`"""

content = content.replace(old_attach_end, new_attach_end)

with open(pres_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated EXECUTIVE_SUMMARY_PRESENTATION.md successfully.")
