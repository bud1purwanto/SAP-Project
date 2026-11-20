import os
from PIL import Image

src_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"

def analyze_img(fname):
    p = os.path.join(src_dir, fname)
    im = Image.open(p).convert("RGB")
    w, h = im.size
    print(f"\n--- {fname} ({w}x{h}) ---")
    # check horizontal color bands
    for y_pct in [0.05, 0.15, 0.3, 0.5, 0.7, 0.85, 0.95]:
        y = int(h * y_pct)
        # sample 5 points
        pts = [im.getpixel((int(w * x_pct), y)) for x_pct in [0.1, 0.3, 0.5, 0.7, 0.9]]
        print(f"y={y:4d} ({int(y_pct*100)}%): {pts}")

for f in ["01_onprem_fiori_launchpad_login.png", "02_scc_initial_dashboard.jpg", "03_scc_subaccount_connected.png", "04_scc_resources_mapping.png"]:
    analyze_img(f)
