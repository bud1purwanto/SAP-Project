import urllib.request, json, base64

url = "http://192.168.1.199:8080/sap/opu/odata/IWFND/CATALOGSERVICE;v=2/Annotations?$format=json&sap-client=130"
req = urllib.request.Request(url)
req.add_header('Authorization', 'Basic ' + base64.b64encode(b'TRSTABAP:supporter').decode('ascii'))
try:
    resp = urllib.request.urlopen(req)
    data = json.loads(resp.read().decode('utf-8'))
    annos = data['d']['results']
    print(f"Total catalog annotations: {len(annos)}")
    for a in annos:
        if "POITEMS" in a.get('TechnicalName', '') or "POITEMS" in a.get('Description', ''):
            print("Found annotation:", a)
except Exception as e:
    print("Catalog annotations error:", e)
