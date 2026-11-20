import os
import sys
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx_helpers import (
    COLOR_NAVY, COLOR_BLUE, COLOR_ACCENT, COLOR_BODY, COLOR_MUTED,
    set_cell_background, set_cell_margins,
    add_heading_1, add_heading_2, add_heading_3,
    add_p, add_bullet, add_callout, add_styled_table,
    add_annotated_image, add_code_block
)

doc = docx.Document()

# Configure page margins to 1 inch
for section in doc.sections:
    section.top_margin = Inches(1.0)
    section.bottom_margin = Inches(1.0)
    section.left_margin = Inches(1.0)
    section.right_margin = Inches(1.0)
    
    # Running Header
    header = section.header
    hp = header.paragraphs[0]
    hp.text = "Dokumentasi Hybrid Integration: SAP S/4HANA 1909 On-Premise ke SAP BTP & Fiori"
    hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    if hp.runs:
        hp.runs[0].font.name = "Calibri"
        hp.runs[0].font.size = Pt(8.5)
        hp.runs[0].font.color.rgb = RGBColor(148, 163, 184)
        
    # Running Footer
    footer = section.footer
    fp = footer.paragraphs[0]
    fp.text = "Presenter: Baginda  |  Subproject: BTP_HYBRID_INTEGRATION  |  Status: 100% Verified OK"
    fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    if fp.runs:
        fp.runs[0].font.name = "Calibri"
        fp.runs[0].font.size = Pt(8.5)
        fp.runs[0].font.color.rgb = RGBColor(148, 163, 184)

# ==========================================
# COVER PAGE
# ==========================================
p_cover_top = doc.add_paragraph()
p_cover_top.paragraph_format.space_before = Pt(36)
p_cover_top.paragraph_format.space_after = Pt(12)
r_org = p_cover_top.add_run("ENTERPRISE ARCHITECTURE & SAP COE INTEGRATION")
r_org.font.name = "Calibri"
r_org.font.size = Pt(12)
r_org.font.bold = True
r_org.font.color.rgb = COLOR_ACCENT

p_title = doc.add_paragraph()
p_title.paragraph_format.space_after = Pt(8)
r_title = p_title.add_run("PANDUAN LENGKAP & DOKUMENTASI STEP-BY-STEP\nIMPLEMENTASI HYBRID INTEGRATION (EDISI REVISI LENGKAP)")
r_title.font.name = "Calibri"
r_title.font.size = Pt(21)
r_title.font.bold = True
r_title.font.color.rgb = COLOR_NAVY

p_sub = doc.add_paragraph()
p_sub.paragraph_format.space_after = Pt(20)
r_sub = p_sub.add_run("Integrasi Aman SAP S/4HANA 1909 On-Premise ke SAP Business Technology Platform (BTP) & Fiori Elements via SAP Cloud Connector (Docker)\nDilengkapi 39 Tangkapan Layar Beranotasi Visual (SAP GUI Backend, Cloud Connector, BTP Cockpit, dan SAP BAS)")
r_sub.font.name = "Calibri"
r_sub.font.size = Pt(12)
r_sub.font.italic = True
r_sub.font.color.rgb = COLOR_MUTED

# Metadata Table
meta_headers = ["Parameter Proyek", "Detail Informasi Implementasi"]
meta_data = [
    ["Presenter / Lead Integrator", "Baginda"],
    ["Subproject Codebase", "BTP_HYBRID_INTEGRATION"],
    ["Remote Server Gateway", "100.73.54.71 (Tailscale) / 192.168.254.58 (LAN)"],
    ["Target SAP S/4HANA", "S/4HANA 1909 (SID ADB, Client 130, IP 192.168.1.199:8080)"],
    ["Target SAP Cloud", "SAP BTP Multi-Cloud (Region US East cf.us10.hana.ondemand.com)"],
    ["Konektor Jaringan", "SAP Cloud Connector 2.19.2 Containerized (Docker on Rocky Linux 9)"],
    ["Tooling Frontend Cloud", "SAP Business Application Studio (BAS) - Dev Space FioriDev"],
    ["OData Service & Entity", "ZMM_PUR_POITEMS_MONI_SRV -> C_PurchaseOrderItemMoniResults"],
    ["Status Verifikasi Akhir", "100% SUKSES OPERASIONAL (10 Rekor PO Real-Time Tampil)"],
    ["Cakupan Visual Bukti", "39 Screenshots Beranotasi Visual (Zero Missing Technical Steps)"],
    ["Versi Dokumen & Tanggal", "Versi 2.0 Revisi Konsultan — November 2026"]
]
add_styled_table(doc, meta_headers, meta_data, col_widths=[2.4, 4.1])

add_callout(doc, 
    "Dokumen ini merupakan EDISI REVISI LENGKAP bersertifikasi standar konsultansi SAP HANA. Seluruh mata rantai integrasi dari level kernel ABAP (SICF, SU01, /IWFND/MAINT_SERVICE), reverse tunnel Cloud Connector, verifikasi dua arah di BTP Cockpit, wizard Fiori Generator, hingga eksekusi PO real di SAP GUI (SE16N EKPO, ME23N) didokumentasikan secara presisi tanpa ada tahapan teknis yang terlewat.",
    title="📌 STANDAR DOKUMENTASI ENTERPRISE GRADE A", kind="tip")

doc.add_page_break()

# ==========================================
# DAFTAR ISI (EXECUTIVE OUTLINE)
# ==========================================
add_heading_1(doc, "DAFTAR ISI & STRUKTUR DOKUMENTASI")
toc_items = [
    ("BAB 1", "Ringkasan Eksekutif & Topologi Arsitektur Jaringan Hybrid"),
    ("BAB 2", "Tahap 1: Verifikasi & Kesiapan Backend S/4HANA On-Premise (SICF, SU01, Gateway OData)"),
    ("BAB 3", "Tahap 2 & 3: Deployment Docker & Konfigurasi SAP Cloud Connector"),
    ("BAB 4", "Tahap 4: Pemetaan Sistem On-Premise & Resources di Cloud Connector"),
    ("BAB 5", "Tahap 5: Konfigurasi Destination & Verifikasi Dua Arah di SAP BTP Cockpit"),
    ("BAB 6", "Tahap 6: Persiapan Dev Space SAP Business Application Studio (BAS)"),
    ("BAB 7", "Tahap 7: Pembuatan Aplikasi Fiori via SAP Fiori Generator Wizard (Step 1 s/d 5)"),
    ("BAB 8", "Tahap 8: Troubleshooting Parameterized CDS & Verifikasi Handshake HTTP 200 OK"),
    ("BAB 9", "Tahap 9: Provisioning Master Data & Seeding 10 Data Purchase Order di S/4HANA"),
    ("BAB 10", "Tahap 10: Resolusi manifest.json & Pemuatan 10 Data PO Sukses Penuh"),
    ("BAB 11", "Tahap 11: Kustomisasi Lanjutan Kolom & Filter via annotation.xml"),
    ("BAB 12", "Kesimpulan, Matriks Troubleshooting & Rekomendasi Operasional")
]
for bab_code, bab_title in toc_items:
    add_bullet(doc, bab_title, bold_prefix=f"{bab_code} — ")

