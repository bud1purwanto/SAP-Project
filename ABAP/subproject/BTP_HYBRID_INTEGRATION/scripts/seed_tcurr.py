import pyrfc
import time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

prog_name = 'Z_SEED_TCURR'
job_name = 'Z_SEED_TCURR_JOB'

abap_source = [
    f"REPORT {prog_name}.",
    "DATA: lt_tcurf TYPE TABLE OF tcurf,",
    "      ls_tcurf TYPE tcurf,",
    "      lt_tcurr TYPE TABLE OF tcurr,",
    "      ls_tcurr TYPE tcurr.",
    "",
    "* 1. Insert TCURF factors",
    "CLEAR ls_tcurf.",
    "ls_tcurf-mandt = sy-mandt.",
    "ls_tcurf-kurst = 'M'.",
    "ls_tcurf-fcurr = 'EUR'.",
    "ls_tcurf-tcurr = 'EUR'.",
    "ls_tcurf-gdatu = '00000000'.",
    "ls_tcurf-ffact = 1.",
    "ls_tcurf-tfact = 1.",
    "MODIFY tcurf FROM @ls_tcurf.",
    "",
    "ls_tcurf-fcurr = 'USD'.",
    "ls_tcurf-tcurr = 'EUR'.",
    "MODIFY tcurf FROM @ls_tcurf.",
    "",
    "ls_tcurf-fcurr = 'EUR'.",
    "ls_tcurf-tcurr = 'USD'.",
    "MODIFY tcurf FROM @ls_tcurf.",
    "",
    "* 2. Insert TCURR rates",
    "CLEAR ls_tcurr.",
    "ls_tcurr-mandt = sy-mandt.",
    "ls_tcurr-kurst = 'M'.",
    "ls_tcurr-fcurr = 'EUR'.",
    "ls_tcurr-tcurr = 'EUR'.",
    "ls_tcurr-gdatu = '79798789'.",
    "ls_tcurr-ukurs = '1.00000'.",
    "MODIFY tcurr FROM @ls_tcurr.",
    "",
    "ls_tcurr-fcurr = 'USD'.",
    "ls_tcurr-tcurr = 'EUR'.",
    "ls_tcurr-ukurs = '0.85000'.",
    "MODIFY tcurr FROM @ls_tcurr.",
    "",
    "ls_tcurr-fcurr = 'EUR'.",
    "ls_tcurr-tcurr = 'USD'.",
    "ls_tcurr-ukurs = '1.18000'.",
    "MODIFY tcurr FROM @ls_tcurr.",
    "",
    "COMMIT WORK.",
    "WRITE: / 'TCURR and TCURF updated successfully.'."
]

source_extended = [{'LINE': line} for line in abap_source]

print("1. Creating ABAP program...")
conn.call('RPY_PROGRAM_INSERT',
          PROGRAM_NAME=prog_name,
          TITLE_STRING='Seed TCURR & TCURF',
          DEVELOPMENT_CLASS='$TMP',
          SUPPRESS_DIALOG='X',
          SOURCE_EXTENDED=source_extended)

print("2. Running via XBP...")
conn.call('BAPI_XMI_LOGON', EXTCOMPANY='SAP', EXTPRODUCT='BTP_DEMO', INTERFACE='XBP', VERSION='2.0')
res_open = conn.call('BAPI_XBP_JOB_OPEN', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name)
job_count = res_open['JOBCOUNT']
conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count, ABAP_PROGRAM_NAME=prog_name, SAP_USER_NAME='TRSTABAP')
res_start = conn.call('BAPI_XBP_JOB_START_IMMEDIATELY', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count)
print("Job started:", res_start)

time.sleep(3)

# Check TCURR
res_check = conn.call('RFC_READ_TABLE', QUERY_TABLE='TCURR',
                      FIELDS=[{'FIELDNAME': 'KURST'}, {'FIELDNAME': 'FCURR'}, {'FIELDNAME': 'TCURR'}, {'FIELDNAME': 'UKURS'}],
                      OPTIONS=[{'TEXT': "KURST = 'M' AND FCURR = 'EUR'"}],
                      ROWCOUNT=5)
print("TCURR entries for EUR:", res_check['DATA'])

conn.close()
