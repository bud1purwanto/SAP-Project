import sys, collections
def parse(f):
    a, q, do = {}, {}, None
    for l in open(f, encoding='utf8'):
        l = l.rstrip('\n').strip()
        if l.startswith('###'): do = l.split()[1]; continue
        if l.startswith('#A|'):
            p = l.split('|'); a.setdefault((p[1], p[2], p[5]), set()).add(p[6])
        elif l.startswith('|') and do:
            p = l.split('|'); q[(p[1], p[2], p[5])] = p[6]
    return a, q
ab, qb = parse(sys.argv[1]); an, qn = parse(sys.argv[2])
chg = sorted(k for k in ab if ab[k] != an.get(k))
print('MIC berubah:', len(chg))
for k in chg:
    print(k[0], k[1], k[2], 'before', '/'.join(sorted(ab[k])), 'after', '/'.join(sorted(an[k])), 'ZQM002', qn.get(k))
neq = [k for k in an if k in qn and an[k] != {qn[k]}]
print('ZQM003 setelah fix != ZQM002:', len(neq))
for k in sorted(neq): print('  ', k, an[k], qn[k])
