import pyrfc
from decimal import Decimal

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

header = {
    'DOC_TYPE': 'NB',
    'VENDOR': '0000100000',
    'PURCH_ORG': '0001',
    'PUR_GROUP': '001',
    'COMP_CODE': '0003',
    'CURRENCY': 'EUR'
}

header_x = {
    'DOC_TYPE': 'X',
    'VENDOR': 'X',
    'PURCH_ORG': 'X',
    'PUR_GROUP': 'X',
    'COMP_CODE': 'X',
    'CURRENCY': 'X'
}

items = [{
    'PO_ITEM': '00010',
    'MATERIAL': 'SRAJII',
    'PLANT': '0003',
    'QUANTITY': Decimal('10.000'),
    'PO_UNIT': 'ROL',
    'NET_PRICE': Decimal('150.00'),
    'PRICE_UNIT': Decimal('1')
}]

items_x = [{
    'PO_ITEM': '00010',
    'PO_ITEMX': 'X',
    'MATERIAL': 'X',
    'PLANT': 'X',
    'QUANTITY': 'X',
    'PO_UNIT': 'X',
    'NET_PRICE': 'X',
    'PRICE_UNIT': 'X'
}]

schedules = [{
    'PO_ITEM': '00010',
    'SCHED_LINE': '0001',
    'DELIVERY_DATE': '20201228',
    'QUANTITY': Decimal('10.000')
}]

schedules_x = [{
    'PO_ITEM': '00010',
    'SCHED_LINE': '0001',
    'SCHED_LINEX': 'X',
    'DELIVERY_DATE': 'X',
    'QUANTITY': 'X'
}]

print("Testing BAPI_PO_CREATE1 for Plant 0003 / CoCode 0003 (TESTRUN=X)...")
res = conn.call('BAPI_PO_CREATE1',
                POHEADER=header,
                POHEADERX=header_x,
                POITEM=items,
                POITEMX=items_x,
                POSCHEDULE=schedules,
                POSCHEDULEX=schedules_x,
                TESTRUN='X')

print("EXPPURCHASEORDER:", res.get('EXPPURCHASEORDER'))
returns = res.get('RETURN', [])
for ret in returns:
    print(f"[{ret['TYPE']}] {ret['ID']} {ret['NUMBER']}: {ret['MESSAGE']}")

conn.close()
