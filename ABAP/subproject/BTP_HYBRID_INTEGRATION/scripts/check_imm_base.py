import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

for v in ['IMMPURCHASEORDER', 'IMMPURCHORDRITEM']:
    res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD26S',
                    FIELDS=[{'FIELDNAME': 'VIEWNAME'}, {'FIELDNAME': 'TABNAME'}, {'FIELDNAME': 'FORTABNAME'}],
                    OPTIONS=[{'TEXT': f"VIEWNAME = '{v}'"}],
                    ROWCOUNT=10)
    print(f"\nDD26S for {v}:")
    for r in res['DATA']:
        print(' ', r['WA'])

conn.close()
