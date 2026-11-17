# COA outsource TTA (rancangan docs/RANCANGAN_PROGRAM_TTA_OUTSOURCE.md)
# usage: python3 make_patch.py <TOP in> <F01 in> <outdir>
import sys
top_in, f01_in, out = sys.argv[1:4]
def one(s, old, new):
    assert s.count(old) == 1, ('anchor', old[:80])
    return s.replace(old, new)

top = open(top_in, encoding='utf8').read()
top = top.rstrip('\n') + '''

* ---------------------------------------------------------------------
* Outsource TTA (batch 9* + Z3): base film dari lot TTA (17.11.2026)
* ---------------------------------------------------------------------
TYPES: BEGIN OF TY_TTAMIC,
         VBELN TYPE LIPS-VBELN,
         CHARG TYPE LIPS-CHARG,
         LMIC  TYPE QPMK-MKMNR,
         MMIC  TYPE QPMK-MKMNR,
       END OF TY_TTAMIC.
DATA: GT_TTAMIC      TYPE STANDARD TABLE OF TY_TTAMIC,
      GS_TTAMIC      TYPE TY_TTAMIC,
      GV_TTA         TYPE C LENGTH 1,
      GV_TTA_SRMAT   TYPE MARA-MATNR,
      GV_TTA_JRMAT   TYPE MARA-MATNR,
      GV_ATINN_PLINE TYPE AUSP-ATINN.
'''

s = open(f01_in, encoding='utf8').read()
# 1. cache trace +3 field
s = one(s, "         LOT_SR_CONV_SIBLING2 TYPE QALS-PRUEFLOS,\n       END OF TY_TRACE_DATA.",
"""         LOT_SR_CONV_SIBLING2 TYPE QALS-PRUEFLOS,
         TTA_SRMAT           TYPE MARA-MATNR,
         TTA_JRMAT           TYPE MARA-MATNR,
       END OF TY_TRACE_DATA.""")
