import urllib.request, urllib.parse, json, base64

def test_filter(label, filter_str):
    encoded_filter = urllib.parse.quote(filter_str, safe='=$&')
    url = f"http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/C_PurchaseOrderItemMoni(P_DisplayCurrency='EUR')/Results?{encoded_filter}&$format=json&sap-client=130"
    req = urllib.request.Request(url)
    req.add_header('Authorization', 'Basic ' + base64.b64encode(b'TRSTABAP:supporter').decode('ascii'))
    try:
        resp = urllib.request.urlopen(req)
        data = json.loads(resp.read().decode('utf-8'))
        count = len(data['d']['results'])
        print(f"{label}: count = {count}")
    except Exception as e:
        print(f"{label}: Error {e}")

test_filter("1. No filter", "")
test_filter("2. Date in 2020", "$filter=PurchaseOrderDate ge datetime'2020-01-01T00:00:00'")
test_filter("3. Date in 2026 (current year)", "$filter=PurchaseOrderDate ge datetime'2026-01-01T00:00:00'")
test_filter("4. CompanyCode eq '0001'", "$filter=CompanyCode eq '0001'")
test_filter("5. Supplier eq '100000'", "$filter=Supplier eq '100000'")
