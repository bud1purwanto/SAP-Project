import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Typing Plant 1000 and pressing Return...')
run('xdotool type --delay 60  1000')
time.sleep(0.3)
run('xdotool key Return')
time.sleep(1.5)

print('Pressing F5 for New Entries...')
run('xdotool key F5')
time.sleep(1.2)

print('Typing SLoc 1011...')
run('xdotool type --delay 50 1011')
time.sleep(0.2)
run('xdotool key Tab')
time.sleep(0.2)
run('xdotool type --delay 50 Feed OPP WR')
time.sleep(0.2)
run('xdotool key Tab')
time.sleep(0.2)

print('Typing SLoc 1813...')
run('xdotool type --delay 50 1813')
time.sleep(0.2)
run('xdotool key Tab')
time.sleep(0.2)
run('xdotool type --delay 50 WR FGS-Non WM')
time.sleep(0.3)

print('Saving with Ctrl+S...')
run('xdotool key ctrl+s')
time.sleep(1.5)

print('Confirming TR dialog if present...')
run('xdotool key Return')
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_1000_saved.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done add_sloc_1000!')
