import glob, os

dos = ['0085006234', '0085006235', '0085006240', '0085006241', '0085006242', '0085006243', '0085006244', '0085006245', '0085006270', '0085006271', '0085006272', '0085006276', '0085006277', '0085006278', '0085006279', '0085006280', '0085006281', '0085006282', '0085006284', '0085006285', '0085006286']

base = '/data/Projects/SAP/ABAP/subproject/COA/outputs/'
missing = []
for d in dos:
    alv = f'{base}screen_zqm002_{d}_alv.png'
    sel = f'{base}screen_zqm002_{d}_sel.png'
    if not os.path.exists(alv):
        # check alt
        alt_alv = f'{base}screen_zqm002_do{d[-4:]}_alv.png'
        if not os.path.exists(alt_alv):
            missing.append((d, 'alv'))
    if not os.path.exists(sel):
        alt_sel = f'{base}screen_zqm002_do{d[-4:]}_sel.png'
        if not os.path.exists(alt_sel):
            missing.append((d, 'sel'))

print('Missing screenshots:', missing)
