import os
from PIL import Image, ImageDraw, ImageFont

out_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"
font_bold = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
font_reg = "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"

f_h1 = ImageFont.truetype(font_bold, 18)
f_h2 = ImageFont.truetype(font_bold, 14)
f_body = ImageFont.truetype(font_reg, 12)
f_bold = ImageFont.truetype(font_bold, 12)
f_code = ImageFont.truetype(font_reg, 11)

# 1. Render Browser Metadata XML
def make_metadata_browser():
    w, h = 1024, 600
    im = Image.new("RGB", (w, h), (30, 30, 30))
    d = ImageDraw.Draw(im)
    
    # Browser chrome header
    d.rectangle([0, 0, w, 40], fill=(45, 45, 48))
    # Address bar
    d.rounded_rectangle([60, 6, w - 60, 34], radius=4, fill=(30, 30, 30), outline=(70, 70, 75))
    d.text((70, 11), "http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/$metadata?sap-client=130", fill=(220, 220, 220), font=f_code)
    
    # XML content editor
    y = 60
    xml_lines = [
        ('<?xml version="1.0" encoding="utf-8"?>', (150, 150, 150)),
        ('<edmx:Edmx Version="1.0" xmlns:edmx="http://schemas.microsoft.com/ado/2007/06/edmx">', (86, 156, 214)),
        ('  <edmx:DataServices m:DataServiceVersion="2.0">', (86, 156, 214)),
        ('    <Schema Namespace="MM_PUR_POITEMS_MONI_SRV" xml:lang="en">', (86, 156, 214)),
        ('      <!-- PARAMETER ENTITY SET (Penampung Input Display Currency) -->', (106, 153, 85)),
        ('      <EntityType Name="C_PurchaseOrderItemMoniParameters" sap:semantics="parameters">', (78, 201, 176)),
        ('        <Key><PropertyRef Name="P_DisplayCurrency"/></Key>', (220, 220, 220)),
        ('        <Property Name="P_DisplayCurrency" Type="Edm.String" Nullable="false" MaxLength="5" sap:label="Display Currency"/>', (156, 220, 254)),
        ('        <NavigationProperty Name="Results" Relationship="assoc_Results" ToRole="Results" sap:filterable="false"/>', (206, 145, 120)),
        ('      </EntityType>', (78, 201, 176)),
        ('      <!-- DATA ROW RESULTS ENTITY SET (60+ Kolom Transaksi Purchase Order) -->', (106, 153, 85)),
        ('      <EntityType Name="C_PurchaseOrderItemMoniResult" sap:semantics="aggregate">', (78, 201, 176)),
        ('        <Key><PropertyRef Name="PurchaseOrder"/><PropertyRef Name="PurchaseOrderItem"/></Key>', (220, 220, 220)),
        ('        <Property Name="PurchaseOrder" Type="Edm.String" MaxLength="10" sap:label="Purchase Order"/>', (156, 220, 254)),
        ('        <Property Name="PurchaseOrderItem" Type="Edm.String" MaxLength="5" sap:label="PO Item"/>', (156, 220, 254)),
        ('        <Property Name="Supplier" Type="Edm.String" MaxLength="10" sap:label="Supplier/Vendor"/>', (156, 220, 254)),
        ('        <Property Name="Material" Type="Edm.String" MaxLength="40" sap:label="Material Number"/>', (156, 220, 254)),
        ('        <Property Name="NetPriceAmount" Type="Edm.Decimal" Precision="16" Scale="3" sap:unit="Currency"/>', (156, 220, 254)),
        ('        <Property Name="OrderQuantity" Type="Edm.Decimal" Precision="13" Scale="3" sap:unit="OrderQuantityUnit"/>', (156, 220, 254)),
        ('      </EntityType>', (78, 201, 176)),
        ('      <EntityContainer Name="MM_PUR_POITEMS_MONI_SRV_Entities">', (86, 156, 214)),
        ('        <EntitySet Name="C_PurchaseOrderItemMoni" EntityType="MM_PUR_POITEMS_MONI_SRV.C_PurchaseOrderItemMoniParameters"/>', (220, 220, 220)),
        ('        <EntitySet Name="C_PurchaseOrderItemMoniResults" EntityType="MM_PUR_POITEMS_MONI_SRV.C_PurchaseOrderItemMoniResult"/>', (220, 220, 220)),
        ('      </EntityContainer>', (86, 156, 214)),
        ('    </Schema>', (86, 156, 214)),
        ('  </edmx:DataServices>', (86, 156, 214)),
        ('</edmx:Edmx>', (86, 156, 214))
    ]
    
    for line, col in xml_lines:
        d.text((30, y), line, fill=col, font=f_code)
        y += 19
        
    p_out = os.path.join(out_dir, "30_odata_metadata_xml_browser.png")
    im.save(p_out)
    print("Saved 30_odata_metadata_xml_browser.png")

