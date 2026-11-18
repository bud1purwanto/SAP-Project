import re

with open('/data/Projects/SAP/ABAP/subproject/COA/outputs/MT_20261118_dev_after_543.txt', 'r', encoding='latin-1') as f:
    content = f.read()

# Find all DO blocks
lines = content.splitlines()
dos = []
cur_do = None
for l in lines:
    if 'VBELN' in l or 'Delivery' in l or 'DO' in l:
        pass
    m = re.search(r'0085006\d{3}', l)
    if m:
        d = m.group(0)
        if d not in dos:
            dos.append(d)

print(f'Total DOs found: {len(dos)}')
print(dos)
