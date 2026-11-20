import pyrfc
import json

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

raw_materials = [
    'RPV-HC401BF',
    'SRP-I',
    'SRP-E',
    'M5AAA01',
    'RPV-FS3011E3',
    'RPM-ABPP10T',
    'RPC-FS5612'
]

header = {
    'PSTNG_DATE': '20231115',
    'DOC_DATE': '20231115',
    'PR_UNAME': 'TRSTABAP',
    'HEADER_TXT': 'INITIAL STOCK 561'
}

code = {
    'GM_CODE': '05'  # 05 = Other goods receipts (MB1C / MIGO)
}

items = []
for mat in raw_materials:
    items.append({
        'MATERIAL': mat,
        'PLANT': '1000',
        'STGE_LOC': '1011',
        'MOVE_TYPE': '561',
        'ENTRY_QNT': 1000.0,
        'ENTRY_UOM': 'KG'
    })

print("Posting Initial Stock 561 for 7 raw materials...")
res = conn.call('BAPI_GOODSMVT_CREATE', GOODSMVT_HEADER=header, GOODSMVT_CODE=code, GOODSMVT_ITEM=items)

matdoc = res.get('MATERIALDOCUMENT')
matyear = res.get('MATDOCUMENTYEAR')
print(f"Material Document: {matdoc}")
print(f"Document Year:     {matyear}")

return_msgs = res.get('RETURN', [])
for ret in return_msgs:
    print(f"[{ret.get('TYPE')}] {ret.get('MESSAGE')} (ID: {ret.get('ID')} NUM: {ret.get('NUMBER')})")

if matdoc:
    print("Calling BAPI_TRANSACTION_COMMIT...")
    c_res = conn.call('BAPI_TRANSACTION_COMMIT', WAIT='X')
    print("Commit result:", c_res)
    print("SUCCESS: Initial Stock 561 posted and committed successfully!")
else:
    print("FAILED: No material document was generated.")

print("\n--- Verifying Stock in Table MARD ---")
res_mard = conn.call('RFC_READ_TABLE', QUERY_TABLE='MARD', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'LGORT'}, {'FIELDNAME': 'LABST'}],
    OPTIONS=[{'TEXT': "WERKS = '1000' AND LGORT = '1011'"}]
)
for r in res_mard.get('DATA', []):
    print("MARD:", r.get('WA'))

print("\n--- Verifying Stock & Value in Table MBEW ---")
res_mbew = conn.call('RFC_READ_TABLE', QUERY_TABLE='MBEW', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'BWKEY'}, {'FIELDNAME': 'LBKUM'}, {'FIELDNAME': 'SALK3'}],
    OPTIONS=[{'TEXT': "BWKEY = '1000'"}]
)
for r in res_mbew.get('DATA', []):
    print("MBEW:", r.get('WA'))
