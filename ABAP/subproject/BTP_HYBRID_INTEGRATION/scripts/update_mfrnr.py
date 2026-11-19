import pyrfc
import time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

prog_name = 'Z_UPDATE_MFRNR'
job_name = 'Z_UPDATE_MFRNR_JOB'

abap_source = [
    f"REPORT {prog_name}.",
    "UPDATE ekpo SET mfrnr = '0000100000' WHERE ebeln >= '4500000001' AND ebeln <= '4500000010'.",
    "COMMIT WORK."
]

source_extended = [{'LINE': line} for line in abap_source]

print("1. Creating program...")
conn.call('RPY_PROGRAM_INSERT',
          PROGRAM_NAME=prog_name,
          TITLE_STRING='Update MFRNR on EKPO',
          DEVELOPMENT_CLASS='$TMP',
          SUPPRESS_DIALOG='X',
          SOURCE_EXTENDED=source_extended)

print("2. Running via XBP...")
conn.call('BAPI_XMI_LOGON', EXTCOMPANY='SAP', EXTPRODUCT='BTP_DEMO', INTERFACE='XBP', VERSION='2.0')
res_open = conn.call('BAPI_XBP_JOB_OPEN', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name)
job_count = res_open['JOBCOUNT']
conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count, ABAP_PROGRAM_NAME=prog_name, SAP_USER_NAME='TRSTABAP')
res_start = conn.call('BAPI_XBP_JOB_START_IMMEDIATELY', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count)

time.sleep(3)

# 3. Check IMMPURCHORDRITEM for 4500000001
res_item = conn.call('RFC_READ_TABLE', QUERY_TABLE='IMMPURCHORDRITEM',
                     FIELDS=[{'FIELDNAME': 'PURCHASEORDER'}, {'FIELDNAME': 'PURCHASEORDERITEM'}, {'FIELDNAME': 'PURCHASEORDERITEMTEXT'}],
                     OPTIONS=[{'TEXT': "PURCHASEORDER = '4500000001'"}],
                     ROWCOUNT=5)

print("IMMPURCHORDRITEM after MFRNR update:", res_item['DATA'])
conn.close()
