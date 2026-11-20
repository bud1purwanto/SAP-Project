import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='MARA', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'MTART'}, {'FIELDNAME': 'MBRSH'}, {'FIELDNAME': 'MEINS'}],
    OPTIONS=[{'TEXT': "MATNR = 'JRAAAI'"}]
)
for r in res.get('DATA', []):
    print("MARA:", r.get('WA'))
