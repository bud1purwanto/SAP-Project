import os
import math
from PIL import Image, ImageDraw, ImageFont

src_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"
out_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/annotated"
os.makedirs(out_dir, exist_ok=True)

font_bold_path = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
font_title = ImageFont.truetype(font_bold_path, 15)
font_badge = ImageFont.truetype(font_bold_path, 13)
font_label = ImageFont.truetype(font_bold_path, 11)

def draw_arrow(draw, start, end, color=(220, 38, 38), width=3, arrow_len=14):
    x1, y1 = start
    x2, y2 = end
    draw.line([start, end], fill=color, width=width)
    dx = x2 - x1
    dy = y2 - y1
    angle = math.atan2(dy, dx)
    p1 = (x2 - arrow_len * math.cos(angle - math.pi / 6),
          y2 - arrow_len * math.sin(angle - math.pi / 6))
    p2 = (x2 - arrow_len * math.cos(angle + math.pi / 6),
          y2 - arrow_len * math.sin(angle + math.pi / 6))
    draw.polygon([end, p1, p2], fill=color)

def annotate_image(fname, step_title, annotations):
    p_in = os.path.join(src_dir, fname)
    if not os.path.exists(p_in):
        print(f"Skipping {fname}, file not found.")
        return
    
    orig = Image.open(p_in).convert("RGB")
    w, h = orig.size
    
    banner_h = 36
    new_h = h + banner_h
    new_img = Image.new("RGB", (w, new_h), (15, 23, 42)) # Slate 900
    new_img.paste(orig, (0, banner_h))
    
    draw = ImageDraw.Draw(new_img)
    # Banner title
    draw.text((14, 9), step_title, fill=(255, 255, 255), font=font_title)
    # Blue accent line
    draw.line([(0, banner_h - 1), (w, banner_h - 1)], fill=(59, 130, 246), width=2)
    
    for anno in annotations:
        box = anno.get('box')
        num = str(anno.get('num', '1'))
        lbl = anno.get('label', '')
        arrow = anno.get('arrow')
        color = anno.get('color', (220, 38, 38))
        
        if box:
            bx0, by0, bx1, by1 = box
            by0 += banner_h
            by1 += banner_h
            
            # draw box outline
            draw.rectangle([bx0, by0, bx1, by1], outline=color, width=3)
            
            # draw badge
            badge_r = 13
            badge_cx = bx0 + 16
            badge_cy = max(banner_h + 16, by0 - 13)
            draw.ellipse([badge_cx - badge_r, badge_cy - badge_r, badge_cx + badge_r, badge_cy + badge_r],
                         fill=color, outline=(255, 255, 255), width=2)
            draw.text((badge_cx, badge_cy), num, fill=(255, 255, 255), font=font_badge, anchor="mm")
            
            # draw label
            if lbl:
                tb = font_label.getbbox(lbl)
                tw = tb[2] - tb[0]
                th = tb[3] - tb[1]
                lx = badge_cx + badge_r + 4
                ly = badge_cy - th // 2 - 2
                draw.rounded_rectangle([lx - 3, ly - 2, lx + tw + 6, ly + th + 4], radius=3, fill=color)
                draw.text((lx, ly - tb[1]), lbl, fill=(255, 255, 255), font=font_label)
        
        if arrow:
            (ax0, ay0), (ax1, ay1) = arrow
            ay0 += banner_h
            ay1 += banner_h
            draw_arrow(draw, (ax0, ay0), (ax1, ay1), color=color, width=3)
            draw.ellipse([ax0 - 13, ay0 - 13, ax0 + 13, ay0 + 13], fill=color, outline=(255, 255, 255), width=2)
            draw.text((ax0, ay0), num, fill=(255, 255, 255), font=font_badge, anchor="mm")
    
    p_out = os.path.join(out_dir, fname)
    new_img.save(p_out, quality=95)
    print(f"Generated: {fname}")

