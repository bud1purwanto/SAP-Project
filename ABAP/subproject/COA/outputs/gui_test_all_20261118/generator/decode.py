import pickle, json
from glyph import *
tm=pickle.load(open('/tmp/claude-1000/-data-Projects-SAP-ABAP/f652a661-609b-4c79-b0c2-40d8b6bf2445/scratchpad/tmpl.pkl','rb'))
def read(im,box):
    g=glyphs(im,box)
    if not g: return ''
    s=''
    for gl in g:
        c=tm.get((gl[2],gl[3]))
        if c is None: return '?'
        s+=c
    return s
z5=json.load(open(O+'ocr_z5.json')); z2=json.load(open(O+'ocr_z2.json'))
R={'z5':{},'z2':{}}
unk=0
for k,d in z5.items():
    if not d: continue
    im=Image.open(O+'zqm005/'+k).convert('RGB'); x0=int(d['mean'][0])-4
    R['z5'][k]=[dict(y=r['y'],name=r['name'],mean=read(im,(x0,r['y']-9,x0+100,r['y']+9))) for r in d['rows']]
    unk+=sum(1 for r in R['z5'][k] if r['mean']=='?')
for k,d in z2.items():
    im=Image.open(O+'zqm002/'+k).convert('RGB')
    R['z2'][k]=[dict(y=r['y'],low=read(im,(1108,r['y']-9,1172,r['y']+9)),up=read(im,(1174,r['y']-9,1238,r['y']+9)),val=read(im,(1240,r['y']-9,1306,r['y']+9)),mic=r['m'],desc=r['d']) for r in d['rows']]
    unk+=sum(1 for r in R['z2'][k] if '?' in (r['low'],r['up'],r['val']))
json.dump(R,open(O+'read.json','w'))
print('unknown cells',unk)
for k in ('z2_0085006285.png','z2_0085006240.png'):
    for r in R['z2'][k]: print(k,r['mic'][-1:],r['low'],r['up'],r['val'])