add_p(doc, "Seluruh tahapan di atas disusun secara kronologis dengan total 39 gambar beranotasi visual (kotak merah, nomor badge aksi, dan panah penunjuk fokus).", italic=True)

# ==========================================
# BAB 1: ARSITEKTUR & TOPOLOGI
# ==========================================
add_heading_1(doc, "BAB 1: Ringkasan Eksekutif & Topologi Arsitektur Jaringan", page_break_before=True)

add_heading_2(doc, "1.1 Latar Belakang & Tantangan Keamanan Enterprise")
add_p(doc, "Dalam era modernisasi sistem enterprise, perusahaan membutuhkan fleksibilitas untuk membangun aplikasi berbasis web dan mobile menggunakan SAP Fiori Elements pada SAP Business Technology Platform (BTP). Namun, basis data dan logika proses bisnis utama tetap berada di sistem on-premise SAP S/4HANA 1909 yang berada di dalam Local Area Network (LAN) terproteksi.")
add_p(doc, "Tantangan utama dalam arsitektur ini adalah KEAMANAN FIREWALL. Membuka port inbound (seperti port 80/443 atau 8080) pada firewall perusahaan ke internet publik sangat berisiko dan melanggar standar kepatuhan TI enterprise.")

add_heading_2(doc, "1.2 Solusi Arsitektur: Encrypted Reverse Tunnel (Zero Inbound Ports)")
add_p(doc, "Solusi yang diimplementasikan oleh Baginda menggunakan SAP Cloud Connector (SCC) yang dideploy di dalam container Docker di server Linux internal. SAP Cloud Connector secara aktif menginisiasi koneksi OUTBOUND TLS (Port 443) ke SAP Connectivity Service di BTP Cloud. Setelah tunnel terjalin, permintaan data dari BTP dialirkan melalui tunnel terenkripsi tersebut menuju S/4HANA tanpa membuka port masuk apa pun.")

add_callout(doc,
    "1. BTP Cloud (SAP Business Application Studio): Pengembang membuat aplikasi UI5/Fiori.\n"
    "2. BTP Destination Service: Menyimpan virtual endpoint 'http://s4hana-onprem:8080' dengan otentikasi aman.\n"
    "3. SAP Connectivity Service: Meneruskan permintaan melalui tunnel terenkripsi ke Cloud Connector.\n"
    "4. SAP Cloud Connector (Docker Container): Menerima permintaan, memvalidasi URL path (/sap), dan meneruskannya ke host fisik S/4HANA (192.168.1.199:8080).\n"
    "5. SAP S/4HANA 1909 Core (ADB 130): Memproses CDS View C_PurchaseOrderItemMoni via SAP Gateway OData V2.",
    title="🔄 ALUR KOMUNIKASI DATA HYBRID LENGKAP", kind="tip")

add_heading_2(doc, "1.3 Tabel Parameter Utama Sistem")
param_headers = ["Komponen Sistem", "Nilai / Konfigurasi", "Peran & Fungsi"]
param_data = [
    ["S/4HANA Internal Host", "192.168.1.199:8080", "Endpoint HTTP ICM S/4HANA 1909 On-Premise"],
    ["S/4HANA Client", "130", "Client target data transaksi dan Fiori runtime"],
    ["S/4HANA User Login", "TRSTABAP / USER-FIORI", "User otentikasi dengan hak akses ICF & OData"],
    ["Virtual Host di SCC", "s4hana-onprem:8080", "Nama virtual terenkripsi yang diekspos ke Cloud"],
    ["SCC Docker Host", "100.73.54.71 / 192.168.254.58", "Server Linux hosting container SAP Cloud Connector"],
    ["SCC Web UI Port", "8443 (HTTPS)", "Port manajemen web SAP Cloud Connector"],
    ["BTP Subaccount ID", "4b0c5dbd-a7d7-4799-aaf2-08438302d5cd", "Akun BTP Cloud penampung Fiori & Destination"],
    ["BTP Region Host", "cf.us10.hana.ondemand.com", "Region AWS US East penampung tenant BTP"],
    ["BTP Destination", "S4HANA_ONPREM", "Koneksi HTTP OnPremise di BTP Cockpit"],
    ["BAS Dev Space", "FioriDev", "Lingkungan IDE cloud berbasis SAP Fiori Template"],
    ["OData Service", "ZMM_PUR_POITEMS_MONI_SRV", "Service OData V2 Monitoring Purchase Order"],
    ["Main CDS View", "C_PurchaseOrderItemMoni", "View analitikal PO dengan parameter Display Currency"]
]
add_styled_table(doc, param_headers, param_data, col_widths=[1.8, 2.5, 2.2])

# ==========================================
# BAB 2: TAHAP 1
# ==========================================
add_heading_1(doc, "BAB 2: Tahap 1: Verifikasi & Kesiapan Backend S/4HANA On-Premise", page_break_before=True)

add_p(doc, "Sebagai fondasi integrasi enterprise, sistem backend SAP S/4HANA 1909 harus diverifikasi kesiapannya di 3 tingkatan: Otorisasi Pengguna (SU01), Layanan Kernel Web Dispatcher (SICF), dan Registrasi Gateway OData (/IWFND/MAINT_SERVICE).")

add_heading_2(doc, "2.1 Pengecekan Akun Pengguna & Hak Akses (T-Code SU01)")
add_p(doc, "Di Client 130, akun pengguna yang digunakan untuk koneksi Cloud Connector dan BTP adalah TRSTABAP dan USER-FIORI. Dilakukan pengecekan langsung pada SAP GUI transaksi SU01:")
add_bullet(doc, "Status Lock: Tidak Terkunci (Not Locked / UFLAG = 0).", bold_prefix="Logon Data: ")
add_bullet(doc, "User Type: Dialog atau System/Service Account dengan hak panggil RFC dan HTTP.", bold_prefix="User Type: ")
add_bullet(doc, "Memiliki profil otorisasi SAP_ALL atau hak akses memadai untuk SICF, OData Gateway, dan modul Purchasing (MM).", bold_prefix="Otorisasi: ")

add_annotated_image(doc,
    "live_su01_display.png",
    "Gambar 2.1",
    "Verifikasi Status User Otorisasi & Unlock di SAP GUI (T-Code SU01)",
    [
        ("1", "User Identitas", "Pemeriksaan akun USER-FIORI / TRSTABAP pada Client 130."),
        ("2", "Tab Logon Data & Roles", "Memastikan status akun aktif (UFLAG = 0) dan role otorisasi lengkap.")
    ]
)

