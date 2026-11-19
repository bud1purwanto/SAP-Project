import urllib.request
import base64

url = "http://192.168.1.199:8080/sap/opu/odata/sap/MM_PUR_POITEMS_MONI_SRV/$metadata?sap-client=130"

req = urllib.request.Request(url)
auth_str = base64.b64encode(b'TRSTABAP:supporter').decode('ascii')
req.add_header('Authorization', f'Basic {auth_str}')

try:
    with urllib.request.urlopen(req, timeout=15) as resp:
        xml_content = resp.read().decode('utf-8')
        print(f"Metadata length: {len(xml_content)}")
        # Print EntitySets
        import re
        entity_sets = re.findall(r'<EntitySet [^>]*>', xml_content)
        print("EntitySets found:")
        for es in entity_sets:
            print(" ", es)
        
        # Look for parameters or Results
        nav_props = re.findall(r'<NavigationProperty [^>]*>', xml_content)
        print("Navigation Properties:")
        for np in nav_props:
            print(" ", np)
except Exception as e:
    print("Error:", e)
