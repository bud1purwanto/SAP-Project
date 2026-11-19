import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Clicking Row 1 SLoc at 185 312...')
run('xdotool mousemove 185 312 click 1')
time.sleep(0.3)

print('Typing 1011...')
run('xdotool type --delay 60  1011')
time.sleep(0.2)

print('Clicking Row 1 Description at 240 312...')
run('xdotool mousemove 240 312 click 1')
time.sleep(0.2)
print('Typing Feed OPP WR...')
run('xdotool type --delay 60 Feed OPP WR')
time.sleep(0.2)

print('Clicking Row 2 SLoc at 185 336...')
run('xdotool mousemove 185 336 click 1')
time.sleep(0.2)
print('Typing 1813...')
run('xdotool type --delay 60 1813')
time.sleep(0.2)

print('Clicking Row 2 Description at 240 336...')
run('xdotool mousemove 240 336 click 1')
time.sleep(0.2)
print('Typing WR FGS-Non WM...')
run('xdotool type --delay 60 WR FGS-Non WM')
time.sleep(0.3)

print('Pressing Return to validate...')
run('xdotool key Return')
time.sleep(1.0)

print('Saving with Ctrl+S...')
run('xdotool key ctrl+s')
time.sleep(1.5)

print('Confirming TR dialog...')
run('xdotool key Return')
time.sleep(2.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_1000_saved2.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
