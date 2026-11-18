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
  DATA: LV_TTAMAT TYPE MARA-MATNR,
        LV_TTABAT TYPE MCH1-CHARG.
  CLEAR: GV_TTA, GV_TTA_SRMAT, GV_TTA_JRMAT.
  PERFORM TTA_CHECK USING IT_DATA-MATNR IT_DATA-CHARG IT_DATA-NOMSR
                    CHANGING GV_TTA.
""")
# 3b. cache hit: pulihkan material TTA
s = one(s, """        LOT_SR_CONV2 = GS_TRACE_DATA-LOT_SR_CONV_SIBLING2.
      ENDIF.
    ENDIF.

    RETURN.
""", """        LOT_SR_CONV2 = GS_TRACE_DATA-LOT_SR_CONV_SIBLING2.
      ENDIF.
    ENDIF.

    IF GS_TRACE_DATA-TTA_SRMAT IS NOT INITIAL OR
       GS_TRACE_DATA-TTA_JRMAT IS NOT INITIAL.
      GV_TTA = 'X'.
      GV_TTA_SRMAT = GS_TRACE_DATA-TTA_SRMAT.
      GV_TTA_JRMAT = GS_TRACE_DATA-TTA_JRMAT.
    ENDIF.
    RETURN.
""")
# 3c. trace TTA sebelum simpan cache
s = one(s, "  \" Setelah selesai mencari semuanya, simpan ke cache\n",
"""  " Outsource TTA: roll DO langsung TTA, atau SR Base Film (batch 9*)
  " di alur converting. Stage converting tetap logika lama.
  IF GV_TTA = 'X'.
    PERFORM TTA_TRACE USING IT_DATA-MATNR IT_DATA-CHARG
                      CHANGING L_SR_BASE_BATCH LOT_SR_BASE
                               L_JR_BASE_BATCH LOT_JR_BASE
                               GV_TTA_SRMAT GV_TTA_JRMAT.
  ELSEIF L_SR_BASE_BATCH IS NOT INITIAL AND
         L_SR_BASE_BATCH <> IT_DATA-CHARG.
    CLEAR LV_TTAMAT.
    LV_TTABAT = L_SR_BASE_BATCH.
    SELECT SINGLE MATNR INTO LV_TTAMAT FROM MCH1
      WHERE CHARG = L_SR_BASE_BATCH.
    IF SY-SUBRC = 0.
      PERFORM TTA_CHECK USING LV_TTAMAT LV_TTABAT SPACE
                        CHANGING GV_TTA.
    ENDIF.
    IF GV_TTA = 'X'.
      PERFORM TTA_TRACE USING LV_TTAMAT LV_TTABAT
                        CHANGING L_SR_BASE_BATCH LOT_SR_BASE
                                 L_JR_BASE_BATCH LOT_JR_BASE
                                 GV_TTA_SRMAT GV_TTA_JRMAT.
    ENDIF.
  ENDIF.
  IF GV_TTA = 'X' AND GV_TTA_SRMAT IS INITIAL AND
     GV_TTA_JRMAT IS INITIAL.
    CLEAR GV_TTA.
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
FORM TTA_CHECK USING    P_MATNR P_CHARG P_NOMSR
               CHANGING P_TTA.
  DATA: LV_T1  TYPE STRING,
        LV_T2  TYPE STRING,
        LV_NM  TYPE STRING,
        LV_OBJ TYPE INOB-OBJEK,
        LV_CU  TYPE INOB-CUOBJ,
        LV_OB2 TYPE AUSP-OBJEK,
        LV_PL  TYPE AUSP-ATWRT,
        LV_RL  TYPE AUSP-ATWRT.
  CLEAR P_TTA.
  CHECK P_CHARG IS NOT INITIAL.
  CHECK P_CHARG(1) = '9'.
  LV_NM = P_NOMSR.
  IF GV_ATINN_PLINE IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
      EXPORTING
        INPUT  = 'ZZPRODLINE'
      IMPORTING
        OUTPUT = GV_ATINN_PLINE.
  ENDIF.
  LV_OBJ = P_MATNR.
  LV_OBJ+18 = P_CHARG.
  SELECT SINGLE CUOBJ INTO LV_CU FROM INOB
    WHERE KLART = '023'
      AND OBTAB = 'MCH1'
      AND OBJEK = LV_OBJ.
  CHECK SY-SUBRC = 0.
  LV_OB2 = LV_CU.
  IF LV_NM IS INITIAL.
    SELECT SINGLE ATWRT INTO LV_RL FROM AUSP
      WHERE OBJEK = LV_OB2
        AND ATINN = ATINN_ROLL
        AND KLART = '023'.
    LV_NM = LV_RL.
  ENDIF.
  SPLIT LV_NM AT SPACE INTO LV_T1 LV_T2.
  IF LV_T1 = 'Z3'.
    P_TTA = 'X'.
    RETURN.
  ENDIF.
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
*       Sama dengan ZEQM015 (ZQMR_TRACEABILITY_TR_TTE UPDATEDATA):
*       - GR 101 sah: pasangan batal dibuang, ambil yang paling awal
*       - order gabungan lewat AFPO-MILL_OC_AUFNR_U, komponen AUFM 261
*       - batch SR: MCH1-LICHA -> MSEG 601 (antar plant)
*       - GR tanpa order (SUBCONTRACT): MSEG 543 di dokumen GR itu
*       Batch hasil = SR TTA (lot Z04 = SR Base Film, boleh kosong),
*       lalu naik ke JR material I (lot Z02/Z03 = JR Base Film).
*       Tidak ketemu -> lot base film tidak diubah.
*----------------------------------------------------------------------*
FORM TTA_TRACE USING    P_MATNR P_CHARG
               CHANGING P_SRB P_SRLOT P_JRB P_JRLOT
                        P_SRMAT P_JRMAT.
  TYPES: BEGIN OF LTY_CMP,
           MATNR TYPE AUFM-MATNR,
           CHARG TYPE AUFM-CHARG,
         END OF LTY_CMP.
  DATA: LT_CMP TYPE STANDARD TABLE OF LTY_CMP,
        LS_CMP TYPE LTY_CMP,
        LV_AUF TYPE MSEG-AUFNR,
        LV_MBL TYPE MSEG-MBLNR,
        LV_DT  TYPE MKPF-CPUDT,
        LV_CMB TYPE AFPO-AUFNR,
        LV_TB  TYPE MSEG-CHARG,
        LV_TM  TYPE MSEG-MATNR,
        LV_B   TYPE MSEG-CHARG,
        LV_BM  TYPE MSEG-MATNR,
        LV_JM  TYPE MSEG-MATNR,
        LV_JC  TYPE MSEG-CHARG,
        LV_LOT TYPE QALS-PRUEFLOS,
        LV_L   TYPE I.
