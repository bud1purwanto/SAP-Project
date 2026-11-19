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

def main():
    wins = list_wins()
    copy_win = None
    for w in wins:
        if 'Copy' in w['title']:
            copy_win = w['window_id']
            break
            
    if not copy_win:
        print('Copy window not found!')
        sys.exit(1)
        
    print(f'Activating Copy window {copy_win}...')
    run(f'xdotool windowraise {copy_win} windowfocus {copy_win}')
    time.sleep(0.5)
    
    # Focus is at From Company Code
    # Clear and type 0001
    print('Typing From Company Code: 0001')
    run('xdotool key --delay 50 ctrl+a BackSpace')
    time.sleep(0.2)
    run('xdotool type --delay 60 0001')
    time.sleep(0.3)
    
    # Tab to To Company Code
    print('Tabbing to To Company Code...')
    run('xdotool key Tab')
    time.sleep(0.3)
    
    # Clear and type 9999
    print('Typing To Company Code: 9999')
    run('xdotool key --delay 50 ctrl+a BackSpace')
    time.sleep(0.2)
    run('xdotool type --delay 60 9999')
    time.sleep(0.3)
    
    # Take screenshot before pressing Return
    take_shot(copy_win, '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/copy_filled.png')
    print('Screenshot saved: copy_filled.png')
    
    # Press Return
    print('Pressing Return to submit copy...')
    run('xdotool key Return')
    time.sleep(4)
    
    # List windows again to see what popup appeared
    wins_after = list_wins()
    print('Windows after submit:', [(w['window_id'], w['title']) for w in wins_after])
    
    # Capture the top window
    top_win = wins_after[0]['window_id'] if wins_after else copy_win
    take_shot(top_win, '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/after_copy_submit.png')
    print('Screenshot saved: after_copy_submit.png')

if __name__ == '__main__':
    main()
