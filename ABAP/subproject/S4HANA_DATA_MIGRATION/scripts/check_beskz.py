import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='MARC', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'WERKS'}, {'FIELDNAME': 'BESKZ'}, {'FIELDNAME': 'SOBSL'}],
    OPTIONS=[{'TEXT': "MATNR = 'JRAAAI' AND WERKS = '1000'"}]
)
for r in res.get('DATA', []):
    print("MARC:", r.get('WA'))
