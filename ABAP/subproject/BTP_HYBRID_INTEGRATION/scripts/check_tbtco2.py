import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TBTCO',
                FIELDS=[{'FIELDNAME': 'JOBNAME'}, {'FIELDNAME': 'JOBCOUNT'}, {'FIELDNAME': 'STATUS'}],
                OPTIONS=[{'TEXT': "JOBNAME = 'Z_TEST_CHAIN_JOB2'"}],
                ROWCOUNT=5)

print("Job status:", res['DATA'])

conn.close()
