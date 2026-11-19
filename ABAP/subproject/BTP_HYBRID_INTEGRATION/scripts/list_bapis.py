import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

queries = [
    "FUNCNAME LIKE 'BAPI%BUPA%'",
    "FUNCNAME LIKE 'BAPI%SUPPLIER%'",
    "FUNCNAME LIKE 'BAPI%VENDOR%'",
    "FUNCNAME LIKE 'BAPI%PURCH%'"
]

for q in queries:
    res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TFDIR',
                    FIELDS=[{'FIELDNAME': 'FUNCNAME'}],
                    OPTIONS=[{'TEXT': f"FMODE = 'R' AND {q}"}],
                    ROWCOUNT=100)
    print(f"\n--- {q} ({len(res['DATA'])} items) ---")
    for r in res['DATA'][:25]:
        print(' ', r['WA'].strip())

conn.close()
