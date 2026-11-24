import os
import sys
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env["DISPLAY"] = ":99"
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

def snap(name):
    path = f"/data/Projects/SAP/ABAP/subproject/ZJR_EXEC/outputs/{name}.png"
    run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {path} >/dev/null 2>&1")
    return path

def get_wins(pattern):
    r = run(f"DISPLAY=:99 xdotool search --name '{pattern}' 2>/dev/null")
    wids = [w.strip() for w in r.stdout.splitlines() if w.strip()]
    return wids

def main():
    print("=== 1. Check existing ADB window ===")
    adb_wids = get_wins("ADB")
    if not adb_wids:
        print("Launching ADB Connection...")
        run("nohup env DISPLAY=:99 /opt/SAPClients/SAPGUI8.10rev6/bin/sapgui '/H/192.168.1.199/S/3201' >/dev/null 2>&1 &")
        for _ in range(20):
            time.sleep(0.5)
            adb_wids = get_wins("ADB")
            if adb_wids: break

    if not adb_wids:
        print("ERROR: ADB window did not open!")
        return

    adb_wid = adb_wids[-1]
    print(f"ADB window: {adb_wid}")
    run(f"DISPLAY=:99 xdotool windowactivate {adb_wid} windowraise {adb_wid}")
    time.sleep(0.5)
    snap("01_adb_window")

    # Check if we are at logon screen by looking at title
    r_title = run(f"DISPLAY=:99 xdotool getwindowname {adb_wid}")
    title = r_title.stdout.strip()
    print("Current ADB title:", title)

    if "(000)" in title or "Logon" in title:
        print("Entering credentials...")
        run("DISPLAY=:99 xdotool key shift+Tab")
        time.sleep(0.2)
        run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete")
        time.sleep(0.1)
        run("DISPLAY=:99 xdotool type --delay 60 '130'")
        time.sleep(0.2)

        run("DISPLAY=:99 xdotool key Tab")
        time.sleep(0.2)
        run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
        time.sleep(0.1)
        run("DISPLAY=:99 xdotool type --delay 60 'TRSTABAP'")
        time.sleep(0.2)

        run("DISPLAY=:99 xdotool key Tab")
        time.sleep(0.2)
        run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
        time.sleep(0.1)
        run("DISPLAY=:99 xdotool type --delay 60 'supporter'")
        time.sleep(0.2)

        run("DISPLAY=:99 xdotool key Tab")
        time.sleep(0.2)
        run("DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete")
        time.sleep(0.1)
        run("DISPLAY=:99 xdotool type --delay 60 'EN'")
        time.sleep(0.2)

        run("DISPLAY=:99 xdotool key Return")
        time.sleep(3)

        # Check License popup
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
            run("DISPLAY=:99 xdotool mousemove 15 359 click 1")
            time.sleep(0.3)
            run("DISPLAY=:99 xdotool mousemove 50 359 click 1")
            time.sleep(0.3)
            run("DISPLAY=:99 xdotool key space")
            time.sleep(0.5)
            run("DISPLAY=:99 xdotool mousemove 1365 881 click 1")
            time.sleep(0.3)
            run("DISPLAY=:99 xdotool key Return")
            time.sleep(4)

    snap("02_adb_logged_in")
    
    # Focus ADB session
    adb_wids = get_wins("ADB")
    if adb_wids:
        swid = adb_wids[-1]
        run(f"DISPLAY=:99 xdotool windowactivate {swid} windowraise {swid}")
        time.sleep(0.5)
        
        # Navigate to SE38 to run ZTEST_INSTALL_DTEL
        print("Navigating to SE38...")
        run("DISPLAY=:99 xdotool mousemove 70 53 click 1")
        time.sleep(0.3)
        run("DISPLAY=:99 xdotool key ctrl+a BackSpace Delete")
        time.sleep(0.2)
        run("DISPLAY=:99 xdotool type --delay 60 '/nSE38'")
        time.sleep(0.3)
        run("DISPLAY=:99 xdotool key Return")
        time.sleep(2)
        snap("03_se38_opened")
        
        # Type ZTEST_INSTALL_DTEL
        run("DISPLAY=:99 xdotool mousemove 200 175 click 1")
        time.sleep(0.2)
        run("DISPLAY=:99 xdotool key ctrl+a BackSpace Delete")
        time.sleep(0.2)
        run("DISPLAY=:99 xdotool type --delay 60 'ZTEST_INSTALL_DTEL'")
        time.sleep(0.3)
        snap("04_se38_typed")
        
        # Press F8 (Execute)
        print("Pressing F8 to execute...")
        run("DISPLAY=:99 xdotool key F8")
        time.sleep(2)
        snap("05_se38_executed")
        print("Execution complete!")

if __name__ == "__main__":
    main()