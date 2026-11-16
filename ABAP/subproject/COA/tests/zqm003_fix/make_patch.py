# Patch ZQM003 = nilai ZQM002. usage: python3 make_patch.py <srcdir-pattern> <outdir>
# pattern berisi {p} -> TOP/F01/ALV
import sys, re
pat, out = sys.argv[1], sys.argv[2]
rd = lambda p: open(pat.format(p=p), encoding='utf8').read()
def one(s, old, new):
    assert s.count(old) == 1, old[:60]
    return s.replace(old, new)
top = rd('TOP')
top = one(top, "        ORIG_CMICMIT TYPE C LENGTH 17,\n      END OF IT_DATA.",
  "        ORIG_CMICMIT TYPE C LENGTH 17,\n"
  "        QM_CMICMIT TYPE C LENGTH 17,  \" nilai sblm ZLOG_COA (ZQM003)\n"
  "      END OF IT_DATA.")
f01 = rd('F01')
f01 = one(f01, "    \" --- BEGIN ZLOG_COA CHECK ---\n",
  "    \" Nilai final sebelum override ZLOG_COA, dipakai ZQM003\n"
  "    IT_DATA-QM_CMICMIT = IT_DATA-CMICMIT.\n"
  "    CONDENSE IT_DATA-QM_CMICMIT.\n\n"
  "    \" --- BEGIN ZLOG_COA CHECK ---\n")
alv = rd('ALV')
alv = one(alv, """  DATA: BEGIN OF LT_UNIQUE OCCURS 0,
          VBELN LIKE LIPS-VBELN,
          MATNR LIKE LIPS-MATNR,
          WERKS LIKE LIPS-WERKS,
          MIC LIKE QAMV-VERWMERKM,
          MICMIT LIKE QAMR-MITTELWERT,
          CMICMIT TYPE C LENGTH 20,
        END OF LT_UNIQUE.
""", "")
alv = one(alv, """  DATA: LV_FINAL_SUM TYPE QAMR-MITTELWERT,
        LV_FINAL_CNT TYPE I,
        LV_FINAL_VAL TYPE QAMR-MITTELWERT,
        LV_FINAL_DEC TYPE I,
        LV_FINAL_UOM TYPE C LENGTH 30.
""", "")
alv = one(alv, "  REFRESH: IT_ALVR, LT_METHOD, LT_RESULT, LT_UNIQUE, LT_FINAL,",
               "  REFRESH: IT_ALVR, LT_METHOD, LT_RESULT, LT_FINAL,")
i = alv.index("  LOOP AT IT_MIC1.\n    LT_UNIQUE-VBELN")
j = alv.index("  SORT LT_FINAL BY VBELN MATNR MIC.\n") + len("  SORT LT_FINAL BY VBELN MATNR MIC.\n")
alv = alv[:i] + """  " Nilai ZQM003 = nilai final ZQM002 (rata-rata per inspection lot
  " di GET_DATA), sebelum override ZLOG_COA. Override di NEW_VALUE.
  LOOP AT IT_DATA.
    CLEAR LT_FINAL.
    LT_FINAL-VBELN   = IT_DATA-VBELN.
    LT_FINAL-MATNR   = IT_DATA-MATNR.
    LT_FINAL-WERKS   = IT_DATA-WERKS.
    LT_FINAL-MIC     = IT_DATA-MIC.
    LT_FINAL-CMICMIT = IT_DATA-QM_CMICMIT.
    APPEND LT_FINAL.
  ENDLOOP.
  SORT LT_FINAL BY VBELN MATNR MIC.
  DELETE ADJACENT DUPLICATES FROM LT_FINAL COMPARING VBELN MATNR MIC.
""" + alv[j:]
assert 'LT_UNIQUE' not in alv and 'LV_FINAL_' not in alv
for p, s in (('TOP', top), ('F01', f01), ('ALV', alv)):
    open(f'{out}/ZQMI_COA_{p}.abap', 'w', encoding='utf8').write(s)
print('ok')
