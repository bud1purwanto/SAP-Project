import os
import time
import subprocess

def run(cmd):
    env = dict(os.environ)
    env['DISPLAY'] = ':99'
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    return res

print('Navigating back to Overview with F3...')
run('xdotool key F3')
time.sleep(1.2)

# Now in overview, focus on Row 4 (Plant 2000)
# Row 4 is at offset y=290
print('Selecting Row 4 Plant 2000...')
run('xdotool mousemove 100 290 click 1')
time.sleep(0.5)

print('Opening Details with F2...')
run('xdotool key F2')
time.sleep(1.5)

print('Typing Name 1 for Plant 2000...')
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "Pabrik Krian (Trias Sentosa)"')
time.sleep(0.2)

print('Tab to Name 2...')
run('xdotool key Tab')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "Sidoarjo"')
time.sleep(0.2)

print('Opening Address with Shift+F5...')
run('xdotool key shift+F5')
time.sleep(1.5)

# In Address dialog:
# Name
run('xdotool mousemove 200 107 click 1')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "Krian"')
time.sleep(0.2)

# Street
run('xdotool mousemove 200 340 click 1')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "Desa Keboharan KM 26, Krian"')
time.sleep(0.2)

# Postal Code
run('xdotool mousemove 150 377 click 1')
time.sleep(0.1)
run('xdotool key --delay 40 ctrl+a BackSpace')
time.sleep(0.1)
run('xdotool type --delay 40 "61262"')
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

# Confirm Country / Address dialog (press Return twice)
print('Confirming Address...')
run('xdotool key Return')
time.sleep(0.8)
run('xdotool key Return')
time.sleep(1.5)

# Save
print('Saving Plant 2000 with Ctrl+S...')
run('xdotool key ctrl+s')
time.sleep(1.5)

# Confirm TR
print('Confirming TR...')
run('xdotool key Return')
time.sleep(1.5)

out_file = '/data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/ox10_2000_saved.png'
run(f'ffmpeg -f x11grab -video_size 1440x900 -i :99 -vframes 1 -y {out_file}')
print('Done!')
