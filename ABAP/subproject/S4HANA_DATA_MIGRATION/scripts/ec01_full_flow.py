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

def take_shot(win_id, out_file):
    sock = '/home/abap/.cache/cua-driver/cua-driver-sap.sock'
    cmd = f"/home/abap/.local/bin/cua-driver --socket {sock} call get_window_state '{{\"pid\":11474,\"window_id\":{win_id},\"screenshot_out_file\":\"{out_file}\"}}'"
    r = run(cmd)
    return r.returncode == 0

def wait_for_window(title_contains, timeout=10):
    start = time.time()
    while time.time() - start < timeout:
        for w in list_wins():
            if title_contains.lower() in w['title'].lower():
                return w
        time.sleep(0.5)
    return None

def main():
    print("=== Step 1: Trigger F6 in EC01 ===")
    run('DISPLAY=:99 xdotool windowraise 29377691 windowfocus 29377691')
    time.sleep(0.3)
    run('DISPLAY=:99 xdotool key F6')
    time.sleep(1.5)
    
    copy_win = wait_for_window('Copy')
    if not copy_win:
        print("ERROR: Copy window did not appear!")
        return
    print(f"Copy window found: {copy_win['window_id']}")
    
    print("=== Step 2: Fill 0001 -> 9999 ===")
    run(f"DISPLAY=:99 xdotool windowfocus {copy_win['window_id']}")
    time.sleep(0.3)
    run('DISPLAY=:99 xdotool key shift+Tab')
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key ctrl+a BackSpace Delete')
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 '0001'")
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key Tab')
    time.sleep(0.2)
    run('DISPLAY=:99 xdotool key ctrl+a BackSpace Delete')
    time.sleep(0.1)
    run("DISPLAY=:99 xdotool type --delay 60 '9999'")
    time.sleep(0.3)
    
    # Submit copy form
    run('DISPLAY=:99 xdotool key Return')
    time.sleep(2)
    
    print("=== Step 3: Wait for G/L accounts popup ===")
    gl_win = wait_for_window('G/L accounts')
    if gl_win:
        print(f"G/L accounts popup found: {gl_win['window_id']}")
        run(f"DISPLAY=:99 xdotool windowfocus {gl_win['window_id']}")
        time.sleep(0.3)
        # Click Yes at root 86, 186
        print("Clicking Yes on G/L accounts (86, 186)...")
        run('DISPLAY=:99 xdotool mousemove 86 186 click 1')
        time.sleep(2)
    else:
        print("G/L accounts popup did not appear, checking current windows...")
        print([(w['window_id'], w['title']) for w in list_wins()])
        
    print("=== Step 4: Wait for Controlling Area popup ===")
    co_win = wait_for_window('Controlling Area')
    if co_win:
        print(f"Controlling Area popup found: {co_win['window_id']}")
        run(f"DISPLAY=:99 xdotool windowfocus {co_win['window_id']}")
        time.sleep(0.3)
        # Click Yes at root 99, 157
        print("Clicking Yes on Controlling Area (99, 157)...")
        run('DISPLAY=:99 xdotool mousemove 99 157 click 1')
        time.sleep(2)
    else:
        print("Controlling Area popup did not appear, checking current windows...")
        print([(w['window_id'], w['title']) for w in list_wins()])
        
    print("=== Step 5: Wait for Number ranges popup ===")
    nr_win = wait_for_window('Transport number')
    if nr_win:
        print(f"Number ranges popup found: {nr_win['window_id']}")
        run(f"DISPLAY=:99 xdotool windowfocus {nr_win['window_id']}")
        time.sleep(0.3)
        # Click Enter at root 1315, 881
        print("Clicking Enter on Number ranges (1315, 881)...")
        run('DISPLAY=:99 xdotool mousemove 1315 881 click 1')
        time.sleep(3)
    else:
        print("Number ranges popup did not appear, checking current windows...")
        print([(w['window_id'], w['title']) for w in list_wins()])
        
    print("=== Step 6: Check post-Step 5 windows ===")
    time.sleep(2)
    current_wins = list_wins()
    print("Windows after full sequence:", [(w['window_id'], w['title']) for w in current_wins])
    
    # Capture the active/top window
    for w in current_wins:
        if w['window_id'] != 29360160: # ignore SAP GUI for Java
            out_file = f"/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/23_step6_{w['window_id']}.png"
            take_shot(w['window_id'], out_file)
            print(f"Screenshot saved for window {w['window_id']} ({w['title']}): {out_file}")

if __name__ == '__main__':
    main()
