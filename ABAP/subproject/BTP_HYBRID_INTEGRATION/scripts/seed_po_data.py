import pyrfc
import time

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

prog_name = 'Z_SEED_PO_ITEMS_V2'
job_name = 'Z_SEED_PO_JOB_V2'

abap_source = [
    f"REPORT {prog_name}.",
    "* Seed Master & Transaction Data for BTP Hybrid Integration Demo",
    "DATA: ls_lfm1 TYPE lfm1,",
    "      ls_marc TYPE marc,",
    "      lt_ekko TYPE TABLE OF ekko,",
    "      ls_ekko TYPE ekko,",
    "      lt_ekpo TYPE TABLE OF ekpo,",
    "      ls_ekpo TYPE ekpo,",
    "      lt_eket TYPE TABLE OF eket,",
    "      ls_eket TYPE eket.",
    "",
    "* 1. Maintain Vendor Purchasing Data in LFM1",
    "SELECT SINGLE * FROM lfm1 WHERE lifnr = '0000100000' AND ekorg = '0001' INTO @ls_lfm1.",
    "IF sy-subrc <> 0.",
    "  CLEAR ls_lfm1.",
    "  ls_lfm1-mandt = sy-mandt.",
    "  ls_lfm1-lifnr = '0000100000'.",
    "  ls_lfm1-ekorg = '0001'.",
    "  ls_lfm1-erdat = sy-datum.",
    "  ls_lfm1-ernam = sy-uname.",
    "  ls_lfm1-waers = 'EUR'.",
    "  ls_lfm1-zterm = '0001'.",
    "  ls_lfm1-verkf = 'PT TECH SOLUTIONS INDONESIA'.",
    "  ls_lfm1-telf1 = '021-5551234'.",
    "  ls_lfm1-ekgrp = '001'.",
    "  INSERT lfm1 FROM @ls_lfm1.",
    "ENDIF.",
    "",
    "* 2. Extend Material SRAJII to Plant 0001 in MARC",
    "SELECT SINGLE * FROM marc WHERE matnr = 'SRAJII' AND werks = '0001' INTO @ls_marc.",
    "IF sy-subrc <> 0.",
    "  SELECT SINGLE * FROM marc WHERE matnr = 'SRAJII' AND werks = '0003' INTO @ls_marc.",
    "  IF sy-subrc = 0.",
    "    ls_marc-werks = '0001'.",
    "    INSERT marc FROM @ls_marc.",
    "  ENDIF.",
    "ENDIF.",
    "",
    "* 3. Clean up any existing demo POs 4500000001..4500000010",
    "DELETE FROM ekko WHERE ebeln >= '4500000001' AND ebeln <= '4500000010'.",
    "DELETE FROM ekpo WHERE ebeln >= '4500000001' AND ebeln <= '4500000010'.",
    "DELETE FROM eket WHERE ebeln >= '4500000001' AND ebeln <= '4500000010'.",
    "",
    "* 4. Populate 10 PO records",
    "DO 10 TIMES.",
    "  DATA(lv_idx) = sy-index.",
    "  DATA(lv_ebeln) = CONV ebeln( 4500000000 + lv_idx ).",
    "",
    "  CLEAR ls_ekko.",
    "  ls_ekko-mandt = sy-mandt.",
    "  ls_ekko-ebeln = lv_ebeln.",
    "  ls_ekko-bukrs = '0001'.",
    "  ls_ekko-bstyp = 'F'.",
    "  ls_ekko-bsart = 'NB'.",
    "  ls_ekko-statu = '9'.",
    "  ls_ekko-aedat = sy-datum.",
    "  ls_ekko-ernam = sy-uname.",
    "  ls_ekko-lifnr = '0000100000'.",
    "  ls_ekko-ekorg = '0001'.",
    "  ls_ekko-ekgrp = '001'.",
    "  ls_ekko-waers = 'EUR'.",
    "  ls_ekko-bedat = sy-datum.",
    "  ls_ekko-kufix = '1'.",
    "  APPEND ls_ekko TO lt_ekko.",
    "",
    "  CLEAR ls_ekpo.",
    "  ls_ekpo-mandt = sy-mandt.",
    "  ls_ekpo-ebeln = lv_ebeln.",
    "  ls_ekpo-ebelp = '00010'.",
    "  ls_ekpo-statu = 'A'.",
    "  ls_ekpo-aedat = sy-datum.",
    "  ls_ekpo-matnr = 'SRAJII'.",
    "  ls_ekpo-bukrs = '0001'.",
    "  ls_ekpo-werks = '0001'.",
    "  ls_ekpo-lgort = '0001'.",
    "  ls_ekpo-matkl = '01'.",
    "  ls_ekpo-meins = 'ROL'.",
    "  ls_ekpo-bprme = 'ROL'.",
    "  ls_ekpo-bpumz = 1.",
    "  ls_ekpo-bpumn = 1.",
    "  ls_ekpo-peinh = 1.",
    "  ls_ekpo-prdat = sy-datum.",
    "",
    "  CASE lv_idx.",
    "    WHEN 1.",
    "      ls_ekpo-txz01 = 'Cloud Connector Bridge Adapter - Enterprise Edition'.",
    "      ls_ekpo-menge = 50.",
    "      ls_ekpo-netpr = 450.",
    "    WHEN 2.",
    "      ls_ekpo-txz01 = 'S/4HANA On-Premise Integration Gateway Module'.",
    "      ls_ekpo-menge = 25.",
    "      ls_ekpo-netpr = 850.",
    "    WHEN 3.",
    "      ls_ekpo-txz01 = 'BTP Fiori Launchpad User License - Annual'.",
    "      ls_ekpo-menge = 100.",
    "      ls_ekpo-netpr = 120.",
    "    WHEN 4.",
    "      ls_ekpo-txz01 = 'Business Technology Platform Custom Extension Kit'.",
    "      ls_ekpo-menge = 10.",
    "      ls_ekpo-netpr = 1200.",
    "    WHEN 5.",
    "      ls_ekpo-txz01 = 'Hybrid Architecture Security Token Hardware Key'.",
    "      ls_ekpo-menge = 80.",
    "      ls_ekpo-netpr = 75.",
    "    WHEN 6.",
    "      ls_ekpo-txz01 = 'SAP Build Work Zone Advanced Runtime Instance'.",
    "      ls_ekpo-menge = 5.",
    "      ls_ekpo-netpr = 3500.",
    "    WHEN 7.",
    "      ls_ekpo-txz01 = 'Destination Service High-Performance Router'.",
    "      ls_ekpo-menge = 15.",
    "      ls_ekpo-netpr = 620.",
    "    WHEN 8.",
    "      ls_ekpo-txz01 = 'S/4HANA CDS View Data Replication Accelerator'.",
    "      ls_ekpo-menge = 30.",
    "      ls_ekpo-netpr = 480.",
    "    WHEN 9.",
    "      ls_ekpo-txz01 = 'Enterprise OData Connectivity Middleware Appliance'.",
    "      ls_ekpo-menge = 20.",
    "      ls_ekpo-netpr = 950.",
    "    WHEN 10.",
    "      ls_ekpo-txz01 = 'Cloud Foundry Microservice Application Container'.",
    "      ls_ekpo-menge = 40.",
    "      ls_ekpo-netpr = 310.",
    "  ENDCASE.",
    "  ls_ekpo-netwr = ls_ekpo-menge * ls_ekpo-netpr.",
    "  ls_ekpo-brtwr = ls_ekpo-netwr.",
    "  APPEND ls_ekpo TO lt_ekpo.",
    "",
    "  CLEAR ls_eket.",
    "  ls_eket-mandt = sy-mandt.",
    "  ls_eket-ebeln = lv_ebeln.",
    "  ls_eket-ebelp = '00010'.",
    "  ls_eket-etenr = '0001'.",
    "  ls_eket-eindt = sy-datum + 14.",
    "  ls_eket-menge = ls_ekpo-menge.",
    "  ls_eket-wemng = 0.",
    "  APPEND ls_eket TO lt_eket.",
    "ENDDO.",
    "",
    "INSERT ekko FROM TABLE @lt_ekko.",
    "INSERT ekpo FROM TABLE @lt_ekpo.",
    "INSERT eket FROM TABLE @lt_eket.",
    "COMMIT WORK.",
    "WRITE: / 'Successfully inserted 10 Purchase Orders.'."
]