* Roll sendiri: vendor batch (601) / subcontract (543)
  PERFORM TTA_SRC USING P_MATNR P_CHARG CHANGING LV_TM LV_TB.
  IF LV_TB IS INITIAL.
*   Roll -> order -> komponen 261 -> vendor batch / subcontract
    PERFORM TTA_GR101 USING P_MATNR P_CHARG
                      CHANGING LV_AUF LV_MBL LV_DT.
    CHECK LV_AUF IS NOT INITIAL.
    PERFORM TTA_COMBINE USING LV_AUF CHANGING LV_CMB.
    SELECT MATNR CHARG INTO TABLE LT_CMP FROM AUFM
      WHERE AUFNR = LV_CMB
        AND BWART = '261'.
    SORT LT_CMP BY MATNR CHARG.
    DELETE ADJACENT DUPLICATES FROM LT_CMP COMPARING MATNR CHARG.
    LOOP AT LT_CMP INTO LS_CMP WHERE CHARG IS NOT INITIAL.
      PERFORM TTA_SRC USING LS_CMP-MATNR LS_CMP-CHARG
                      CHANGING LV_TM LV_TB.
      IF LV_TB IS NOT INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  CHECK LV_TB IS NOT INITIAL.
* SR TTA = SR Base Film
  P_SRB   = LV_TB.
  P_SRMAT = LV_TM.
  CLEAR: P_SRLOT, P_JRB, P_JRLOT, P_JRMAT.
  SELECT SINGLE PRUEFLOS INTO LV_LOT FROM QALS
    WHERE CHARG = LV_TB
      AND ART   = 'Z04'.
  P_SRLOT = LV_LOT.
* JR TTA material I = JR Base Film
  LV_B  = LV_TB.
  LV_BM = LV_TM.
  DO 5 TIMES.
    CLEAR: LV_AUF, LV_JM, LV_JC, LV_CMB.
    PERFORM TTA_GR101 USING LV_BM LV_B
                      CHANGING LV_AUF LV_MBL LV_DT.
    IF LV_AUF IS INITIAL.
