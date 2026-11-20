import os, time, subprocess

def run_x(cmd):
    env = dict(os.environ)
    env["DISPLAY"] = ":99"
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

win_id = 46137391
run_x(f"xdotool windowactivate {win_id}")
time.sleep(0.5)

# Type USER-FIORI and press F7 (Display)
run_x("xdotool key ctrl+a BackSpace")
time.sleep(0.2)
run_x("xdotool type --delay 70 'USER-FIORI'")
time.sleep(0.3)
run_x("xdotool key F7")
time.sleep(3)

out = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/live_su01_display.png"
cmd = f"DISPLAY=:99 xwd -id {win_id} -silent -out /tmp/su01_disp.xwd && ffmpeg -y -i /tmp/su01_disp.xwd -update 1 {out} 2>/dev/null"
run_x(cmd)
print(f"Saved: {out}, size={os.path.getsize(out) if os.path.exists(out) else 0}")
