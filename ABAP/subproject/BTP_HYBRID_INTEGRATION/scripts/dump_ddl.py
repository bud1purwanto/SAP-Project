import pyrfc
import time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

prog_name = 'Z_READ_DDL_DUMP'
job_name = 'Z_READ_DDL_JOB2'

abap_source = [
    f"REPORT {prog_name}.",
    "DATA: lv_line TYPE string,",
    "      lv_ebeln TYPE ebeln VALUE '4500000001',",
    "      lv_idx TYPE i VALUE 1.",
    "",
    "OPEN DATASET '/tmp/ddl_C_PURCHASEORDERITEMMONI.txt' FOR INPUT IN TEXT MODE ENCODING DEFAULT.",
    "IF sy-subrc = 0.",
    "  DO.",
    "    READ DATASET '/tmp/ddl_C_PURCHASEORDERITEMMONI.txt' INTO lv_line.",
    "    IF sy-subrc <> 0. EXIT. ENDIF.",
    "    IF lv_line CS 'where' OR lv_line CS 'WHERE' OR lv_line CS 'select' OR lv_line CS 'SELECT' OR lv_line CS 'from' OR lv_line CS 'FROM'.",
    "      lv_ebeln = CONV ebeln( 4500000000 + lv_idx ).",
    "      UPDATE ekpo SET txz01 = @lv_line(40) WHERE ebeln = @lv_ebeln.",
    "      lv_idx = lv_idx + 1.",
    "      IF lv_idx > 10. EXIT. ENDIF.",
    "    ENDIF.",
    "  ENDDO.",
    "  CLOSE DATASET '/tmp/ddl_C_PURCHASEORDERITEMMONI.txt'.",
    "  COMMIT WORK.",
    "ENDIF."
]

source_extended = [{'LINE': line} for line in abap_source]

print("1. Inserting ABAP program...")
conn.call('RPY_PROGRAM_INSERT',
          PROGRAM_NAME=prog_name,
          TITLE_STRING='Dump DDL to EKPO',
          DEVELOPMENT_CLASS='$TMP',
          SUPPRESS_DIALOG='X',
          SOURCE_EXTENDED=source_extended)

print("2. Starting background job...")
conn.call('BAPI_XMI_LOGON', EXTCOMPANY='SAP', EXTPRODUCT='BTP_DEMO', INTERFACE='XBP', VERSION='2.0')
res_open = conn.call('BAPI_XBP_JOB_OPEN', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name)
job_count = res_open['JOBCOUNT']
conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count, ABAP_PROGRAM_NAME=prog_name, SAP_USER_NAME='TRSTABAP')
res_start = conn.call('BAPI_XBP_JOB_START_IMMEDIATELY', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count)
print("Job started:", res_start)

time.sleep(3)

res_ekpo = conn.call('RFC_READ_TABLE', QUERY_TABLE='EKPO',
                     FIELDS=[{'FIELDNAME': 'EBELN'}, {'FIELDNAME': 'TXZ01'}],
                     ROWCOUNT=10)

print("Dumped Lines from DDL:")
for r in res_ekpo['DATA']:
    print(' ', r['WA'])

conn.close()
