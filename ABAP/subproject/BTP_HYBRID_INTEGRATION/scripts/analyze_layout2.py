import os
from PIL import Image

src_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"

def check_regions(fname):
    p = os.path.join(src_dir, fname)
    im = Image.open(p).convert("RGB")
    w, h = im.size
    print(f"\n=== {fname} ({w}x{h}) ===")
    # Print color of top, middle, bottom
    print("Top bar (50, 20):", im.getpixel((min(50, w-1), min(20, h-1))))
    print("Center (w//2, h//2):", im.getpixel((w//2, h//2)))

for f in ["05_btp_create_destination_scratch.png", "06_btp_destination_check_success.jpg", 
          "07_bas_devspace_running.png", "08_bas_fiori_generator_destination.png",
          "09_btp_destination_dynamic_property.png", "10_bas_auth_incorrect_error.png",
          "11_bas_odata_services_loaded.png", "12_bas_entity_selection_selected.png",
          "13_bas_project_attributes.png", "14_bas_project_generated_open_folder.png"]:
    check_regions(f)
