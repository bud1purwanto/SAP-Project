# Opsi D limit alias: upper/lower dari master data material asli
# (ZMAP_COA material asli umum + customer, sisi kosong = spec lot),
# limit mapping material alias tidak dipakai.
# usage: python3 make_patch.py <F01 in> <F01 out>
import sys
src, out = sys.argv[1], sys.argv[2]
s = open(src, encoding='utf8').read()
def one(old, new):
    global s
    assert s.count(old) == 1, old[:70]
    s = s.replace(old, new)
one("""      " Replace lower limit if custom mapping exists in ZMAP_COA
      IF LS_COA_MAP-LOWER_LIMIT IS NOT INITIAL.
        IT_DATA-MICMIN = LS_COA_MAP-LOWER_LIMIT.
        PERFORM PARSE_LIMIT_TO_RAW USING LS_COA_MAP-LOWER_LIMIT
          CHANGING IT_DATA-RAW_MICMIN.
      ENDIF.

      " Replace upper limit if custom mapping exists in ZMAP_COA
      IF LS_COA_MAP-UPPER_LIMIT IS NOT INITIAL.
        IT_DATA-MICMAX = LS_COA_MAP-UPPER_LIMIT.
        PERFORM PARSE_LIMIT_TO_RAW USING LS_COA_MAP-UPPER_LIMIT
          CHANGING IT_DATA-RAW_MICMAX.
      ENDIF.
    ENDIF.
""", """      " Alias COA (Opsi D): limit dari master data material asli
      " (ALIAS_APPLY_LIMIT), limit mapping material alias tidak dipakai
      IF IT_DATA-COA_PATH <> 'ALIAS'.
      " Replace lower limit if custom mapping exists in ZMAP_COA
      IF LS_COA_MAP-LOWER_LIMIT IS NOT INITIAL.
        IT_DATA-MICMIN = LS_COA_MAP-LOWER_LIMIT.
        PERFORM PARSE_LIMIT_TO_RAW USING LS_COA_MAP-LOWER_LIMIT
          CHANGING IT_DATA-RAW_MICMIN.
      ENDIF.

      " Replace upper limit if custom mapping exists in ZMAP_COA
      IF LS_COA_MAP-UPPER_LIMIT IS NOT INITIAL.
        IT_DATA-MICMAX = LS_COA_MAP-UPPER_LIMIT.
        PERFORM PARSE_LIMIT_TO_RAW USING LS_COA_MAP-UPPER_LIMIT
          CHANGING IT_DATA-RAW_MICMAX.
      ENDIF.
      ENDIF.
    ENDIF.
""")
one("""    " Alias COA: limit gabungan (opsi limit menunggu keputusan QA)
    IF IT_DATA-COA_PATH = 'ALIAS'.""", """    " Alias COA: limit dari master data material asli (Opsi D)
    IF IT_DATA-COA_PATH = 'ALIAS'.""")
