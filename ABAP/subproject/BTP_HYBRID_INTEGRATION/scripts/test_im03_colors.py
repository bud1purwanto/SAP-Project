from PIL import Image

im = Image.open("/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/03_scc_subaccount_connected.png").convert("RGB")
# print unique dominant colors
colors = sorted(im.getcolors(876*401), key=lambda x: x[0], reverse=True)
print("Top 15 colors in im03:")
for cnt, col in colors[:15]:
    print(f"  {cnt:6d} pixels: {col}")
