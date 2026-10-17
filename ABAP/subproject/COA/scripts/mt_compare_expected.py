#!/usr/bin/env python3
"""Bandingkan output harness (### DO / |VBELN|MATNR|CHK|NUM|MIC|CMICMIT|INSLOT) dengan
docs/data_inspeksi_sap_gabungan.md (tabel master 119 baris)."""
import re, sys, pathlib
base = pathlib.Path(__file__).resolve().parent.parent
exp = {}
for line in (base / 'docs/data_inspeksi_sap_gabungan.md').read_text(encoding='utf8').splitlines():
    c = [x.strip() for x in line.strip().strip('|').split('|')]
    if len(c) >= 15 and c[0].isdigit() and re.fullmatch(r'\d{10}', c[1]):
        exp[(c[1], c[6])] = c[12]
got = {}
for line in pathlib.Path(sys.argv[1]).read_text().splitlines():
    if line.startswith('|'):
        c = line.strip('|').split('|')
        if len(c) >= 7:
            got[(c[0], c[4])] = (c[5], c[6])
def norm(v):
    v = v.strip()
    if v in ('-', ''): return None
    try: return float(v)
    except ValueError: return v
ok = bad = 0
dos = sorted({d for d, _ in exp})
for d in dos:
    for (dd, mic), ev in sorted(exp.items()):
        if dd != d: continue
        g = got.get((d, mic))
        gv = g[0] if g else 'TIDAK ADA'
        e, gg = norm(ev), norm(gv) if g else 'X'
        same = (e == gg) or (e is None and gg == 0.0)
        if same: ok += 1
        else:
            bad += 1
            print(f'BEDA {d} {mic:9s} ekspektasi={ev:>7s} program={gv:>7s} lot={g[1] if g else "-"}')
    extra = [m for (dd, m) in got if dd == d and (d, m) not in exp]
    if extra: print(f'EXTRA {d}: MIC di program tapi tidak di dataset: {extra}')
print(f'\nCOCOK {ok} / {ok+bad}  (nilai "-" di dataset dianggap = 0 di program)')
