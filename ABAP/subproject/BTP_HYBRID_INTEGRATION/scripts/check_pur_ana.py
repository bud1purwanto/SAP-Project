import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

for tab in ['IPURANACONF', 'PPURORDITEM', 'PPOITEMENH']:
    try:
        res = conn.call('RFC_READ_TABLE', QUERY_TABLE=tab, ROWCOUNT=5)
        print(f"{tab}: {len(res['DATA'])} rows")
    except Exception as e:
        print(f"{tab}: error {e}")

conn.close()
