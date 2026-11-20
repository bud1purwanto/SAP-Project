import os, time, subprocess

def run_x(cmd):
    env = dict(os.environ)
    env["DISPLAY"] = ":99"
    return subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)

win_id = 46137391

def snap(filename):
    out = f"/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/attachments/{filename}"
    cmd = f"DISPLAY=:99 xwd -id {win_id} -silent -out /tmp/{filename}.xwd && ffmpeg -y -i /tmp/{filename}.xwd -update 1 {out} 2>/dev/null"
    run_x(cmd)
    print(f"Captured: {out} ({os.path.getsize(out)} bytes)")

def nav(tcode):
    print(f"\n--- Navigating to /n{tcode} ---")
    run_x(f"xdotool windowactivate {win_id}")
    time.sleep(0.3)
    run_x("xdotool mousemove 70 53 click 1")
    time.sleep(0.2)
    run_x("xdotool key ctrl+a BackSpace")
    time.sleep(0.2)
    run_x(f"xdotool type --delay 60 '/n{tcode}'")
    time.sleep(0.2)
    run_x("xdotool key Return")
    time.sleep(3)

# 1. SE16N with EKPO
nav("SE16N")
# type EKPO in table field (cursor is default in table field)
run_x("xdotool key ctrl+a BackSpace")
time.sleep(0.2)
run_x("xdotool type --delay 60 'EKPO'")
time.sleep(0.3)
# tab to Max hits or press F8
run_x("xdotool key F8")
time.sleep(3)
snap("live_se16n_ekpo_10_hits.png")

# 2. ME23N (Display Purchase Order)
nav("ME23N")
time.sleep(2)
snap("live_me23n_display_po.png")

# 3. /IWFND/MAINT_SERVICE
nav("/IWFND/MAINT_SERVICE")
time.sleep(4)
snap("live_gateway_maint_service.png")

# 4. SICF
nav("SICF")
time.sleep(2)
# press F8 (Execute) to show hierarchy
run_x("xdotool key F8")
time.sleep(3)
snap("live_sicf_service_tree.png")

print("\nAll SAP GUI live screenshots captured successfully!")
