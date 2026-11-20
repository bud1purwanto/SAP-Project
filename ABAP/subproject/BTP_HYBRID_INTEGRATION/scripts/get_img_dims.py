import os
from PIL import Image

src_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"
for fname in sorted(os.listdir(src_dir)):
    if fname.endswith((".png", ".jpg")):
        p = os.path.join(src_dir, fname)
        im = Image.open(p)
        print(f"'{fname}': w={im.width}, h={im.height}")
