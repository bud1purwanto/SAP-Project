import urllib.request, base64, re
url = 'http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MOLI_SRV/TMetadata?sap-client=130'
req = urllib.request.Request(url)
req.add_header('Authorization', 'Basic ' + base64.b64encode(b'TRSTABAP:supporter').decode('ascii'))
content = urllib.request.urlopen(req).read().decode('utf-8')
match = re.search(r'<EntityType Name="C_PurchaseOrderItemMoniParameters".*?</EntityType>', content, re.DOTALL)
if match:
    print(match.group(0))