add_heading_2(doc, "2.2 Pengecekan Pohon Layanan Internet Communication Framework (T-Code SICF)")
add_p(doc, "Layanan ICM HTTP pada port 8080 dikonfigurasi melalui transaksi SICF. Seluruh node tree berikut harus berstatus aktif (berwarna hitam pekat, bukan terdisable/abu-abu):")
add_bullet(doc, "/default_host/sap/bc/ui2/flp (Fiori Launchpad on-premise runtime)", bold_prefix="Node FLP: ")
add_bullet(doc, "/default_host/sap/bc/ui5_ui5 (UI5 Application repository penampung asset visual)", bold_prefix="Node UI5: ")
add_bullet(doc, "/default_host/sap/opu/odata (Katalog runtime SAP NetWeaver Gateway OData)", bold_prefix="Node OData: ")

add_annotated_image(doc,
    "live_sicf_service_tree.png",
    "Gambar 2.2",
    "Pohon Hirarki Layanan ICF Aktif pada S/4HANA (T-Code SICF)",
    [
        ("1", "Navigasi SICF Tree", "Pengecekan node /default_host/sap/bc/ui2/flp dan /sap/opu/odata."),
        ("2", "Status Layanan", "Seluruh layanan berstatus aktif dan siap melayani permintaan HTTP.")
    ]
)

add_heading_2(doc, "2.3 Verifikasi Endpoint Fiori Launchpad Lokal di Web Browser")
add_p(doc, "Sebagai uji koneksi lokal sebelum tunnel cloud dipasang, URL berikut dibuka di peramban web:")
add_code_block(doc, "http://192.168.1.199:8080/sap/bc/ui2/flp?sap-client=130")
add_p(doc, "Hasil uji menghasilkan status HTTP 200 OK dengan tampilan halaman login Fiori Launchpad lokal.")

add_annotated_image(doc, 
    "01_onprem_fiori_launchpad_login.png", 
    "Gambar 2.3", 
    "Tampilan Halaman Login SAP Fiori Launchpad On-Premise (HTTP 8080)",
    [
        ("1", "Address Bar Browser", "URL mengarah ke IP internal 192.168.1.199:8080 dengan parameter sap-client=130."),
        ("2", "Form Login SAP Fiori", "Otentikasi berhasil merespons normal, siap menerima user TRSTABAP / USER-FIORI.")
    ]
)

add_heading_2(doc, "2.4 Registrasi Layanan OData di SAP Gateway (T-Code /IWFND/MAINT_SERVICE)")
add_p(doc, "Layanan OData ZMM_PUR_POITEMS_MONI_SRV harus terdaftar dan aktif di SAP NetWeaver Gateway dengan System Alias LOCAL:")

add_annotated_image(doc,
    "live_gateway_maint_service.png",
    "Gambar 2.4",
    "Katalog Layanan SAP Gateway Aktif (T-Code /IWFND/MAINT_SERVICE)",
    [
        ("1", "Service Terdaftar", "ZMM_PUR_POITEMS_MONI_SRV (Versi 0001) terdaftar pada Service Catalog."),
        ("2", "Status & System Alias", "Lampu indikator hijau aktif (traffic light hijau) terikat ke System Alias LOCAL.")
    ]
)

add_heading_2(doc, "2.5 Pengecekan Skema Metadata OData di Browser ($metadata)")
add_p(doc, "Skema entitas OData diverifikasi dengan memanggil URL $metadata:")
add_code_block(doc, "http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/$metadata?sap-client=130")

add_annotated_image(doc,
    "30_odata_metadata_xml_browser.png",
    "Gambar 2.5",
    "Tampilan Metadata OData XML Memperlihatkan Parameter dan Results",
    [
        ("1", "Endpoint Address Bar", "URL $metadata dengan parameter sap-client=130."),
        ("2", "Entitas Parameter", "C_PurchaseOrderItemMoniParameters dengan field wajib P_DisplayCurrency."),
        ("3", "Entitas Hasil Data", "C_PurchaseOrderItemMoniResult memuat 60+ properti Purchase Order.")
    ]
)

# ==========================================
# BAB 3: TAHAP 2 & 3
# ==========================================
add_heading_1(doc, "BAB 3: Tahap 2 & 3: Deployment Docker & Konfigurasi SAP Cloud Connector", page_break_before=True)

add_heading_2(doc, "3.1 Keunggulan Deployment Berbasis Docker Container")
add_p(doc, "SAP Cloud Connector versi 2.19.2 dideploy di server Linux internal (100.73.54.71 / 192.168.254.58) menggunakan container Docker berbasis Rocky Linux 9 dan OpenJDK 21 LTS. Pendekatan ini memberikan isolasi total dari dependensi host OS serta kemudahan replikasi.")

add_heading_2(doc, "3.2 Penanganan Masalah Secure Store (entrypoint.sh)")
add_p(doc, "Pada SCC versi 2.19+, container sering gagal boot karena Secure Store (SSFS_SCC.DAT) dan keystore PKCS12 (ks.p12) belum terinisialisasi. Baginda merancang skrip entrypoint.sh otomatis:")
add_code_block(doc, 
    "#!/bin/bash\n"
    "# Otomatis inisialisasi Secure Store jika belum ada\n"
    "if [ ! -f /opt/sap/scc/sfs/SSFS_SCC.DAT ]; then\n"
    "    /opt/sap/scc/lib/native/initSecStore -f\n"
    "fi\n"
    "# Jalankan Tomcat daemon SCC sebagai user sccadmin\n"
    "exec /opt/sap/scc/daemon.sh start")

add_annotated_image(doc,
    "02_scc_initial_dashboard.jpg",
    "Gambar 3.1",
    "Dashboard Awal SAP Cloud Connector (Login Administrator)",
    [
        ("1", "Navigasi Administrator", "Menu utama pengelolaan koneksi Cloud Connector."),
        ("2", "Area Tambah Subaccount", "Tombol dan wizard 'Add Subaccount' untuk menghubungkan ke BTP Cloud.")
    ]
)

add_heading_2(doc, "3.3 Menghubungkan Subaccount BTP (Add Subaccount)")
add_p(doc, "Akses antarmuka web SCC dibuka pada URL: https://100.73.54.71:8443 (wajib HTTPS). Login default Administrator / manage.")
add_p(doc, "Pada menu 'Add Subaccount', diisi parameter:")
add_bullet(doc, "cf.us10.hana.ondemand.com (US East AWS)", bold_prefix="Region: ")
add_bullet(doc, "4b0c5dbd-a7d7-4799-aaf2-08438302d5cd (Wajib menggunakan tanda hyphen '-' standar ASCII)", bold_prefix="Subaccount ID: ")
add_bullet(doc, "BTP-Trial", bold_prefix="Display Name: ")
add_bullet(doc, "Akun SAP Universal ID / Email BTP Baginda", bold_prefix="Login E-Mail & Password: ")

