import os
from PIL import Image

src_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"

# Let's inspect images 01 to 06
for fname in ["01_onprem_fiori_launchpad_login.png", "02_scc_initial_dashboard.jpg", "03_scc_subaccount_connected.png", "04_scc_resources_mapping.png", "05_btp_create_destination_scratch.png", "06_btp_destination_check_success.jpg"]:
    im = Image.open(os.path.join(src_dir, fname))
    print(f"{fname}: size={im.size}")
