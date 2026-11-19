import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

for fn in ['FLBPC_MAINTAIN_VENDOR_SAVE', 'VENDOR_SAVE', 'VENDOR_SAVE_BACKGROUND', 'ME_MIX_VENDOR_DATA']:
    try:
        res = conn.call('RFC_GET_FUNCTION_INTERFACE', FUNCNAME=fn)
        remote = res.get('REMOTE_CALL', '')
        print(f"{fn}: REMOTE_CALL='{remote}'")
    except Exception as e:
        print(f"{fn}: error {e}")

conn.close()
