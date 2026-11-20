import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD03L', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'FIELDNAME'}],
    OPTIONS=[{'TEXT': "TABNAME = 'BAPIMATHEAD' AND AS4LOCAL = 'A'"}]
)
for r in res.get('DATA', []):
    print("BAPIMATHEAD:", r.get('WA'))
