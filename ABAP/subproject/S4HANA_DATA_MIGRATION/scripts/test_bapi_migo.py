import pyrfc
import json

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

# Test posting 1 material: RPV-HC401BF, 1000 KG, Plant 1000, SLoc 1011, Move Type 561
header = {
    'PSTNG_DATE': '20231115',
    'DOC_DATE': '20231115',
    'PR_UNAME': 'TRSTABAP'
}
code = {
    'GM_CODE': '05'
}
items = [
    {
        'MATERIAL': 'RPV-HC401BF',
        'PLANT': '1000',
        'STGE_LOC': '1011',
        'MOVE_TYPE': '561',
        'ENTRY_QNT': 1000.0,
        'ENTRY_UOM': 'KG'
    }
]

print("Calling BAPI_GOODSMVT_CREATE (test run)...")
res = conn.call('BAPI_GOODSMVT_CREATE', GOODSMVT_HEADER=header, GOODSMVT_CODE=code, GOODSMVT_ITEM=items)
print("Material Document:", res.get('MATERIALDOCUMENT'))
print("MatDoc Year:", res.get('MATDOCUMENTYEAR'))
print("Return messages:")
for ret in res.get('RETURN', []):
    print(f"[{ret.get('TYPE')}] {ret.get('MESSAGE')} (ID: {ret.get('ID')} NUM: {ret.get('NUMBER')})")