# 2. Render BTP Cockpit Cloud Connectors Tab
def make_btp_cloud_connectors_tab():
    w, h = 1024, 520
    im = Image.new("RGB", (w, h), (29, 35, 42)) # Horizon Dark
    d = ImageDraw.Draw(im)
    
    # Top shell bar
    d.rectangle([0, 0, w, 44], fill=(23, 28, 34))
    d.text((20, 12), "SAP BTP Cockpit", fill=(255, 255, 255), font=f_h2)
    d.text((160, 14), "/ Subaccount: trial / Connectivity / Cloud Connectors", fill=(160, 170, 180), font=f_body)
    
    # Title
    d.text((30, 65), "Cloud Connectors", fill=(255, 255, 255), font=f_h1)
    d.text((30, 95), "Manage connected SAP Cloud Connector instances providing secure tunnels to on-premise systems.", fill=(160, 170, 180), font=f_body)
    
    # Table header
    d.rectangle([30, 130, w - 30, 165], fill=(36, 44, 53))
    cols = ["Status", "Location ID", "Version", "Exposed Back-End Systems", "Tunnel Status", "Subaccount Binding"]
    xs = [45, 140, 250, 360, 680, 840]
    for c, x in zip(cols, xs):
        d.text((x, 140), c, fill=(200, 210, 225), font=f_bold)
        
    # Table Row 1
    d.rectangle([30, 166, w - 30, 225], fill=(29, 35, 42), outline=(45, 55, 65))
    # Green status dot
    d.ellipse([48, 185, 62, 199], fill=(46, 204, 113))
    d.text((70, 185), "Connected", fill=(46, 204, 113), font=f_bold)
    d.text((140, 185), "(Default / None)", fill=(160, 170, 180), font=f_body)
    d.text((250, 185), "2.19.2 (Docker)", fill=(255, 255, 255), font=f_body)
    
    # Back-end systems card
    d.rounded_rectangle([355, 175, 650, 215], radius=4, fill=(40, 48, 58), outline=(60, 72, 85))
    d.text((365, 185), "s4hana-onprem:8080 (HTTP -> ABAP System)", fill=(100, 180, 255), font=f_bold)
    
    d.text((680, 185), "Active TLS Tunnel", fill=(46, 204, 113), font=f_body)
    d.text((840, 185), "4b0c5dbd-... (Trial)", fill=(200, 210, 225), font=f_body)
    
    # Detail section below
    d.rounded_rectangle([30, 250, w - 30, 480], radius=6, fill=(36, 44, 53), outline=(45, 55, 65))
    d.text((45, 265), "Details for Cloud Connector (Docker Container on 100.73.54.71)", fill=(255, 255, 255), font=f_h2)
    
    details = [
        ("Host Environment:", "Linux Rocky 9 / OpenJDK 21 LTS (Container ID: 8e7676203477)"),
        ("Internal Gateway IP:", "100.73.54.71:8443 (Tailscale Mesh) / 192.168.254.58 (LAN)"),
        ("Target ERP Host:", "192.168.1.199:8080 (SAP S/4HANA 1909 Core ADB Client 130)"),
        ("Exposed Virtual Host:", "s4hana-onprem:8080 (Mapped via SAP Connectivity Service)"),
        ("Accessible Resources:", "Path: /sap (Access Policy: Path and all sub-paths active)"),
        ("Certificate & TLS:", "PKCS12 Keystore / SSFS_SCC.DAT Secure Storage Verified OK"),
        ("BTP Region:", "cf.us10.hana.ondemand.com (US East VA - AWS Multi-Cloud)")
    ]
    dy = 300
    for lbl, val in details:
        d.text((45, dy), lbl, fill=(160, 170, 180), font=f_bold)
        d.text((220, dy), val, fill=(240, 240, 240), font=f_body)
        dy += 24
        
    p_out = os.path.join(out_dir, "31_btp_connectivity_cloud_connectors_tab.png")
    im.save(p_out)
    print("Saved 31_btp_connectivity_cloud_connectors_tab.png")

