import sys, json, re, glob, os
from rapidocr_onnxruntime import RapidOCR
from PIL import Image, ImageOps
import numpy as np
ocr=RapidOCR(intra_op_num_threads=2)
O='/data/Projects/SAP/ABAP/subproject/COA/outputs/gui_test_all_20261118'
def ocr_img(im, sc):
    c=im.convert('L'); c=c.resize((c.width*sc,c.height*sc),Image.BICUBIC)
    c=ImageOps.expand(c,border=20,fill=255)
    res,_=ocr(np.array(c.convert('RGB')))
    out=[]
    for b,t,s in (res or []):
        out.append(((b[0][0]-20)/sc,(b[0][1]-20)/sc,(b[2][0]-20)/sc,(b[2][1]-20)/sc,t))
    return sorted(out)
def toks_row(im,x1,x2,yc,h=11,scs=(6,4)):
    best=[]
    for sc in scs:
        t=[a[4] for a in ocr_img(im.crop((x1,yc-h,x2,yc+h)),sc)]
        if len(t)>len(best): best=t
    return best
def p5(path):
    im=Image.open(path).convert('RGB')
    toksA=ocr_img(im.crop((560,158,1320,800)),3)
    rows={}; hdr=None
    for x1,y1,x2,y2,t in toksA:
        y1+=158;y2+=158;x1+=560;x2+=560
        if 'Mean' in t and y1<175: hdr=(x1,x2)
        if (y1+y2)/2<175: continue
        rows.setdefault(round(((y1+y2)/2-187)/20),[]).append((x1,t))
    if not hdr: return None
    xa=max(hdr[0]-110,700); xb=min(hdr[1]+40,1320)
    toksB=ocr_img(im.crop((xa,176,xb,800)),5)
    nums={}
    for x1,y1,x2,y2,t in toksB:
        yc=176+(y1+y2)/2
        nums.setdefault(round((yc-187)/20),[]).append((x1,t))
    out=[]
    for k in sorted(rows):
        r=sorted(rows[k])
        name=' '.join(t for x,t in r if re.search('[A-Za-z]{3}',t) and x>600)
        out.append(dict(y=187+k*20,name=name,toks=[t for x,t in sorted(nums.get(k,[]))]))
    return dict(mean=hdr,rows=out)
def p2(path, n):
    im=Image.open(path).convert('RGB')
    h=28*n+16
    A=ocr_img(im.crop((1100,210,1310,210+h)),5)
    B=ocr_img(im.crop((189,210,372,210+h)),5)
    C=ocr_img(im.crop((372,210,700,210+h)),4)
    rows={}
    for key,T,x0 in (('v',A,1100),('m',B,189),('d',C,372)):
        for x1,y1,x2,y2,t in T:
            k=round((210+(y1+y2)/2-224)/28)
            rows.setdefault(k,{}).setdefault(key,[]).append((x1,t))
    out=[]
    for k in range(n):
        r=rows.get(k,{})
        out.append(dict(y=224+28*k,v=[t for x,t in sorted(r.get('v',[]))],m=[t for x,t in sorted(r.get('m',[]))],d=[t for x,t in sorted(r.get('d',[]))]))
    return dict(rows=out)
if __name__=='__main__':
    kind=sys.argv[1]
    import collections
    M=json.load(open('/tmp/claude-1000/-data-Projects-SAP-ABAP/f652a661-609b-4c79-b0c2-40d8b6bf2445/scratchpad/model.json'))['rows']
    NROWS=collections.Counter()
    seen=set()
    for r in M:
        if (r['do'],r['mic']) not in seen: seen.add((r['do'],r['mic'])); NROWS[r['do']]+=1
    cache=O+'/ocr_%s.json'%kind
    d=json.load(open(cache)) if os.path.exists(cache) else {}
    for p in sorted(glob.glob(O+'/zqm005/z5_*.png')) if kind=='z5' else sorted(glob.glob(O+'/zqm002/z2_*.png')):
        k=os.path.basename(p)
        if k in d: continue
        d[k]=p5(p) if kind=='z5' else p2(p, NROWS[k[3:13]])
        print(k,flush=True)
        json.dump(d,open(cache,'w'))
