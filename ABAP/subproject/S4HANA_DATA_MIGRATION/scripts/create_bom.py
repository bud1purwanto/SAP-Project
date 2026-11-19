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
    print("Typing 100 in Base quantity...")
    run_cmd("xdotool key ctrl+a BackSpace")
    time.sleep(0.2)
    run_cmd("xdotool type '100'")
    time.sleep(0.3)

    print("Clearing BOM group...")
    run_cmd("xdotool mousemove 150 380 click 1")
    time.sleep(0.3)
    run_cmd("xdotool key ctrl+a BackSpace")
    time.sleep(0.3)

    print("Clicking Item button at x=35, y=145...")
    run_cmd("xdotool mousemove 35 145 click 1")
    time.sleep(2)
    snap("bom_after_item_click.png")

if __name__ == '__main__':
    main()
