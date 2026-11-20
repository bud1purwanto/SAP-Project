import os
from PIL import Image

src_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"
files = sorted([f for f in os.listdir(src_dir) if f.endswith((".png", ".jpg"))])

for i, f in enumerate(files):
    im = Image.open(os.path.join(src_dir, f))
    print(f"[{i+1:02d}] {f:42} | Size: {im.width}x{im.height}")
