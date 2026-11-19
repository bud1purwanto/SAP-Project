import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

for p in ['Z_TEST', 'Z_TEST1', 'Z_TEST2', 'Z_TEST3', 'Z_TEST4', 'ZBUDI']:
    try:
        res = conn.call('RPY_PROGRAM_READ', PROGRAM_NAME=p)
        print(f"\n--- {p} ({len(res['SOURCE_EXTENDED'])} lines) ---")
        for line in res['SOURCE_EXTENDED'][:10]:
            print(line['LINE'])
    except Exception as e:
        print(f"{p}: error {e}")

conn.close()
