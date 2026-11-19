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
    print("=== Step 1: Fill Login Fields in ADB ===")
    # Shift+Tab to Client
    run('DISPLAY=:99 xdotool key shift+Tab')
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete')
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 '130'")
    time.sleep(0.2)
    
    # Tab to User
    run('DISPLAY=:99 xdotool key Tab')
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete')
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 'TRSTABAP'")
    time.sleep(0.2)
    
    # Tab to Password
    run('DISPLAY=:99 xdotool key Tab')
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete')
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 'supporter'")
    time.sleep(0.2)
    
    # Tab to Language
    run('DISPLAY=:99 xdotool key Tab')
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete')
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 'EN'")
    time.sleep(0.2)
    
    # Submit login
    print("Submitting login...")
    run('DISPLAY=:99 xdotool key Return')
    time.sleep(3)
    
    # Check for License popup
    wins = list_wins()
    print("Windows after login Return:", [(w['window_id'], w['title']) for w in wins])
    
    license_win = None
    for w in wins:
        if 'License' in w['title']:
            license_win = w['window_id']
            break
            
    if license_win:
        print(f"Handling License popup: {license_win}")
        run(f"DISPLAY=:99 xdotool windowfocus {license_win}")
        time.sleep(0.3)
        # Select Radio 2
        run(f"DISPLAY=:99 xdotool mousemove 26 373 click 1")
        time.sleep(0.3)
        run('DISPLAY=:99 xdotool key space')
        time.sleep(0.3)
        # Submit popup
        run('DISPLAY=:99 xdotool mousemove 1360 881 click 1')
        time.sleep(0.5)
        run('DISPLAY=:99 xdotool key Return')
        time.sleep(4)
        
    wins_final = list_wins()
    print("Windows final:", [(w['window_id'], w['title']) for w in wins_final])
    
    # Take screenshot with ffmpeg
    run('ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y /tmp/screen_logged_in.png')
    print("Screenshot saved to /tmp/screen_logged_in.png")

if __name__ == '__main__':
    main()
