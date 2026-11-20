from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/win_46137391.png")
print("Win size:", im.size)
# check color distribution
colors = sorted(im.getcolors(1440*881) or [], key=lambda x: x[0], reverse=True)
print("Top 5 colors:", colors[:5])
