import pyrfc
from decimal import Decimal

conn = pyrfc.Connection(ashost='192.168.1.199', sysnr='01', client='130', user='TRSTABAP', passwd='supporter')

task = [{
    'TASK_LIST_USAGE': '1',
    'TASK_LIST_STATUS': '4',
    'PLANT': '1000',
    'DESCRIPTION': 'Jumbo Roll PLE-18 Master Recipe',
    'TASK_MEASURE_UNIT': 'KG',
    'LOT_SIZE_FROM': Decimal('0.0'),
    'LOT_SIZE_TO': Decimal('99999999.0')
}]

mat = [{
    'MATERIAL': 'JRAAAI',
    'PLANT': '1000'
}]

ops = [
    {
        'ACTIVITY': '0010',
        'PLANT': '1000',
        'WORK_CNTR': 'JROPP01',
        'CONTROL_KEY': 'PI01',
        'DESCRIPTION': 'Extrusion Line 1 Waru',
        'BASE_QUANTITY': Decimal('1.0'),
        'OPERATION_MEASURE_UNIT': 'KG',
        'DENOMINATOR': Decimal('1'),
        'NOMINATOR': Decimal('1')
    }
]

print("Calling BAPI_ROUTING_CREATE with PROFILE=PI01, Decimal DENOMINATOR & NOMINATOR...")
try:
    res = conn.call('BAPI_ROUTING_CREATE',
        PROFILE='PI01',
        TASK=task,
        MATERIALTASKALLOCATION=mat,
        OPERATION=ops
    )
    print("GROUP:", res.get('GROUP'))
    print("GROUPCOUNTER:", res.get('GROUPCOUNTER'))
    ret = res.get('RETURN', [])
    for r in ret:
        print(f"[{r.get('TYPE')}] {r.get('MESSAGE')} ({r.get('ID')} {r.get('NUMBER')})")
        
    if res.get('GROUP') and not any(r.get('TYPE') == 'E' for r in ret):
        print("Calling BAPI_TRANSACTION_COMMIT...")
        c_res = conn.call('BAPI_TRANSACTION_COMMIT', WAIT='X')
        print("Commit result:", c_res)
        print("SUCCESS: Master Recipe created and committed!")
    else:
        print("Not committed due to error.")
except Exception as e:
    print("Exception:", e)
