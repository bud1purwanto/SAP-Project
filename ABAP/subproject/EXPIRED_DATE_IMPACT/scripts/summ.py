import json,re
res=json.load(open('scan_result.json')); mp=json.load(open('map_all.json'))
rows=[]
for n,h in sorted(res.items()):
    src=open(f'all/{n}.abap',errors='ignore').read().split('\n')
    code=[(i+1,l) for i,l in enumerate(src) if not l.lstrip().startswith('*')]
    f=[]
    for i,l in code:
        u=l.upper().split('"')[0]
        if re.search(r'=\s*[\w<>\-]+\s*\+\s*\(?\s*[\w<>\-]+',u) and re.search(r'EXP|LIVE|LIFE|ATFLV|DEXDT|VFDAT|EDATE|ZEXP|GRDATE|BEST|USED',u):
            f.append(f'L{i}: '+re.sub(r'\s+',' ',l.strip())[:90])
    pl=sorted(set(re.findall(r"\b(?:WERKS|BUKRS|BWKEY|P_WERKS|S_WERKS|PLANT)\b[^'\n]{0,25}'(\w{3,4})'",'\n'.join(l for _,l in code).upper())))
    m=mp.get(n,{}); t=m.get('trdir',{})
    tcs=sorted({x for v in m.get('tc',{}).values() for x in v if x})
    rows.append(dict(obj=n,subc=t.get('SUBC',''),udat=t.get('UDAT',''),masters=m.get('masters',[]),tcodes=tcs,hits=h,formula=f[:4],plants=pl))
json.dump(rows,open('summary.json','w'),indent=1)
for r in rows:
    if 'ZZEXPIREDLIVE' in r['hits'] or r['formula']:
        print(r['obj'],r['subc'],r['udat'],'M=',','.join(r['masters'][:3]),'T=',','.join(r['tcodes']),'P=',','.join(r['plants']),'|',' ; '.join(r['formula'][:2]))
