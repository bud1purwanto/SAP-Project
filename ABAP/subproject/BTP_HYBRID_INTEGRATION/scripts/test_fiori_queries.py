import urllib.request
import json
import base64

def test_query(desc, url_suffix):
    base_url = "http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/"
    full_url = base_url + url_suffix
    req = urllib.request.Request(full_url)
    auth_str = base64.b64encode(b'TRSTABAP:supporter').decode('ascii')
    req.add_header('Authorization', f'Basic {auth_str}')
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            results = data.get('d', {}).get('results', [])
            print(f"{desc}: Status {resp.status}, count = {len(results)}")
    except urllib.error.HTTPError as he:
        print(f"{desc}: HTTPError {he.code} {he.reason}")
    except Exception as e:
        print(f"{desc}: Error {e}")

# 1. Standard with EUR
test_query("1. P_DisplayCurrency='EUR'", "C_PurchaseOrderItemMoni(P_DisplayCurrency='EUR')/Results?$format=json&sap-client=130")

# 2. Empty DisplayCurrency
test_query("2. P_DisplayCurrency=''", "C_PurchaseOrderItemMoni(P_DisplayCurrency='')/Results?$format=json&sap-client=130")

# 3. Without parameters
test_query("3. C_PurchaseOrderItemMoniResults direct", "C_PurchaseOrderItemMoniResults?$format=json&sap-client=130")

# 4. With typical Fiori Elements $select
test_query("4. With $select", "C_PurchaseOrderItemMoni(P_DisplayCurrency='EUR')/Results?$format=json&sap-client=130&$select=PurchaseOrder,PurchaseOrderItem,PurchaseOrderItemText,DisplayCurrency")

# 5. With $inlinecount
test_query("5. With $inlinecount", "C_PurchaseOrderItemMoni(P_DisplayCurrency='EUR')/Results?$format=json&sap-client=130&$inlinecount=allpages")
