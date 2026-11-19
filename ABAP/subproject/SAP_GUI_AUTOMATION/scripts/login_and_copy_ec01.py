import os
import sys
import time
import subprocess
import json

def run(cmd):
    print("RUN:", cmd)
    env = dict(os.environ)
    env["DISPLAY"] = ":99"
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    if res.stdout: print("OUT:", res.stdout.strip())
    if res.stderr: print("ERR:", res.stderr.strip())
    return res

def snap(name):
    path = f"/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/{name}.png"
    run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {path} >/dev/null 2>&1")
    print(f"Captured: {path}")
    return path

def list_visible_windows():
    cmd = "DISPLAY=:99 xdotool search --onlyvisible --name '' getwindowname %@ 2>/dev/null"
    env = dict(os.environ)
    env["DISPLAY"] = ":99"
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    lines = [line.strip() for line in res.stdout.splitlines() if line.strip()]
    return lines

def main():
    print("=== Step 1: Cleanup non-ADB windows ===")
    run("DISPLAY=:99 xdotool search --name 'TRD (1)' windowclose 2>/dev/null")
    time.sleep(1)

    print("=== Step 2: Ensure ADB Logon Window is open ===")
    # Check if ADB window is open
    wins = list_visible_windows()
    adb_open = any("ADB" in w for w in wins)
    if not adb_open:
        print("Launching ADB...")
        run("nohup env DISPLAY=:99 /opt/SAPClients/SAPGUI8.10rev6/bin/sapgui '/H/192.168.1.199/S/3201' >/dev/null 2>&1 &")
        time.sleep(3)

    snap("step1_adb_ready")

    print("=== Step 3: Focus ADB and enter credentials ===")
    # Focus ADB window
    run("WID=$(DISPLAY=:99 xdotool search --name 'ADB (1)' | tail -1); DISPLAY=:99 xdotool windowactivate $WID windowraise $WID")
    time.sleep(0.5)

    # Shift+Tab to Client field
    run("DISPLAY=:99 xdotool key shift+Tab")
    time.sleep(0.2)
    run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete")
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 '130'")
    time.sleep(0.2)

    # Tab to User
    run("DISPLAY=:99 xdotool key Tab")
    time.sleep(0.2)
    run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 'TRSTABAP'")
    time.sleep(0.2)

    # Tab to Password
    run("DISPLAY=:99 xdotool key Tab")
    time.sleep(0.2)
    run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 'supporter'")
    time.sleep(0.2)

    # Tab to Language
    run("DISPLAY=:99 xdotool key Tab")
    time.sleep(0.2)
    run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete")
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 'EN'")
    time.sleep(0.2)

    print("Submitting logon...")
    run("DISPLAY=:99 xdotool key Return")
    time.sleep(3)

    snap("step2_post_logon")

    # Check if License popup appeared
    wins = list_visible_windows()
    print("Windows after logon:", wins)
    has_license = any("License" in w for w in wins)

    if has_license:
        print("=== Step 4: Handling License dialog ===")
        # Bring License window to front and move to 0,0
        run("LWID=$(DISPLAY=:99 xdotool search --name 'License' | tail -1); DISPLAY=:99 xdotool windowmove $LWID 0 0 windowraise $LWID windowfocus $LWID")
        time.sleep(0.5)

        # Click Option 2: circle at (15, 456), text at (100, 456)
        print("Clicking Option 2 radio button...")
        run("DISPLAY=:99 xdotool mousemove 15 456 click 1")
        time.sleep(0.3)
        run("DISPLAY=:99 xdotool mousemove 100 456 click 1")
        time.sleep(0.3)
        run("DISPLAY=:99 xdotool key space")
        time.sleep(0.5)

        snap("step3_license_option2_selected")

        # Click Enter button at (1365, 862)
        print("Clicking Enter on License dialog...")
        run("DISPLAY=:99 xdotool mousemove 1365 862 click 1")
        time.sleep(0.5)
        run("DISPLAY=:99 xdotool key Return")
        time.sleep(4)

    snap("step4_after_license")

    # Verify session window
    wins = list_visible_windows()
    print("Windows currently open:", wins)

    print("=== Step 5: Check Easy Access & Navigate to EC01 ===")
    # Make sure active window is the SAP Easy Access session
    run("SWID=$(DISPLAY=:99 xdotool search --name 'ADB (1)' | tail -1); DISPLAY=:99 xdotool windowactivate $SWID windowraise $SWID")
    time.sleep(0.5)

    # Click command field at (70, 53)
    run("DISPLAY=:99 xdotool mousemove 70 53 click 1")
    time.sleep(0.3)
    run("DISPLAY=:99 xdotool key ctrl+a BackSpace Delete")
    time.sleep(0.2)
    run("DISPLAY=:99 xdotool type --delay 60 '/nEC01'")
    time.sleep(0.3)
    run("DISPLAY=:99 xdotool key Return")
    time.sleep(3)

    snap("step5_ec01_screen")

    wins = list_visible_windows()
    print("Windows after EC01:", wins)

if __name__ == "__main__":
    main()
