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
    print("Setting Base Quantity = 100 in Header...")
    run_cmd("xdotool key F6")
    time.sleep(1.0)

    # Click Base quantity at x=235, y=600
    run_cmd("xdotool mousemove 235 600 click 1")
    time.sleep(0.2)
    run_cmd("xdotool key ctrl+a BackSpace")
    time.sleep(0.2)
    run_cmd("xdotool type '100'")
    time.sleep(0.2)
    run_cmd("xdotool key Return")
    time.sleep(0.5)

    # Return to Item Overview via F5
    run_cmd("xdotool key F5")
    time.sleep(1.0)
    snap("alt2_header_set.png")

    print("Adding Item 1: RPV-HC401BF...")
    # Row 1 is at y=370
    run_cmd("xdotool mousemove 68 370 click 1")
    time.sleep(0.2)
    run_cmd("xdotool key ctrl+a")
    run_cmd("xdotool type 'L'")
    time.sleep(0.2)

    run_cmd("xdotool mousemove 115 370 click 1")
    time.sleep(0.2)
    run_cmd("xdotool key ctrl+a")
    run_cmd("xdotool type 'RPV-HC401BF'")
    time.sleep(0.2)

    run_cmd("xdotool key Return")
    time.sleep(1.0)

    # Type quantity in detail screen (comma notation!)
    run_cmd("xdotool type '22,454'")
    time.sleep(0.2)
    run_cmd("xdotool key Return")
    time.sleep(0.5)

    run_cmd("xdotool key F5")
    time.sleep(1.0)
    snap("alt2_item1_added.png")

    # Items 2 through 9
    items = [
        ('SRP-I', '64,948'),
        ('SRP-E', '3,711'),
        ('M5AAA01', '1,670'),
        ('RPV-FS3011E3', '5,077'),
        ('RPM-ABPP10T', '0,077'),
        ('RPV-FS3011E3', '4,948'),
        ('RPC-FS5612', '0,155'),
        ('RPM-ABPP10T', '0,052'),
    ]

    for comp, qty in items:
        print(f"Adding item: {comp} with qty {qty}...")
        run_cmd("xdotool mousemove 68 395 click 1")
        time.sleep(0.2)
        run_cmd("xdotool key ctrl+a")
        run_cmd("xdotool type 'L'")
        time.sleep(0.2)

        run_cmd("xdotool mousemove 115 395 click 1")
        time.sleep(0.2)
        run_cmd("xdotool key ctrl+a")
        run_cmd(f"xdotool type '{comp}'")
        time.sleep(0.2)

        run_cmd("xdotool key Return")
        time.sleep(1.0)

        run_cmd(f"xdotool type '{qty}'")
        time.sleep(0.2)
        run_cmd("xdotool key Return")
        time.sleep(0.5)

        run_cmd("xdotool key F5")
        time.sleep(1.0)

    print("All 9 items added! Taking snapshot before save...")
    snap("alt2_all_items.png")

    print("Saving BOM (Ctrl+S)...")
    run_cmd("xdotool key ctrl+s")
    time.sleep(2.5)
    snap("alt2_saved.png")

if __name__ == '__main__':
    main()
