import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Fixing Address for Plant 2000...')
# Focus Country (currently focused) and type ID
run('xdotool type --delay 50 "ID"')
time.sleep(0.2)

# Click Postal Code at x=150, y=334 (offset corrected)
run('xdotool mousemove 150 334 click 1')
time.sleep(0.2)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "61262"')
time.sleep(0.2)

# Tab to City
run('xdotool key Tab')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "Sidoarjo"')
time.sleep(0.2)

# Return twice to validate and confirm
print('Confirming Address with Return...')
run('xdotool key Return')
time.sleep(0.8)
run('xdotool key Return')
time.sleep(1.5)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox10_2000_after_addr.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
