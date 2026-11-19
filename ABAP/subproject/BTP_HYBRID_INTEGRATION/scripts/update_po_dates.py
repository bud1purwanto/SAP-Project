import pyrfc, time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

prog_name = 'Z_UPDATE_PO_DATES_2'
job_name = 'Z_JOB_UPD_DATES_2'

source_lines = [
    "REPORT Z_UPDATE_PO_DATES_2.",
    "UPDATE ekko SET aedat = '20261119', bedat = '20261119' WHERE ebeln >= '4500000001' AND ebeln <= '4500000010'.",
    "UPDATE ekpo SET aedat = '20261119' WHERE ebeln >= '4500000001' AND ebeln <= '4500000010'.",
    "UPDATE eket SET eindt = '20261119', bedat = '20261119' WHERE ebeln >= '4500000001' AND ebeln <= '4500000010'.",
    "COMMIT WORK.",
    "WRITE: / 'Dates updated successfully to 20261119'."
]

source = [{'LINE': line} for line in source_lines]

try:
    res_ins = conn.call('RPY_PROGRAM_INSERT',
        PROGRAM_NAME=prog_name,
        TITLE_STRING='Update PO dates to 2026',
        DEVELOPMENT_CLASS='$TMP',
        SUPPRESS_DIALOG='X',
        SOURCE_EXTENDED=source
    )
    print("Insert program success:", res_ins)
except Exception as e:
    print("Insert error:", e)

conn.call('BAPI_XMI_LOGON', EXTCOMPANY='ANTIGRAVITY', EXTPRODUCT='AGENT', INTERFACE='XBP', VERSION='3.0')
job_open = conn.call('BAPI_XBP_JOB_OPEN', JOBNAME=job_name, EXTERNAL_USER_NAME='TRSTABAP')
job_id = job_open['JOBCOUNT']

conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP',
    JOBNAME=job_name,
    JOBCOUNT=job_id,
    EXTERNAL_USER_NAME='TRSTABAP',
    ABAP_PROGRAM_NAME=prog_name
)

conn.call('BAPI_XBP_JOB_START_IMMEDIATELY', JOBNAME=job_name, JOBCOUNT=job_id, EXTERNAL_USER_NAME='TRSTABAP')
print("Job started:", job_id)

time.sleep(2)
conn.call('BAPI_XMI_LOGOFF', INTERFACE='XBP')
print("Finished!")