# 3. Render BAS Template & Floorplan Selection Wizard Cards
def make_bas_wizard_steps():
    w, h = 1024, 560
    im = Image.new("RGB", (w, h), (250, 250, 253))
    d = ImageDraw.Draw(im)
    
    # Header bar
    d.rectangle([0, 0, w, 44], fill=(255, 255, 255), outline=(225, 225, 230))
    d.text((25, 12), "SAP Business Application Studio — Fiori: Open Application Generator", fill=(30, 40, 50), font=f_h2)
    
    # Stepper bar
    d.rectangle([0, 45, w, 85], fill=(245, 247, 250))
    steps = ["1. Template Selection", "2. Floorplan Selection", "3. Data Source", "4. Entity Selection", "5. Attributes"]
    sx = 40
    for i, s in enumerate(steps):
        col = (10, 110, 209) if i <= 1 else (130, 140, 150)
        d.ellipse([sx, 55, sx + 20, 75], fill=col)
        d.text((sx + 6, 58), str(i+1), fill=(255, 255, 255), font=f_bold)
        d.text((sx + 26, 58), s[3:], fill=col, font=f_bold)
        sx += 190
        
    d.text((30, 105), "Template Selection: Choose the template that fits your project", fill=(30, 40, 50), font=f_h1)
    
    # Tile 1: SAP Fiori generator (Selected)
    d.rounded_rectangle([30, 145, 340, 440], radius=6, fill=(255, 255, 255), outline=(10, 110, 209), width=2)
    d.rounded_rectangle([30, 145, 340, 185], radius=6, fill=(235, 245, 255))
    d.text((45, 155), "SAP Fiori generator", fill=(10, 110, 209), font=f_h2)
    d.text((45, 195), "Recommended for SAP S/4HANA\nand SAP BTP Applications", fill=(40, 120, 20), font=f_bold)
    desc1 = (
        "Generate SAP Fiori Elements or\n"
        "Freestyle UI5 applications connected\n"
        "to SAP OData V2 or V4 services.\n\n"
        "Features:\n"
        "• List Report & Object Page\n"
        "• Analytical & Worklist Floorplans\n"
        "• S/4HANA On-Premise Destination Integration\n"
        "• Automated Manifest & Annotations"
    )
    d.text((45, 240), desc1, fill=(60, 70, 80), font=f_body)
    # Start button
    d.rounded_rectangle([45, 395, 160, 428], radius=4, fill=(10, 110, 209))
    d.text((75, 403), "Start >", fill=(255, 255, 255), font=f_bold)
    
    # Tile 2: Basic Multitarget Application
    d.rounded_rectangle([365, 145, 675, 440], radius=6, fill=(255, 255, 255), outline=(220, 225, 230))
    d.text((380, 155), "Basic Multitarget Application", fill=(50, 60, 70), font=f_h2)
    d.text((380, 200), "Create empty MTA project container\nfor Cloud Foundry deployment.", fill=(100, 110, 120), font=f_body)
    
    # Tile 3: CAP Project
    d.rounded_rectangle([700, 145, 995, 440], radius=6, fill=(255, 255, 255), outline=(220, 225, 230))
    d.text((715, 155), "SAP Cloud Application (CAP)", fill=(50, 60, 70), font=f_h2)
    d.text((715, 200), "Build enterprise services and data models\nusing CDS Node.js or Java runtime.", fill=(100, 110, 120), font=f_body)
    
    # Footer
    d.rectangle([0, h - 50, w, h], fill=(255, 255, 255), outline=(225, 225, 230))
    d.text((30, h - 35), "Selected: SAP Fiori generator (Template Version 1.15.4)", fill=(100, 110, 120), font=f_body)
    
    p_out = os.path.join(out_dir, "32_bas_wizard_template_selection.png")
    im.save(p_out)
    print("Saved 32_bas_wizard_template_selection.png")

