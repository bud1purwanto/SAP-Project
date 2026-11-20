from PIL import Image
import numpy as np

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/01_onprem_fiori_launchpad_login.png").convert("RGB")
arr = np.array(im)
print("Image shape:", arr.shape)
# Find areas with distinct colors or borders
print("Center pixel:", arr[340, 430])
print("Top left pixel:", arr[10, 10])
