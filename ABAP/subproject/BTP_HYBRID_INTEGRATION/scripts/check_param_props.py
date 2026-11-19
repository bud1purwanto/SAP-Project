import urllib.request, re, base64

url = "http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/$metadata?sap-client=130"
req = urllib.request.Request(url)
req.add_header('Authorization', 'Basic ' + base64.b64encode(b'TRSTABAP:supporter').decode('ascii'))
resp = urllib.request.urlopen(req)
content = resp.read().decode('utf-8')

m = re.search(r'<EntityType Name="C_PurchaseOrderItemMoniParameters".*?</EntityType>', content, re.DOTALL)
if m:
    print(m.group(0))