source_extended = [{'LINE': line} for line in abap_source]

print(f"1. Creating ABAP Program {prog_name}...")
res = conn.call('RPY_PROGRAM_INSERT',
                PROGRAM_NAME=prog_name,
                TITLE_STRING='Seed 10 Purchase Orders for BTP Fiori Elements',
                DEVELOPMENT_CLASS='$TMP',
                SUPPRESS_DIALOG='X',
                SOURCE_EXTENDED=source_extended)
print("Program inserted successfully!")

# 2. Run Program via XBP Background Job
print("2. Starting XMI Logon...")
res_logon = conn.call('BAPI_XMI_LOGON',
                      EXTCOMPANY='SAP',
                      EXTPRODUCT='BTP_DEMO',
                      INTERFACE='XBP',
                      VERSION='2.0')
print("XMI Session:", res_logon['SESSIONID'])

print(f"3. Opening Job {job_name}...")
res_open = conn.call('BAPI_XBP_JOB_OPEN', EXTERNAL_USER_NAME='TRSTABAP', JOBNAME=job_name)
job_count = res_open['JOBCOUNT']
print(f"Job Count: {job_count}")

print(f"4. Adding ABAP Step {prog_name}...")
res_step = conn.call('BAPI_XBP_JOB_ADD_ABAP_STEP',
                     EXTERNAL_USER_NAME='TRSTABAP',
                     JOBNAME=job_name,
                     JOBCOUNT=job_count,
                     ABAP_PROGRAM_NAME=prog_name,
                     SAP_USER_NAME='TRSTABAP')
