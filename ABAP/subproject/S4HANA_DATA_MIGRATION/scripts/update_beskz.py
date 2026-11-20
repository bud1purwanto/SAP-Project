import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

headdata = {
    'MATERIAL': 'JRAAAI',
    'MRP_VIEW': 'X'
}

plantdata = {
    'PLANT': '1000',
    'PROC_TYPE': 'E'
}

plantdatax = {
    'PLANT': '1000',
    'PROC_TYPE': 'X'
}

print("Calling BAPI_MATERIAL_SAVEDATA to set BESKZ = E for JRAAAI...")
res = conn.call('BAPI_MATERIAL_SAVEDATA', HEADDATA=headdata, PLANTDATA=plantdata, PLANTDATAX=plantdatax)
print("RETURN:", res.get('RETURN'))

if res.get('RETURN', {}).get('TYPE') in ['S', 'I', 'W', '']:
    c_res = conn.call('BAPI_TRANSACTION_COMMIT', WAIT='X')
    print("Commit result:", c_res)
    print("SUCCESS: Updated BESKZ to E!")
else:
    print("FAILED")

# Verify in MARC
res_marc = conn.call('RFC_READ_TABLE', QUERY_TABLE='MARC', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'BESKZ'}],
    OPTIONS=[{'TEXT': "MATNR = 'JRAAAI' AND WERKS = '1000'"}]
)
for r in res_marc.get('DATA', []):
    print("Verified MARC:", r.get('WA'))