one("""*       Limit COA gabungan. Opsi limit (A / B1 / B2 / C) menunggu
*       keputusan QA, lihat RANCANGAN_PROGRAM_ALIAS_ZQM002.md §6.
*       Sementara: limit mapping material alias (kalau terisi), sisi
*       kosong = spec lot wakil (sama dengan perilaku program sekarang).
*----------------------------------------------------------------------*
FORM ALIAS_APPLY_LIMIT CHANGING PS_DATA LIKE IT_DATA.
  CHECK PS_DATA-COA_PATH = 'ALIAS'.
ENDFORM.""", """*       Opsi D (keputusan QA 17.11.2026): upper/lower dari master
*       data material asli roll wakil, sama dengan cetak as-is:
*       ZMAP_COA material asli (umum, ditimpa customer bila diisi)
*       untuk MIC asli batch; sisi kosong = spec lot (QAMV),
*       tanpa lot = spec master MIC asli (QPMK).
*       Dalam 1 alias spec material asli pasti sama (info QA).
*----------------------------------------------------------------------*
FORM ALIAS_APPLY_LIMIT CHANGING PS_DATA LIKE IT_DATA.
  DATA: LV_KUN  TYPE LIKP-KUNAG,
        LV_LOW  TYPE ZMAP_COA-LOWER_LIMIT,
        LV_UPP  TYPE ZMAP_COA-UPPER_LIMIT,
        LV_CLOW TYPE ZMAP_COA-LOWER_LIMIT,
        LV_CUPP TYPE ZMAP_COA-UPPER_LIMIT.
  DATA: LV_MIN TYPE QPMK-TOLERANZUN,
        LV_MAX TYPE QPMK-TOLERANZOB,
        LV_DEC TYPE I,
        LV_UOM TYPE C LENGTH 30.
  CHECK PS_DATA-COA_PATH = 'ALIAS'.
  CHECK PS_DATA-BATCH_MIC IS NOT INITIAL.
  CLEAR: LV_KUN, LV_LOW, LV_UPP, LV_CLOW, LV_CUPP.
  " Tanpa lot: spec dasar dari master MIC asli (QPMK), seperti as-is
  IF PS_DATA-INSLOT IS INITIAL.
    CLEAR: LV_MIN, LV_MAX.
    SELECT SINGLE TOLERANZUN TOLERANZOB INTO (LV_MIN, LV_MAX)
      FROM QPMK
      WHERE MKMNR = PS_DATA-BATCH_MIC
        AND WERKS = PS_DATA-WERKS.
    IF SY-SUBRC <> 0.
      SELECT SINGLE TOLERANZUN TOLERANZOB INTO (LV_MIN, LV_MAX)
        FROM QPMK
        WHERE MKMNR = PS_DATA-BATCH_MIC.
    ENDIF.
    IF SY-SUBRC = 0.
      PERFORM MICFMT USING PS_DATA-BATCH_MIC PS_DATA-WERKS
              CHANGING LV_DEC LV_UOM.
      WRITE LV_MIN TO PS_DATA-MICMIN EXPONENT 0
        DECIMALS LV_DEC LEFT-JUSTIFIED.
      WRITE LV_MAX TO PS_DATA-MICMAX EXPONENT 0
        DECIMALS LV_DEC LEFT-JUSTIFIED.
      PS_DATA-RAW_MICMIN = LV_MIN.
      PS_DATA-RAW_MICMAX = LV_MAX.
    ENDIF.
  ENDIF.
  SELECT SINGLE LOWER_LIMIT UPPER_LIMIT INTO (LV_LOW, LV_UPP)
    FROM ZMAP_COA
    WHERE MATNR    = PS_DATA-MATNR
      AND MIC      = PS_DATA-BATCH_MIC
      AND KUNNR    = ' '
      AND DELETION NE 'X'.
  SELECT SINGLE KUNAG INTO LV_KUN FROM LIKP
    WHERE VBELN = PS_DATA-VBELN.
  IF LV_KUN IS NOT INITIAL.
    SELECT SINGLE LOWER_LIMIT UPPER_LIMIT INTO (LV_CLOW, LV_CUPP)
      FROM ZMAP_COA
      WHERE MATNR    = PS_DATA-MATNR
        AND MIC      = PS_DATA-BATCH_MIC
        AND KUNNR    = LV_KUN
        AND DELETION NE 'X'.
    IF SY-SUBRC = 0.
      IF LV_CLOW IS NOT INITIAL.
        LV_LOW = LV_CLOW.
      ENDIF.
      IF LV_CUPP IS NOT INITIAL.
        LV_UPP = LV_CUPP.
      ENDIF.
    ENDIF.
  ENDIF.
  IF LV_LOW IS NOT INITIAL.
    PS_DATA-MICMIN = LV_LOW.
    PERFORM PARSE_LIMIT_TO_RAW USING LV_LOW
      CHANGING PS_DATA-RAW_MICMIN.
  ENDIF.
  IF LV_UPP IS NOT INITIAL.
    PS_DATA-MICMAX = LV_UPP.
    PERFORM PARSE_LIMIT_TO_RAW USING LV_UPP
      CHANGING PS_DATA-RAW_MICMAX.
  ENDIF.
ENDFORM.""")
open(out, 'w', encoding='utf8').write(s)
print('ok')
