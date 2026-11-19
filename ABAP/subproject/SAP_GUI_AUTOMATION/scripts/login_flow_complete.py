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
    print("Initial windows:", [w["title"] for w in wins])

    main_win = None
    for w in wins:
        if "SAP GUI for Java" in w["title"]:
            main_win = w["window_id"]
            break

    if not main_win:
        print("SAP GUI for Java not found!")
        return

    # 1. Bring main window to front & click Connect
    run(f"xdotool windowactivate --sync {main_win}")
    time.sleep(0.5)
    # Click Connect button at x=35, y=50
    run(f"xdotool mousemove --window {main_win} 35 50 click 1")
    time.sleep(2)

    # 2. Wait for ADB window
    adb_win = None
    for _ in range(10):
        wins = list_wins()
        for w in wins:
            if "ADB" in w["title"]:
                adb_win = w["window_id"]
                break
        if adb_win: break
        time.sleep(0.5)

    if not adb_win:
        print("ADB window did not open!")
        return

    print("ADB window found:", adb_win)
    run(f"xdotool windowactivate --sync {adb_win}")
    time.sleep(0.5)

    # In ADB window, User field has initial focus.
    # Shift+Tab to Client
    run("xdotool key shift+Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace Delete Delete")
    time.sleep(0.2)
    run("xdotool type --delay 60 '130'")
    time.sleep(0.2)

    # Tab to User
    run("xdotool key Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.2)
    run("xdotool type --delay 60 'TRSTABAP'")
    time.sleep(0.2)

    # Tab to Password
    run("xdotool key Tab")
    time.sleep(0.2)
    run("xdotool key End BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace BackSpace Delete Delete Delete")
    time.sleep(0.2)
    run("xdotool type --delay 60 'supporter'")
    time.sleep(0.2)

    # Press Enter
    run("xdotool key Return")
    time.sleep(3)

    # 3. Check for License dialog or Easy Access
    wins = list_wins()
    print("Post-enter windows:", [w["title"] for w in wins])

    license_win = None
    for w in wins:
        if "License" in w["title"]:
            license_win = w["window_id"]
            break

    if license_win:
        print("Handling License popup:", license_win)
        run(f"xdotool windowactivate --sync {license_win}")
        time.sleep(0.5)
        # In this dialog, Option 3 is selected by default.
        # Press Up arrow to move to Option 2 ("Continue without ending other logons")
        run("xdotool key Up")
        time.sleep(0.3)
        # Press Return to submit
        run("xdotool key Return")
        time.sleep(4)

    # Check windows again
    wins = list_wins()
    print("Final windows:", [w["title"] for w in wins])

    # Find the active SAP session window
    session_win = None
    for w in wins:
        if "ADB" in w["title"] or "SAP Easy Access" in w["title"]:
            session_win = w["window_id"]
            break

    if session_win:
        sock = "/home/abap/.cache/cua-driver/cua-driver-sap.sock"
        cmd_shot = f"/home/abap/.local/bin/cua-driver --socket {sock} call get_window_state '{{\"pid\":11474,\"window_id\":{session_win},\"screenshot_out_file\":\"/tmp/login_success.png\"}}'"
        run(cmd_shot)
        run("cp /tmp/login_success.png /data/Projects/SAP/ABAP/subproject/S4HANA_DATA_MIGRATION/docs/attachments/13_login_success.png")
        print("Screenshot saved to /tmp/login_success.png")

if __name__ == '__main__':
    main()
