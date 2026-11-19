import os
import sys
import time
import subprocess

def run_cmd(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

def snap(filename):
    out = f"/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/{filename}"
    cmd = f"xwd -root -silent -out /tmp/root.xwd && ffmpeg -y -i /tmp/root.xwd -update 1 {out} 2>/dev/null"
    run_cmd(cmd)
    print(f"Snapshot saved: {out}")

def main():
    print("Testing Row 1 quantity fix with comma...")
    run_cmd("xdotool mousemove 475 410 click 1")
    time.sleep(0.2)
    run_cmd("xdotool key ctrl+a")
    time.sleep(0.1)
    run_cmd("xdotool type '22,454'")
    time.sleep(0.2)
    run_cmd("xdotool key Return")
    time.sleep(1.0)
    snap("test_comma_row1.png")

if __name__ == '__main__':
    main()