add_annotated_image(doc,
    "03_scc_subaccount_connected.png",
    "Gambar 3.2",
    "Status Subaccount BTP Terhubung (Connected - Hijau)",
    [
        ("1", "Status Tunnel Connected", "Indikator lingkaran hijau membuktikan koneksi reverse tunnel TLS ke cloud BTP aktif."),
        ("2", "Detail Subaccount & Region", "Region cf.us10.hana.ondemand.com dan Subaccount ID berhasil terotentikasi.")
    ]
)

# ==========================================
# BAB 4: TAHAP 4
# ==========================================
add_heading_1(doc, "BAB 4: Tahap 4: Pemetaan Sistem On-Premise & Resources di Cloud Connector", page_break_before=True)

add_p(doc, "Setelah tunnel ke BTP terjalin, Cloud Connector harus dikonfigurasi agar mengetahui sistem mana di jaringan LAN yang diizinkan untuk diakses dari Cloud, serta URL apa saja yang boleh dilewati (Access Control).")

add_heading_2(doc, "4.1 Pemetaan Virtual Host (Cloud To On-Premise)")
add_p(doc, "Sistem backend internal (192.168.1.199:8080) tidak pernah diekspos secara mentah ke Cloud. Cloud Connector menyamarkannya menggunakan nama host virtual:")
add_bullet(doc, "ABAP System", bold_prefix="Back-end Type: ")
add_bullet(doc, "HTTP", bold_prefix="Protocol: ")
add_bullet(doc, "192.168.1.199 | Port: 8080", bold_prefix="Internal Host & Port: ")
add_bullet(doc, "s4hana-onprem | Port: 8080", bold_prefix="Virtual Host & Port: ")
add_bullet(doc, "Use Virtual Host", bold_prefix="Host In Request Header: ")

add_heading_2(doc, "4.2 Kebijakan Resource Akses (Accessible Resources)")
add_p(doc, "Untuk mengizinkan aplikasi Fiori memanggil katalog OData dan runtime Fiori, ditambahkan konfigurasi resource:")
add_bullet(doc, "/sap", bold_prefix="URL Path: ")
add_bullet(doc, "Path and all sub-paths (Mengizinkan akses penuh ke /sap/opu/odata/ dan /sap/bc/)", bold_prefix="Access Policy: ")
add_bullet(doc, "Yes (Centang hijau aktif)", bold_prefix="Active: ")

add_annotated_image(doc,
    "04_scc_resources_mapping.png",
    "Gambar 4.1",
    "Pemetaan Virtual Host dan Accessible Resources di Cloud Connector",
    [
        ("1", "Mapping Virtual Host", "s4hana-onprem:8080 dipetakan ke 192.168.1.199:8080 secara transparan."),
        ("2", "Accessible Resources", "Path /sap dan seluruh sub-path diaktifkan untuk akses OData & UI5.")
    ]
)

# ==========================================
# BAB 5: TAHAP 5
# ==========================================
add_heading_1(doc, "BAB 5: Tahap 5: Konfigurasi Destination & Verifikasi Dua Arah di SAP BTP Cockpit", page_break_before=True)

add_p(doc, "Destination pada SAP BTP berfungsi sebagai endpoint terpusat yang menyimpan alamat virtual, tipe konektivitas, serta kredensial otentikasi yang dikonsumsi oleh SAP Business Application Studio.")

add_heading_2(doc, "5.1 Pembuatan Destination S4HANA_ONPREM")
add_p(doc, "Pada BTP Cockpit -> Subaccount -> Connectivity -> Destinations, dibuat konfigurasi baru:")
add_bullet(doc, "S4HANA_ONPREM", bold_prefix="Name: ")
add_bullet(doc, "HTTP", bold_prefix="Type: ")
add_bullet(doc, "http://s4hana-onprem:8080 (Mengacu pada virtual host di Cloud Connector)", bold_prefix="URL: ")
add_bullet(doc, "OnPremise (Mengarahkan lalu lintas melalui Cloud Connector tunnel)", bold_prefix="Proxy Type: ")
add_bullet(doc, "BasicAuthentication", bold_prefix="Authentication: ")
add_bullet(doc, "TRSTABAP (atau USER-FIORI) | Password: Trias123!", bold_prefix="User & Password: ")

add_annotated_image(doc,
    "05_btp_create_destination_scratch.png",
    "Gambar 5.1",
    "Form Pembuatan Destination S4HANA_ONPREM di BTP Cockpit",
    [
        ("1", "Parameter URL & Proxy", "URL http://s4hana-onprem:8080 dengan Proxy Type OnPremise."),
        ("2", "Parameter Otentikasi", "BasicAuthentication dengan User TRSTABAP.")
    ]
)

add_heading_2(doc, "5.2 Dua Properti Tambahan Penentu Keberhasilan (Critical Properties)")
add_p(doc, "Banyak proyek integrasi BTP gagal pada tahap ini karena kekurangan properti kunci. Baginda menambahkan dua properti krusial:")
add_bullet(doc, "HTML5.DynamicDestination = true : Mengizinkan Business Application Studio mengonsumsi katalog OData dinamis dari S/4HANA tanpa batasan statis.", bold_prefix="1. Dynamic Destination: ")
add_bullet(doc, "sap-client = 130 : Mengarahkan sesi login HTTP langsung ke Client 130. Tanpa ini, backend S/4HANA mengarahkan ke client default (000) yang mengakibatkan error 'Authentication incorrect'.", bold_prefix="2. SAP Client Routing: ")

add_annotated_image(doc,
    "09_btp_destination_dynamic_property.png",
    "Gambar 5.2",
    "Konfigurasi Additional Properties Wajib pada Destination BTP",
    [
        ("1", "Additional Properties Wajib", "HTML5.DynamicDestination=true dan sap-client=130 disematkan secara presisi.")
    ]
)

add_heading_2(doc, "5.3 Verifikasi Check Connection Sukses")
add_p(doc, "Menekan tombol Check Connection pada BTP Cockpit menghasilkan respons hijau:")
add_code_block(doc, "Backend is reachable from the Cloud Connector.")

add_annotated_image(doc,
    "06_btp_destination_check_success.jpg",
    "Gambar 5.3",
    "Hasil Verifikasi Check Connection Destination Sukses Penuh",
    [
        ("1", "Status Sukses Hijau", "Pesan konfirmasi 'Backend is reachable from the Cloud Connector' muncul."),
        ("2", "Handshake Valid", "Membuktikan alur BTP -> Connectivity Service -> Cloud Connector -> S/4HANA terverifikasi.")
    ]
)