*     SR hasil slitting: 531 di order JR
      SELECT SINGLE AUFNR INTO LV_AUF FROM MSEG
        WHERE MATNR = LV_BM
          AND CHARG = LV_B
          AND BWART = '531'
          AND AUFNR <> SPACE
          AND SMBLN = SPACE.
    ENDIF.
    IF LV_AUF IS INITIAL.
      EXIT.
    ENDIF.
    PERFORM TTA_COMBINE USING LV_AUF CHANGING LV_CMB.
    SELECT MATNR CHARG INTO (LV_JM, LV_JC) FROM AUFM
      UP TO 1 ROWS
      WHERE AUFNR = LV_CMB
        AND BWART = '261'
        AND MATNR LIKE 'JR%'.
    ENDSELECT.
    IF LV_JC IS INITIAL.
      EXIT.
    ENDIF.
    LV_L = STRLEN( LV_JM ) - 1.
    IF LV_L >= 0 AND LV_JM+LV_L(1) = 'I'.
      P_JRB   = LV_JC.
      P_JRMAT = LV_JM.
      EXIT.
    ENDIF.
    LV_B  = LV_JC.
    LV_BM = LV_JM.
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
*&      Form  TTA_SRC
*&---------------------------------------------------------------------*
*       Batch asal satu level di atas (ZEQM015 IT_PREBATCH):
*       1. material SR: MCH1-LICHA -> MSEG 601 dengan CHARG = LICHA
*       2. GR 101 tanpa order (SUBCONTRACT): MSEG 543 di dokumen GR
*       Ambil yang pertama ketemu (urutan 601, lalu 543).
*----------------------------------------------------------------------*
FORM TTA_SRC USING    P_MATNR P_CHARG
             CHANGING P_TM P_TB.
  DATA: LV_LI  TYPE MCH1-LICHA,
        LV_MAT TYPE MARA-MATNR,
        LV_AUF TYPE MSEG-AUFNR,
        LV_MBL TYPE MSEG-MBLNR,
        LV_DT  TYPE MKPF-CPUDT.
  CLEAR: P_TM, P_TB.
  LV_MAT = P_MATNR.
  IF LV_MAT(2) = 'SR'.
    SELECT SINGLE LICHA INTO LV_LI FROM MCH1
      WHERE MATNR = P_MATNR
        AND CHARG = P_CHARG.
    IF LV_LI IS NOT INITIAL.
      SELECT SINGLE MATNR CHARG INTO (P_TM, P_TB) FROM MSEG
        WHERE CHARG = LV_LI
          AND BWART = '601'.
    ENDIF.
    IF P_TB IS NOT INITIAL.
      RETURN.
    ENDIF.
  ENDIF.
  PERFORM TTA_GR101 USING P_MATNR P_CHARG
                    CHANGING LV_AUF LV_MBL LV_DT.
  IF LV_AUF IS INITIAL AND LV_DT IS NOT INITIAL.
    SELECT SINGLE MATNR CHARG INTO (P_TM, P_TB) FROM MSEG
      WHERE MBLNR = LV_MBL
        AND BWART = '543'.
  ENDIF.
ENDFORM.                    " TTA_SRC
*&---------------------------------------------------------------------*
*&      Form  TTA_GR101
*&---------------------------------------------------------------------*
*       GR 101 sah seperti ZEQM015: 101/102 batch, buang pasangan yang
*       dibatalkan, urut tanggal-jam entri, ambil yang pertama.
*----------------------------------------------------------------------*
FORM TTA_GR101 USING    P_MATNR P_CHARG
               CHANGING P_AUF P_MBL P_DT.
  TYPES: BEGIN OF LTY_GR,
           AUFNR TYPE MSEG-AUFNR,
           MBLNR TYPE MSEG-MBLNR,
           MJAHR TYPE MSEG-MJAHR,
           ZEILE TYPE MSEG-ZEILE,
           CPUDT TYPE MSEG-CPUDT_MKPF,
           CPUTM TYPE MSEG-CPUTM_MKPF,
           SMBLN TYPE MSEG-SMBLN,
           SJAHR TYPE MSEG-SJAHR,
           SMBLP TYPE MSEG-SMBLP,
           BWART TYPE MSEG-BWART,
         END OF LTY_GR.
  DATA: LT_GR TYPE STANDARD TABLE OF LTY_GR,
        LT_RV TYPE STANDARD TABLE OF LTY_GR,
        LS_GR TYPE LTY_GR.
  CLEAR: P_AUF, P_MBL, P_DT.
  SELECT AUFNR MBLNR MJAHR ZEILE CPUDT_MKPF CPUTM_MKPF
         SMBLN SJAHR SMBLP BWART
    INTO TABLE LT_GR FROM MSEG
    WHERE BWART IN ('101','102')
      AND MATNR = P_MATNR
      AND CHARG = P_CHARG.
  LT_RV = LT_GR.
  DELETE LT_RV WHERE SMBLN IS INITIAL.
  LOOP AT LT_RV INTO LS_GR.
    DELETE LT_GR WHERE MBLNR = LS_GR-SMBLN
                   AND MJAHR = LS_GR-SJAHR
                   AND ZEILE = LS_GR-SMBLP.
  ENDLOOP.
  DELETE LT_GR WHERE SMBLN IS NOT INITIAL OR BWART = '102'.
  SORT LT_GR BY CPUDT CPUTM.
  READ TABLE LT_GR INTO LS_GR INDEX 1.
  CHECK SY-SUBRC = 0.
  P_AUF = LS_GR-AUFNR.
  P_MBL = LS_GR-MBLNR.
  SELECT SINGLE CPUDT INTO P_DT FROM MKPF
    WHERE MBLNR = P_MBL.
ENDFORM.                    " TTA_GR101
*&---------------------------------------------------------------------*
*&      Form  TTA_COMBINE
*&---------------------------------------------------------------------*
*       Order gabungan (MILL_OC), seperti VCOMBINE di ZEQM015.
*----------------------------------------------------------------------*
FORM TTA_COMBINE USING    P_AUF
                 CHANGING P_CMB.
  CLEAR P_CMB.
  SELECT SINGLE AUFNR INTO P_CMB FROM AFPO
    WHERE MILL_OC_AUFNR_U = P_AUF.
  IF P_CMB IS INITIAL.
    P_CMB = P_AUF.
  ENDIF.
ENDFORM.                    " TTA_COMBINE
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
