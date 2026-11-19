import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

ext_user = 'TRSTABAP'
job_name = 'Z_TEST_SEED_JOB'

try:
    # 1. Open Job
    res_open = conn.call('BAPI_XBP_JOB_OPEN', EXTERNAL_USER_NAME=ext_user, JOBNAME=job_name)
    print("Job Open:", res_open)
    job_count = res_open['JOBCOUNT']

    # 2. Add ABAP Step
    res_step = conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP',
                         EXTERNAL_USER_NAME=ext_user,
                         JOBNAME=job_name,
                         JOBCOUNT=job_count,
                         ABAP_PROGRAM_NAME='Z_SEED_PO_ITEMS',
                         SAP_USER_NAME='TRSTABAP')
    print("Add Step:", res_step)

    # 3. Start Immediately
    res_start = conn.call('BAPI_XBP_JOB_START_IMMEDIATELY',
                          EXTERNAL_USER_NAME=ext_user,
                          JOBNAME=job_name,
                          JOBCOUNT=job_count)
    print("Start Immediately:", res_start)

except Exception as e:
    print("Error:", e)

conn.close()
