import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TBTCO',
                FIELDS=[{'FIELDNAME': 'JOBNAME'}, {'FIELDNAME': 'JOBCOUNT'}, {'FIELDNAME': 'STATUS'}, {'FIELDNAME': 'STRTDATE'}, {'FIELDNAME': 'STRTTIME'}],
                OPTIONS=[{'TEXT': "STATUS = 'F'"}],
                ROWCOUNT=10)

print(f"Finished jobs ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