# 2. GET_DATA: reset tabel MIC TTA
s = one(s, "  PERFORM ALIAS_RESOLVE.\n", "  REFRESH GT_TTAMIC.\n  PERFORM ALIAS_RESOLVE.\n")
# 3. GET_TRACED_LOTS: cek TTA
s = one(s, "  CONCATENATE V_LINE V_CODE V_MOYE V_SEQ INTO L_MOTHER_ROLL SEPARATED BY SPACE.\n",
"""  CONCATENATE V_LINE V_CODE V_MOYE V_SEQ INTO L_MOTHER_ROLL SEPARATED BY SPACE.
  " Outsource TTA: batch 9* + Z3 -> base film dari lot TTA
  CLEAR: GV_TTA, GV_TTA_SRMAT, GV_TTA_JRMAT.
  PERFORM TTA_CHECK CHANGING GV_TTA.
""")
# 3b. cache hit: pulihkan material TTA
s = one(s, """        LOT_SR_CONV2 = GS_TRACE_DATA-LOT_SR_CONV_SIBLING2.
      ENDIF.
    ENDIF.

    RETURN.
""", """        LOT_SR_CONV2 = GS_TRACE_DATA-LOT_SR_CONV_SIBLING2.
      ENDIF.
    ENDIF.

    IF GV_TTA = 'X'.
      GV_TTA_SRMAT = GS_TRACE_DATA-TTA_SRMAT.
      GV_TTA_JRMAT = GS_TRACE_DATA-TTA_JRMAT.
    ENDIF.
    RETURN.
""")
# 3c. trace TTA sebelum simpan cache
s = one(s, "  \" Setelah selesai mencari semuanya, simpan ke cache\n",
"""  " Outsource TTA: lot base film dari rantai TTA (converting tetap)
  IF GV_TTA = 'X'.
    PERFORM TTA_TRACE CHANGING L_SR_BASE_BATCH LOT_SR_BASE
                               L_JR_BASE_BATCH LOT_JR_BASE
                               GV_TTA_SRMAT GV_TTA_JRMAT.
  ENDIF.
  " Setelah selesai mencari semuanya, simpan ke cache
""")
s = one(s, "  GS_TRACE_DATA-LOT_JR_BASE = LOT_JR_BASE.\n",
"""  GS_TRACE_DATA-LOT_JR_BASE = LOT_JR_BASE.
  GS_TRACE_DATA-TTA_SRMAT = GV_TTA_SRMAT.
  GS_TRACE_DATA-TTA_JRMAT = GV_TTA_JRMAT.
""")
# 4. GET_MIC
s = one(s, "         LV_MT_MK  TYPE QAMV-MERKNR.\n",
"""         LV_MT_MK  TYPE QAMV-MERKNR.
  DATA : LV_QMIC   TYPE QPMK-MKMNR,
         LV_TTABF  TYPE C LENGTH 1.
""")
s = one(s, "    \" Multi-level converting (16/10/2026): MIC tidak ada di lot hasil\n",
"""    " Outsource TTA: MIC mapping -> MIC lot TTA (base film saja)
    LV_QMIC = IT_ZMAP-MIC.
    CLEAR LV_TTABF.
    IF GV_TTA = 'X'.
      IF IT_ZMAP-MAPPING CS 'SR Base Film'.
        LV_TTABF = 'X'.
        PERFORM TTA_MAP_MIC USING IT_ZMAP-MIC GV_TTA_SRMAT INS
                            CHANGING LV_QMIC.
      ELSEIF IT_ZMAP-MAPPING CS 'JR Base Film'.
        LV_TTABF = 'X'.
        PERFORM TTA_MAP_MIC USING IT_ZMAP-MIC GV_TTA_JRMAT INS
                            CHANGING LV_QMIC.
      ENDIF.
    ENDIF.

    " Multi-level converting (16/10/2026): MIC tidak ada di lot hasil
""")
s = one(s, "    IF GT_MT_LOT[] IS NOT INITIAL.\n      CLEAR LV_MT_MK.\n",
"    IF GT_MT_LOT[] IS NOT INITIAL AND LV_TTABF IS INITIAL.\n      CLEAR LV_MT_MK.\n")
s = one(s, """        FROM QAMV
        WHERE PRUEFLOS = INS
          AND VERWMERKM = IT_ZMAP-MIC.

      IF SY-SUBRC EQ 0.
        PERFORM COPY.
""", """        FROM QAMV
        WHERE PRUEFLOS = INS
          AND VERWMERKM = LV_QMIC.

      IF SY-SUBRC EQ 0.
        PERFORM COPY.
        " Outsource TTA: catat MIC lot -> MIC mapping (relabel GET_DATA)
        IF LV_QMIC <> IT_ZMAP-MIC.
          CLEAR GS_TTAMIC.
          GS_TTAMIC-VBELN = IT_DATA-VBELN.
          GS_TTAMIC-CHARG = IT_DATA-CHARG.
          GS_TTAMIC-LMIC  = LV_QMIC.
          GS_TTAMIC-MMIC  = IT_ZMAP-MIC.
          APPEND GS_TTAMIC TO GT_TTAMIC.
        ENDIF.
""")
s = one(s, """  SORT IT_MIC2 BY MIC.
  LOOP AT IT_ZMAP.
    READ TABLE IT_MIC2 WITH KEY MIC = IT_ZMAP-MIC BINARY SEARCH.
""", """  SORT IT_MIC2 BY MIC.
  LOOP AT IT_ZMAP.
    " Outsource TTA: MIC mapping yang terbaca lewat MIC lot dianggap ada
    LV_QMIC = IT_ZMAP-MIC.
    READ TABLE GT_TTAMIC INTO GS_TTAMIC
      WITH KEY VBELN = IT_DATA-VBELN CHARG = IT_DATA-CHARG
               MMIC  = IT_ZMAP-MIC.
    IF SY-SUBRC = 0.
      LV_QMIC = GS_TTAMIC-LMIC.
    ENDIF.
    " Tanpa BINARY SEARCH: APPEND di loop ini merusak urutan IT_MIC2
    READ TABLE IT_MIC2 WITH KEY MIC = LV_QMIC.
""")
# 5. GET_DATA relabel MIC lot TTA -> MIC mapping
s = one(s, """        IT_MIC1-COA_MIC  = IT_MIC1-MIC.
        IF IT_LOT-COA_PATH = 'ALIAS'.
          READ TABLE GT_AMIC_B INTO GS_AMIC
            WITH KEY VBELN = IT_LOT-VBELN
                     MATNR = IT_LOT-MATNR
                     BMIC  = IT_MIC1-MIC.
""", """        IT_MIC1-COA_MIC  = IT_MIC1-MIC.
        " Outsource TTA: tampil dengan MIC mapping, baca dengan MIC lot
        READ TABLE GT_TTAMIC INTO GS_TTAMIC
          WITH KEY VBELN = IT_LOT-VBELN CHARG = IT_LOT-CHARG
                   LMIC  = IT_MIC1-MIC.
        IF SY-SUBRC = 0.
          IT_MIC1-COA_MIC = GS_TTAMIC-MMIC.
        ENDIF.
        IF IT_LOT-COA_PATH = 'ALIAS'.
          READ TABLE GT_AMIC_B INTO GS_AMIC
            WITH KEY VBELN = IT_LOT-VBELN
                     MATNR = IT_LOT-MATNR
                     BMIC  = IT_MIC1-COA_MIC.
""")
s = one(s, """            WHERE MATNR = IT_LOT-MATNR
              AND MIC   = IT_MIC1-MIC
              AND KUNNR = LV_KUNNR
              AND DELETION NE 'X'.""", """            WHERE MATNR = IT_LOT-MATNR
              AND MIC   = IT_MIC1-COA_MIC
              AND KUNNR = LV_KUNNR
              AND DELETION NE 'X'.""")
