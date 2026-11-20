import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

headdata = {
    'MATERIAL': 'JRAAAI',
    'MRP_VIEW': 'X',
}

plantdata = {
    'PLANT': '1000',
    'MRP_TYPE': 'ND',
    'PROC_TYPE': 'E'
}

plantdatax = {
    'PLANT': '1000',
    'MRP_TYPE': 'X',
    'PROC_TYPE': 'X'
}

res = conn.call('BAPI_MATERIAL_SAVEDATA', HEADDATA=headdata, PLANTDATA=plantdata, PLANTDATAX=plantdatax)
print("RETURN:", res.get('RETURN'))
for msg in res.get('RETURNMESSAGES', []):
    print(f"[{msg.get('TYPE')}] {msg.get('MESSAGE')} ({msg.get('ID')} {msg.get('NUMBER')})")

conn.call('BAPI_TRANSACTION_COMMIT', WAIT='X')

res_marc = conn.call('RFC_READ_TABLE', QUERY_TABLE='MARC', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'BESKZ'}, {'FIELDNAME': 'DISMM'}],
    OPTIONS=[{'TEXT': "MATNR = 'JRAAAI' AND WERKS = '1000'"}]
)
for r in res_marc.get('DATA', []):
    print("Verified MARC:", r.get('WA'))
