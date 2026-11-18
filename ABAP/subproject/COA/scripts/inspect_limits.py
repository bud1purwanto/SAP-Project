with open('/data/Projects/SAP/ABAP/subproject/COA/outputs/LIMIT_20261118_dev_after_543.txt', 'r', encoding='latin-1') as f:
    lim_text = f.read()

lines = lim_text.splitlines()
for l in lines[:25]:
    print(l)
