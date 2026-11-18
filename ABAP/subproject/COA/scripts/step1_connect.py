import subprocess
import time

def run(cmd):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return p.stdout.strip()

print("Activating SAP GUI window...")
# Focus SAP GUI window
run("DISPLAY=:99 xdotool search --onlyvisible --name 'SAP GUI for Java' windowactivate --sync")
time.sleep(1)

# Double click Development AIX (around x=200, y=120)
print("Double clicking Development AIX...")
run("DISPLAY=:99 xdotool mousemove 200 120 click --repeat 2 1")

# Wait 5 seconds for connection
for i in range(5):
    time.sleep(1)
    print(f"Waiting {i+1}s...")

run("ffmpeg -y -f x11grab -video_size 1440x900 -i :99 -vframes 1 /data/Projects/SAP/ABAP/subproject/COA/outputs/screen_after_connect.png")
print("Screenshot saved to screen_after_connect.png")

out = run("DISPLAY=:99 xdotool search --name '.*'")
for wid in out.splitlines():
    wname = run(f"DISPLAY=:99 xdotool getwindowname {wid}")
    if wname:
        print(f"{wid}: {wname}")
