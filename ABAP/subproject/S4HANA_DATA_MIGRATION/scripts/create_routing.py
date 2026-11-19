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
    print("Setting Usage=1 and Overall Status=4...")
    run_cmd("xdotool type '1'")
    time.sleep(0.2)
    run_cmd("xdotool key Tab")
    time.sleep(0.2)
    run_cmd("xdotool type '4'")
    time.sleep(0.2)
    run_cmd("xdotool key Return")
    time.sleep(1.0)

    print("Going to Operations via F5...")
    run_cmd("xdotool key F5")
    time.sleep(1.5)
    snap("ca01_operations.png")

if __name__ == '__main__':
    main()
