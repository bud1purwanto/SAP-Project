import urllib.request, json, base64

url = "http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/C_PurchaseOrderItemMoni(P_DisplayCurrency='EUR')/Results?$top=1&$format=json&sap-client=130"
req = urllib.request.Request(url)
req.add_header('Authorization', 'Basic ' + base64.b64encode(b'TRSTABAP:supporter').decode('ascii'))
resp = urllib.request.urlopen(req)
data = json.loads(resp.read().decode('utf-8'))
results = data['d']['results']
if not results:
    print("No items returned!")
else:
    item = results[0]
    for k, v in sorted(item.items()):
        if not k.startswith('__'):
            print(f"{k}: {v}")
