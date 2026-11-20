import os
from PIL import Image

src_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"

for f in ["15_bas_fiori_run_debugging_active.jpg", "16_fiori_app_initial_screen.png",
          "17_fiori_app_error_unknown_entity.png", "18_user_query_steps_7_8.png",
          "19_fiori_app_success_no_data_found.png", "20_fiori_app_no_data_user_view.png",
          "21_sap_gui_ekko_10_hits.jpg", "22_bas_manifest_json_inspection.jpg",
          "23_fiori_blank_screen_noflp.png", "24_bas_preview_options_dialog.png",
          "25_define_column_properties_1_column.png", "26_fiori_table_10_records_success.jpg",
          "27_page_editor_custom_column_dialog.png", "28_pagemap_instruction_query.jpg",
          "29_bas_default_annotation_xml.png"]:
    p = os.path.join(src_dir, f)
    im = Image.open(p).convert("RGB")
    w, h = im.size
    print(f"{f:42} | {w}x{h} | center={im.getpixel((w//2, h//2))}")
