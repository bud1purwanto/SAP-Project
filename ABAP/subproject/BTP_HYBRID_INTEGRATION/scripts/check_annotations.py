import urllib.request, re, base64

url = "http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/$metadata?sap-client=130"
req = urllib.request.Request(url)
req.add_header('Authorization', 'Basic ' + base64.b64encode(b'TRSTABAP:supporter').decode('ascii'))
resp = urllib.request.urlopen(req)
content = resp.read().decode('utf-8')

# Search for Annotations Target="...C_PurchaseOrderItemMoni..."
targets = re.findall(r'<Annotations Target="([^"]+)">', content)
print("Annotation Targets found:")
for t in set(targets):
    if "PurchaseOrder" in t:
        print(" ", t)

# Search for UI.LineItem
line_items = re.findall(r'<Annotation Term="UI.LineItem".*?</Annotation>', content, re.DOTALL)
print(f"Total UI.LineItem annotations: {len(line_items)}")
for li in line_items[:2]:
    print(li[:400])

# Search for UI.SelectionFields
sel_fields = re.findall(r'<Annotation Term="UI.SelectionFields".*?</Annotation>', content, re.DOTALL)
print(f"Total UI.SelectionFields annotations: {len(sel_fields)}")
for sf in sel_fields:
    print(sf)
