import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

abap_source = [
    "REPORT Z_DEBUG_CDS_VIEW.",
    "DATA: lt_results TYPE TABLE OF C_PurchaseOrderItemMoni,",
    "      lv_count TYPE i.",
    "",
    "SELECT * FROM C_PurchaseOrderItemMoni( P_DisplayCurrency = 'EUR' )",
    "  INTO TABLE @lt_results.",
    "",
    "lv_count = lines( lt_results ).",
    "WRITE: / 'Total rows in CDS View C_PurchaseOrderItemMoni:', lv_count.",
    "",
    "* Let's check I_PurchaseOrderItem",
    "DATA: lt_items TYPE TABLE OF I_PurchaseOrderItem.",
    "SELECT * FROM I_PurchaseOrderItem INTO TABLE @lt_items UP TO 10 ROWS.",
    "WRITE: / 'Total rows in I_PurchaseOrderItem:', lines( lt_items ).",
    "",
    "* Let's check I_PurchaseOrder",
    "DATA: lt_pos TYPE TABLE OF I_PurchaseOrder.",
    "SELECT * FROM I_PurchaseOrder INTO TABLE @lt_pos UP TO 10 ROWS.",
    "WRITE: / 'Total rows in I_PurchaseOrder:', lines( lt_pos )."
]

source_extended = [{'LINE': line} for line in abap_source]

prog_name = 'Z_DEBUG_CDS_VIEW'
job_name = 'Z_DEBUG_CDS_JOB'

print(f"Creating ABAP Program {prog_name}...")
res = conn.call('RPY_PROGRAM_INSERT',
                PROGRAM_NAME=prog_name,
                TITLE_STRING='Debug CDS View C_PurchaseOrderItemMoni',
                DEVELOPMENT_CLASS='$TMP',
                SUPPRESS_DIALOG='X',
                SOURCE_EXTENDED=source_extended)

# Logon XMI
res_logon = conn.call('BAPI_XMI_LOGON', EXTCOMPANY='SAP', EXTPRODUCT='BTP_DEMO', INTERFACE='XBP', VERSION='2.0')
res_open = conn.call('BAPI_XBP_JOB_OPEN', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name)
job_count = res_open['JOBCOUNT']
conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count, ABAP_PROGRAM_NAME=prog_name, SAP_USER_NAME='TRSTABAP')
conn.call('BAPI_XBP_JOB_START_IMMEDIATELY', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count)

import time
time.sleep(3)

# Read Spool or Job Log
res_log = conn.call('BAPI_XBP_JOB_READ', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count, STEP_DETAILS='X')
print("Job Log details:", res_log)

conn.close()
