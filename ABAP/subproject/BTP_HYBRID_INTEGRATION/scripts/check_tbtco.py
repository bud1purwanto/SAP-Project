import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TBTCO',
                FIELDS=[{'FIELDNAME': 'JOBNAME'}, {'FIELDNAME': 'JOBCOUNT'}, {'FIELDNAME': 'STATUS'}, {'FIELDNAME': 'STRTDATE'}, {'FIELDNAME': 'STRTTIME'}, {'FIELDNAME': 'ENDDATE'}, {'FIELDNAME': 'ENDTIME'}],
                OPTIONS=[{'TEXT': "JOBNAME = 'Z_SEED_PO_JOB'"}],
                ROWCOUNT=10)

print("Job Status:")
for r in res['DATA']:
    print(' ', r['WA'])

conn.close()
