import os
import math
from PIL import Image, ImageDraw, ImageFont

annotated_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/annotated"
os.makedirs(annotated_dir, exist_ok=True)

font_path = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
font_regular_path = "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"

def draw_arrow(draw, start, end, color=(220, 38, 38), width=3, arrow_len=16):
    x1, y1 = start
    x2, y2 = end
    draw.line([start, end], fill=color, width=width)
    dx = x2 - x1
    dy = y2 - y1
    angle = math.atan2(dy, dx)
    p1 = (x2 - arrow_len * math.cos(angle - math.pi / 6),
          y2 - arrow_len * math.sin(angle - math.pi / 6))
    p2 = (x2 - arrow_len * math.cos(angle + math.pi / 6),
          y2 - arrow_len * math.sin(angle + math.pi / 6))
    draw.polygon([end, p1, p2], fill=color)

def draw_badge(draw, center, number_str, font, r=14, bg_color=(220, 38, 38), fg_color=(255, 255, 255)):
    cx, cy = center
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=bg_color, outline=(255, 255, 255), width=2)
    draw.text((cx, cy), number_str, fill=fg_color, font=font, anchor="mm")

def draw_pill_label(draw, top_left, text, font, bg_color=(220, 38, 38), fg_color=(255, 255, 255), pad=6):
    x, y = top_left
    bbox = font.getbbox(text)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    box = [x, y, x + tw + pad * 2, y + th + pad * 2]
    draw.rounded_rectangle(box, radius=4, fill=bg_color)
    draw.text((x + pad, y + pad - bbox[1]), text, fill=fg_color, font=font)
    return box

print("Annotation helper defined successfully.")
