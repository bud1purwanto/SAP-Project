import os, sys, time, subprocess, json

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

# Find ADB window
res = run('xdotool search --name "ADB (1) (130)"')
wins = [w.strip() for w in res.stdout.splitlines() if w.strip()]
print("Found windows:", wins)

if wins:
    win = wins[0]
    print(f"Activating {win}...")
    run(f"xdotool windowactivate --sync {win}")
    time.sleep(0.5)
    
    # Click command field at (70, 53)
    run("xdotool mousemove 70 53 click 1")
    time.sleep(0.2)
    run("xdotool key ctrl+a BackSpace")
    time.sleep(0.2)
    run("xdotool type --delay 60 '/nSE16N'")
    time.sleep(0.2)
    run("xdotool key Return")
    time.sleep(2)
    
    # Snapshot
    out = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/snap_se16n_raw.png"
    run(f"ffmpeg -y -f x11grab -video_size 1440x900 -i :99.0 -vframes 1 {out}")
    print("Snapshot saved:", out, "Exists:", os.path.exists(out))
