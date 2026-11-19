import os
import sys
import time
import subprocess
import json

def run(cmd):
    print("RUN:", cmd)
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    if res.stdout: print("OUT:", res.stdout.strip())
    if res.stderr: print("ERR:", res.stderr.strip())
    return res

def list_wins():
    sock = '/home/abap/.cache/cua-driver/cua-driver-sap.sock'
    cmd = f"/home/abap/.local/bin/cua-driver --socket {sock} call list_windows '{{}}'"
    r = run(cmd)
    try:
        data = json.loads(r.stdout)
        return data.get('windows', [])
    except Exception as e:
        return []

def main():
    # 1. Launch direct ADB
    print("=== Step 1: Launch direct ADB connection ===")
    run("nohup env DISPLAY=:99 /opt/SAPClients/SAPGUI8.10rev6/bin/sapgui '/H/192.168.1.199/S/3201' >/dev/null 2>&1 &")
    
    adb_win = None
    for _ in range(15):
        time.sleep(0.5)
        for w in list_wins():
            if 'ADB' in w['title']:
                adb_win = w['window_id']
                break
        if adb_win: break
        
    if not adb_win:
        print("ERROR: ADB window not found!")
        return
        
    print(f"ADB logon window found: {adb_win}")
    run(f"xdotool windowactivate --sync {adb_win}")
    time.sleep(0.5)
    
    # 2. Fill login form
    print("=== Step 2: Fill credentials ===")
    run("xdotool key shift+Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete")
    time.sleep(0.1)
    run("xdotool type --delay 60 '130'")
    time.sleep(0.2)
    
    run("xdotool key Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.1)
    run("xdotool type --delay 60 'TRSTABAP'")
    time.sleep(0.2)
    
    run("xdotool key Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.1)
    run("xdotool type --delay 60 'supporter'")
    time.sleep(0.2)
    
    run("xdotool key Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete")
    time.sleep(0.1)
    run("xdotool type --delay 60 'EN'")
    time.sleep(0.2)
    
    print("Submitting login form...")
    run("xdotool key Return")
    time.sleep(3)
    
    # 3. Handle License popup if present
    license_win = None
    for _ in range(6):
        for w in list_wins():
            if 'License' in w['title']:
                license_win = w['window_id']
                break
        if license_win: break
        time.sleep(0.5)
        
    if license_win:
        print(f"=== Step 3: Handle License popup {license_win} ===")
        run(f"xdotool windowactivate --sync {license_win}")
        time.sleep(0.5)
        # Click Option 2 radio button
        run(f"xdotool mousemove --window {license_win} 26 354 click 1")
        time.sleep(0.4)
        run("xdotool key space")
        time.sleep(0.4)
        # Click Enter
        run(f"xdotool mousemove --window {license_win} 1360 862 click 1")
        time.sleep(0.5)
        run("xdotool key Return")
        time.sleep(5)
        
    # 4. Wait for ADB session window
    print("=== Step 4: Verify ADB session window ===")
    session_win = None
    for _ in range(12):
        wins = list_wins()
        for w in wins:
            if 'ADB' in w['title'] and '(130)' in w['title']:
                session_win = w['window_id']
                break
            elif 'ADB' in w['title'] and '(000)' not in w['title']:
                session_win = w['window_id']
                break
        if session_win: break
        time.sleep(0.5)
        
    if not session_win:
        print("Warning: ADB (130) title not found yet, checking current windows:")
        print([(w['window_id'], w['title']) for w in list_wins()])
    else:
        print(f"ADB session window active: {session_win}")
        
    # Take screenshot of Easy Access
    shot1 = "/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/27_easy_access.png"
    run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {shot1}")
    print(f"Easy access screenshot saved to {shot1}")
    
    # 5. Navigate to EC01
    print("=== Step 5: Navigate to EC01 ===")
    run("xdotool mousemove 70 53 click 1")
    time.sleep(0.3)
    run("xdotool key ctrl+a BackSpace Delete")
    time.sleep(0.2)
    run("xdotool type --delay 60 '/nEC01'")
    time.sleep(0.3)
    run("xdotool key Return")
    time.sleep(3)
    
    # Take screenshot of EC01
    shot2 = "/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/28_ec01_screen.png"
    run(f"ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {shot2}")
    print(f"EC01 screenshot saved to {shot2}")

if __name__ == '__main__':
    main()
