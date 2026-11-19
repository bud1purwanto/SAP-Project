import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

res = conn.call('RFC_READ_TABLE', QUERY_TABLE='TCURR',
                FIELDS=[{'FIELDNAME': 'KURST'}, {'FIELDNAME': 'FCURR'}, {'FIELDNAME': 'TCURR'}, {'FIELDNAME': 'UKURS'}],
                OPTIONS=[{'TEXT': "KURST = 'M' AND FCURR = 'EUR'"}],
                ROWCOUNT=10)

print(f"TCURR for KURST=M and FCURR=EUR ({len(res['DATA'])}):")
for r in res['DATA']:
    print(' ', r['WA'])

res_eur_eur = conn.call('RFC_READ_TABLE', QUERY_TABLE='TCURR',
                        FIELDS=[{'FIELDNAME': 'KURST'}, {'FIELDNAME': 'FCURR'}, {'FIELDNAME': 'TCURR'}, {'FIELDNAME': 'UKURS'}],
                        OPTIONS=[{'TEXT': "FCURR = 'EUR' AND TCURR = 'EUR'"}],
                        ROWCOUNT=10)
print(f"TCURR EUR->EUR ({len(res_eur_eur['DATA'])}):")
for r in res_eur_eur['DATA']:
    print(' ', r['WA'])

conn.close()