print("Step result:", res_step['RETURN'])

print("5. Starting Job immediately...")
res_start = conn.call('BAPI_XBP_JOB_START_IMMEDIATELY',
                      EXTERNAL_USER_NAME='TRSTABAP',
                      JOBNAME=job_name,
                      JOBCOUNT=job_count)
print("Start result:", res_start['RETURN'])

# Wait a moment for job to complete
print("Waiting for job execution to complete...")
time.sleep(3)

# 6. Verify Job Status in TBTCO
res_job = conn.call('RFC_READ_TABLE', QUERY_TABLE='TBTCO',
                    FIELDS=[{'FIELDNAME': 'JOBNAME'}, {'FIELDNAME': 'JOBCOUNT'}, {'FIELDNAME': 'STATUS'}],
                    OPTIONS=[{'TEXT': f"JOBNAME = '{job_name}' AND JOBCOUNT = '{job_count}'"}],
                    ROWCOUNT=1)
print("Job TBTCO:", res_job['DATA'])

# 7. Verify LFM1
res_lfm1 = conn.call('RFC_READ_TABLE', QUERY_TABLE='LFM1',
                     FIELDS=[{'FIELDNAME': 'LIFNR'}, {'FIELDNAME': 'EKORG'}, {'FIELDNAME': 'WAERS'}],
                     OPTIONS=[{'TEXT': "LIFNR = '0000100000'"}],
                     ROWCOUNT=5)
print(f"LFM1 Records ({len(res_lfm1['DATA'])}):")
for r in res_lfm1['DATA']:
    print(' ', r['WA'])

# 8. Verify EKKO count
res_ekko = conn.call('RFC_READ_TABLE', QUERY_TABLE='EKKO',
                     FIELDS=[{'FIELDNAME': 'EBELN'}, {'FIELDNAME': 'BSART'}, {'FIELDNAME': 'LIFNR'}, {'FIELDNAME': 'WAERS'}],
                     ROWCOUNT=20)
print(f"EKKO Records ({len(res_ekko['DATA'])}):")
for r in res_ekko['DATA']:
    print(' ', r['WA'])

# 9. Verify EKPO count
res_ekpo = conn.call('RFC_READ_TABLE', QUERY_TABLE='EKPO',
                     FIELDS=[{'FIELDNAME': 'EBELN'}, {'FIELDNAME': 'EBELP'}, {'FIELDNAME': 'TXZ01'}],
                     ROWCOUNT=20)
print(f"EKPO Records ({len(res_ekpo['DATA'])}):")
for r in res_ekpo['DATA']:
    print(' ', r['WA'])

conn.close()
