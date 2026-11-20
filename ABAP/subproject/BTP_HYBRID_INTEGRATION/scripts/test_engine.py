import os
import math
from PIL import Image, ImageDraw, ImageFont

src_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"
out_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/annotated"
os.makedirs(out_dir, exist_ok=True)

font_bold_path = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
font_reg_path = "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"

font_title = ImageFont.truetype(font_bold_path, 16)
font_badge = ImageFont.truetype(font_bold_path, 14)
font_label = ImageFont.truetype(font_bold_path, 12)

def draw_arrow(draw, start, end, color=(220, 38, 38), width=3, arrow_len=14):
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

def annotate_image(fname, step_title, annotations):
    """
    annotations: list of dicts:
      {
        'box': (x0, y0, x1, y1),
        'num': '1',
        'label': 'Text Label',
        'arrow': ((x_from, y_from), (x_to, y_to)) # optional
      }
    """
    p_in = os.path.join(src_dir, fname)
    if not os.path.exists(p_in):
        print(f"Skipping {fname}, file not found.")
        return
    
    orig = Image.open(p_in).convert("RGB")
    w, h = orig.size
    
    # Add top banner for step context (height 36px)
    banner_h = 36
    new_h = h + banner_h
    new_img = Image.new("RGB", (w, new_h), (15, 23, 42)) # Slate 900
    new_img.paste(orig, (0, banner_h))
    
    draw = ImageDraw.Draw(new_img)
    # Draw banner title
    draw.text((12, 10), step_title, fill=(255, 255, 255), font=font_title)
    # Draw accent line below banner
    draw.line([(0, banner_h - 1), (w, banner_h - 1)], fill=(59, 130, 246), width=2)
    
    # Draw each annotation
    for anno in annotations:
        box = anno.get('box')
        num = str(anno.get('num', '1'))
        lbl = anno.get('label', '')
        arrow = anno.get('arrow')
        color = anno.get('color', (220, 38, 38)) # default red
        
        if box:
            bx0, by0, bx1, by1 = box
            # offset y by banner_h
            by0 += banner_h
            by1 += banner_h
            # draw box
            draw.rectangle([bx0, by0, bx1, by1], outline=color, width=3)
            
            # draw badge
            badge_r = 13
            badge_cx = bx0 + 16
            badge_cy = max(banner_h + 16, by0 - 14)
            draw.ellipse([badge_cx - badge_r, badge_cy - badge_r, badge_cx + badge_r, badge_cy + badge_r],
                         fill=color, outline=(255, 255, 255), width=2)
            draw.text((badge_cx, badge_cy), num, fill=(255, 255, 255), font=font_badge, anchor="mm")
            
            # draw label if provided
            if lbl:
                tb = font_label.getbbox(lbl)
                tw = tb[2] - tb[0]
                th = tb[3] - tb[1]
                lx = badge_cx + badge_r + 4
                ly = badge_cy - th // 2 - 2
                draw.rounded_rectangle([lx - 3, ly - 2, lx + tw + 6, ly + th + 4], radius=3, fill=color)
                draw.text((lx, ly - tb[1]), lbl, fill=(255, 255, 255), font=font_label)
        
        if arrow:
            (ax0, ay0), (ax1, ay1) = arrow
            ay0 += banner_h
            ay1 += banner_h
            draw_arrow(draw, (ax0, ay0), (ax1, ay1), color=color, width=3)
            # badge at start of arrow
            draw.ellipse([ax0 - 13, ay0 - 13, ax0 + 13, ay0 + 13], fill=color, outline=(255, 255, 255), width=2)
            draw.text((ax0, ay0), num, fill=(255, 255, 255), font=font_badge, anchor="mm")
    
    p_out = os.path.join(out_dir, fname)
    new_img.save(p_out, quality=95)
    print(f"Generated: {fname}")

print("Annotate engine ready.")
