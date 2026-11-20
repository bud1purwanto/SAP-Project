from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/06_btp_destination_check_success.jpg").convert("RGB")
w, h = im.size
col = [im.getpixel((500, y)) for y in range(h)]
dialog_ys = [y for y, px in enumerate(col) if px[1] > px[0] + 5] # green/cyan tint of check dialog
if dialog_ys:
    print(f"Dialog y-range at x=500: {min(dialog_ys)} to {max(dialog_ys)}")