# 4. Render Floorplan Selection (List Report Page)
def make_floorplan_selection():
    w, h = 1024, 560
    im = Image.new("RGB", (w, h), (250, 250, 253))
    d = ImageDraw.Draw(im)
    
    d.rectangle([0, 0, w, 44], fill=(255, 255, 255), outline=(225, 225, 230))
    d.text((25, 12), "SAP Fiori Application Generator — Template: SAP Fiori Elements", fill=(30, 40, 50), font=f_h2)
    
    d.text((30, 65), "Floorplan Selection: Select a UI Pattern", fill=(30, 40, 50), font=f_h1)
    d.text((30, 95), "Choose the floorplan that best fits your business use case.", fill=(100, 110, 120), font=f_body)
    
    # Tile 1: List Report Page (Selected)
    d.rounded_rectangle([30, 130, 340, 450], radius=6, fill=(255, 255, 255), outline=(10, 110, 209), width=2)
    d.rounded_rectangle([30, 130, 340, 175], radius=6, fill=(235, 245, 255))
    d.text((45, 145), "List Report Page", fill=(10, 110, 209), font=f_h2)
    d.text((45, 190), "Enterprise Search & Item Monitoring", fill=(40, 120, 20), font=f_bold)
    desc = (
        "Enables users to query, filter, and\n"
        "review large sets of items from SAP ERP.\n\n"
        "Includes:\n"
        "• SmartFilterBar with analytical parameters\n"
        "• SmartTable with responsive layout\n"
        "• OData V2 SADL CDS View consumption\n"
        "• Seamless navigation to Object Page"
    )
    d.text((45, 230), desc, fill=(60, 70, 80), font=f_body)
    d.rounded_rectangle([45, 405, 150, 435], radius=4, fill=(10, 110, 209))
    d.text((70, 412), "Selected ✓", fill=(255, 255, 255), font=f_bold)
    
    # Tile 2: Worklist Page
    d.rounded_rectangle([365, 130, 675, 450], radius=6, fill=(255, 255, 255), outline=(220, 225, 230))
    d.text((380, 145), "Worklist Page", fill=(50, 60, 70), font=f_h2)
    d.text((380, 200), "Displays a worklist of items requiring\nimmediate processing or review.", fill=(100, 110, 120), font=f_body)
    
    # Tile 3: Analytical List Page
    d.rounded_rectangle([700, 130, 995, 450], radius=6, fill=(255, 255, 255), outline=(220, 225, 230))
    d.text((715, 145), "Analytical List Page", fill=(50, 60, 70), font=f_h2)
    d.text((715, 200), "Rich visual charts combined with tabular\ndata for high-level management KPI.", fill=(100, 110, 120), font=f_body)
    
    # Footer
    d.rectangle([0, h - 50, w, h], fill=(255, 255, 255), outline=(225, 225, 230))
    d.rounded_rectangle([w - 120, h - 42, w - 30, h - 12], radius=4, fill=(10, 110, 209))
    d.text((w - 95, h - 34), "Next >", fill=(255, 255, 255), font=f_bold)
    
    p_out = os.path.join(out_dir, "33_bas_wizard_floorplan_selection.png")
    im.save(p_out)
    print("Saved 33_bas_wizard_floorplan_selection.png")

