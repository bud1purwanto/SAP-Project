import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Filling Address for Plant 1000...')
# Name 1
run('xdotool mousemove 200 107 click 1')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "Waru"')
time.sleep(0.2)

# Street
run('xdotool mousemove 200 340 click 1')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "Jl. Raya Waru 1 B, Waru"')
time.sleep(0.2)

# Postal Code
run('xdotool mousemove 150 377 click 1')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "61256"')
time.sleep(0.2)

# City
run('xdotool mousemove 240 377 click 1')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "Sidoarjo"')
time.sleep(0.2)

# Country
run('xdotool mousemove 140 413 click 1')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "ID"')
time.sleep(0.2)

# Confirm Address dialog
print('Confirming Address with Return...')
run('xdotool key Return')
time.sleep(1.5)

# Save
print('Saving Plant 1000 with Ctrl+S...')
run('xdotool key ctrl+s')
time.sleep(1.5)

# Confirm TR
print('Confirming TR...')
run('xdotool key Return')
time.sleep(1.5)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox10_1000_saved.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