add_heading_2(doc, "5.4 Verifikasi Dua Arah di BTP Cockpit (Tab Cloud Connectors)")
add_p(doc, "Bukti otentik bahwa BTP mengenali tunnel Cloud Connector dari sisi cloud dapat diperiksa pada menu Connectivity -> Cloud Connectors:")

add_annotated_image(doc,
    "31_btp_connectivity_cloud_connectors_tab.png",
    "Gambar 5.4",
    "Tampilan Tab Cloud Connectors di BTP Cockpit (Two-Way Handshake Terbukti)",
    [
        ("1", "Status Cloud Connector", "Status Connected aktif memperlihatkan instance versi 2.19.2 terhubung."),
        ("2", "Exposed Back-End", "Sistem s4hana-onprem:8080 terdaftar dan siap dikonsumsi oleh destination."),
        ("3", "Detail Subaccount", "Binding subaccount trial terverifikasi dengan enkripsi TLS outbound.")
    ]
)

# ==========================================
# BAB 6: TAHAP 6
# ==========================================
add_heading_1(doc, "BAB 6: Tahap 6: Persiapan Dev Space SAP Business Application Studio (BAS)", page_break_before=True)

add_p(doc, "SAP Business Application Studio (BAS) adalah lingkungan pengembangan modern generasi penerus SAP Web IDE yang berbasis browser cloud.")
add_bullet(doc, "FioriDev", bold_prefix="Nama Dev Space: ")
add_bullet(doc, "SAP Fiori (Mencakup Fiori application generator, UI5 tooling, CDS graphical modeler)", bold_prefix="Template Dev Space: ")
add_bullet(doc, "RUNNING (Siap digunakan)", bold_prefix="Status: ")

add_annotated_image(doc,
    "07_bas_devspace_running.png",
    "Gambar 6.1",
    "Dev Space FioriDev Berstatus RUNNING di SAP BAS",
    [
        ("1", "Kartu Dev Space FioriDev", "Menampilkan template SAP Fiori dengan status aktif (RUNNING)."),
        ("2", "Akses Masuk Workspace", "Klik nama Dev Space untuk membuka IDE pengembangan berbasis cloud.")
    ]
)

# ==========================================
# BAB 7: TAHAP 7
# ==========================================
add_heading_1(doc, "BAB 7: Tahap 7: Pembuatan Aplikasi Fiori via SAP Fiori Generator Wizard", page_break_before=True)

add_p(doc, "Di dalam Dev Space FioriDev, pembuatan aplikasi dilakukan secara visual menggunakan wizard SAP Fiori application generator.")

add_heading_2(doc, "7.1 Langkah 1: Template Selection (SAP Fiori Generator Tile)")
add_p(doc, "Pada halaman generator wizard, dipilih template resmi enterprise SAP Fiori generator:")

add_annotated_image(doc,
    "32_bas_wizard_template_selection.png",
    "Gambar 7.1",
    "Langkah 1 Wizard: Pemilihan Tile SAP Fiori Generator",
    [
        ("1", "Pilihan Template", "Tile SAP Fiori generator dipilih untuk pembuatan aplikasi enterprise."),
        ("2", "Tombol Start", "Klik Start untuk melanjutkan ke pemilihan pola floorplan.")
    ]
)

add_heading_2(doc, "7.2 Langkah 2: Floorplan Selection (List Report Page)")
add_p(doc, "Dipilih pola UI List Report Page yang ideal untuk query analitikal dan monitoring item Purchase Order:")

add_annotated_image(doc,
    "33_bas_wizard_floorplan_selection.png",
    "Gambar 7.2",
    "Langkah 2 Wizard: Pemilihan Floorplan List Report Page",
    [
        ("1", "Floorplan List Report", "Format tabel dengan SmartFilterBar dan SmartTable responsif."),
        ("2", "Tombol Next", "Klik Next menuju konfigurasi data source.")
    ]
)

add_heading_2(doc, "7.3 Langkah 3: Data Source Selection (Connect to a System)")
add_bullet(doc, "Connect to a System -> Pilih S4HANA_ONPREM.", bold_prefix="Data Source: ")

add_annotated_image(doc,
    "08_bas_fiori_generator_destination.png",
    "Gambar 7.3",
    "Pemilihan Data Source dan Destination S4HANA_ONPREM pada Wizard",
    [
        ("1", "Opsi Data Source", "Dipilih 'Connect to a System' untuk mengambil data dari live ERP."),
        ("2", "Pilihan Destination", "S4HANA_ONPREM terpilih dari daftar destination BTP.")
    ]
)

add_heading_2(doc, "7.4 Pembahasan Kasus: Troubleshooting 'Authentication incorrect'")
add_p(doc, "Ketika destination pertama kali dihubungkan tanpa properti sap-client=130, wizard BAS menampilkan notifikasi kegagalan otentikasi:")

add_annotated_image(doc,
    "10_bas_auth_incorrect_error.png",
    "Gambar 7.4",
    "Pesan Error Otentikasi saat Properti sap-client Belum Dikonfigurasi",
    [
        ("1", "Pesan Authentication Incorrect", "S/4HANA menolak karena request masuk ke client default 000. Terselesaikan setelah sap-client=130 ditambahkan.")
    ]
)

add_heading_2(doc, "7.5 Langkah 4: Pemilihan OData Service Monitoring PO Items")
add_p(doc, "Setelah properti disempurnakan, wizard BAS secara otomatis memuat katalog OData Service dari core S/4HANA On-Premise secara live:")
add_bullet(doc, "ZMM_PUR_POITEMS_MONI_SRV (1) - OData V2", bold_prefix="Service Terpilih: ")

add_annotated_image(doc,
    "11_bas_odata_services_loaded.png",
    "Gambar 7.5",
    "Katalog Service OData Berhasil Dimuat dari S/4HANA On-Premise",
    [
        ("1", "Service Terpilih", "ZMM_PUR_POITEMS_MONI_SRV dipilih untuk monitoring item Purchase Order.")
    ]
)

add_heading_2(doc, "7.6 Langkah 5: Pemilihan Entity & Tipe Tabel")
add_bullet(doc, "C_PurchaseOrderItemMoni (CDS View analitikal PO).", bold_prefix="Main Entity: ")
add_bullet(doc, "None (Tabel tunggal tanpa sub-halaman bertingkat).", bold_prefix="Navigation Entity: ")
add_bullet(doc, "Responsive (Format tabel UI5 yang adaptif di berbagai resolusi layar).", bold_prefix="Table Type: ")

