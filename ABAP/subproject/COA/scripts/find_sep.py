from PIL import Image

O = "/data/Projects/SAP/ABAP/subproject/COA/outputs/gui_test_20261118/"
im_z2 = Image.open(O + "zqm002_do0085006285.png")
im_z5 = Image.open(O + "zqm005_lot040000015885_JRSEFI.png")

# Header row of Z2 is around y=202. Let's find border columns
for x in range(880, 1050, 1):
    c = im_z2.getpixel((x, 202))
    # Grey column separator is darker than header background
    if c[0] < 200:
        print(f"Z2 col sep at x={x}: {c}")

for x in range(700, 850, 1):
    c = im_z5.getpixel((x, 168))
    if c[0] < 200:
        print(f"Z5 col sep at x={x}: {c}")
