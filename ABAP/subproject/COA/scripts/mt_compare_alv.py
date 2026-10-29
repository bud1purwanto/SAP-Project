#!/usr/bin/env python3
"""Bandingkan output harness ZQM003 (|VBELN|MATNR|POSNR|CHARG|MIC|CMICMIT|INS) dengan dataset .md.
Nilai ZQM003 per (DO, MIC) sama untuk semua baris; dibandingkan per (DO, MIC)."""
import re, sys, pathlib
base = pathlib.Path(__file__).resolve().parent.parent
exp = {}
for line in (base / 'docs/data_inspeksi_sap_gabungan.md').read_text(encoding='utf8').splitlines():
    c = [x.strip() for x in line.strip().strip('|').split('|')]
    if len(c) >= 15 and c[0].isdigit() and re.fullmatch(r'\d{10}', c[1]):
        exp[(c[1], c[6])] = (c[12], c[0])
got = {}
for line in pathlib.Path(sys.argv[1]).read_text().splitlines():
    if line.startswith('|'):
        c = line.strip('|').split('|')
        if len(c) >= 7:
            got.setdefault((c[0], c[4]), set()).add((c[5], c[6]))
def num(v):
    v = v.strip()
    if v in ('-', ''): return None
    try: return float(v)
    except ValueError: return v
ok = bad = 0
for (d, mic), (ev, no) in sorted(exp.items()):
    g = got.get((d, mic))
    if not g:
        bad += 1; print(f'BEDA {d} {mic:9s} baris#{no} ekspektasi={ev} program=TIDAK ADA'); continue
    vals = {v for v, _ in g}
    gv = sorted(vals)[0]
    e, gg = num(ev), num(gv)
    if len(vals) == 1 and (e == gg or (e is None and gg == 0.0)): ok += 1
    else:
        bad += 1; print(f'BEDA {d} {mic:9s} baris#{no} ekspektasi={ev:>7s} program={"/".join(sorted(vals))} lot={sorted({l for _, l in g})}')
print(f'\nCOCOK {ok} / {ok+bad}  (ZQM003, "-" di dataset = 0 di program)')
