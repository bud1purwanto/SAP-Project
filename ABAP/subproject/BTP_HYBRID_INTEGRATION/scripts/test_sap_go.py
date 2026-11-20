import os, time, subprocess

def run_x(cmd):
    env = dict(os.environ)
    env["DISPLAY"] = ":99"
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

win_id = 46137391

def go_tcode(tcode, filename):
    print(f"Navigating to /n{tcode}...")
    run_x(f"xdotool windowactivate {win_id}")
    time.sleep(0.5)
    # click command field
    run_x("xdotool mousemove 70 53 click 1")
    time.sleep(0.2)
    run_x("xdotool key ctrl+a BackSpace")
    time.sleep(0.2)
    run_x(f"xdotool type --delay 70 '/n{tcode}'")
    time.sleep(0.3)
    run_x("xdotool key Return")
    time.sleep(3)
    
    out = f"/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/{filename}"
    cmd = f"DISPLAY=:99 xwd -id {win_id} -silent -out /tmp/{filename}.xwd && ffmpeg -y -i /tmp/{filename}.xwd -update 1 {out} 2>/dev/null"
    run_x(cmd)
    print(f"Saved: {out}, size={os.path.getsize(out) if os.path.exists(out) else 0}")

# Test with SU01
go_tcode("SU01", "live_su01_initial.png")
