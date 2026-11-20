import subprocess
import time
import os

env = dict(os.environ)
env['DISPLAY'] = ':99'

def run(cmd):
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

# Find logon pad window
r = run("xdotool search --name 'SAP GUI for Java'")
win_ids = [w.strip() for w in r.stdout.splitlines() if w.strip()]
print("Logon pad windows:", win_ids)
if win_ids:
    win = win_ids[-1]
    run(f"xdotool windowactivate {win}")
    time.sleep(0.5)

# Take screenshot to see where S4 HANA is
run("ffmpeg -y -f x11grab -i :99 -vframes 1 /tmp/logon_pad.png")
print("Captured /tmp/logon_pad.png")
