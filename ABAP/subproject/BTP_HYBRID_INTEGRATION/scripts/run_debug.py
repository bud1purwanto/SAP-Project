import pyrfc
import time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

prog_name = 'Z_DEBUG_QUERY'
job_name = 'Z_DEBUG_JOB'

abap_source = [
    f"REPORT {prog_name}.",
    "DATA: lt_moni TYPE TABLE OF cpurorditemmoni,",
    "      lt_ekko TYPE TABLE OF ekko,",
    "      lt_ekpo TYPE TABLE OF ekpo,",
    "      lv_msg TYPE char40.",
    "",
    "SELECT * FROM ekko INTO TABLE @lt_ekko.",
    "SELECT * FROM ekpo INTO TABLE @lt_ekpo.",
    "",
    "TRY.",
    "    SELECT * FROM cpurorditemmoni INTO TABLE @lt_moni UP TO 10 ROWS.",
    "    lv_msg = |EKKO:{ lines( lt_ekko ) } EKPO:{ lines( lt_ekpo ) } MONI:{ lines( lt_moni ) }|.",
    "  CATCH cx_root INTO DATA(lx).",
    "    lv_msg = |ERROR: { lx->get_text( ) }|.",
    "ENDTRY.",
    "",
    "UPDATE ekpo SET txz01 = @lv_msg WHERE ebeln = '4500000001'.",
    "COMMIT WORK."
]

source_extended = [{'LINE': line} for line in abap_source]

print("1. Creating debug program...")
conn.call('RPY_PROGRAM_INSERT',
          PROGRAM_NAME=prog_name,
          TITLE_STRING='Debug Query',
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

# Read EKPO-TXZ01 for 4500000001
res_ekpo = conn.call('RFC_READ_TABLE', QUERY_TABLE='EKPO',
                     FIELDS=[{'FIELDNAME': 'EBELN'}, {'FIELDNAME': 'TXZ01'}],
                     OPTIONS=[{'TEXT': "EBELN = '4500000001'"}],
                     ROWCOUNT=1)

print("DEBUG RESULT:", res_ekpo['DATA'])
conn.close()
