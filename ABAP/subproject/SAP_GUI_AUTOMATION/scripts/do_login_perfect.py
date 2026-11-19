import os
import time
import subprocess
import json

def run(cmd):
    print("RUN:", cmd)
    env = dict(os.environ)
    env["DISPLAY"] = ":99"
    res = subprocess.run(cmd, shell=True, capture_output=True, text=True, env=env)
    if res.stdout: print("OUT:", res.stdout.strip())
    if res.stderr: print("ERR:", res.stderr.strip())
    return res

def list_wins():
    sock = "/home/abap/.cache/cua-driver/cua-driver-sap.sock"
    cmd = f"/home/abap/.local/bin/cua-driver --socket {sock} call list_windows '{{}}'"
    r = run(cmd)
    try:
        data = json.loads(r.stdout)
        return data.get("windows", [])
    except Exception:
        return []

def main():
    wins = list_wins()
    main_win = None
    gui_pid = 1186032
    for w in wins:
        if "SAP GUI for Java" in w["title"]:
            main_win = w["window_id"]
            gui_pid = w["pid"]
            break

    if not main_win:
        print("SAP GUI not found")
        return

    print(f"Connecting via main_win={main_win}, pid={gui_pid}")
    run(f"xdotool windowactivate --sync {main_win}")
    time.sleep(0.5)
    run(f"xdotool mousemove --window {main_win} 35 50 click 1")
    time.sleep(2)

    # 2. Wait for ADB logon window
    adb_win = None
    for _ in range(15):
        for w in list_wins():
            if "ADB" in w["title"]:
                adb_win = w["window_id"]
                gui_pid = w["pid"]
                break
        if adb_win: break
        time.sleep(0.5)

    if not adb_win:
        print("ADB window not found!")
        return

    print("ADB logon window:", adb_win)
    run(f"xdotool windowmove {adb_win} 0 0")
    run(f"xdotool windowactivate --sync {adb_win}")
    time.sleep(0.5)

    # Shift+Tab to Client
    run("xdotool key shift+Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete")
    time.sleep(0.1)
    run("xdotool type --delay 60 '130'")
    time.sleep(0.2)

    # Tab to User
    run("xdotool key Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.1)
    run("xdotool type --delay 60 'TRSTABAP'")
    time.sleep(0.2)

    # Tab to Password
    run("xdotool key Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.1)
    run("xdotool type --delay 60 'supporter'")
    time.sleep(0.2)

    # Tab to Language
    run("xdotool key Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete")
    time.sleep(0.1)
    run("xdotool type --delay 60 'EN'")
    time.sleep(0.2)

    # Submit login
    run("xdotool key Return")
    time.sleep(3)

    # 3. Check for License dialog
    license_win = None
    for _ in range(8):
        for w in list_wins():
            if "License" in w["title"]:
                license_win = w["window_id"]
                gui_pid = w["pid"]
                break
        if license_win: break
        time.sleep(0.5)

    if license_win:
        print("License popup detected:", license_win)
        run(f"xdotool windowmove {license_win} 0 0")
        run(f"xdotool windowactivate --sync {license_win}")
        time.sleep(0.5)

        # Click Radio 2 circle at (x=26, y=354)
        run(f"xdotool mousemove --window {license_win} 26 354 click 1")
        time.sleep(0.5)
        run("xdotool key space")
        time.sleep(0.5)

        # Click Enter button at x=1360, y=862
        run(f"xdotool mousemove --window {license_win} 1360 862 click 1")
        time.sleep(1)
        run("xdotool key Return")
        time.sleep(5)

    # 4. Check final windows
    final_wins = list_wins()
    print("Final windows:", [w["title"] for w in final_wins])
    for w in final_wins:
        wid = w["window_id"]
        title = w["title"]
        if "ADB" in title or "Easy Access" in title:
            print("Session window:", title, "id:", wid)
            sock = "/home/abap/.cache/cua-driver/cua-driver-sap.sock"
            shot_cmd = f'/home/abap/.local/bin/cua-driver --socket {sock} call get_window_state \'{{"pid":{gui_pid},"window_id":{wid},"screenshot_out_file":"/tmp/sap_logged_in.png"}}\''
            run(shot_cmd)
            run("cp /tmp/sap_logged_in.png /data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/24_login_restored.png")

if __name__ == '__main__':
    main()
