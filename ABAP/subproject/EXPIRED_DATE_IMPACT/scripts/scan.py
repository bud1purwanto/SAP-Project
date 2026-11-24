import os,re,json,glob
pats={
 'ZZEXPIREDLIVE':r'ZZEXPIREDLIVE',
 'ATINN877':r"'0*877'",
 'FM_PRODDATE':r'Z_GET_PRODUCTION_DATE',
 'VFDAT':r'\bVFDAT\b',
 'HSDAT':r'\bHSDAT\b',
 'MHD':r'\bMHD(HB|RZ|LP|PHB)\b',
 'EXPIR':r'EXPIR',
 'BESTUSE':r'BEST\s*USE|USED?\s*BEFORE|USE\s*BY|SHELF',
 'D180':r'\+\s*180\b|\b180\s*\.',
 'SLED_FM':r'VB_MAINTAIN_SHELF_LIFE|VBDT_|SHELF_LIFE',
}
res={}
for f in glob.glob('all/*.abap'):
    n=os.path.basename(f)[:-5]
    lines=[l for l in open(f,errors='ignore').read().split('\n') if not l.lstrip().startswith('*') and not l.lstrip().startswith('"')]
    txt='\n'.join(lines).upper()
    hit={k:len(re.findall(p,txt)) for k,p in pats.items()}
    hit={k:v for k,v in hit.items() if v}
    if hit: res[n]=hit
json.dump(res,open('scan_result.json','w'),indent=1)
from collections import Counter
c=Counter(); [c.update(h.keys()) for h in res.values()]
print(len(res),c)
