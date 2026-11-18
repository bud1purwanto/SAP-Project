import subprocess

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout.strip()

print("=== WINDOWS ===")
out = run("DISPLAY=:99 xdotool search --name '.*'")
for wid in out.splitlines():
    wname = run(f"DISPLAY=:99 xdotool getwindowname {wid}")
    if wname:
        print(f"{wid}: {wname}")

run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/current_screen.png")
print("Screenshot saved to /data/Projects/SAP/ABAP/subproject/COA/outputs/current_screen.png")
