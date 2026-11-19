import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='EKET',
                FIELDS=[{'FIELDNAME': 'EBELN'}, {'FIELDNAME': 'EBELP'}, {'FIELDNAME': 'ETENR'}, {'FIELDNAME': 'EINDT'}, {'FIELDNAME': 'MENGE'}, {'FIELDNAME': 'WEMNG'}],
                ROWCOUNT=20)

print(f"EKET count ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
