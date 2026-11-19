import subprocess
import json

p = subprocess.Popen(
    ['/home/abap/.local/bin/cua-driver', '--socket', '/home/abap/.cache/cua-driver/cua-driver-sap.sock', 'call', 'get_window_state'],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
)
out, _ = p.communicate(json.dumps({'pid': 1288533, 'window_id': 35651634}))
data = json.loads(out)
elements = data.get('elements', [])
print(f"Total elements: {len(elements)}")
for i, el in enumerate(elements):
    role = el.get('role', '')
    name = el.get('name', '')
    bounds = el.get('bounds', {})
    if any(k in role.lower() for k in ['table', 'cell', 'text', 'entry', 'edit', 'input']) or any(k in name.lower() for k in ['sloc', 'plant', 'desc', 'storage']):
        print(f"[{i}] role={role} name='{name}' bounds={bounds}")
