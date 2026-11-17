# ZQM002: kolom Material = material alias (COA_MAT) utk baris jalur ALIAS.
# usage: python3 make_patch.py <srcdir> <outdir>
import sys
src, out = sys.argv[1], sys.argv[2]
def one(s, old, new):
    assert s.count(old) == 1, old[:70]
    return s.replace(old, new)
f02 = open(f'{src}/ZQMI_COA_F02.abap', encoding='utf8').read()
f02 = one(f02, """MODULE TCERTI_GET_LINES OUTPUT.
  G_TCERTI_LINES = SY-LOOPC.
""", """MODULE TCERTI_GET_LINES OUTPUT.
  G_TCERTI_LINES = SY-LOOPC.
  " Alias COA: kolom Material tampil material alias (header line saja,
  " isi tabel IT_DATA tetap material asli; PAI hanya TRANSPORTING
  " CHK CMICMIT RANGE_FLAG)
  IF IT_DATA-COA_PATH = 'ALIAS' AND IT_DATA-COA_MAT IS NOT INITIAL.
    IT_DATA-MATNR = IT_DATA-COA_MAT.
  ENDIF.
""")
f01 = open(f'{src}/ZQMI_COA_F01.abap', encoding='utf8').read()
f01 = one(f01, "    IT_EXPORT-MATNR = IT_DATA-MATNR.\n",
"""    IT_EXPORT-MATNR = IT_DATA-MATNR.
    " Alias COA: material alias, sama dengan layar ZQM002
    IF IT_DATA-COA_PATH = 'ALIAS' AND IT_DATA-COA_MAT IS NOT INITIAL.
      IT_EXPORT-MATNR = IT_DATA-COA_MAT.
    ENDIF.
""")
for n, s in (('F01', f01), ('F02', f02)):
    open(f'{out}/ZQMI_COA_{n}.abap', 'w', encoding='utf8').write(s)
print('ok')
