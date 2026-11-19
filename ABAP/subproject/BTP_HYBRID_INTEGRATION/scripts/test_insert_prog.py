import pyrfc

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

prog_name = 'Z_SEED_PO_ITEMS'
source = [
    {'LINE': 'REPORT Z_SEED_PO_ITEMS.'},
    {'LINE': 'WRITE: / \'Seeding Purchase Orders for BTP...\'.' }
]

try:
    res = conn.call('RPY_PROGRAM_INSERT',
                    PROGRAM_NAME=prog_name,
                    TITLE_STRING='Seed Purchase Orders for BTP Fiori Demo',
                    DEVELOPMENT_CLASS='$TMP',
                    SUPPRESS_DIALOG='X',
                    SOURCE_EXTENDED=source)
    print("RPY_PROGRAM_INSERT success:", res)
except Exception as e:
    print("RPY_PROGRAM_INSERT error:", e)

conn.close()
