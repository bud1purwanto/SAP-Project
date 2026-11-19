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
    print("Filling Row 2 (0020)...")
    # Click ICt (col 2, row 2)
    run_cmd("xdotool mousemove 68 395 click 1")
    time.sleep(0.1)
    run_cmd("xdotool key ctrl+a")
    run_cmd("xdotool type 'L'")
    time.sleep(0.1)

    # Click Component (col 3, row 2)
    run_cmd("xdotool mousemove 115 395 click 1")
    time.sleep(0.1)
    run_cmd("xdotool key ctrl+a")
    run_cmd("xdotool type 'SRP-I'")
    time.sleep(0.1)

    # Click Quantity (col 5, row 2)
    run_cmd("xdotool mousemove 490 395 click 1")
    time.sleep(0.1)
    run_cmd("xdotool key ctrl+a")
    run_cmd("xdotool type '64.948'")
    time.sleep(0.1)

    # Press Return
    run_cmd("xdotool key Return")
    time.sleep(1.5)
    snap("row2_test.png")

if __name__ == '__main__':
    main()
