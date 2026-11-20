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
    # Resize to standard max width if very large (e.g. 1440 down to 1024)
    if orig.width > 1100:
        ratio = 1024 / orig.width
        orig = orig.resize((1024, int(orig.height * ratio)), Image.Resampling.LANCZOS)
        
    w, h = orig.size
    banner_h = 36
    new_h = h + banner_h
    new_img = Image.new("RGB", (w, new_h), (15, 23, 42)) # Slate 900
    new_img.paste(orig, (0, banner_h))
    
    draw = ImageDraw.Draw(new_img)
    draw.text((14, 9), step_title, fill=(255, 255, 255), font=font_title)
    draw.line([(0, banner_h - 1), (w, banner_h - 1)], fill=(59, 130, 246), width=2)
    
    for anno in annotations:
        box = anno.get('box')
        num = str(anno.get('num', '1'))
        lbl = anno.get('label', '')
        arrow = anno.get('arrow')
        color = anno.get('color', (220, 38, 38))
        
        if box:
            bx0, by0, bx1, by1 = box
            # scale box if resized
            by0 += banner_h
            by1 += banner_h
            draw.rectangle([bx0, by0, bx1, by1], outline=color, width=3)
            
            badge_r = 13
            badge_cx = bx0 + 16
            badge_cy = max(banner_h + 16, by0 - 13)
            draw.ellipse([badge_cx - badge_r, badge_cy - badge_r, badge_cx + badge_r, badge_cy + badge_r],
                         fill=color, outline=(255, 255, 255), width=2)
            draw.text((badge_cx, badge_cy), num, fill=(255, 255, 255), font=font_badge, anchor="mm")
            
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
    print(f"Annotated: {fname}")

NEW_CONFIGS = [
    ("live_sicf_service_tree.png", "TAHAP 1: Verifikasi Pohon Layanan ICF di SAP GUI (T-Code SICF)", [
        {'box': (30, 60, 980, 220), 'num': '1', 'label': 'T-Code SICF: Hirarki /default_host/sap/bc/ui2/flp & /sap/opu/odata'},
        {'box': (30, 240, 980, 560), 'num': '2', 'label': 'Status Layanan: Aktif (Warna Hitam / Service Available)'}
    ]),
    ("live_su01_display.png", "TAHAP 1: Verifikasi User Otorisasi & Status Lock (T-Code SU01)", [
        {'box': (30, 50, 980, 150), 'num': '1', 'label': 'User: USER-FIORI / TRSTABAP di Client 130'},
        {'box': (30, 160, 980, 540), 'num': '2', 'label': 'Tab Logon Data & Roles: Status Unlock (UFLAG = 0)'}
    ]),
    ("live_gateway_maint_service.png", "TAHAP 1: Katalog Layanan SAP Gateway (T-Code /IWFND/MAINT_SERVICE)", [
        {'box': (30, 50, 980, 250), 'num': '1', 'label': 'Service Terdaftar: ZMM_PUR_POITEMS_MONI_SRV (Versi 0001)'},
        {'box': (30, 260, 980, 560), 'num': '2', 'label': 'System Alias: LOCAL | Status: Traffic Light Hijau (Aktif)'}
    ]),
    ("30_odata_metadata_xml_browser.png", "TAHAP 1: Endpoint $metadata OData XML Service di Browser", [
        {'box': (50, 4, 980, 36), 'num': '1', 'label': 'Endpoint URL: /sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/$metadata'},
        {'box': (25, 95, 980, 260), 'num': '2', 'label': 'EntityType C_PurchaseOrderItemMoni (Parameter P_DisplayCurrency)'},
        {'box': (25, 275, 980, 480), 'num': '3', 'label': 'EntityType C_PurchaseOrderItemMoniResult (60+ Kolom Transaksi PO)'}
    ]),
    ("31_btp_connectivity_cloud_connectors_tab.png", "TAHAP 5: Verifikasi Status Cloud Connector di BTP Cockpit", [
        {'box': (30, 120, 990, 230), 'num': '1', 'label': 'Tab Cloud Connectors: Connected (Centang Hijau) | Versi 2.19.2'},
        {'box': (350, 170, 655, 220), 'num': '2', 'label': 'Exposed System Terdeteksi: s4hana-onprem:8080 (HTTP)'},
        {'box': (30, 245, 990, 485), 'num': '3', 'label': 'Detail Binding Subaccount 4b0c5dbd-... & Tunnel TLS Aktif'}
    ]),
    ("32_bas_wizard_template_selection.png", "TAHAP 7: Fiori Generator Wizard Step 1 - Template Selection", [
        {'box': (25, 140, 345, 445), 'num': '1', 'label': 'Pilih Tile: SAP Fiori generator (Template Standar Enterprise)'},
        {'arrow': ((90, 480), (90, 430)), 'num': '2', 'label': 'Klik Tombol Start'}
    ]),
    ("33_bas_wizard_floorplan_selection.png", "TAHAP 7: Fiori Generator Wizard Step 2 - Floorplan Selection", [
        {'box': (25, 125, 345, 455), 'num': '1', 'label': 'Pilih Tile: List Report Page (Tabel Dinamis & FilterBar)'},
        {'arrow': ((950, 490), (950, 435)), 'num': '2', 'label': 'Klik Tombol Next'}
    ]),
    ("live_se16n_ekpo_10_hits.png", "TAHAP 9: Verifikasi Item Dokumen PO di SAP GUI (T-Code SE16N EKPO)", [
        {'box': (30, 50, 980, 140), 'num': '1', 'label': 'Tabel EKPO: 10 Rekor Item Dokumen Purchase Order Client 130'},
        {'box': (30, 150, 980, 560), 'num': '2', 'label': 'Daftar PO 4500000000-4500000009 Item 10 | Material & Plant 0001'}
    ]),
    ("live_me23n_display_po.png", "TAHAP 9: Display Dokumen Purchase Order Resmi di SAP GUI (T-Code ME23N)", [
        {'box': (30, 50, 980, 220), 'num': '1', 'label': 'Header PO: Nomor Dokumen 4500000000 | Status Net Value EUR'},
        {'box': (30, 230, 980, 560), 'num': '2', 'label': 'Item Overview: Material, Kuantitas, Harga Satuan, dan Jadwal Pengiriman'}
    ]),
    ("34_fiori_table_gear_column_selection.png", "TAHAP 10: Pemilihan Kolom Tabel via Dialog View Settings (Gear ⚙️)", [
        {'box': (255, 55, 770, 545), 'num': '1', 'label': 'Modal Dialog View Settings: Tab Columns (6 Kolom Terpilih)'},
        {'box': (280, 145, 750, 420), 'num': '2', 'label': 'Checklist: PurchaseOrder, Item, Supplier, Material, Qty, Net Price'},
        {'arrow': ((710, 560), (710, 520)), 'num': '3', 'label': 'Klik Tombol OK untuk Terapkan ke Tabel'}
    ])
]

for fname, title, annos in NEW_CONFIGS:
    annotate_image(fname, title, annos)

print("\nAll 10 new technical screens annotated successfully!")
