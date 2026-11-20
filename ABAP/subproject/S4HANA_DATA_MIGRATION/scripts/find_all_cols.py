from PIL import Image
im = Image.open('/tmp/omwd_tabbed.png')
# find vertical lines at Y=251
cols = []
for x in range(10, 450):
    p = im.getpixel((x, 251))[:3]
    if p[0] != 234 and p[0] != 245 and p[0] != 252:
        cols.append((x, p))
print('Distinct points at Y=251:', len(cols))
# group into columns
import itertools
xs = [x for x, p in cols if p[0] < 230]
print('Border Xs:', xs)
