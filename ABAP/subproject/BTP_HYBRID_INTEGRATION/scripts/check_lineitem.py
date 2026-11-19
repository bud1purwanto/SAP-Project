import urllib.request, re, base64

url = "http://192.168.1.199:8080/sap/opu/odata/IWFND/CATALOGSERVICE;v=2/Annotations(TechnicalName='MM_PUR_POITEMS_MONI_ANNO_MDL',Version='0001')/$value?sap-client=130"
req = urllib.request.Request(url)
req.add_header('Authorization', 'Basic ' + base64.b64encode(b'TRSTABAP:supporter').decode('ascii'))
resp = urllib.request.urlopen(req)
content = resp.read().decode('utf-8')

line_item = re.search(r'<Annotation Term="UI.LineItem".*?</Annotation>', content, re.DOTALL)
if line_item:
    print(line_item.group(0))
