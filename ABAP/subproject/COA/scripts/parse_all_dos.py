import re, json

with open('/data/Projects/SAP/ABAP/subproject/COA/outputs/MT_20261118_dev_after_543.txt', 'r', encoding='latin-1') as f:
    mt_text = f.read()

# Let's inspect sections in MT text
dos_data = {}
sections = re.split(r'={20,}', mt_text)
print(f'Total sections: {len(sections)}')

# Let's inspect the first 3 sections
for i, s in enumerate(sections[:4]):
    print(f'--- SECTION {i} ---')
    print(s[:300])

