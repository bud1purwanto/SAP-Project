import pyrfc
import time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

prog_name = 'Z_READ_DDL_SRC'
job_name = 'Z_READ_DDL_JOB'

abap_source = [
    f"REPORT {prog_name}.",
    "DATA: lv_src TYPE string,",
    "      lt_lines TYPE TABLE OF string.",
    "",
    "SELECT SINGLE source FROM ddddlsrc WHERE ddlname = 'C_PURCHASEORDERITEMMONI' INTO @lv_src.",
    "IF sy-subrc = 0.",
    "  OPEN DATASET '/tmp/ddl_C_PURCHASEORDERITEMMONI.txt' FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.",
    "  IF sy-subrc = 0.",
    "    TRANSFER lv_src TO '/tmp/ddl_C_PURCHASEORDERITEMMONI.txt'.",
    "    CLOSE DATASET '/tmp/ddl_C_PURCHASEORDERITEMMONI.txt'.",
    "  ENDIF.",
    "ENDIF.",
    "",
    "* Also check what tables have data",
    "SELECT SINGLE source FROM ddddlsrc WHERE ddlname = 'I_PURCHASEORDERITEM' INTO @lv_src.",
    "IF sy-subrc = 0.",
    "  OPEN DATASET '/tmp/ddl_I_PURCHASEORDERITEM.txt' FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.",
    "  IF sy-subrc = 0.",
    "    TRANSFER lv_src TO '/tmp/ddl_I_PURCHASEORDERITEM.txt'.",
    "    CLOSE DATASET '/tmp/ddl_I_PURCHASEORDERITEM.txt'.",
    "  ENDIF.",
    "ENDIF."
]

source_extended = [{'LINE': line} for line in abap_source]

print("1. Creating ABAP Program...")
conn.call('RPY_PROGRAM_INSERT',
          PROGRAM_NAME=prog_name,
          TITLE_STRING='Read DDL Source',
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
print("Job finished!")
conn.close()
