import os, glob
from PIL import Image

files = sorted(glob.glob("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/*"))
for f in files:
    try:
        im = Image.open(f)
        print(f"{os.path.basename(f):45} | Size: {im.size[0]}x{im.size[1]} | Format: {im.format}")
    except Exception as e:
        print(f"{os.path.basename(f):45} | Error: {e}")
