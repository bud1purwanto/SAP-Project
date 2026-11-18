import zipfile
import xml.etree.ElementTree as ET

with zipfile.ZipFile('/tmp/test_out.xlsx', 'r') as z:
    for name in z.namelist():
        if name.endswith('.xml') or name.endswith('.rels'):
            data = z.read(name)
            try:
                ET.fromstring(data)
                print(f'XML OK: {name}')
            except Exception as e:
                print(f'XML CORRUPT: {name} -> {e}')