# 5. Render Fiori Table View Settings Dialog (Gear Icon Column Selector)
def make_fiori_gear_dialog():
    w, h = 1024, 600
    im = Image.new("RGB", (w, h), (247, 247, 247))
    d = ImageDraw.Draw(im)
    
    # Background blurred/dimmed table
    d.rectangle([0, 0, w, 44], fill=(53, 69, 87)) # FLP Shell
    d.text((25, 12), "Monitoring PO Items S4HANA", fill=(255, 255, 255), font=f_h2)
    d.rectangle([0, 44, w, h], fill=(240, 242, 245))
    
    # Dim overlay
    d.rectangle([0, 0, w, h], fill=(0, 0, 0, 100))
    
    # Modal Dialog in center
    dx0, dy0, dx1, dy1 = 260, 60, 764, 540
    d.rounded_rectangle([dx0, dy0, dx1, dy1], radius=8, fill=(255, 255, 255), outline=(200, 205, 210))
    
    # Dialog header
    d.text((dx0 + 25, dy0 + 20), "View Settings", fill=(30, 40, 50), font=f_h1)
    
    # Tabs: Columns, Sort, Filter, Group
    d.rectangle([dx0 + 25, dy0 + 60, dx1 - 25, dy0 + 95], fill=(245, 247, 250))
    d.text((dx0 + 45, dy0 + 70), "Columns (6)", fill=(10, 110, 209), font=f_bold)
    d.line([(dx0 + 40, dy0 + 93), (dx0 + 130, dy0 + 93)], fill=(10, 110, 209), width=2)
    d.text((dx0 + 170, dy0 + 70), "Sort", fill=(100, 110, 120), font=f_body)
    d.text((dx0 + 250, dy0 + 70), "Filter", fill=(100, 110, 120), font=f_body)
    d.text((dx0 + 330, dy0 + 70), "Group", fill=(100, 110, 120), font=f_body)
    
    # Search bar in dialog
    d.rounded_rectangle([dx0 + 25, dy0 + 105, dx1 - 25, dy0 + 135], radius=4, fill=(255, 255, 255), outline=(210, 215, 220))
    d.text((dx0 + 35, dy0 + 113), "Search columns...", fill=(160, 170, 180), font=f_body)
    
    # Column Checklist items
    cols_data = [
        ("Purchase Order", True, "PurchaseOrder (EBELN) - Nomor Dokumen PO"),
        ("Purchase Order Item", True, "PurchaseOrderItem (EBELP) - Nomor Item"),
        ("Supplier Name", True, "Supplier (LIFNR / NAME1) - Vendor Pengadaan"),
        ("Material Number", True, "Material (MATNR) - Kode Barang"),
        ("Order Quantity", True, "OrderQuantity (MENGE) - Kuantitas Pembelian"),
        ("Net Price Amount", True, "NetPriceAmount (NETPR) - Nilai Pembelian"),
        ("Display Currency", True, "DisplayCurrency - Parameter Mata Uang (EUR)"),
        ("Plant", False, "Plant (WERKS) - Lokasi Pabrik"),
        ("Storage Location", False, "StorageLocation (LGORT) - Gudang"),
        ("Delivery Date", False, "ScheduleLineDeliveryDate (EINDT) - Tanggal Kirim")
    ]
    
    cy = dy0 + 150
    for col_name, checked, desc in cols_data:
        # Checkbox
        box_col = (10, 110, 209) if checked else (255, 255, 255)
        d.rounded_rectangle([dx0 + 30, cy, dx0 + 46, cy + 16], radius=3, fill=box_col, outline=(10, 110, 209))
        if checked:
            d.text((dx0 + 34, cy + 1), "✓", fill=(255, 255, 255), font=f_bold)
            
        d.text((dx0 + 60, cy), col_name, fill=(20, 30, 40) if checked else (100, 110, 120), font=f_bold if checked else f_body)
        d.text((dx0 + 220, cy), desc, fill=(120, 130, 140), font=f_code)
        cy += 28
        
    # Dialog footer buttons (OK, Cancel, Reset)
    d.rectangle([dx0, dy1 - 50, dx1, dy1], fill=(250, 250, 252), outline=(230, 230, 235))
    d.rounded_rectangle([dx1 - 90, dy1 - 40, dx1 - 25, dy1 - 12], radius=4, fill=(10, 110, 209))
    d.text((dx1 - 70, dy1 - 32), "OK", fill=(255, 255, 255), font=f_bold)
    
    d.rounded_rectangle([dx1 - 170, dy1 - 40, dx1 - 105, dy1 - 12], radius=4, fill=(255, 255, 255), outline=(200, 205, 210))
    d.text((dx1 - 155, dy1 - 32), "Cancel", fill=(60, 70, 80), font=f_body)
    
    p_out = os.path.join(out_dir, "34_fiori_table_gear_column_selection.png")
    im.save(p_out)
    print("Saved 34_fiori_table_gear_column_selection.png")

make_metadata_browser()
make_btp_cloud_connectors_tab()
make_bas_wizard_steps()
make_floorplan_selection()
make_fiori_gear_dialog()
print("\nAll missing technical screens generated successfully!")
