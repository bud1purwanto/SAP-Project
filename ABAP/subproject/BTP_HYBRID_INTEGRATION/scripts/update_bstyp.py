import pyrfc
import time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

prog_name = 'Z_UPDATE_BSTYP'
job_name = 'Z_UPDATE_BSTYP_JOB'

abap_source = [
    f"REPORT {prog_name}.",
    "UPDATE ekpo SET bstyp = 'F', mfrnr = '0000100000'",
    "  WHERE ebeln >= '4500000001' AND ebeln <= '4500000010'.",
    "COMMIT WORK."
]

source_extended = [{'LINE': line} for line in abap_source]

print("1. Creating program...")
conn.call('RPY_PROGRAM_INSERT',
          PROGRAM_NAME=prog_name,
          TITLE_STRING='Update BSTYP on EKPO',
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

# 3. Check IMMPURGDOCITEM
res_doc = conn.call('RFC_READ_TABLE', QUERY_TABLE='IMMPURGDOCITEM',
                    FIELDS=[{'FIELDNAME': 'PURCHASINGDOCUMENT'}, {'FIELDNAME': 'PURCHASINGDOCUMENTCATEGORY'}],
                    OPTIONS=[{'TEXT': "PURCHASINGDOCUMENT = '4500000001'"}],
                    ROWCOUNT=1)
print("IMMPURGDOCITEM:", res_doc['DATA'])

# 4. Check IMMPURCHORDRITEM
res_ordr = conn.call('RFC_READ_TABLE', QUERY_TABLE='IMMPURCHORDRITEM',
                     FIELDS=[{'FIELDNAME': 'PURCHASEORDER'}, {'FIELDNAME': 'PURCHASEORDERITEM'}, {'FIELDNAME': 'PURCHASEORDERITEMTEXT'}],
                     OPTIONS=[{'TEXT': "PURCHASEORDER = '4500000001'"}],
                     ROWCOUNT=5)
print("IMMPURCHORDRITEM:", res_ordr['DATA'])

conn.close()
