import urllib.request, base64

url = "http://192.168.1.199:8080/sap/opu/odata/IWFND/CATALOGSERVICE;v=2/Annotations(TechnicalName='MM_PUR_POITEMS_MONI_ANNO_MDL',Version='0001')/$value?sap-client=130"
req = urllib.request.Request(url)
req.add_header('Authorization', 'Basic ' + base64.b64encode(b'TRSTABAP:supporter').decode('ascii'))
resp = urllib.request.urlopen(req)
content = resp.read().decode('utf-8')
print("Annotation file length:", len(content))

import re
# Check for UI.SelectionVariant or default filters
sel_variants = re.findall(r'<Annotation Term="UI.SelectionVariant".*?</Annotation>', content, re.DOTALL)
print(f"Total UI.SelectionVariant: {len(sel_variants)}")
for sv in sel_variants:
    print(sv[:500])

# Check for UI.SelectionFields
sel_fields = re.findall(r'<Annotation Term="UI.SelectionFields".*?</Annotation>', content, re.DOTALL)
print(f"Total UI.SelectionFields: {len(sel_fields)}")
for sf in sel_fields:
    print(sf)

# Check for UI.LineItem
line_items = re.findall(r'<Annotation Term="UI.LineItem".*?</Annotation>', content, re.DOTALL)
print(f"Total UI.LineItem: {len(line_items)}")
for li in line_items:
    # Print the property names in LineItem
    props = re.findall(r'PropertyPath">([^<]+)<', li)
    print(" LineItem columns:", props)
