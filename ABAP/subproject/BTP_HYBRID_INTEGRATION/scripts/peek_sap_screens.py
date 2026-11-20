import os
from PIL import Image

src = "/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments"
for fname in ["01_sap_logon.png", "02_adb_login.png", "27_easy_access.png", "adb_session_ready.png"]:
    p = os.path.join(src, fname)
    if os.path.exists(p):
        im = Image.open(p)
        print(f"{fname}: {im.size}, mode={im.mode}")
