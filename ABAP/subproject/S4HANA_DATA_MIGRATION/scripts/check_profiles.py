import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TCA10', DELIMITER='|', ROWCOUNT=20)
for r in res.get('DATA', []):
    print("TCA10:", r.get('WA'))