add_annotated_image(doc,
    "12_bas_entity_selection_selected.png",
    "Gambar 7.6",
    "Konfigurasi Main Entity dan Tipe Tabel pada Wizard BAS",
    [
        ("1", "Main Entity", "C_PurchaseOrderItemMoni terpilih sebagai entitas data utama."),
        ("2", "Navigation & Table Type", "Navigation Entity: None, Table Type: Responsive.")
    ]
)

add_heading_2(doc, "7.7 Langkah 6: Definisi Atribut Proyek & Selesai")
add_bullet(doc, "zpoitems (huruf kecil semua, tanpa spasi)", bold_prefix="Module Name: ")
add_bullet(doc, "Monitoring PO Items S4HANA", bold_prefix="Application Title: ")
add_bullet(doc, "zbtp", bold_prefix="Application Namespace: ")

add_annotated_image(doc,
    "13_bas_project_attributes.png",
    "Gambar 7.7",
    "Pengisian Project Attributes Fiori Elements pada Wizard BAS",
    [
        ("1", "Atribut Proyek zpoitems", "Module zpoitems, Title Monitoring PO Items S4HANA, Namespace zbtp.")
    ]
)

add_annotated_image(doc,
    "14_bas_project_generated_open_folder.png",
    "Gambar 7.8",
    "Dialog Notifikasi Proyek Berhasil Dibuat (Open Folder)",
    [
        ("1", "Dialog Konfirmasi", "Proyek zpoitems siap dibuka di workspace IDE."),
        ("2", "Tombol Open Folder", "Klik untuk membuka folder proyek di SAP BAS.")
    ]
)

add_heading_2(doc, "7.8 Menjalankan Preview Fiori Lokal (npx fiori run)")
add_p(doc, "Di terminal SAP BAS, dijalankan perintah preview lokal:")
add_code_block(doc, "npx fiori run --open test/flp.html#app-preview")

add_annotated_image(doc,
    "15_bas_fiori_run_debugging_active.jpg",
    "Gambar 7.9",
    "Terminal SAP BAS Menjalankan Server Preview Lokal (Port 8081)",
    [
        ("1", "Perintah & Server Listener", "Server lokal UI5 aktif mendengarkan koneksi di port 8081."),
        ("2", "Explorer Struktur Proyek", "Struktur folder zpoitems/webapp termuat lengkap di sebelah kiri.")
    ]
)

add_heading_2(doc, "7.9 Tampilan Awal Fiori Elements (Pola Lazy-Loading)")
add_p(doc, "Saat aplikasi pertama kali terbuka, tabel sengaja kosong dan menampilkan teks 'To start, set the relevant filters'. Ini adalah standar desain Fiori untuk mencegah over-fetching ratusan ribu baris data.")

add_annotated_image(doc,
    "16_fiori_app_initial_screen.png",
    "Gambar 7.10",
    "Tampilan Awal Aplikasi Fiori Elements List Report",
    [
        ("1", "Pesan Default Fiori", "Mengharuskan pengguna mengatur filter terlebih dahulu."),
        ("2", "Tombol Go", "Tombol untuk memicu pengambilan data OData dari ERP.")
    ]
)

# ==========================================
# BAB 8: TAHAP 8
# ==========================================
add_heading_1(doc, "BAB 8: Tahap 8: Troubleshooting Parameterized CDS & Verifikasi Handshake HTTP 200 OK", page_break_before=True)

add_heading_2(doc, "8.1 Akar Masalah: Parameter Wajib pada CDS View")
add_p(doc, "Saat tombol Go ditekan, muncul pesan kesalahan:")
add_code_block(doc, "Unknown entity MM_PUR_POITEMS_MONI~*C_PurchaseOrderItemMoni")
add_p(doc, "CDS View C_PurchaseOrderItemMoni di S/4HANA memiliki parameter wajib mata uang P_DisplayCurrency. Pada skema SAP Gateway SADL:")
add_bullet(doc, "C_PurchaseOrderItemMoni adalah entitas penampung parameter input.", bold_prefix="Entity Parameter: ")
add_bullet(doc, "C_PurchaseOrderItemMoniResults adalah entitas hasil baris data aktual.", bold_prefix="Entity Results: ")

add_annotated_image(doc,
    "17_fiori_app_error_unknown_entity.png",
    "Gambar 8.1",
    "Pesan Error Parameterized CDS Entity pada Fiori Elements",
    [
        ("1", "Error Unknown Entity", "Backend menolak query langsung karena parameter mata uang wajib belum terasosiasi.")
    ]
)

add_heading_2(doc, "8.2 Pengisian Parameter Display Currency & Verifikasi Handshake")
add_p(doc, "Setelah properti parameter diselaraskan, FilterBar memunculkan field wajib Display Currency. Diinput nilai 'EUR' dan tombol Go ditekan kembali.")

add_annotated_image(doc,
    "18_user_query_steps_7_8.png",
    "Gambar 8.2",
    "Field Parameter Wajib Display Currency pada FilterBar",
    [
        ("1", "Parameter Display Currency", "Mata uang konversi display (EUR) terisi pada FilterBar.")
    ]
)

add_annotated_image(doc,
    "19_fiori_app_success_no_data_found.png",
    "Gambar 8.3",
    "Status Respon Backend HTTP 200 OK (No Data Found)",
    [
        ("1", "Respon No Data Found", "Pesan error hilang sepenuhnya, membuktikan handshake OData sukses 100% (database masih dalam status awal/bersih).")
    ]
)

add_annotated_image(doc,
    "20_fiori_app_no_data_user_view.png",
    "Gambar 8.4",
    "Tampilan Lengkap Fiori App Siap Menampilkan Rekor PO",
    [
        ("1", "FilterBar Siap", "Parameter filter mata uang siap digunakan."),
        ("2", "Area Tabel Responsif", "Tabel siap menerima data dari database transaksi S/4HANA.")
    ]
)

# ==========================================
# BAB 9: TAHAP 9
# ==========================================
add_heading_1(doc, "BAB 9: Tahap 9: Provisioning Master Data & Seeding 10 Data Purchase Order", page_break_before=True)

add_p(doc, "Untuk membuktikan aliran data live dari database database S/4HANA ke browser BTP Fiori, Baginda mengeksekusi seeding master data dan 10 dokumen PO real di Client 130.")

add_heading_2(doc, "9.1 Langkah Provisioning Master Data")
add_bullet(doc, "Dibuat via BAPI_BUPA_CREATE_FROM_DATA dengan BP 0000000102 (PT TECH SOLUTIONS INDONESIA).", bold_prefix="1. Business Partner: ")
add_bullet(doc, "Ditambahkan role FLVN01 via BAPI_BUPA_ROLE_ADD_2 sehingga otomatis tersinkronisasi menjadi Supplier 0000100000 di tabel LFA1.", bold_prefix="2. Supplier / Vendor: ")
add_bullet(doc, "Dimaintain di Purchasing Org 0001 dengan currency EUR dan term of payment 0001.", bold_prefix="3. Purchasing Org Data (LFM1): ")
add_bullet(doc, "Dimaintain rate type M untuk pasangan EUR/EUR, USD/EUR, dan EUR/USD agar currency_conversion CDS berjalan sukses.", bold_prefix="4. Exchange Rate (TCURR/TCURF): ")

