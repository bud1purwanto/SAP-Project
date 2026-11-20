import subprocess

res = subprocess.run(["fc-list", ":", "file"], capture_output=True, text=True)
fonts = [line for line in res.stdout.splitlines() if "ttf" in line.lower() or "otf" in line.lower()]
print(f"Total fonts found: {len(fonts)}")
for f in fonts[:10]:
    print(f)
