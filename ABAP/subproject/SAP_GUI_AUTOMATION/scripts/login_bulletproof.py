import os
import sys
import time
import subprocess
import json

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
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
    # 1. Close any non-logon windows (TRD, etc.)
    for w in list_wins():
        if 'TRD' in w['title']:
            run(f"DISPLAY=:99 xdotool windowclose {w['window_id']}")
    time.sleep(1)
    
    # 2. Launch direct ADB connection
    print("Launching direct ADB connection...")
    run("nohup env DISPLAY=:99 /opt/SAPClients/SAPGUI8.10rev6/bin/sapgui '/H/192.168.1.199/S/3201' >/dev/null 2>&1 &")
    
    # 3. Wait for ADB window
    adb_win = None
    for _ in range(15):
        time.sleep(0.5)
        for w in list_wins():
            if 'ADB' in w['title']:
                adb_win = w['window_id']
                break
        if adb_win:
            break
            
    if not adb_win:
        print("ERROR: ADB window did not open!")
        return
        
    print(f"ADB logon window found: {adb_win}")
    run(f"DISPLAY=:99 xdotool windowactivate --sync {adb_win}")
    time.sleep(0.5)
    
    # 4. Fill Client, User, Password, Language
    print("Typing login credentials...")
    run('DISPLAY=:99 xdotool key shift+Tab')
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete')
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 '130'")
    time.sleep(0.2)
    
    run('DISPLAY=:99 xdotool key Tab')
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete')
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 'TRSTABAP'")
    time.sleep(0.2)
    
    run('DISPLAY=:99 xdotool key Tab')
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete')
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 'supporter'")
    time.sleep(0.2)
    
    run('DISPLAY=:99 xdotool key Tab')
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete')
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 'EN'")
    time.sleep(0.2)
    
    print("Submitting login form...")
    run('DISPLAY=:99 xdotool key Return')
    time.sleep(3)
    
    # 5. Check for License dialog
    wins = list_wins()
    print("Windows after login Return:", [(w['window_id'], w['title']) for w in wins])
    license_win = None
    for w in wins:
        if 'License' in w['title']:
            license_win = w['window_id']
            break
            
    if license_win:
        print(f"Handling License dialog {license_win}...")
        run(f"DISPLAY=:99 xdotool windowactivate --sync {license_win}")
        time.sleep(0.5)
        # Move up to Option 2
        run('DISPLAY=:99 xdotool key Up')
        time.sleep(0.3)
        # Submit
        run('DISPLAY=:99 xdotool key Return')
        time.sleep(4)
        
    wins_after = list_wins()
    print("Final windows:", [(w['window_id'], w['title']) for w in wins_after])
    
    # Take screenshot with ffmpeg
    out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/26_adb_logged_in.png'
    run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
    print(f"Logged in screenshot saved: {out_file}")

if __name__ == '__main__':
    main()
