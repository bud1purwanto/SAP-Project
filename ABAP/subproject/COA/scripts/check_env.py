import sys
print('Python:', sys.version)
try:
    import PIL
    print('PIL: OK')
except Exception as e:
    print('PIL error:', e)
try:
    import openpyxl
    print('openpyxl: OK')
except Exception as e:
    print('openpyxl error:', e)
