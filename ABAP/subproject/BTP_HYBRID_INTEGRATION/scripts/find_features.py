import os
from PIL import Image

src_dir = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments"

def find_color_boxes(fname, color_predicate, min_w=30, min_h=15):
    p = os.path.join(src_dir, fname)
    im = Image.open(p).convert("RGB")
    w, h = im.size
    
    # scan grid of 5x5
    matched_pts = []
    for y in range(0, h, 4):
        for x in range(0, w, 4):
            r, g, b = im.getpixel((x, y))
            if color_predicate(r, g, b):
                matched_pts.append((x, y))
    
    if not matched_pts:
        return []
    
    # group points into clusters
    clusters = []
    for pt in matched_pts:
        added = False
        for c in clusters:
            if abs(pt[0] - c['cx']) < 60 and abs(pt[1] - c['cy']) < 40:
                c['pts'].append(pt)
                c['x0'] = min(c['x0'], pt[0])
                c['y0'] = min(c['y0'], pt[1])
                c['x1'] = max(c['x1'], pt[0])
                c['y1'] = max(c['y1'], pt[1])
                c['cx'] = (c['x0'] + c['x1']) // 2
                c['cy'] = (c['y0'] + c['y1']) // 2
                added = True
                break
        if not added:
            clusters.append({
                'pts': [pt],
                'x0': pt[0], 'y0': pt[1], 'x1': pt[0], 'y1': pt[1],
                'cx': pt[0], 'cy': pt[1]
            })
    
    # filter clusters by min size
    results = [c for c in clusters if (c['x1'] - c['x0']) >= min_w and (c['y1'] - c['y0']) >= min_h]
    return sorted(results, key=lambda c: len(c['pts']), reverse=True)

print("Finder ready.")
