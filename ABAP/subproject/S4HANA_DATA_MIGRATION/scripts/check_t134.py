import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='T134', NO_DATA='X')
for f in res.get('FIELDS', []):
    if 'KZ' in f.get('FIELDNAME') or 'MTART' in f.get('FIELDNAME') or 'BESK' in f.get('FIELDNAME'):
        print(f.get('FIELDNAME'), f.get('TYPE'), f.get('LENGTH'))