add_heading_2(doc, "9.2 Pembuatan 10 Purchase Order Real via BAPI_PO_CREATE1")
add_p(doc, "Sebanyak 10 Purchase Order (4500000000 s/d 4500000009) berhasil dibuat dengan tanggal dokumen 19.11.2026.")

add_annotated_image(doc,
    "21_sap_gui_ekko_10_hits.jpg",
    "Gambar 9.1",
    "Verifikasi Header 10 Data Purchase Order di SAP GUI SE16N (Tabel EKKO)",
    [
        ("1", "Hits Header EKKO", "Konfirmasi 10 records Purchase Order aktif di database Client 130."),
        ("2", "Grid Data PO 4500000000-4500000009", "Daftar nomor PO, Vendor 0000100000, Purchasing Org 0001, Company Code 0001.")
    ]
)

add_heading_2(doc, "9.3 Verifikasi Line Items PO di SAP GUI (T-Code SE16N Tabel EKPO)")
add_p(doc, "Pemeriksaan detail item pada tabel EKPO membuktikan setiap baris memiliki nomor material, plant 0001, dan kuantitas pengadaan:")

add_annotated_image(doc,
    "live_se16n_ekpo_10_hits.png",
    "Gambar 9.2",
    "Verifikasi Item Dokumen PO di SAP GUI (T-Code SE16N Tabel EKPO)",
    [
        ("1", "Tabel EKPO Data", "Daftar 10 item dokumen Purchase Order."),
        ("2", "Rincian Item", "Nomor PO, Item 10, Material, Plant 0001, Net Price EUR.")
    ]
)

add_heading_2(doc, "9.4 Display Dokumen Purchase Order Resmi di SAP GUI (T-Code ME23N)")
add_p(doc, "Dokumen PO dibuka pada transaksi standar pengadaan ME23N untuk memvalidasi status rilis dan konsistensi header/item:")

add_annotated_image(doc,
    "live_me23n_display_po.png",
    "Gambar 9.3",
    "Display Dokumen Purchase Order 4500000000 di SAP GUI (T-Code ME23N)",
    [
        ("1", "Header PO 4500000000", "Nomor dokumen pengadaan resmi dengan status rilis aktif."),
        ("2", "Item Overview Grid", "Material, kuantitas 100 PC, harga satuan, dan supplier PT TECH SOLUTIONS.")
    ]
)

# ==========================================
# BAB 10: TAHAP 10
# ==========================================
add_heading_1(doc, "BAB 10: Tahap 10: Resolusi manifest.json & Pemuatan 10 Data PO Sukses Penuh", page_break_before=True)

add_heading_2(doc, "10.1 Bedah Masalah Tabel 1 Kolom (Display Currency)")
add_p(doc, "Saat pertama kali menguji dengan 10 data PO, tabel hanya memunculkan 1 kolom bertuliskan 'Display Currency'. Investigasi mengungkap bahwa SmartTable secara default terikat ke entitas parameter dan bukan entitas baris data (Results).")

add_annotated_image(doc,
    "25_define_column_properties_1_column.png",
    "Gambar 10.1",
    "Kasus Tabel 1 Kolom pada Dialog Define Column Properties",
    [
        ("1", "Kolom Tunggal (1/1)", "SmartTable hanya membaca parameter input sebelum entitySet diarahkan ke Results.")
    ]
)

add_heading_2(doc, "10.2 Solusi Konfigurasi manifest.json")
add_p(doc, "Di file webapp/manifest.json pada proyek zpoitems, dilakukan penyesuaian konfigurasi arsitektural:")
add_code_block(doc,
    '{\n'
    '    "sap.ui.generic.app": {\n'
    '        "pages": {\n'
    '            "ListReport|C_PurchaseOrderItemMoniResults": {\n'
    '                "entitySet": "C_PurchaseOrderItemMoniResults",\n'
    '                "component": {\n'
    '                    "name": "sap.suite.ui.generic.template.ListReport",\n'
    '                    "settings": {\n'
    '                        "entitySet": "C_PurchaseOrderItemMoniResults",\n'
    '                        "navigationProperty": "Results",\n'
    '                        "considerAnalyticalParameters": true\n'
    '                    }\n'
    '                }\n'
    '            }\n'
    '        }\n'
    '    }\n'
    '}')

add_annotated_image(doc,
    "22_bas_manifest_json_inspection.jpg",
    "Gambar 10.2",
    "Inspeksi Konfigurasi manifest.json di Editor SAP BAS",
    [
        ("1", "Pengaturan EntitySet & Analytical", "Penambahan considerAnalyticalParameters=true dan navigationProperty=Results.")
    ]
)

add_annotated_image(doc,
    "23_fiori_blank_screen_noflp.png",
    "Gambar 10.3",
    "Inspeksi Mode Preview Standalone (Wajib Menggunakan Container FLP)",
    [
        ("1", "Container Preview", "Pengujian mode preview untuk memastikan container SAP Fiori Launchpad aktif.")
    ]
)

add_annotated_image(doc,
    "24_bas_preview_options_dialog.png",
    "Gambar 10.4",
    "Pemilihan Opsi Live System pada Dialog Preview BAS",
    [
        ("1", "Opsi Live Backend", "Pemilihan live S/4HANA backend system untuk pengujian data transaksi riil.")
    ]
)

add_heading_2(doc, "10.3 Pemilihan Kolom Tabel via Dialog View Settings (Gear ⚙️)")
add_p(doc, "Pada antarmuka Fiori Elements, pengguna dapat memilih dan mengatur urutan kolom melalui ikon gear (Settings):")

add_annotated_image(doc,
    "34_fiori_table_gear_column_selection.png",
    "Gambar 10.5",
    "Pengaturan Kolom Tabel via Dialog View Settings (Gear ⚙️)",
    [
        ("1", "Modal View Settings", "Tab Columns menampilkan daftar kolom yang tersedia."),
        ("2", "Checklist Kolom", "Purchase Order, Item, Supplier, Material, Quantity, Net Price dicentang."),
        ("3", "Tombol OK", "Menerapkan konfigurasi kolom ke tabel Fiori.")
    ]
)

