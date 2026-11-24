"""Klasifikasi 144 objek hasil scan full-text ke kelompok dampak (dipakai build_excel.py)."""
A = ['ZBAP_READY_REPORT', 'ZBAP_STOCK_BY_CHAR1', 'ZCOPY_ZBMBC', 'ZTBAP_STOCK_BY_CHAR1', 'ZRM07MLBS',
     'ZHUR_ROLL_LIST_BY_DEL', 'ZHUR_ROLL_LIST_BY_DEL_GG', 'ZQMI_COA', 'ZQMI_PACKING_STATUS',
     'ZQMI_PACKING_STATUS_TTE', 'ZMMR_RETURN_PALLET', 'ZMMR_RETURN_PALLET_W_CYCLE', 'ZMM_TYBROL_TO_BATCH',
     'ZQMI_BARRIER_PASS_FAIL', 'ZQMI_BARRIER_NCR_UPLOAD']
B = ['ZMMR_LABELROL_STANDAR', 'ZMMR_LABELROL_INCHI', 'ZMMR_LABELROL_PM', 'ZLABEL_A211', 'ZMMR_LABELROL_DOCX',
     'ZMMR_LABELROL_WINDOWS', 'ZMMR_LABELROL_NONSAP', 'ZMMR_LABELROL_TYB', 'ZLABELROL_A131', 'ZLABELROL_A132',
     'ZLABELROL_A133', 'ZLABELROL_A136', 'ZLABELROL_A138', 'ZLABELROL_A139', 'ZLABELROL_A400', 'ZLABELROL_A401',
     'ZLABELROL_CHANGE_90', 'ZMMR_CHANGE_LABELROL_WIN']
C = ['ZHUR_LABELPACK', 'ZLABELHU_A146', 'ZLABELHU_A400', 'ZLABELHU_A401',
     'ZMMR_LABELHU_WINDOWS', 'ZMMR_LABELHU_KTNG', 'ZHU_LABEL', 'ZHU_LABEL_1100', 'ZHU_LABEL_GG01',
     'ZHU_LABEL_KTNG', 'ZHU_LABEL_PMI']
CEK = {'ZHU_LABEL_GENT': 'Field "Used Before" dideklarasi, perlu cek apakah dicetak',
       'ZMMR_LABELROL_MODIFIED_KTNG': 'Kolom "Expired Date" ada di ALV, nilainya tidak dihitung di source'}
D = ['ZIC_UPLOAD_SO', 'ZIC_UPLOAD_SO_CKI', 'ZIC_UPLOAD_SO_CKI_2', 'ZSDI_UP_QUOT', 'ZSDI_UP_QUOT_TTA',
     'ZSDI_UP_QUOT_TTE', 'ZSDR_CUSTOMIZING_SALES_MASTER1', 'ZSDR_QUOTATION_LIST', 'ZPPR_PENDING_ORDER_ALF',
     'ZPPR_PENDING_ORDER_SCHLINE', 'ZMMI_GRN_SUBCON_TTE', 'ZMAP_COA_BATCH', 'SAPLZCHARACTERISTICS']
SRC = ['LZTRIASU01', 'Z_GET_PRODUCTION_DATE=========FT']
E_ = ['ZBAP_READY_REPORT_STFN', 'ZBAP_READY_REPORT_ORI', 'ZBAP_STOCK_BY_CHAR', 'ZBMBC_JR', 'ZHUR_READY_REPORT',
      'ZHUR_ROLL_LIST_BY_DEL1', 'ZHUR_ROLL_LIST_BY_DEL2', 'ZHUR_ROLL_LIST_BY_DEL_V2', 'ZITI_ZSD024S',
      'ZHU_LABEL_GG01X', 'ZLABELROL_TES', 'ZTES_LABEL_INCL', 'ZMMR_CHANGE_LABELROL_WIN_BUDI',
      'ZMMI_GRN_SUBCON_TTE_BUDI', 'ZMMR_STOCK_BY_CHAR', 'ZMMR_STOCK_BY_CHAR1', 'ZQMI_BARRIER_PASS_FAIL_CP',
      'ZPPR_PENDING_ORDER_ALF_CP', 'ZPPR_SLITTING_REKAP_KACONG', 'ZPP_UP_CLASS3', 'ZPP_UP_CLASS4',
      'ZPP_UP_CLASS5', 'Z_COBA_HU', 'Z_CONSIGNMENT2', 'Z_POOPEN', 'ZSO', 'Z_SO']

GROUPS = [  # kode, nama, status
    ('A', 'A. Report / monitor / COA / interface', 'Terdampak'),
    ('B', 'B. Label roll', 'Terdampak'),
    ('C', 'C. Label HU / pallet', 'Terdampak'),
    ('S', 'S. Sumber Production Date (FM)', 'Terkait: tidak menampilkan Expired Date'),
    ('D', 'D. Sumber nilai umur simpan / tampilan', 'Terkait: tidak menampilkan Expired Date'),
    ('K', 'K. Perlu cek manual', 'Perlu cek'),
    ('E', 'E. Salinan / uji / lama (tanpa T-code)', 'Kemungkinan tidak dipakai'),
    ('F', 'F. Tidak terkait (arti lain)', 'Tidak terdampak'),
]
GNAME = {g[0]: g[1] for g in GROUPS}
GSTAT = {g[0]: g[2] for g in GROUPS}


ALL = set(A + B + C + D + E_)


def aggregate(objs):
    """Gabung include ke program induknya (kalau induk dikenal), hasil: list record per program."""
    prog = {}
    for o in objs:
        m = (o['masters'] or [o['obj']])[0]
        key = m if m in ALL else o['obj']
        r = prog.setdefault(key, {'prog': key, 'objs': [], 'tcodes': set(), 'hits': set(), 'formula': []})
        r['objs'].append(o['obj'])
        r['tcodes'].update(o['tcodes'])
        r['hits'].update(o['hits'])
        r['formula'] += o['formula']
    return sorted(prog.values(), key=lambda r: r['prog'])


def classify(r):
    k, h = r['prog'], r['hits']
    if k in SRC:
        return 'S', 'FM tanggal produksi (GR 101 non-reversal, fallback MCH1-ERSDA)'
    if k in CEK:
        return 'K', CEK[k]
    if k in E_:
        return 'E', 'Tidak ada T-code; salinan/uji/versi lama'
    for g, lst in (('A', A), ('B', B), ('C', C)):
        if k in lst:
            return g, ''
    if k in D:
        return 'D', 'Membaca/mengisi umur simpan, tidak menghitung tanggal'
    if h <= {'FM_PRODDATE'}:
        return 'F', 'Hanya memakai tanggal produksi, tidak menampilkan expired'
    if h & {'VFDAT', 'HSDAT', 'MHD', 'SLED_FM'}:
        return 'F', 'Shelf life bahan baku / BAPI movement (bukan roll FG)'
    return 'F', 'Kata "expir" dalam arti lain (payment, LC, aging)'
