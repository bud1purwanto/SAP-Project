import json, collections, re, glob, os
import numpy as np
from PIL import Image
O='/data/Projects/SAP/ABAP/subproject/COA/outputs/gui_test_all_20261118/'
def glyphs(im, box, thr=170):
    a=np.array(im.crop(box).convert('L'))
    dark=a<thr
    cols=dark.any(axis=0)
    out=[];x=0;n=len(cols)
    while x<n:
        if cols[x]:
            s=x
            while x<n and cols[x]: x+=1
            sub=dark[:,s:x]; rows=np.where(sub.any(axis=1))[0]
            sub=sub[rows[0]:rows[-1]+1]
            out.append((s+box[0], (rows[0]+box[1]), sub.shape, sub.tobytes()))
        else: x+=1
    return out
def segs(g):  # group into tokens by gap > 5px
    toks=[];cur=[]
    for gl in g:
        if cur and gl[0]-(cur[-1][0]+cur[-1][2][1])>6: toks.append(cur);cur=[]
        cur.append(gl)
    if cur: toks.append(cur)
    return toks
def cells():
    z5=json.load(open(O+'ocr_z5.json')); z2=json.load(open(O+'ocr_z2.json'))
    for k,d in z5.items():
        if not d: continue
        im=Image.open(O+'zqm005/'+k).convert('RGB')
        x0=int(d['mean'][0])-4
        for r in d['rows']:
            yield ('z5',k,r['y'],im,(x0,r["y"]-9,x0+100,r["y"]+9),r['toks'][-1] if len(r['toks'])>=3 else None)
    for k,d in z2.items():
        im=Image.open(O+'zqm002/'+k).convert('RGB')
        for r in d['rows']:
            v=r['v']
            yield ('z2',k,r['y'],im,(1238,r['y']-9,1306,r['y']+9),v[-1] if len(v)==3 else None)
if __name__=='__main__':
    votes=collections.defaultdict(collections.Counter)
    for kind,k,y,im,box,tok in cells():
        if not tok or not re.fullmatch(r'\d+(\.\d+)?',tok): continue
        g=glyphs(im,box)
        if len(g)!=len(tok): continue
        for gl,ch in zip(g,tok): votes[(gl[2],gl[3])][ch]+=1
    tmpl={}
    amb=0
    for key,c in votes.items():
        (ch,n),=c.most_common(1)
        if len(c)>1: amb+=1
        tmpl[key]=ch
    print(len(tmpl),'templates',amb,'ambiguous')
    chars=collections.Counter(tmpl.values()); print(chars)
    import pickle; pickle.dump(tmpl,open('/tmp/claude-1000/-data-Projects-SAP-ABAP/f652a661-609b-4c79-b0c2-40d8b6bf2445/scratchpad/tmpl.pkl','wb'))
