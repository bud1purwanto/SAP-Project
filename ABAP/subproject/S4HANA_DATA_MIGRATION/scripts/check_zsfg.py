import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='T134', DELIMITER='|',
    FIELDS=[{'FIELDNAME': 'MTART'}],
    ROWCOUNT=50
)
types = [r.get('WA').strip() for r in res.get('DATA', [])]
print("Material Types in ADB 130:", types)
