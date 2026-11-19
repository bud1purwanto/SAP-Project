import urllib.request, json, base64

url = "http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/C_PurchaseOrderItemMoni?$format=json&sap-client=130"
req = urllib.request.Request(url)
req.add_header('Authorization', 'Basic ' + base64.b64encode(b'TRSTABAP:supporter').decode('ascii'))
try:
    resp = urllib.request.urlopen(req)
    data = json.loads(resp.read().decode('utf-8'))
    print("Direct C_PurchaseOrderItemMoni response:", data)
except urllib.error.HTTPError as he:
    print("HTTPError:", he.code, he.read().decode('utf-8')[:300])
except Exception as e:
    print("Error:", e)
