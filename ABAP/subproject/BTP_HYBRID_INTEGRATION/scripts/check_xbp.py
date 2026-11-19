import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

for fn in ['BAPI_XBP_JOB_OPEN', 'BAPI_XBP_JOB_ADD_ABAP_STEP', 'BAPI_XBP_JOB_CLOSE', 'BAPI_XBP_JOB_START_IMMEDIATELY']:
    try:
        res = conn.call('RFC_GET_FUNCTION_INTERFACE', FUNCNAME=fn)
        print(f"{fn}: REMOTE_CALL='{res.get('REMOTE_CALL')}'")
    except Exception as e:
        print(f"{fn}: error {e}")

conn.close()
