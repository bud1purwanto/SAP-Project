import subprocess

try:
    res = subprocess.run(["which", "tesseract"], capture_output=True, text=True)
    print("tesseract:", res.stdout.strip() or "Not found")
except Exception as e:
    print(e)
