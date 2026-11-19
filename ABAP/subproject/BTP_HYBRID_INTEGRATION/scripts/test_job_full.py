import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

# 1. XMI Logon
res_logon = conn.call('BAPI_XMI_LOGON',
                      EXTCOMPANY='SAP',
                      EXTPRODUCT='BTP_DEMO',
                      INTERFACE='XBP',
                      VERSION='2.0')
print("XMI Logon:", res_logon)

# 2. Open Job
job_name = 'Z_SEED_PO_JOB'
res_open = conn.call('BAPI_XBP_JOB_OPEN', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name)
print("Job Open:", res_open)
job_count = res_open['JOBCOUNT']

# 3. Add ABAP Step
res_step = conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP',
                     EXTERNAL_USER_NAME='TRSTABAP',
                     JOBNAME=job_name,
                     JOBCOUNT=job_count,
                     ABAP_PROGRAM_NAME='Z_SEED_PO_ITEMS',
                     SAP_USER_NAME='TRSTABAP')
print("Add Step:", res_step)

# 4. Start Immediately
res_start = conn.call('BAPI_XBP_JOB_START_IMMEDIATELY',
                      EXTERNAL_USER_NAME='TRSTABAP',
                      JOBNAME=job_name,
                      JOBCOUNT=job_count)
print("Start Immediately:", res_start)

conn.close()
