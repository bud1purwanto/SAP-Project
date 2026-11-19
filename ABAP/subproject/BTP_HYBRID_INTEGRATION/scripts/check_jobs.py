import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

for fn in ['JOB_OPEN', 'JOB_SUBMIT', 'JOB_CLOSE']:
    try:
        res = conn.call('RFC_GET_FUNCTION_INTERFACE', FUNCNAME=fn)
        print(f"{fn}: REMOTE_CALL='{res.get('REMOTE_CALL')}'")
    except Exception as e:
        print(f"{fn}: error {e}")

conn.close()
