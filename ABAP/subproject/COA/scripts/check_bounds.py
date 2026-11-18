from PIL import Image

O = "/data/Projects/SAP/ABAP/subproject/COA/outputs/gui_test_20261118/"
im_z2 = Image.open(O + "zqm002_do0085006285.png")
im_z5 = Image.open(O + "zqm005_lot040000015885_JRSEFI.png")

print("ZQM002 size:", im_z2.size)
print("ZQM005 size:", im_z5.size)

# In ZQM002, let's find where the Value column ends
# Let's inspect pixel colors on row y=224 from x=800 to x=1000
for x in range(850, 950, 5):
    print(f"Z2 x={x}: {im_z2.getpixel((x, 224))}")

# In ZQM005, let's find where Mean Value column ends
for x in range(700, 800, 5):
    print(f"Z5 x={x}: {im_z5.getpixel((x, 186))}")
