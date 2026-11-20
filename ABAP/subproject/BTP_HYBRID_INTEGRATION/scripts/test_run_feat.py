import sys
from PIL import Image
from find_features import find_color_boxes

# Green in 06_btp_destination_check_success
green_pred = lambda r, g, b: g > 100 and r < 80 and b < 80
boxes = find_color_boxes("06_btp_destination_check_success.jpg", green_pred)
print("06 Green boxes:", [(b['x0'], b['y0'], b['x1'], b['y1']) for b in boxes[:3]])

# Blue in 14_bas_project_generated_open_folder
blue_pred = lambda r, g, b: b > 140 and r < 60 and g > 60
boxes14 = find_color_boxes("14_bas_project_generated_open_folder.png", blue_pred)
print("14 Blue boxes:", [(b['x0'], b['y0'], b['x1'], b['y1']) for b in boxes14[:3]])
