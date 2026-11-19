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
    print("Pressing Return on CS02 initial screen...")
    run_cmd("xdotool key Return")
    time.sleep(1.5)

    print("Clicking Select All button at x=14, y=145...")
    run_cmd("xdotool mousemove 14 145 click 1")
    time.sleep(0.5)

    print("Clicking Delete button (trash can) at x=245, y=145...")
    run_cmd("xdotool mousemove 245 145 click 1")
    time.sleep(1.0)
    snap("cs02_deleted_selection.png")

if __name__ == '__main__':
    main()
