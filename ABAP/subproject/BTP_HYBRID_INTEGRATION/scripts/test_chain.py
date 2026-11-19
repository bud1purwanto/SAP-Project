import pyrfc
import time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

prog_name = 'Z_TEST_CHAIN_V2'
job_name = 'Z_TEST_CHAIN_JOB2'

abap_source = [
    f"REPORT {prog_name}.",
    "DATA: lv_c1 TYPE i,",
    "      lv_c2 TYPE i,",
    "      lv_c3 TYPE i,",
    "      lv_c4 TYPE i,",
    "      lv_c5 TYPE i,",
    "      lv_res TYPE char40.",
    "",
    "SELECT COUNT( * ) FROM I_PurchaseOrderItem INTO @lv_c1.",
    "SELECT COUNT( * ) FROM I_PurchaseOrder INTO @lv_c2.",
    "SELECT COUNT( * ) FROM PPURORDITEM INTO @lv_c3.",
    "SELECT COUNT( * ) FROM PPURORDITEMMNTR INTO @lv_c4.",
    "SELECT COUNT( * ) FROM CPURORDITEMMONI INTO @lv_c5.",
    "",
    "lv_res = |C1:{ lv_c1 } C2:{ lv_c2 } C3:{ lv_c3 } C4:{ lv_c4 } C5:{ lv_c5 }|.",
    "UPDATE ekpo SET txz01 = @lv_res WHERE ebeln = '4500000001'.",
    "COMMIT WORK."
]

source_extended = [{'LINE': line} for line in abap_source]

print("1. Creating ABAP program...")
conn.call('RPY_PROGRAM_INSERT',
          PROGRAM_NAME=prog_name,
          TITLE_STRING='Test CDS View Chain',
          DEVELOPMENT_CLASS='$TMP',
          SUPPRESS_DIALOG='X',
          SOURCE_EXTENDED=source_extended)

print("2. Running via XBP...")
conn.call('BAPI_XMI_LOGON', EXTCOMPANY='SAP', EXTPRODUCT='BTP_DEMO', INTERFACE='XBP', VERSION='2.0')
res_open = conn.call('BAPI_XBP_JOB_OPEN', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name)
job_count = res_open['JOBCOUNT']
conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count, ABAP_PROGRAM_NAME=prog_name, SAP_USER_NAME='TRSTABAP')
conn.call('BAPI_XBP_JOB_START_IMMEDIATELY', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count)

time.sleep(3)

# Check EKPO
res_ekpo = conn.call('RFC_READ_TABLE', QUERY_TABLE='EKPO',
                     FIELDS=[{'FIELDNAME': 'EBELN'}, {'FIELDNAME': 'TXZ01'}],
                     OPTIONS=[{'TEXT': "EBELN = '4500000001'"}],
                     ROWCOUNT=1)

print("RESULT COUNTS:", res_ekpo['DATA'])
conn.close()
