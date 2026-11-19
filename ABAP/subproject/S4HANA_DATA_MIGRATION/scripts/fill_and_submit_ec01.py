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
    copy_win = 29377847
    print('Starting key navigation...')
    
    # 1. Shift+Tab to From Company Code
    run('xdotool key shift+Tab')
    time.sleep(0.3)
    
    # Type 0001
    run('xdotool key ctrl+a BackSpace Delete')
    time.sleep(0.1)
    run("xdotool type --delay 60 '0001'")
    time.sleep(0.3)
    
    # 2. Tab to To Company Code
    run('xdotool key Tab')
    time.sleep(0.3)
    
    # Type 9999
    run('xdotool key ctrl+a BackSpace Delete')
    time.sleep(0.1)
    run("xdotool type --delay 60 '9999'")
    time.sleep(0.3)
    
    # Screenshot of filled form
    shot1 = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/18_ec01_filled.png'
    take_shot(copy_win, shot1)
    print(f'Filled screenshot saved to {shot1}')
    
    # 3. Submit with Return
    print('Submitting via Return...')
    run('xdotool key Return')
    time.sleep(5)
    
    # 4. Check windows after submit
    wins = list_wins()
    print('Windows now:', [(w['window_id'], w['title']) for w in wins])
    top_id = wins[0]['window_id'] if wins else copy_win
    shot2 = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/19_after_ec01_submit.png'
    take_shot(top_id, shot2)
    print(f'Post-submit screenshot saved to {shot2}')

if __name__ == '__main__':
    main()
