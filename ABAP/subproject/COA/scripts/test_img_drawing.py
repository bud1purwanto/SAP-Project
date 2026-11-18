import openpyxl
from PIL import Image, ImageDraw, ImageFont
import os

# Create a small crisp arrow image
im = Image.new('RGBA', (320, 36), (255, 255, 255, 0))
d = ImageDraw.Draw(im)
# Draw rounded pill
d.rounded_rectangle([2, 2, 318, 34], radius=6, fill=(37, 99, 235), outline=(30, 64, 175), width=2)
# Draw arrow line and tip
d.line([(30, 18), (280, 18)], fill=(255, 255, 255), width=3)
d.polygon([(280, 12), (295, 18), (280, 24)], fill=(255, 255, 255))
arrow_path = '/tmp/test_arrow.png'
im.save(arrow_path)

wb = openpyxl.Workbook()
ws = wb.active
ws.title = 'Test'
ws['A1'] = 'Movable Arrow Test'
img = openpyxl.drawing.image.Image(arrow_path)
ws.add_image(img, 'B3')

wb.save('/tmp/test_out.xlsx')

# Test loading back
wb_check = openpyxl.load_workbook('/tmp/test_out.xlsx')
print('SUCCESS! openpyxl load_workbook worked without error!')
