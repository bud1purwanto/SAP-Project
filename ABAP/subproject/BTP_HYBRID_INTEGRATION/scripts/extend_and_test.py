import pyrfc
from decimal import Decimal
import time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

# 1. Maintain MBEW for SRAJII in BWKEY 0001 via ABAP program
prog_name = 'Z_EXTEND_MBEW'
job_name = 'Z_EXTEND_MBEW_JOB'

abap_code = [
    f"REPORT {prog_name}.",
    "DATA: ls_mbew TYPE mbew.",
    "SELECT SINGLE * FROM mbew WHERE matnr = 'SRAJII' AND bwkey = '0001' INTO @ls_mbew.",
    "IF sy-subrc <> 0.",
    "  SELECT SINGLE * FROM mbew WHERE matnr = 'SRAJII' AND bwkey = '0003' INTO @ls_mbew.",
    "  IF sy-subrc = 0.",
    "    ls_mbew-bwkey = '0001'.",
    "    INSERT mbew FROM @ls_mbew.",
    "    COMMIT WORK.",
    "  ENDIF.",
    "ENDIF."
]

conn.call('RPY_PROGRAM_INSERT',
          PROGRAM_NAME=prog_name,
          TITLE_STRING='Extend MBEW for SRAJII',
          DEVELOPMENT_CLASS='$TMP',
          SUPPRESS_DIALOG='X',
          SOURCE_EXTENDED=[{'LINE': l} for l in abap_code])

conn.call('BAPI_XMI_LOGON', EXTCOMPANY='SAP', EXTPRODUCT='BTP_DEMO', INTERFACE='XBP', VERSION='2.0')
res_open = conn.call('BAPI_XBP_JOB_OPEN', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name)
job_count = res_open['JOBCOUNT']
conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count, ABAP_PROGRAM_NAME=prog_name, SAP_USER_NAME='TRSTABAP')
conn.call('BAPI_XBP_JOB_START_IMMEDIATELY', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name, JOBCOUNT=job_count)

time.sleep(2)

# Check MBEW
res_mbew = conn.call('RFC_READ_TABLE', QUERY_TABLE='MBEW',
                     FIELDS=[{'FIELDNAME': 'MATNR'}, {'FIELDNAME': 'BWKEY'}, {'FIELDNAME': 'BKLAS'}],
                     OPTIONS=[{'TEXT': "MATNR = 'SRAJII'"}],
                     ROWCOUNT=5)
print("MBEW records:", res_mbew['DATA'])

# 2. Test BAPI_PO_CREATE1 with TESTRUN='X' and Delivery Date in 2020
header = {
    'DOC_TYPE': 'NB',
    'VENDOR': '0000100000',
    'PURCH_ORG': '0001',
    'PUR_GROUP': '001',
    'COMP_CODE': '0001',
    'CURRENCY': 'EUR'
}

header_x = {
    'DOC_TYPE': 'X',
    'VENDOR': 'X',
    'PURCH_ORG': 'X',
    'PUR_GROUP': 'X',
    'COMP_CODE': 'X',
    'CURRENCY': 'X'
}

items = [{
    'PO_ITEM': '00010',
    'MATERIAL': 'SRAJII',
    'PLANT': '0001',
    'QUANTITY': Decimal('10.000'),
    'PO_UNIT': 'ROL',
    'NET_PRICE': Decimal('150.00'),
    'PRICE_UNIT': Decimal('1')
}]

items_x = [{
    'PO_ITEM': '00010',
    'PO_ITEMX': 'X',
    'MATERIAL': 'X',
    'PLANT': 'X',
    'QUANTITY': 'X',
    'PO_UNIT': 'X',
    'NET_PRICE': 'X',
    'PRICE_UNIT': 'X'
}]

schedules = [{
    'PO_ITEM': '00010',
    'SCHED_LINE': '0001',
    'DELIVERY_DATE': '20201225',
    'QUANTITY': Decimal('10.000')
}]

schedules_x = [{
    'PO_ITEM': '00010',
    'SCHED_LINE': '0001',
    'SCHED_LINEX': 'X',
    'DELIVERY_DATE': 'X',
    'QUANTITY': 'X'
}]

print("\nTesting BAPI_PO_CREATE1 (TESTRUN=X)...")
res = conn.call('BAPI_PO_CREATE1',
                POHEADER=header,
                POHEADERX=header_x,
                POITEM=items,
                POITEMX=items_x,
                POSCHEDULE=schedules,
                POSCHEDULEX=schedules_x,
                TESTRUN='X')

print("EXPPURCHASEORDER:", res.get('EXPPURCHASEORDER'))
returns = res.get('RETURN', [])
for ret in returns:
    print(f"[{ret['TYPE']}] {ret['ID']} {ret['NUMBER']}: {ret['MESSAGE']}")

conn.close()
