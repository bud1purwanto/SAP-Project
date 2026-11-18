import os
import math
from PIL import Image, ImageDraw, ImageFont
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter
from openpyxl.drawing.image import Image as OpenpyxlImage
from openpyxl.formatting.rule import FormulaRule

BASE_DIR = '/data/Projects/SAP/ABAP/subproject/COA/outputs/gui_test_20261118/'
OUTPUT_DIR = '/data/Projects/SAP/ABAP/subproject/COA/outputs/'

font_path_bold = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
font_path_reg = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'

def get_font(size, bold=False):
    p = font_path_bold if bold else font_path_reg
    return ImageFont.truetype(p, size)

# 10 Warna kontras untuk 10 baris
COL = [
    (220, 38, 38),   # 1: Merah
    (37, 99, 235),   # 2: Biru
    (22, 163, 74),   # 3: Hijau
    (217, 119, 6),   # 4: Kuning-orange
    (147, 51, 234),  # 5: Ungu
    (8, 145, 178),   # 6: Cyan
    (219, 39, 119),  # 7: Magenta
    (101, 163, 13),  # 8: Lime
    (234, 88, 12),   # 9: Orange tua
    (100, 116, 139)  # 10: Slate gray
]

Z2_Y = [224, 252, 280, 308, 336, 364, 392, 420, 448, 476]
Z5_Y = [186, 206, 226, 246, 266, 326, 346, 366, 386, 406]

def draw_arrow(d, p1, p2, color, width=3):
    d.line([p1, p2], fill=color, width=width)
    angle = math.atan2(p2[1] - p1[1], p2[0] - p1[0])
    L = 15
    pts = [
        p2,
        (p2[0] - L * math.cos(angle - 0.45), p2[1] - L * math.sin(angle - 0.45)),
        (p2[0] - L * math.cos(angle + 0.45), p2[1] - L * math.sin(angle + 0.45))
    ]
    d.polygon(pts, fill=color)

def generate_hd_panah_image(do_num, out_png):
    # Crop ZQM002: x=30 to x=865 (width=835), y=183 to y=490 (height=307)
    im_z2 = Image.open(f'{BASE_DIR}zqm002_do{do_num}.png').convert('RGB')
    a = im_z2.crop((30, 183, 865, 490))
    
    # Crop ZQM005 Lot JR TTA 040000015885: x=8 to x=765 (width=757), y=158 to y=425 (height=267)
    im_z5 = Image.open(f'{BASE_DIR}zqm005_lot040000015885_JRSEFI.png').convert('RGB')
    b = im_z5.crop((8, 158, 765, 425))
    
    gap = 140
    top = 70
    bottom = 55
    W = 15 + a.width + gap + b.width + 15
    H = top + max(a.height, b.height) + bottom
    
    canvas = Image.new('RGB', (W, H), (255, 255, 255))
    d = ImageDraw.Draw(canvas)
    
    ax = 15
    bx = ax + a.width + gap
    
    canvas.paste(a, (ax, top))
    canvas.paste(b, (bx, top))
    
    # Header box dekoratif
    d.rectangle([ax, 8, ax + a.width, 62], fill=(241, 245, 249), outline=(203, 213, 225), width=1)
    d.text((ax + 12, 14), f'ZQM002  —  DO {do_num}', font=get_font(18, True), fill=(15, 23, 42))
    d.text((ax + 12, 38), 'Nilai MIC ALV Grid ZQM002 (Kolom Value)', font=get_font(12), fill=(71, 85, 105))
    
    d.rectangle([bx, 8, bx + b.width, 62], fill=(241, 245, 249), outline=(203, 213, 225), width=1)
    d.text((bx + 12, 14), 'ZQM005  —  Lot 040000015885 (JRSEFI 0000371969, Plant TTA2)', font=get_font(18, True), fill=(15, 23, 42))
    d.text((bx + 12, 38), 'Hasil Uji Lot JR Base Film (Kolom Mean Value)', font=get_font(12), fill=(71, 85, 105))
    
    # Border sekeliling kedua tabel
    d.rectangle([ax - 1, top - 1, ax + a.width + 1, top + a.height + 1], outline=(148, 163, 184), width=1)
    d.rectangle([bx - 1, top - 1, bx + b.width + 1, top + b.height + 1], outline=(148, 163, 184), width=1)
    
    # Render kotak dan panah penghubung
    for i, (y2, y5) in enumerate(zip(Z2_Y, Z5_Y)):
        color = COL[i]
        ya = top + y2 - 183
        yb = top + y5 - 158
        
        if i == 9: # Baris 10: Surface Tension Untreated Side (SR Base Film)
            d.rectangle([ax + 305 - 30, ya - 13, ax + a.width - 2, ya + 13], outline=(148, 163, 184), width=3)
            # Label penjelas baris 10
            d.rectangle([ax + a.width + 8, ya - 12, ax + a.width + 125, ya + 12], fill=(241, 245, 249), outline=(148, 163, 184), width=1)
            d.text((ax + a.width + 14, ya - 9), '10: Tanpa Panah', font=get_font(12, True), fill=(100, 116, 139))
            continue
            
        # Kotak highlight baris di ZQM002
        d.rectangle([ax + 305 - 30, ya - 13, ax + a.width - 2, ya + 13], outline=color, width=3)
        # Kotak highlight baris di ZQM005
        d.rectangle([bx + 2, yb - 9, bx + b.width - 2, yb + 9], outline=color, width=3)
        
        # Garis panah penghubung
        draw_arrow(d, (ax + a.width + 4, ya), (bx - 4, yb), color, width=3)
        
        # Badge nomor panah
        num_str = f'{i+1}'
        badge_x = ax + a.width + 16
        badge_y = ya - 9
        d.ellipse([badge_x, badge_y - 2, badge_x + 22, badge_y + 20], fill=color)
        d.text((badge_x + (7 if len(num_str) == 1 else 3), badge_y + 1), num_str, font=get_font(12, True), fill=(255, 255, 255))
        
    # Banner Catatan Kaki
    foot_y = top + max(a.height, b.height) + 12
    d.rectangle([ax, foot_y, bx + b.width, foot_y + 34], fill=(248, 250, 252), outline=(203, 213, 225), width=1)
    foot_msg = 'Catatan: Baris 1-9 (JR Base Film) MATCH 100% dengan Mean Value Lot JR TTA 040000015885. Baris 10 (SR Base Film) tidak memiliki lot SR di TTA2.'
    d.text((ax + 12, foot_y + 9), foot_msg, font=get_font(12, True), fill=(30, 41, 59))
    
    canvas.save(out_png, quality=100)
    print(f'Generated HD Panah: {out_png} ({W}x{H})')
    return out_png

generate_hd_panah_image('0085006285', f'{BASE_DIR}peta_panah_do0085006285_hd.png')
generate_hd_panah_image('0085006286', f'{BASE_DIR}peta_panah_do0085006286_hd.png')
