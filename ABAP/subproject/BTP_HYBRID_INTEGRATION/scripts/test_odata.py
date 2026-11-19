import requests

url = "http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/C_PurchaseOrderItemMoni(P_DisplayCurrency='EUR')/Results?$format=json&sap-client=130&$top=15"

try:
    resp = requests.get(url, auth=('TRSTABAP', 'supporter'), timeout=15)
    print("HTTP Status:", resp.status_code)
    data = resp.json()
    results = data.get('d', {}).get('results', [])
    print(f"Total PO Items Returned by OData: {len(results)}")
    for item in results:
        po = item.get('PurchaseOrder')
        po_item = item.get('PurchaseOrderItem')
        desc = item.get('PurchaseOrderItemText')
        curr = item.get('DisplayCurrency')
        net = item.get('NetPriceAmount')
        print(f"  PO {po} / {po_item}: {desc} | Net: {net} {curr}")
except Exception as e:
    print("Error:", e)
