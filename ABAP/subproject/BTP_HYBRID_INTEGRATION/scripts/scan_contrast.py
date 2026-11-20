import os
from PIL import Image

src_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"

def scan_text_or_contrast(fname, row_step=20):
    im = Image.open(os.path.join(src_dir, fname)).convert("L")
    w, h = im.size
    print(f"=== {fname} ({w}x{h}) ===")
    active_rows = []
    for y in range(0, h, row_step):
        row_vals = [im.getpixel((x, y)) for x in range(0, w, 10)]
        diff = max(row_vals) - min(row_vals)
        if diff > 50:
            active_rows.append((y, diff))
    # print summary of active regions
    print(f"Active row bands (contrast > 50): {len(active_rows)} bands between y={active_rows[0][0] if active_rows else 0} and y={active_rows[-1][0] if active_rows else 0}")

for f in ["01_onprem_fiori_launchpad_login.png", "02_scc_initial_dashboard.jpg", "03_scc_subaccount_connected.png", 
          "04_scc_resources_mapping.png", "05_btp_create_destination_scratch.png", "06_btp_destination_check_success.jpg"]:
    scan_text_or_contrast(f)
