"""Convert capture_alv.mjs JSON -> markdown (full visible ALV + WMS 17-column subset) + CSV.
Usage: python3 alv_to_md.py <raw.json> <out_prefix> "<param text>"
"""
import csv, json, sys

raw, prefix, params = sys.argv[1], sys.argv[2], sys.argv[3]
d = json.load(open(raw))
w = d['writes']
heads, rows, cur, runtime, total = [], [], None, '', ''
for i, z in enumerate(w):
    tag, _, body = z.partition('|')
    if tag == 'H':
        f = body.split('|')
        heads.append({'name': f[0], 'text': f[1] if len(f) > 1 else '', 'no_out': f[2] if len(f) > 2 else '', 'tech': f[3] if len(f) > 3 else ''})
    elif tag in ('R', 'C'):
        nxt = w[i + 1] if i + 1 < len(w) else ''
        if nxt.startswith('C|'):
            body = body.ljust(250)          # WRITES trims trailing blanks of non-final chunk
        if tag == 'R':
            if cur is not None:
                rows.append(cur)
            cur = body
        else:
            cur += body
    elif tag == 'T':
        runtime = body.strip()
    elif tag == 'N':
        total = body.strip()
    elif tag == 'E':
        sys.exit('capture error: ' + body)
if cur is not None:
    rows.append(cur)

vis = [h for h in heads if not h['no_out'].strip() and not h['tech'].strip()]
data = [r.split('|')[:len(vis)] for r in rows]
names = [h['name'] for h in vis]

WMS = [('WERKS', 'Plant'), ('MATNR', 'Material No'), ('ZZTYPE', 'Type'), ('ZZTHICKNESS', 'Thick'),
       ('CHARG', 'Batch'), ('ZZWIDTH', 'Width'), ('ZZLENGTH', 'Length'), ('ZZALIAS', 'TipeAlias'),
       ('ZZCRITERIA', 'CriteriaGrade'), ('LGORT', 'Sloc'), ('LGPLA', 'Storage Bin'), ('VBELN', 'SO No'),
       ('POSNR', 'SO Item'), ('AUART', 'Sales Doc Type'), ('HUBOX', 'HU Box'), ('HUPLT', 'HU Pallet'),
       ('NAME1', 'Customer Name')]
missing = [f for f, _ in WMS if f not in names]

def md_cell(v):
    return v.replace('|', '/').strip()

def write_md(path, title, cols, rws, note=''):
    with open(path, 'w') as f:
        f.write(f'# {title}\n\n')
        f.write(f'- Sistem: Development AIX (TRD), T-Code ZBMBC / ZBAP_STOCK_BY_CHAR1, Execution Type Screen\n')
        f.write(f'- Parameter: {params}\n')
        f.write(f'- Runtime SUBMIT: {runtime} s; jumlah baris ALV: {total}\n')
        if note:
            f.write(f'- {note}\n')
        f.write('\n| ' + ' | '.join(cols) + ' |\n')
        f.write('|' + '---|' * len(cols) + '\n')
        for r in rws:
            f.write('| ' + ' | '.join(md_cell(v) for v in r) + ' |\n')

write_md(prefix + '_full.md', 'ZBMBC ALV Baseline (before) - kolom tampil', [f"{h['text']} ({h['name']})" for h in vis], data)
with open(prefix + '_full.csv', 'w', newline='') as f:
    cw = csv.writer(f)
    cw.writerow(names)
    cw.writerows(data)

idx = [names.index(f) for f, _ in WMS if f in names]
sub = sorted(([r[i].strip() for i in idx] for r in data), key=lambda r: tuple(r))
note = 'Subset 17 kolom WMS (urutan kolom Y_ZBMBCSR), diurutkan per baris untuk compare.'
if missing:
    note += ' Kolom tidak ada di fieldcat ALV: ' + ', '.join(missing)
write_md(prefix + '_wms17.md', 'ZBMBC ALV Baseline (before) - 17 kolom WMS', [t for f, t in WMS if f in names], sub, note)
print('heads', len(heads), 'visible', len(vis), 'rows', len(rows), 'total', total, 'runtime', runtime, 'missing', missing)
