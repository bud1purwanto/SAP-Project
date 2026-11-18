import re, json

with open('/data/Projects/SAP/ABAP/subproject/COA/outputs/MT_20261118_dev_after_543.txt', 'r', encoding='latin-1') as f:
    mt_lines = f.readlines()

with open('/data/Projects/SAP/ABAP/subproject/COA/outputs/LIMIT_20261118_dev_after_543.txt', 'r', encoding='latin-1') as f:
    limit_lines = f.readlines()

dos_data = {}
current_do = None

for line in mt_lines:
    line = line.strip()
    if line.startswith('###'):
        current_do = line.replace('#', '').strip()
        if current_do not in dos_data:
            dos_data[current_do] = {'material': '', 'mics': [], 'limits': {}}
    elif line.startswith('|') and current_do:
        parts = [p.strip() for p in line.split('|')]
        if len(parts) >= 8:
            vbeln = parts[1]
            matnr = parts[2]
            flag = parts[3]
            seq = parts[4]
            char_id = parts[5]
            val = parts[6]
            lot = parts[7]
            dos_data[current_do]['material'] = matnr
            dos_data[current_do]['mics'].append({
                'seq': seq,
                'char_id': char_id,
                'val': val,
                'lot': lot
            })

for line in limit_lines:
    line = line.strip()
    if line.startswith('#L|'):
        parts = [p.strip() for p in line.split('|')]
        if len(parts) >= 7:
            vbeln = parts[1]
            char_id = parts[4]
            low = parts[5]
            up = parts[6]
            if vbeln in dos_data:
                dos_data[vbeln]['limits'][char_id] = (low, up)

print(f'Parsed {len(dos_data)} DOs successfully:')
for d, info in dos_data.items():
    m = info.get('material')
    cnt = len(info.get('mics', []))
    lim_cnt = len(info.get('limits', {}))
    print(f'DO {d}: Material={m}, Total MICs={cnt}, Limits={lim_cnt}')

with open('/tmp/dos_data_parsed.json', 'w') as f:
    json.dump(dos_data, f, indent=2)
