import sys
from PIL import ImageGrab
ImageGrab.grab(xdisplay=':99').save(sys.argv[1])
