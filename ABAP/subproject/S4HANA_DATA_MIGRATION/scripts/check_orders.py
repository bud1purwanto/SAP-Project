import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

print("=== CHECKING T399X for WERKS 1000 and 0001 ===")
res = conn.call('RFC_READ_TABLE', QUERY_TABLE='T399X', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'AUART'}, {'FIELDNAME': 'AUTYP'}, {'FIELDNAME': 'PLNTY'}],
    OPTIONS=[{'TEXT': "WERKS IN ('0001', '1000')"}]
)
for r in res.get('DATA', []):
    print("T399X:", r.get('WA'))
