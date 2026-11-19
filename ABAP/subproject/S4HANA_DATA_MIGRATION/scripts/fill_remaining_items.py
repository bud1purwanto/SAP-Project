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

def add_item(component, qty):
    print(f"Adding item: {component} with qty {qty}...")
    run_cmd("xdotool mousemove 68 395 click 1")
    time.sleep(0.2)
    run_cmd("xdotool key ctrl+a")
    run_cmd("xdotool type 'L'")
    time.sleep(0.2)

    run_cmd("xdotool mousemove 115 395 click 1")
    time.sleep(0.2)
    run_cmd("xdotool key ctrl+a")
    run_cmd(f"xdotool type '{component}'")
    time.sleep(0.2)

    run_cmd("xdotool key Return")
    time.sleep(1.0)

    run_cmd(f"xdotool type '{qty}'")
    time.sleep(0.2)
    run_cmd("xdotool key Return")
    time.sleep(0.5)

    run_cmd("xdotool key F5")
    time.sleep(1.0)

def main():
    items = [
        ('M5AAA01', '1.670'),
        ('RPV-FS3011E3', '5.077'),
        ('RPM-ABPP10T', '0.077'),
        ('RPV-FS3011E3', '4.948'),
        ('RPC-FS5612', '0.155'),
        ('RPM-ABPP10T', '0.052'),
    ]

    for comp, qty in items:
        add_item(comp, qty)

    print("All items added. Taking snapshot of table before save...")
    snap("all_items_before_save.png")

    print("Saving BOM (Ctrl+S)...")
    run_cmd("xdotool key ctrl+s")
    time.sleep(2.5)
    snap("after_bom_save.png")

if __name__ == '__main__':
    main()
