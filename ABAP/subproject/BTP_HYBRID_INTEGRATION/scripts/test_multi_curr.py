import urllib.request
import json
import base64

currencies = ['EUR', 'USD', 'JPY']

for curr in currencies:
    url = f"http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/C_PurchaseOrderItemMoni(P_DisplayCurrency='{curr}')/Results?$format=json&sap-client=130&$top=5"
    req = urllib.request.Request(url)
    auth_str = base64.b64encode(b'TRSTABAP:supporter').decode('ascii')
    req.add_header('Authorization', f'Basic {auth_str}')
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            results = data.get('d', {}).get('results', [])
            print(f"Currency {curr}: {len(results)} items returned (Status {resp.status})")
    except Exception as e:
        print(f"Currency {curr}: Error {e}")
