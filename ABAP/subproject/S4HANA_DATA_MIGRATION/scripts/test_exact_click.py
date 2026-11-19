import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Activating window 35651634...')
run('xdotool windowactivate 35651634')
time.sleep(0.5)

print('Moving to 185 312 and clicking...')
run('xdotool mousemove 185 312 click 1')
time.sleep(0.3)

print('Typing 1011...')
run('xdotool type --delay 60  1011')
time.sleep(0.3)

print('Tab...')
run('xdotool key Tab')
time.sleep(0.3)

print('Typing Feed OPP WR...')
run('xdotool type --delay 60 Feed OPP WR')
time.sleep(0.3)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_exact_typed.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