s = one(s, """            WHERE MATNR = IT_LOT-MATNR
              AND MIC   = IT_MIC1-MIC
              AND KUNNR = ' '
              AND DELETION NE 'X'.""", """            WHERE MATNR = IT_LOT-MATNR
              AND MIC   = IT_MIC1-COA_MIC
              AND KUNNR = ' '
              AND DELETION NE 'X'.""")
# 6. FORM baru
s = s.rstrip('\n') + '''
*&---------------------------------------------------------------------*
*&      Form  TTA_CHECK
*&---------------------------------------------------------------------*
*       Roll outsource TTA: batch berawalan 9 DAN Z3 (token pertama
*       ZZNOMORROLL atau ZZPRODLINE). Keputusan QA 17.11.2026.
*----------------------------------------------------------------------*
FORM TTA_CHECK CHANGING P_TTA.
  DATA: LV_T1  TYPE STRING,
        LV_T2  TYPE STRING,
        LV_OBJ TYPE INOB-OBJEK,
        LV_CU  TYPE INOB-CUOBJ,
        LV_OB2 TYPE AUSP-OBJEK,
        LV_PL  TYPE AUSP-ATWRT.
  CLEAR P_TTA.
  CHECK IT_DATA-CHARG IS NOT INITIAL.
  CHECK IT_DATA-CHARG(1) = '9'.
  SPLIT IT_DATA-NOMSR AT SPACE INTO LV_T1 LV_T2.
  IF LV_T1 = 'Z3'.
    P_TTA = 'X'.
    RETURN.
  ENDIF.
  IF GV_ATINN_PLINE IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = 'ZZPRODLINE'
      IMPORTING
        OUTPUT = GV_ATINN_PLINE.
  ENDIF.
  LV_OBJ = IT_DATA-MATNR.
  LV_OBJ+18 = IT_DATA-CHARG.
  SELECT SINGLE CUOBJ INTO LV_CU FROM INOB
    WHERE KLART = '023'
      AND OBTAB = 'MCH1'
      AND OBJEK = LV_OBJ.
  CHECK SY-SUBRC = 0.
  LV_OB2 = LV_CU.
  SELECT SINGLE ATWRT INTO LV_PL FROM AUSP
    WHERE OBJEK = LV_OB2
      AND ATINN = GV_ATINN_PLINE
      AND KLART = '023'.
  IF LV_PL = 'Z3'.
    P_TTA = 'X'.
  ENDIF.
ENDFORM.                    " TTA_CHECK
*&---------------------------------------------------------------------*
*&      Form  TTA_TRACE
*&---------------------------------------------------------------------*
*       Ikut ZEQM015: roll -> order (101) -> komponen (261) -> vendor
*       batch (MCH1-LICHA) di plant TTA = SR TTA (lot Z04 = SR Base
*       Film, boleh kosong) -> order -> komponen JR, berhenti di JR
*       material I (lot Z02/Z03 = JR Base Film). Vendor batch TTA
*       tidak ketemu -> lot base film tidak diubah.
*----------------------------------------------------------------------*
FORM TTA_TRACE CHANGING P_SRB P_SRLOT P_JRB P_JRLOT
                        P_SRMAT P_JRMAT.
  DATA: LV_AUF TYPE MSEG-AUFNR,
        LV_CM  TYPE MSEG-MATNR,
        LV_CC  TYPE MSEG-CHARG,
        LV_LI  TYPE MCH1-LICHA,
        LV_TB  TYPE MCHA-CHARG,
        LV_TM  TYPE MCHA-MATNR,
        LV_B   TYPE MSEG-CHARG,
        LV_JM  TYPE MSEG-MATNR,
        LV_JC  TYPE MSEG-CHARG,
        LV_LOT TYPE QALS-PRUEFLOS,
        LV_L   TYPE I.
  SELECT SINGLE AUFNR INTO LV_AUF FROM MSEG
    WHERE MATNR = IT_DATA-MATNR
      AND CHARG = IT_DATA-CHARG
      AND BWART = '101'
      AND AUFNR <> SPACE
      AND SMBLN = SPACE.
  CHECK LV_AUF IS NOT INITIAL.
  SELECT SINGLE MATNR CHARG INTO (LV_CM, LV_CC) FROM MSEG
    WHERE AUFNR = LV_AUF
      AND BWART = '261'
      AND SMBLN = SPACE.
  CHECK LV_CC IS NOT INITIAL.
  SELECT SINGLE LICHA INTO LV_LI FROM MCH1
    WHERE MATNR = LV_CM
      AND CHARG = LV_CC.
  CHECK LV_LI IS NOT INITIAL.
  LV_TB = LV_LI.
  SELECT SINGLE MATNR INTO LV_TM FROM MCHA
    WHERE CHARG = LV_TB
      AND WERKS LIKE 'TTA%'.
  CHECK SY-SUBRC = 0.
* SR TTA = SR Base Film
  P_SRB   = LV_TB.
  P_SRMAT = LV_TM.
  CLEAR: P_SRLOT, P_JRB, P_JRLOT, P_JRMAT.
  SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS
    WHERE CHARG = LV_TB
      AND ART   = 'Z04'.
  P_SRLOT = LV_LOT.
* JR TTA material I = JR Base Film
  LV_B = LV_TB.
  DO 5 TIMES.
    CLEAR: LV_AUF, LV_JM, LV_JC.
    SELECT SINGLE AUFNR INTO LV_AUF FROM MSEG
      WHERE CHARG = LV_B
        AND ( BWART = '101' OR BWART = '531' )
        AND AUFNR <> SPACE
        AND SMBLN = SPACE.
    IF LV_AUF IS INITIAL.
      EXIT.
    ENDIF.
    SELECT SINGLE MATNR CHARG INTO (LV_JM, LV_JC) FROM MSEG
      WHERE AUFNR = LV_AUF
        AND BWART = '261'
        AND SMBLN = SPACE
        AND MATNR LIKE 'JR%'.
    IF LV_JC IS INITIAL.
      EXIT.
    ENDIF.
    LV_L = STRLEN( LV_JM ) - 1.
    IF LV_L >= 0 AND LV_JM+LV_L(1) = 'I'.
      P_JRB   = LV_JC.
      P_JRMAT = LV_JM.
      EXIT.
    ENDIF.
    LV_B = LV_JC.
  ENDDO.
  IF P_JRB IS NOT INITIAL.
    CLEAR LV_LOT.
    SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS
      WHERE CHARG = P_JRB
        AND ( ART = 'Z02' OR ART = 'Z03' ).
    IF LV_LOT IS INITIAL.
      LV_TB = P_JRB.
      PERFORM GET_JR_SIBLING_LOT USING LV_TB CHANGING LV_LOT.
    ENDIF.
    P_JRLOT = LV_LOT.
  ENDIF.
ENDFORM.                    " TTA_TRACE
*&---------------------------------------------------------------------*
*&      Form  TTA_MAP_MIC
*&---------------------------------------------------------------------*
*       MIC mapping -> MIC lot TTA, urutan sama dengan alias:
*       EXACT -> RULE -> SUFFIX -> DESC (level S/P/A sama). Kandidat =
*       inspection plan material TTA + MIC lot. Hasil harus ada di lot;
*       tidak ketemu -> P_QMIC = MIC mapping (value 0 seperti sekarang).
*----------------------------------------------------------------------*
FORM TTA_MAP_MIC USING    P_MIC
                          P_MATNR
                          P_LOT
                 CHANGING P_QMIC.
  TYPES: BEGIN OF TY_CND,
           MIC  TYPE QPMK-MKMNR,
           DESC TYPE QPMT-KURZTEXT,
         END OF TY_CND.
  DATA: LT_CND TYPE STANDARD TABLE OF TY_CND,
        LS_CND TYPE TY_CND,
        LS_PL  TYPE TY_APLAN,
        LV_MAT TYPE MARA-MATNR,
        LV_MIC TYPE QPMK-MKMNR,
        LV_NEW TYPE QPMK-MKMNR,
        LV_HIT TYPE I,
        LV_MK  TYPE QAMV-MERKNR,
        LV_DSC TYPE QPMT-KURZTEXT,
        LV_ADS TYPE STRING,
        LV_BDS TYPE STRING.
  P_QMIC = P_MIC.
  CHECK P_MATNR IS NOT INITIAL.
  CHECK P_LOT IS NOT INITIAL.
  LV_MIC = P_MIC.
  LV_MAT = P_MATNR.
  SELECT SINGLE MERKNR INTO LV_MK FROM QAMV
    WHERE PRUEFLOS  = P_LOT
      AND VERWMERKM = LV_MIC.
  CHECK SY-SUBRC <> 0.
  PERFORM ALIAS_LOAD_PLAN USING LV_MAT.
  LOOP AT GT_APLAN INTO LS_PL WHERE MATNR = LV_MAT.
    LS_CND-MIC  = LS_PL-MIC.
    LS_CND-DESC = LS_PL-DESC.
    APPEND LS_CND TO LT_CND.
  ENDLOOP.
  SELECT VERWMERKM KURZTEXT APPENDING TABLE LT_CND
    FROM QAMV
    WHERE PRUEFLOS = P_LOT.
  SORT LT_CND BY MIC.
  DELETE ADJACENT DUPLICATES FROM LT_CND COMPARING MIC.
  CLEAR LV_NEW.
* EXACT / RULE
  IF STRLEN( LV_MIC ) = 8.
    CONCATENATE LV_MIC(1) LV_MAT+2(3) LV_MIC+4(4) INTO LV_NEW.
    READ TABLE LT_CND TRANSPORTING NO FIELDS
      WITH KEY MIC = LV_NEW BINARY SEARCH.
    IF SY-SUBRC <> 0.
      CLEAR LV_NEW.
    ENDIF.
  ENDIF.
* SUFFIX
  IF LV_NEW IS INITIAL AND STRLEN( LV_MIC ) = 8.
    CLEAR LV_HIT.
    LOOP AT LT_CND INTO LS_CND.
      CHECK STRLEN( LS_CND-MIC ) = 8.
      IF LS_CND-MIC(1) = LV_MIC(1) AND LS_CND-MIC+4(4) = LV_MIC+4(4).
        LV_HIT = LV_HIT + 1.
        LV_NEW = LS_CND-MIC.
      ENDIF.
    ENDLOOP.
    IF LV_HIT <> 1.
      CLEAR LV_NEW.
    ENDIF.
  ENDIF.
* DESC (level S/P/A sama)
  IF LV_NEW IS INITIAL.
    CLEAR LV_DSC.
    SELECT SINGLE KURZTEXT INTO LV_DSC FROM QPMT
      WHERE MKMNR = LV_MIC
        AND SPRACHE = 'E'.
    LV_ADS = LV_DSC.
    CONDENSE LV_ADS NO-GAPS.
    TRANSLATE LV_ADS TO UPPER CASE.
    CLEAR LV_HIT.
    IF LV_ADS IS NOT INITIAL.
      LOOP AT LT_CND INTO LS_CND.
        CHECK LS_CND-MIC(1) = LV_MIC(1).
        LV_BDS = LS_CND-DESC.
        CONDENSE LV_BDS NO-GAPS.
        TRANSLATE LV_BDS TO UPPER CASE.
        IF LV_BDS = LV_ADS.
          LV_HIT = LV_HIT + 1.
          LV_NEW = LS_CND-MIC.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF LV_HIT <> 1.
      CLEAR LV_NEW.
    ENDIF.
  ENDIF.
* hasil harus ada di lot
  IF LV_NEW IS NOT INITIAL.
    SELECT SINGLE MERKNR INTO LV_MK FROM QAMV
      WHERE PRUEFLOS  = P_LOT
        AND VERWMERKM = LV_NEW.
    IF SY-SUBRC = 0.
      P_QMIC = LV_NEW.
    ENDIF.
  ENDIF.
ENDFORM.                    " TTA_MAP_MIC
'''
open(f'{out}/ZQMI_COA_TOP.abap', 'w', encoding='utf8').write(top)
open(f'{out}/ZQMI_COA_F01.abap', 'w', encoding='utf8').write(s)
print('ok')
