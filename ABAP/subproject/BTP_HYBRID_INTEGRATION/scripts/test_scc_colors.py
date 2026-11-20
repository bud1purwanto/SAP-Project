from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/snap_scc_live_browser.png")
print("SCC Browser size:", im.size)
colors = sorted(im.getcolors(1440*900) or [], key=lambda x: x[0], reverse=True)
print("Top 5 colors:", colors[:5])
