import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

views = ['CPURORDITEMMONI', 'PPURORDITEMMNTR', 'PPURORDITEM', 'PPOITEMCASTDAMT']

for v in views:
    res = conn.call('RFC_READ_TABLE', QUERY_TABLE='DD28S',
                    FIELDS=[{'FIELDNAME': 'VIEWNAME'}, {'FIELDNAME': 'TABNAME'}, {'FIELDNAME': 'FIELDNAME'}, {'FIELDNAME': 'OPERATOR'}, {'FIELDNAME': 'VALUE'}],
                    OPTIONS=[{'TEXT': f"VIEWNAME = '{v}'"}],
                    ROWCOUNT=50)
    print(f"\n--- DD28S conditions for {v} ({len(res['DATA'])}) ---")
    for r in res['DATA']:
        print(' ', r['WA'])

conn.close()
