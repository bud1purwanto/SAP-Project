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
        print('Error listing windows:', e)
        return []

def take_snapshot(win_id, out_file):
    sock = '/home/abap/.cache/cua-driver/cua-driver-sap.sock'
    cmd = f"/home/abap/.local/bin/cua-driver --socket {sock} call get_window_state '{{\"pid\":11474,\"window_id\":{win_id},\"screenshot_out_file\":\"{out_file}\"}}'"
    r = run(cmd)
    return r.returncode == 0

def navigate(tcode):
    wins = list_wins()
    adb_win = None
    for w in wins:
        if 'ADB' in w['title'] and '(130)' in w['title']:
            adb_win = w['window_id']
            break
    
    if not adb_win:
        # Fallback to any ADB window not 000
        for w in wins:
            if 'ADB' in w['title'] and '(000)' not in w['title']:
                adb_win = w['window_id']
                break
                
    if not adb_win:
        print('SAP ADB (130) window not found!')
        sys.exit(1)
        
    print(f'Activating SAP window {adb_win}...')
    run(f'xdotool windowactivate --sync {adb_win}')
    time.sleep(0.5)
    
    # Click command field at x=70, y=53
    print(f'Clicking command field and typing {tcode}...')
    run('xdotool mousemove 70 53 click 1')
    time.sleep(0.3)
    
    # Clear and type
    run('xdotool key --delay 50 ctrl+a BackSpace')
    time.sleep(0.2)
    run(f"xdotool type --delay 80 '/n{tcode}'")
    time.sleep(0.3)
    run('xdotool key Return')
    time.sleep(3)
    
    # Check new window state
    wins_after = list_wins()
    current_win = adb_win
    for w in wins_after:
        if 'ADB' in w['title'] and '(130)' in w['title']:
            current_win = w['window_id']
            print('Active window now:', w['title'], f'(id: {w["window_id"]})')
            break
            
    out_file = f'/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/after_{tcode}.png'
    take_snapshot(current_win, out_file)
    print(f'Screenshot saved to {out_file}')

if __name__ == '__main__':
    tcode = sys.argv[1] if len(sys.argv) > 1 else 'EC01'
    navigate(tcode)
