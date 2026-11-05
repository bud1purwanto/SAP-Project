"""Compare Y_ZBMBCSR (capture_wms.mjs JSON) vs baseline ALV (alv_to_md.py full CSV), 17 kolom WMS.
Usage: python3 compare_wms_vs_alv.py <baseline_full.csv> <wms_raw.json> <out.md> [hu]
  hu = baseline hanya baris dengan HU Box / HU Pallet (sesuai filter WMS 29.10.2026)
"""
import collections, csv, json, sys

base_csv, wms_json, out = sys.argv[1:4]
F = ['WERKS', 'MATNR', 'ZZTYPE', 'ZZTHICKNESS', 'CHARG', 'ZZWIDTH', 'ZZLENGTH', 'ZZALIAS', 'ZZCRITERIA',
     'LGORT', 'LGPLA', 'VBELN', 'POSNR', 'AUART', 'HUBOX', 'HUPLT', 'NAME1']
T = ['Plant', 'Material No', 'Type', 'Thick', 'Batch', 'Width', 'Length', 'TipeAlias', 'CriteriaGrade',
     'Sloc', 'Storage Bin', 'SO No', 'SO Item', 'Sales Doc Type', 'HU Box', 'HU Pallet', 'Customer Name']
KEY = [0, 1, 4, 9, 11, 12]

r = list(csv.reader(open(base_csv)))
idx = [r[0].index(f) for f in F]
base = [tuple(x[i].strip() for i in idx) for x in r[1:]]
if len(sys.argv) > 4 and sys.argv[4] == 'hu':
    base = [x for x in base if x[14] or x[15]]

d = json.load(open(wms_json))
w = d['writes']
rows, cur, runtime, total, wcount = [], None, '', '', ''
for i, z in enumerate(w):
    tag, _, body = z.partition('|')
    if tag in ('R', 'C'):
        nxt = w[i + 1] if i + 1 < len(w) else ''
        if nxt.startswith('C|'):
            body = body.ljust(250)
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
    elif tag == 'W':
        wcount = body.strip()
    elif tag == 'E':
        sys.exit('capture error: ' + body)
if cur is not None:
    rows.append(cur)
wms = [tuple(v.strip() for v in x.split('|')[:17]) for x in rows]

cb, cw = collections.Counter(base), collections.Counter(wms)
only_b, only_w = cb - cw, cw - cb

# per-column diff by key (only unique keys on both sides)
kb = collections.defaultdict(list)
kw = collections.defaultdict(list)
for x in base:
    kb[tuple(x[k] for k in KEY)].append(x)
for x in wms:
    kw[tuple(x[k] for k in KEY)].append(x)
coldiff = collections.Counter()
samples = collections.defaultdict(list)
for k in kb.keys() & kw.keys():
    if len(kb[k]) == 1 and len(kw[k]) == 1:
        a, b = kb[k][0], kw[k][0]
        for i in range(17):
            if a[i] != b[i]:
                coldiff[T[i]] += 1
                if len(samples[T[i]]) < 5:
                    samples[T[i]].append((k, a[i], b[i]))
missing_keys = len(kb.keys() - kw.keys())
extra_keys = len(kw.keys() - kb.keys())

ok = not only_b and not only_w
with open(out, 'w') as f:
    f.write('# Compare ZBMBC WMS (Y_ZBMBCSR) vs ALV Screen baseline\n\n')
    f.write(f'- Baseline ALV: {len(base)} baris ({base_csv})\n')
    f.write(f'- WMS Y_ZBMBCSR: {len(wms)} baris (N={total}); runtime SUBMIT WMS: {runtime} s; ZBMBCSR_WMS count setelah SP: {wcount}\n')
    f.write(f'- Hasil: **{"IDENTIK - tidak ada different" if ok else "ADA DIFFERENT"}**\n')
    f.write(f'- Baris hanya di ALV: {sum(only_b.values())}; baris hanya di WMS: {sum(only_w.values())}\n')
    f.write(f'- Key ALV tidak ada di WMS: {missing_keys}; key WMS tidak ada di ALV: {extra_keys}\n\n')
    if coldiff:
        f.write('## Selisih per kolom (key unik)\n\n| Kolom | Jumlah beda | Contoh (key, ALV, WMS) |\n|---|---|---|\n')
        for c, n in coldiff.most_common():
            f.write(f'| {c} | {n} | {"; ".join(str(s) for s in samples[c])} |\n')
        f.write('\n')
    for title, cnt in (('Hanya di ALV (max 50)', only_b), ('Hanya di WMS (max 50)', only_w)):
        if cnt:
            f.write(f'## {title}\n\n| ' + ' | '.join(T) + ' |\n|' + '---|' * 17 + '\n')
            for x in list(cnt.elements())[:50]:
                f.write('| ' + ' | '.join(x) + ' |\n')
            f.write('\n')
print('base', len(base), 'wms', len(wms), 'only_alv', sum(only_b.values()), 'only_wms', sum(only_w.values()),
      'coldiff', dict(coldiff), 'missing_keys', missing_keys, 'extra_keys', extra_keys, 'runtime', runtime, 'zbmbcsr_wms', wcount)