CONFIGS = [
    ("01_onprem_fiori_launchpad_login.png", "TAHAP 1: Verifikasi Endpoint Fiori Launchpad S/4HANA On-Premise", [
        {'box': (70, 20, 790, 65), 'num': '1', 'label': 'URL: http://192.168.1.199:8080/sap/bc/ui2/flp?sap-client=130'},
        {'box': (95, 230, 720, 635), 'num': '2', 'label': 'Form Login User TRSTABAP / USER-FIORI (Client 130)'}
    ]),
    ("02_scc_initial_dashboard.jpg", "TAHAP 2: Dashboard Awal SAP Cloud Connector (Docker Container)", [
        {'box': (15, 50, 230, 520), 'num': '1', 'label': 'Menu Navigasi Administrator SCC'},
        {'box': (240, 65, 995, 480), 'num': '2', 'label': 'Area Konfigurasi Penambahan Subaccount BTP'}
    ]),
    ("03_scc_subaccount_connected.png", "TAHAP 3: Subaccount BTP Terhubung ke Cloud Connector", [
        {'box': (25, 65, 850, 140), 'num': '1', 'label': 'Status Tunnel: Connected (Indikator Aktif Hijau)'},
        {'box': (25, 145, 850, 365), 'num': '2', 'label': 'Region: cf.us10.hana.ondemand.com & Subaccount ID'}
    ]),
    ("04_scc_resources_mapping.png", "TAHAP 4: Cloud To On-Premise System & Resource Mapping", [
        {'box': (25, 75, 995, 330), 'num': '1', 'label': 'Virtual Host (s4hana-onprem:8080) -> Internal (192.168.1.199:8080)'},
        {'box': (25, 345, 995, 645), 'num': '2', 'label': 'Resource Mapping: URL Path /sap (Path and all sub-paths)'}
    ]),
    ("05_btp_create_destination_scratch.png", "TAHAP 5: Konfigurasi Destination S4HANA_ONPREM di BTP Cockpit", [
        {'box': (25, 30, 495, 430), 'num': '1', 'label': 'Name: S4HANA_ONPREM | URL: http://s4hana-onprem:8080 | Proxy: OnPremise'},
        {'box': (505, 30, 985, 430), 'num': '2', 'label': 'Authentication: BasicAuthentication | User: TRSTABAP'}
    ]),
    ("06_btp_destination_check_success.jpg", "TAHAP 5: Verifikasi Check Connection Destination Sukses", [
        {'box': (320, 140, 700, 370), 'num': '1', 'label': 'Sukses: Backend is reachable from the Cloud Connector'},
        {'arrow': ((220, 250), (320, 250)), 'num': '2', 'label': 'Handshake Terverifikasi'}
    ]),
    ("07_bas_devspace_running.png", "TAHAP 6: Persiapan Dev Space SAP Business Application Studio (BAS)", [
        {'box': (35, 105, 990, 325), 'num': '1', 'label': 'Dev Space: FioriDev | Tipe: SAP Fiori | Status: RUNNING'},
        {'arrow': ((150, 260), (90, 175)), 'num': '2', 'label': 'Klik untuk Buka Workspace'}
    ]),
    ("08_bas_fiori_generator_destination.png", "TAHAP 7: Fiori Generator - Pemilihan Data Source & Destination", [
        {'box': (50, 110, 970, 280), 'num': '1', 'label': 'Data source: Connect to a System'},
        {'box': (50, 290, 970, 460), 'num': '2', 'label': 'System Destination: S4HANA_ONPREM'}
    ]),
    ("09_btp_destination_dynamic_property.png", "TAHAP 5: Tambahan Properti Wajib Destination di BTP Cockpit", [
        {'box': (30, 95, 990, 485), 'num': '1', 'label': 'Wajib: HTML5.DynamicDestination=true & sap-client=130'}
    ]),
    ("10_bas_auth_incorrect_error.png", "TROUBLESHOOTING: Mengatasi Error 'Authentication incorrect'", [
        {'box': (30, 60, 990, 250), 'num': '1', 'label': 'Error: Authentication incorrect (Solusi: Tambahkan sap-client=130)'}
    ]),
    ("11_bas_odata_services_loaded.png", "TAHAP 7: Fiori Generator - Katalog OData Service Terpilih", [
        {'box': (50, 170, 970, 410), 'num': '1', 'label': 'Pilih: ZMM_PUR_POITEMS_MONI_SRV (1) - OData V2'}
    ]),
    ("12_bas_entity_selection_selected.png", "TAHAP 7: Fiori Generator - Pemilihan Entity & Table Type", [
        {'box': (45, 55, 975, 205), 'num': '1', 'label': 'Main Entity: C_PurchaseOrderItemMoni'},
        {'box': (45, 215, 975, 385), 'num': '2', 'label': 'Navigation: None | Table Type: Responsive'}
    ]),
    ("13_bas_project_attributes.png", "TAHAP 7: Fiori Generator - Definisi Project Attributes", [
        {'box': (40, 35, 980, 185), 'num': '1', 'label': 'Module: zpoitems | Title: Monitoring PO Items S4HANA | Namespace: zbtp'}
    ]),
    ("14_bas_project_generated_open_folder.png", "TAHAP 7: Proyek Selesai Dibuat - Buka Folder Workspace", [
        {'box': (250, 85, 770, 300), 'num': '1', 'label': 'Dialog Project Generated: Klik tombol biru Open Folder'},
        {'arrow': ((220, 220), (360, 220)), 'num': '2', 'label': 'Akses Project zpoitems'}
    ]),
    ("15_bas_fiori_run_debugging_active.jpg", "TAHAP 7: Menjalankan Preview Fiori di BAS Terminal", [
        {'box': (35, 375, 990, 770), 'num': '1', 'label': 'Terminal: npx fiori run | Server aktif di http://localhost:8081'},
        {'box': (35, 65, 310, 370), 'num': '2', 'label': 'Struktur Proyek: zpoitems'}
    ]),
    ("16_fiori_app_initial_screen.png", "TAHAP 7: Tampilan Awal Fiori Elements (Pola Lazy-Loading)", [
        {'box': (90, 210, 930, 390), 'num': '1', 'label': 'Pesan Default: To start, set the relevant filters'},
        {'box': (810, 85, 990, 165), 'num': '2', 'label': 'Tombol Go untuk trigger query'}
    ]),
    ("17_fiori_app_error_unknown_entity.png", "TROUBLESHOOTING: Parameterized CDS Entity Error", [
        {'box': (170, 150, 850, 490), 'num': '1', 'label': 'Unknown entity: CDS View membutuhkan parameter P_DisplayCurrency'}
    ]),
    ("18_user_query_steps_7_8.png", "TAHAP 8: Parameter Input Display Currency", [
        {'box': (25, 15, 940, 85), 'num': '1', 'label': 'Field Parameter Wajib: Display Currency (Isi: EUR)'}
    ]),
    ("19_fiori_app_success_no_data_found.png", "TAHAP 8: Verifikasi Handshake HTTP 200 OK (Database Bersih)", [
        {'box': (35, 55, 990, 290), 'num': '1', 'label': 'Respon: No data found (HTTP 200 OK Sukses - Tabel EKKO Bersih)'}
    ]),
    ("20_fiori_app_no_data_user_view.png", "TAHAP 8: Tampilan Lengkap FilterBar & Status Siap Data", [
        {'box': (25, 55, 995, 225), 'num': '1', 'label': 'FilterBar: Display Currency EUR Terisi'},
        {'box': (25, 235, 995, 445), 'num': '2', 'label': 'Tabel Siap Menerima Rekor Purchase Order'}
    ]),
    ("21_sap_gui_ekko_10_hits.jpg", "TAHAP 9: Verifikasi 10 Purchase Order di SAP GUI S/4HANA (SE16N)", [
        {'box': (25, 55, 995, 135), 'num': '1', 'label': 'Tabel EKKO: 10 Records Berhasil Dibuat di Client 130'},
        {'box': (25, 140, 995, 690), 'num': '2', 'label': 'Daftar PO 4500000000 s/d 4500000009 | Vendor PT TECH SOLUTIONS'}
    ]),
    ("22_bas_manifest_json_inspection.jpg", "TAHAP 10: Konfigurasi manifest.json di BAS Code Editor", [
        {'box': (170, 210, 990, 570), 'num': '1', 'label': 'Pengaturan: navigationProperty=Results & considerAnalyticalParameters=true'}
    ]),
    ("23_fiori_blank_screen_noflp.png", "TAHAP 10: Analisis Standalone vs FLP Preview Mode", [
        {'box': (35, 75, 990, 850), 'num': '1', 'label': 'Preview FLP Container (test/flp.html) Wajib untuk Fiori Elements'}
    ]),
    ("24_bas_preview_options_dialog.png", "TAHAP 10: Dialog Pemilihan Opsi Preview Fiori", [
        {'box': (170, 115, 850, 430), 'num': '1', 'label': 'Pilih: Run with real backend system (S/4HANA Live)'}
    ]),
    ("25_define_column_properties_1_column.png", "TAHAP 10: Analisis Kasus 1 Kolom vs Results EntitySet", [
        {'box': (170, 130, 850, 550), 'num': '1', 'label': 'Kasus: (1/1) Display Currency Muncul jika Entitas Belum diarahkan ke Results'}
    ]),
    ("26_fiori_table_10_records_success.jpg", "TAHAP 10: HASIL AKHIR - 10 DATA PURCHASE ORDER TAMPIL LENGKAP!", [
        {'box': (25, 60, 995, 185), 'num': '1', 'label': 'Filter: Display Currency EUR & Tombol Go'},
        {'box': (25, 190, 995, 255), 'num': '2', 'label': 'Purchase Order Items (10 Rekor)'},
        {'box': (25, 260, 995, 840), 'num': '3', 'label': 'Data Live: PO Number, Item, Material, Qty, Amount EUR, Vendor'}
    ]),
    ("27_page_editor_custom_column_dialog.png", "TAHAP 11: Page Editor - Add Custom Column Dialog", [
        {'box': (90, 150, 760, 670), 'num': '1', 'label': 'Tombol + pada Page Editor untuk Custom Extension Column'}
    ]),
    ("28_pagemap_instruction_query.jpg", "TAHAP 11: Struktur Visual Fiori Elements Page Map", [
        {'box': (90, 90, 930, 490), 'num': '1', 'label': 'Struktur Hirarki: List Report Page -> Object Page'}
    ]),
    ("29_bas_default_annotation_xml.png", "TAHAP 11: Kustomisasi Kolom & Filter Permanen di annotation.xml", [
        {'box': (35, 55, 850, 430), 'num': '1', 'label': 'Definisi XML: UI.LineItem (PurchaseOrder, Item) & UI.SelectionFields'}
    ])
]

for fname, title, annos in CONFIGS:
    annotate_image(fname, title, annos)

print("\nAll 29 images annotated successfully!")
