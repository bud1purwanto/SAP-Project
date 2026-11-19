import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TBTCO',
                FIELDS=[{'FIELDNAME': 'JOBNAME'}, {'FIELDNAME': 'JOBCOUNT'}, {'FIELDNAME': 'STATUS'}],
                OPTIONS=[{'TEXT': "JOBNAME = 'Z_DEBUG_JOB'"}],
                ROWCOUNT=10)

print("Job Status:", res['DATA'])

# Check job log
if res['DATA']:
    last_job = res['DATA'][-1]['WA'].split()
    print("Last job:", last_job)

conn.close()
