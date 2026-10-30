"""Compare ZMMI_WMS ALV capture vs ZBMBC baseline wms17.md per kolom.
Usage: python3 compare_vs_zbmbc.py <zmmi_raw.json> <zbmbc_wms17.md> <out.md> "<param text>"
"""
import json, sys
from collections import defaultdict, Counter
raw, base_md, out, params = sys.argv[1:5]
COLS = ['WERKS','MATNR','ZZTYPE','ZZTHICKNESS','CHARG','ZZWIDTH','ZZLENGTH','ZZALIAS','ZZCRITERIA',
        'LGORT','LGPLA','VBELN','POSNR','AUART','HUBOX','HUPLT','NAME1']
TXT = ['Plant','Material No','Type','Thick','Batch','Width','Length','TipeAlias','CriteriaGrade','Sloc',
       'Storage Bin','SO No','SO Item','Sales Doc Type','HU Box','HU Pallet','Customer Name']
KEY = [0,1,4,9,11,12]   # WERKS MATNR CHARG LGORT VBELN POSNR

w = json.load(open(raw))['writes']
heads, rows, cur, rt, tot = [], [], None, '', ''
for i, z in enumerate(w):
    tag, _, body = z.partition('|')
    if tag == 'H': heads.append(body.strip())
    elif tag in ('R','C'):
        if i + 1 < len(w) and w[i+1].startswith('C|'): body = body.ljust(250)
        if tag == 'R':
            if cur is not None: rows.append(cur)
            cur = body
        else: cur += body
    elif tag == 'T': rt = body.strip()
    elif tag == 'N': tot = body.strip()
if cur is not None: rows.append(cur)
ix = [heads.index(c) for c in COLS]
zm = [[r.split('|')[i].strip() for i in ix] for r in rows]

base = []
for l in open(base_md):
    if not l.startswith('| ') or l.startswith('| Plant') or l.startswith('| Kolom'): continue
    c = [x.strip() for x in l.strip().strip('|').split('|')]
    if len(c) == 17: base.append(c)

def norm(v, j):
    v = v.strip()
    if j in (5, 6):   # width/length: angka
        v = v.replace(',', '').replace('.', '') if v else v
    if j == 12 and v == '': v = '000000'
    return v

zm_sr = [r for r in zm if r[1].startswith('SR')]
bk = defaultdict(list)
for r in base: bk[tuple(r[j] for j in KEY)].append(r)
bcharg = defaultdict(list)
for r in base: bcharg[(r[0], r[1], r[4])].append(r)

diff = Counter(); ex = defaultdict(list); same_rows = 0; nokey = []; nobatch = []; matched = 0
for r in zm_sr:
    k = tuple(r[j] for j in KEY)
    cand = bk.get(k)
    if not cand:
        (nokey if bcharg.get((r[0], r[1], r[4])) else nobatch).append(r); continue
    matched += 1
    # pilih kandidat dengan beda paling sedikit (multi HU per batch)
    best = min(cand, key=lambda b: sum(norm(b[j], j) != norm(r[j], j) for j in range(17)))
    d = [j for j in range(17) if norm(best[j], j) != norm(r[j], j)]
    if not d: same_rows += 1
    for j in d:
        diff[j] += 1
        if len(ex[j]) < 5: ex[j].append((r[4], best[j], r[j]))

with open(out, 'w') as f:
    f.write('# Compare ZMMI_WMS vs ZBMBC baseline (17 kolom WMS)\n\n')
    f.write(f'- Sistem: Development AIX (TRD)\n- ZMMI_WMS parameter: {params}\n')
    f.write(f'- ZMMI_WMS runtime SUBMIT: {rt} s; baris ALV: {tot}; baris material SR*: {len(zm_sr)}\n')
    f.write(f'- Baseline ZBMBC: {base_md.split("/")[-1]} ({len(base)} baris, SR*, capture 28.10.2026)\n')
    f.write(f'- Key match: WERKS MATNR CHARG LGORT VBELN POSNR\n\n')
    f.write('## Ringkasan\n\n')
    f.write(f'- Baris ZMMI_WMS (SR*) ketemu key di ZBMBC: {matched}\n')
    f.write(f'- Identik 17 kolom: {same_rows}\n')
    f.write(f'- Batch ada di ZBMBC tapi key beda (Sloc/SO berubah): {len(nokey)}\n')
    f.write(f'- Batch tidak ada di baseline ZBMBC: {len(nobatch)}\n\n')
    f.write('## Selisih per kolom (baris yang key-nya match)\n\n| Kolom | Beda | Contoh (Batch, ZBMBC, ZMMI_WMS) |\n|---|---|---|\n')
    for j in range(17):
        e = '; '.join(f'{a}: `{b}` vs `{c}`' for a, b, c in ex[j])
        f.write(f'| {TXT[j]} | {diff[j]} | {e} |\n')
    for title, lst in (('Key beda (max 30)', nokey), ('Batch tidak ada di baseline (max 30)', nobatch)):
        f.write(f'\n## {title}\n\n| ' + ' | '.join(TXT) + ' | ZBMBC (Sloc/SO/HU Box/HU Pallet) |\n|' + '---|' * 18 + '\n')
        for r in lst[:30]:
            b = bcharg.get((r[0], r[1], r[4]), [])
            bs = '; '.join(f'{x[9]}/{x[11]}/{x[14]}/{x[15]}' for x in b[:3])
            f.write('| ' + ' | '.join(r) + f' | {bs} |\n')
print('zm', len(zm), 'sr', len(zm_sr), 'base', len(base), 'matched', matched, 'same', same_rows,
      'nokey', len(nokey), 'nobatch', len(nobatch), dict((COLS[j], n) for j, n in diff.items()))
