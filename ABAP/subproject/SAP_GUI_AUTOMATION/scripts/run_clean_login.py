import os
import sys
import time
import subprocess

def run(cmd):
    print("RUN:", cmd)
    env = dict(os.environ)
    env["DISPLAY"] = ":99"
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    if res.stdout.strip(): print("OUT:", res.stdout.strip())
    if res.stderr.strip(): print("ERR:", res.stderr.strip())
    return res

def snap(name):
    path = f"/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/{name}.png"
    run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {path} >/dev/null 2>&1")
    print(f"Captured: {path}")
    return path

def get_wins(pattern):
    r = run(f"DISPLAY=:99 xdotool search --name '{pattern}' 2>/dev/null")
    wids = [w.strip() for w in r.stdout.splitlines() if w.strip()]
    return wids

def main():
    print("=== 1. Launch ADB Connection ===")
    run("nohup env DISPLAY=:99 /opt/SAPClients/SAPGUI8.10rev6/bin/sapgui '/H/192.168.1.199/S/3201' >/dev/null 2>&1 &")
    
    adb_wids = []
    for _ in range(15):
        time.sleep(0.5)
        adb_wids = get_wins("ADB")
        if adb_wids: break
        
    if not adb_wids:
        print("ERROR: ADB window did not open!")
        return
        
    adb_wid = adb_wids[-1]
    print(f"Found ADB window: {adb_wid}")
    run(f"DISPLAY=:99 xdotool windowactivate {adb_wid} windowraise {adb_wid}")
    time.sleep(0.5)
    snap("adb_logon_opened")

    print("=== 2. Enter Credentials ===")
    # Shift+Tab to Client
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

    print("Submitting login...")
    run("DISPLAY=:99 xdotool key Return")
    time.sleep(3)
    snap("adb_post_logon_screen")

    print("=== 3. Check License Popup ===")
    lic_wids = []
    for _ in range(6):
        lic_wids = get_wins("License")
        if lic_wids: break
        time.sleep(0.5)

    if lic_wids:
        lic_wid = lic_wids[-1]
        print(f"Handling License dialog: {lic_wid}")
        run(f"DISPLAY=:99 xdotool windowmove {lic_wid} 0 0 windowraise {lic_wid} windowfocus {lic_wid}")
        time.sleep(0.5)

        # Click Option 2 circle at (15, 359) and text at (50, 359)
        print("Clicking Option 2 at (15, 359)...")
        run("DISPLAY=:99 xdotool mousemove 15 359 click 1")
        time.sleep(0.3)
        run("DISPLAY=:99 xdotool mousemove 50 359 click 1")
        time.sleep(0.3)
        run("DISPLAY=:99 xdotool key space")
        time.sleep(0.5)
        snap("adb_license_opt2_clicked")

        # Click Enter button at (1365, 881)
        print("Clicking Enter at (1365, 881)...")
        run("DISPLAY=:99 xdotool mousemove 1365 881 click 1")
        time.sleep(0.3)
        run("DISPLAY=:99 xdotool key Return")
        time.sleep(5)
    else:
        print("No License popup appeared.")

    snap("adb_after_license_handled")

    print("=== 4. Verify Active Session Window ===")
    wins_r = run("DISPLAY=:99 xdotool search --onlyvisible --name '' getwindowname %@ 2>/dev/null")
    print("Visible windows:", wins_r.stdout.strip())

    session_wids = get_wins("ADB")
    if session_wids:
        swid = session_wids[-1]
        run(f"DISPLAY=:99 xdotool windowactivate {swid} windowraise {swid}")
        time.sleep(0.5)

    snap("adb_session_ready")

    print("=== 5. Navigate to EC01 ===")
    # Command field at (70, 53)
    run("DISPLAY=:99 xdotool mousemove 70 53 click 1")
    time.sleep(0.3)
    run("DISPLAY=:99 xdotool key ctrl+a BackSpace Delete")
    time.sleep(0.2)
    run("DISPLAY=:99 xdotool type --delay 60 '/nEC01'")
    time.sleep(0.3)
    run("DISPLAY=:99 xdotool key Return")
    time.sleep(4)

    snap("adb_ec01_reached")
    print("=== COMPLETED ===")

if __name__ == "__main__":
    main()
