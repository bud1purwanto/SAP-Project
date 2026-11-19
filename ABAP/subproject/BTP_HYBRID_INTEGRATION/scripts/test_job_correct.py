import pyrfc
import time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

job_name = 'Z_TEST_CHAIN_JOB3'
prog_name = 'Z_TEST_CHAIN_V2'

conn.call('BAPI_XMI_LOGON', EXTCOMPANY='SAP', EXTPRODUCT='BTP_DEMO', INTERFACE='XBP', VERSION='2.0')

res_open = conn.call('BAPI_XBP_JOB_OPEN', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name)
job_count = res_open['JOBCOUNT']
print("Open:", job_count)

res_step = conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count, ABAP_PROGRAM_NAME=prog_name, SAP_USER_NAME='TRSTABAP')
print("Step:", res_step['RETURN'])

# Call CLOSE
res_close = conn.call('BAPI_XBP_JOB_CLOSE', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count)
print("Close:", res_close['RETURN'])

# Call START_IMMEDIATELY
res_start = conn.call('BAPI_XBP_JOB_START_IMMEDIATELY', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count)
print("Start:", res_start['RETURN'])

time.sleep(3)

# Check status in TBTCO
res_job = conn.call('RFC_READ_TABLE', QUERY_TABLE='TBTCO',
                    FIELDS=[{'FIELDNAME': 'JOBNAME'}, {'FIELDNAME': 'JOBCOUNT'}, {'FIELDNAME': 'STATUS'}],
                    OPTIONS=[{'TEXT': f"JOBNAME = '{job_name}' AND JOBCOUNT = '{job_count}'"}],
                    ROWCOUNT=1)
print("TBTCO:", res_job['DATA'])

# Check EKPO
res_ekpo = conn.call('RFC_READ_TABLE', QUERY_TABLE='EKPO',
                     FIELDS=[{'FIELDNAME': 'EBELN'}, {'FIELDNAME': 'TXZ01'}],
                     OPTIONS=[{'TEXT': "EBELN = '4500000001'"}],
                     ROWCOUNT=1)
print("EKPO RESULT:", res_ekpo['DATA'])

conn.close()
