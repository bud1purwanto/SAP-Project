import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

run('xdotool search --name  ADB 1 130  windowactivate --sync')
time.sleep(0.5)

# Click at input y = 269 (Screen y = 312)
print('Clicking Row 1 SLoc at 185 269...')
run('xdotool mousemove 185 269 click 1')
time.sleep(0.3)

print('Typing 1011...')
run('xdotool type --delay 60  1011')
time.sleep(0.3)

print('Pressing Tab...')
run('xdotool key Tab')
time.sleep(0.3)

print('Typing Feed OPP WR...')
run('xdotool type --delay 60 Feed OPP WR')
time.sleep(0.3)

print('Pressing Tab...')
run('xdotool key Tab')
time.sleep(0.3)

print('Typing 1813...')
run('xdotool type --delay 60 1813')
time.sleep(0.3)

print('Pressing Tab...')
run('xdotool key Tab')
time.sleep(0.3)

print('Typing WR FGS-Non WM...')
run('xdotool type --delay 60 WR FGS-Non WM')
time.sleep(0.3)

print('Pressing Return to validate...')
run('xdotool key Return')
time.sleep(1.0)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox09_typed.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
