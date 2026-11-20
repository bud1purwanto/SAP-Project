import os
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
    
    # Header & Footer
    header = section.header
    hp = header.paragraphs[0]
    hp.text = "Dokumentasi Hybrid Integration: SAP S/4HANA 1909 On-Premise ke SAP BTP & Fiori"
    hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    if hp.runs:
        hp.runs[0].font.name = "Calibri"
        hp.runs[0].font.size = Pt(8.5)
        hp.runs[0].font.color.rgb = RGBColor(148, 163, 184)
        
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
r_title = p_title.add_run("PANDUAN LENGKAP & DOKUMENTASI STEP-BY-STEP\nIMPLEMENTASI HYBRID INTEGRATION")
r_title.font.name = "Calibri"
r_title.font.size = Pt(22)
r_title.font.bold = True
r_title.font.color.rgb = COLOR_NAVY

p_sub = doc.add_paragraph()
p_sub.paragraph_format.space_after = Pt(24)
r_sub = p_sub.add_run("Integrasi Aman SAP S/4HANA 1909 On-Premise ke SAP Business Technology Platform (BTP) & Fiori Elements via SAP Cloud Connector (Docker)")
r_sub.font.name = "Calibri"
r_sub.font.size = Pt(13)
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
    ["Versi Dokumen & Tanggal", "Versi 1.0 Final - November 2026"]
]
add_styled_table(doc, meta_headers, meta_data, col_widths=[2.5, 4.0])

add_callout(doc, 
    "Dokumen ini memuat panduan komprehensif, runtut per tahap, dan dilengkapi 29 tangkapan layar (screenshot) beranotasi visual (kotak merah dan nomor penunjuk aksi). Dokumentasi ini dirancang agar siap dipresentasikan kepada manajemen maupun dibagikan ke tim teknis sebagai standar acuan implementasi hybrid cloud SAP.",
    title="📌 TUJUAN & CAKUPAN DOKUMEN", kind="tip")

doc.add_page_break()

# ==========================================
# DAFTAR ISI (EXECUTIVE OUTLINE)
# ==========================================
add_heading_1(doc, "DAFTAR ISI & STRUKTUR DOKUMENTASI")
toc_items = [
    ("BAB 1", "Ringkasan Eksekutif & Topologi Arsitektur Jaringan Hybrid"),
    ("BAB 2", "Tahap 1: Verifikasi & Kesiapan Sistem SAP S/4HANA On-Premise"),
    ("BAB 3", "Tahap 2 & 3: Deployment Docker & Konfigurasi SAP Cloud Connector"),
    ("BAB 4", "Tahap 4: Pemetaan Sistem On-Premise & Resources di Cloud Connector"),
    ("BAB 5", "Tahap 5: Konfigurasi Destination di SAP BTP Cockpit"),
    ("BAB 6", "Tahap 6: Persiapan Dev Space SAP Business Application Studio (BAS)"),
    ("BAB 7", "Tahap 7: Pembuatan Aplikasi Fiori via SAP Fiori Generator Wizard"),
    ("BAB 8", "Tahap 8: Troubleshooting Parameterized CDS & Verifikasi Handshake HTTP 200 OK"),
    ("BAB 9", "Tahap 9: Provisioning Master Data & Seeding 10 Data Purchase Order"),
    ("BAB 10", "Tahap 10: Resolusi manifest.json & Pemuatan 10 Data PO Sukses Penuh"),
    ("BAB 11", "Tahap 11: Kustomisasi Lanjutan Kolom & Filter via annotation.xml"),
    ("BAB 12", "Kesimpulan, Matriks Troubleshooting & Rekomendasi Operasional")
]
for bab_code, bab_title in toc_items:
    add_bullet(doc, bab_title, bold_prefix=f"{bab_code} — ")

add_p(doc, "Seluruh tahapan di atas disusun secara kronologis berdasarkan perjalanan implementasi aktual yang telah teruji dan terverifikasi secara penuh pada infrastruktur perusahaan.", italic=True)

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

doc.save("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/outputs/doc_part1.docx")
print("Part 1 built successfully.")