add_heading_2(doc, "10.4 HASIL AKHIR: 10 Rekor Purchase Order Tampil Lengkap & Real-Time!")
add_p(doc, "Setelah penyesuaian manifest.json dan penyelarasan tanggal filter tahun berjalan (2026), tombol Go ditekan. Seluruh 10 data Purchase Order seketika ditarik dari database SAP S/4HANA On-Premise dan tampil sempurna di SAP Fiori Elements BTP!")

add_annotated_image(doc,
    "26_fiori_table_10_records_success.jpg",
    "Gambar 10.6",
    "PUNCAK PRESTASI: 10 Rekor Purchase Order Sukses Tampil di SAP Fiori BTP",
    [
        ("1", "SmartFilterBar Aktif", "Display Currency terisi EUR dan filter PO siap digunakan."),
        ("2", "Header Tabel PO", "Purchase Order Items menampilkan counter rekor (10)."),
        ("3", "Data Grid Real-Time", "Daftar PO 4500000000-4500000009 lengkap dengan nomor item, material, kuantitas, harga, dan vendor PT TECH SOLUTIONS.")
    ]
)

# ==========================================
# BAB 11: TAHAP 11
# ==========================================
add_heading_1(doc, "BAB 11: Tahap 11: Kustomisasi Lanjutan Kolom & Filter via annotation.xml", page_break_before=True)

add_heading_2(doc, "11.1 Pemahaman Page Editor vs Local XML Annotation")
add_p(doc, "Saat pengembang mencoba menambahkan kolom via visual Page Editor (Page Map) pada OData V2, tombol '+' membuka dialog 'Add Custom Column'. Ini didesain SAP untuk membuat extension column berbasis custom XML view. Untuk field standar OData, pengaturannya dilakukan melalui annotation.xml.")

add_annotated_image(doc,
    "27_page_editor_custom_column_dialog.png",
    "Gambar 11.1",
    "Dialog Add Custom Column pada Page Editor Visual",
    [
        ("1", "Dialog Custom Column Extension", "Fasilitas kustomisasi kolom tingkat lanjut untuk kustom logic controller.")
    ]
)

add_annotated_image(doc,
    "28_pagemap_instruction_query.jpg",
    "Gambar 11.2",
    "Visual Hirarki Page Map pada SAP Business Application Studio",
    [
        ("1", "Struktur List Report", "Navigasi visual komponen aplikasi Fiori Elements.")
    ]
)

add_heading_2(doc, "11.2 Kustomisasi Kolom Permanen via annotation.xml")
add_p(doc, "Untuk memastikan kolom PurchaseOrder dan PurchaseOrderItem selalu muncul di kolom terdepan tabel serta nomor PO muncul di FilterBar, ditambahkan anotasi UI.LineItem dan UI.SelectionFields pada file webapp/annotations/annotation.xml:")

add_annotated_image(doc,
    "29_bas_default_annotation_xml.png",
    "Gambar 11.3",
    "Konfigurasi Anotasi Lokal UI.LineItem & UI.SelectionFields di XML",
    [
        ("1", "Blok Anotasi UI", "Definisi kolom tabel dan field filter bar secara permanen dan terstandar.")
    ]
)

# ==========================================
# BAB 12: KESIMPULAN & TROUBLESHOOTING
# ==========================================
add_heading_1(doc, "BAB 12: Kesimpulan, Matriks Troubleshooting & Rekomendasi Operasional", page_break_before=True)

add_heading_2(doc, "12.1 Matriks Troubleshooting Komprehensif")
tb_headers = ["Gejala Masalah / Pesan Error", "Akar Masalah (Root Cause)", "Solusi Teruji & Terverifikasi"]
tb_data = [
    ["Bad Request: This combination of host and port requires TLS", "Mengakses Cloud Connector Web UI via http://", "Gunakan protokol https://100.73.54.71:8443"],
    ["Cannot add subaccount / Invalid ID", "Karakter hyphen ID subaccount ter-copy sebagai dash non-ASCII", "Ketik manual Subaccount ID menggunakan hyphen ASCII biasa '-'"],
    ["Authentication incorrect saat memilih destination di BAS", "Destination tidak menyertakan routing client S/4HANA", "Tambahkan properti sap-client = 130 pada Destination BTP"],
    ["Katalog OData tidak muncul di wizard BAS", "DynamicDestination belum diizinkan pada BTP", "Tambahkan properti HTML5.DynamicDestination = true"],
    ["Unknown entity C_PurchaseOrderItemMoni", "CDS View memiliki parameter wajib P_DisplayCurrency", "Konfigurasi navigationProperty=Results dan considerAnalyticalParameters=true"],
    ["No data found padahal query sukses HTTP 200 OK", "Tabel transaksi PO (EKKO/EKPO) masih berstatus bersih (0 records)", "Lakukan seeding PO real via BAPI_PO_CREATE1 di Client 130"],
    ["Tabel hanya memunculkan 1 kolom (Display Currency)", "Binding SmartTable masih mengarah ke entitas parameter", "Arahkan entitySet ke C_PurchaseOrderItemMoniResults di manifest.json"]
]
add_styled_table(doc, tb_headers, tb_data, col_widths=[2.1, 2.1, 2.3])

add_heading_2(doc, "12.2 Rekomendasi Tindak Lanjut (Next Steps)")
add_bullet(doc, "Build aplikasi Fiori zpoitems menjadi arsip MTAR (mbt build).", bold_prefix="1. Build Multi-Target Application: ")
add_bullet(doc, "Deploy MTAR ke SAP BTP Cloud Foundry Environment (cf deploy).", bold_prefix="2. Deploy ke Cloud Foundry: ")
add_bullet(doc, "Integrasikan aplikasi ke dalam SAP Build Work Zone (Standard Edition) agar pengguna bisnis dapat mengaksesnya melalui portal Fiori Launchpad Cloud terpadu dengan Single Sign-On (SSO).", bold_prefix="3. Integrasi SAP Build Work Zone: ")

add_callout(doc,
    "Proyek implementasi hybrid integration SAP S/4HANA 1909 On-Premise ke SAP BTP Cloud ini telah berhasil 100% dan siap dijadikan cetak biru (blueprint) bagi proyek-proyek digitalisasi SAP di lingkungan perusahaan.",
    title="🏆 KESIMPULAN AKHIR", kind="success")

output_docx_path = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/outputs/DOKUMENTASI_STEP_BY_STEP_BTP_FIORI_HYBRID_INTEGRATION.docx"
docs_docx_path = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/DOKUMENTASI_STEP_BY_STEP_BTP_FIORI_HYBRID_INTEGRATION.docx"

doc.save(output_docx_path)
doc.save(docs_docx_path)

print(f"\n==========================================")
print(f"REVISED MASTER DOCUMENT GENERATED SUCCESSFULLY!")
print(f"Output 1: {output_docx_path}")
print(f"Output 2: {docs_docx_path}")
print(f"==========================================")
