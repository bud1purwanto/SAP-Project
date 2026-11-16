*&---------------------------------------------------------------------*
*&      Form  ALIAS_RESOLVE
*&---------------------------------------------------------------------*
*       Alias COA (ZZALIAS): tentukan jalur tiap roll. Roll beralias
*       dikelompokkan per VBELN + material alias. Jalur alias hanya
*       dipakai kalau seluruh tipe produksi dalam kelompok lolos;
*       selain itu roll dicetak as-is per MATNR (fallback).
*----------------------------------------------------------------------*
FORM ALIAS_RESOLVE.
  TYPES: BEGIN OF TY_AMX,
           VBELN TYPE LIPS-VBELN,
           MATNR TYPE MARA-MATNR,
           AMAT  TYPE MARA-MATNR,
           NOAL  TYPE C,
         END OF TY_AMX.
  DATA: LT_AMX   TYPE STANDARD TABLE OF TY_AMX,
        LT_MIXG  TYPE STANDARD TABLE OF TY_AMX,
        LS_AMX   TYPE TY_AMX,
        LS_AMX2  TYPE TY_AMX,
        LV_ALIAS TYPE AUSP-ATWRT,
        LV_AMAT  TYPE MARA-MATNR,
        LV_KUNNR TYPE KUNNR,
        LV_STAT  TYPE C LENGTH 7,
        LV_CNT   TYPE I.

  REFRESH: GT_AROLL, GT_AGRP, GT_AMAP, GT_AMIC, GT_AMIC_B, GT_ALOG.

  " 1) Per roll: ZZALIAS -> material alias
  LOOP AT IT_DATA.
    CLEAR: GS_AROLL, LV_ALIAS, LV_AMAT.
    GS_AROLL-VBELN = IT_DATA-VBELN.
    GS_AROLL-POSNR = IT_DATA-POSNR.
    GS_AROLL-CHARG = IT_DATA-CHARG.
    GS_AROLL-MATNR = IT_DATA-MATNR.
    READ TABLE IT_INOB WITH KEY MATNR = IT_DATA-MATNR
                                CHARG = IT_DATA-CHARG BINARY SEARCH.
    IF SY-SUBRC = 0 AND GV_ATINN_ALIAS IS NOT INITIAL.
      READ TABLE IT_AUSP WITH KEY OBJEK = IT_INOB-OBJEK
                                  ATINN = GV_ATINN_ALIAS BINARY SEARCH.
      IF SY-SUBRC = 0.
        LV_ALIAS = IT_AUSP-ATWRT.
      ENDIF.
    ENDIF.
    GS_AROLL-ALIAS = LV_ALIAS.
    IF LV_ALIAS IS INITIAL.
      GS_AROLL-PATH = 'NOALIAS'.
    ELSE.
      PERFORM ALIAS_CONVERT USING LV_ALIAS IT_DATA-MATNR
                            CHANGING LV_AMAT.
      IF LV_AMAT IS INITIAL.
        GS_AROLL-PATH = 'NOCONV'.
      ELSE.
        GS_AROLL-AMAT = LV_AMAT.
        GS_AROLL-PATH = 'ALIAS'.
      ENDIF.
    ENDIF.
    INSERT GS_AROLL INTO TABLE GT_AROLL.
  ENDLOOP.

  " 2) MIXED: dalam 1 DO, 1 MATNR punya roll dengan material alias
  "    berbeda, atau campur roll beralias dengan roll tanpa alias /
  "    NOCONV. Semua roll MATNR itu dicetak per tipe produksi.
  LOOP AT GT_AROLL INTO GS_AROLL.
    CLEAR LS_AMX.
    LS_AMX-VBELN = GS_AROLL-VBELN.
    LS_AMX-MATNR = GS_AROLL-MATNR.
    IF GS_AROLL-PATH = 'ALIAS'.
      LS_AMX-AMAT = GS_AROLL-AMAT.
    ELSE.
      LS_AMX-NOAL = 'X'.
    ENDIF.
    APPEND LS_AMX TO LT_AMX.
  ENDLOOP.
  SORT LT_AMX BY VBELN MATNR AMAT NOAL.
  DELETE ADJACENT DUPLICATES FROM LT_AMX COMPARING ALL FIELDS.
  LOOP AT LT_AMX INTO LS_AMX WHERE AMAT IS NOT INITIAL.
    CLEAR LV_CNT.
    LOOP AT LT_AMX INTO LS_AMX2 WHERE VBELN = LS_AMX-VBELN
                                  AND MATNR = LS_AMX-MATNR.
      LV_CNT = LV_CNT + 1.
    ENDLOOP.
    IF LV_CNT > 1.
      APPEND LS_AMX TO LT_MIXG.
    ENDIF.
  ENDLOOP.
  LOOP AT LT_MIXG INTO LS_AMX.
    LOOP AT GT_AROLL INTO GS_AROLL WHERE VBELN = LS_AMX-VBELN
                                     AND MATNR = LS_AMX-MATNR.
      GS_AROLL-PATH = 'MIXED'.
      MODIFY GT_AROLL FROM GS_AROLL TRANSPORTING PATH.
    ENDLOOP.
  ENDLOOP.

  " 3) Per kelompok VBELN + material alias
  LOOP AT GT_AROLL INTO GS_AROLL WHERE PATH = 'ALIAS'.
    READ TABLE GT_AGRP TRANSPORTING NO FIELDS
      WITH TABLE KEY VBELN = GS_AROLL-VBELN AMAT = GS_AROLL-AMAT.
    CHECK SY-SUBRC <> 0.
    CLEAR: GS_AGRP, LV_STAT.
    GS_AGRP-VBELN = GS_AROLL-VBELN.
    GS_AGRP-AMAT  = GS_AROLL-AMAT.
    GS_AGRP-ALIAS = GS_AROLL-ALIAS.
    READ TABLE LT_MIXG TRANSPORTING NO FIELDS
      WITH KEY VBELN = GS_AROLL-VBELN AMAT = GS_AROLL-AMAT.
    IF SY-SUBRC = 0.
      LV_STAT = 'MIXED'.
    ENDIF.
    IF LV_STAT IS INITIAL.
      CLEAR LV_KUNNR.
      SELECT SINGLE KUNAG INTO LV_KUNNR FROM LIKP
        WHERE VBELN = GS_AROLL-VBELN.
      PERFORM ALIAS_READ_MAP USING GS_AGRP-VBELN GS_AGRP-AMAT LV_KUNNR
                             CHANGING LV_STAT.
    ENDIF.
    IF LV_STAT IS INITIAL.
      PERFORM ALIAS_TRANSLATE_GROUP USING GS_AGRP-VBELN GS_AGRP-AMAT
                                    CHANGING LV_STAT GS_AGRP-NMAT.
    ENDIF.
    IF LV_STAT IS INITIAL.
      GS_AGRP-STATUS = 'ALIAS'.
    ELSE.
      GS_AGRP-STATUS = LV_STAT.
    ENDIF.
    INSERT GS_AGRP INTO TABLE GT_AGRP.
  ENDLOOP.

  " 4) Status kelompok berlaku untuk semua roll kelompok itu
  LOOP AT GT_AROLL INTO GS_AROLL WHERE PATH = 'ALIAS'.
    READ TABLE GT_AGRP INTO GS_AGRP
      WITH TABLE KEY VBELN = GS_AROLL-VBELN AMAT = GS_AROLL-AMAT.
    IF SY-SUBRC = 0 AND GS_AGRP-STATUS <> 'ALIAS'.
      GS_AROLL-PATH = GS_AGRP-STATUS.
      MODIFY GT_AROLL FROM GS_AROLL TRANSPORTING PATH.
    ENDIF.
  ENDLOOP.

  " 5) Buang data kelompok fallback, index balik untuk relabel MIC
  LOOP AT GT_AGRP INTO GS_AGRP WHERE STATUS <> 'ALIAS'.
    DELETE GT_AMIC WHERE VBELN = GS_AGRP-VBELN AND AMAT = GS_AGRP-AMAT.
    DELETE GT_AMAP WHERE VBELN = GS_AGRP-VBELN
                     AND MATNR = GS_AGRP-AMAT.
  ENDLOOP.
  GT_AMIC_B[] = GT_AMIC[].
ENDFORM.                    " ALIAS_RESOLVE
*&---------------------------------------------------------------------*
*&      Form  ALIAS_CONVERT
*&---------------------------------------------------------------------*
*       Alias -> material alias (1 alias = 1 material alias).
*       a) ZZCODE: teks nilai (CAWNT-ATWTB) = alias -> kode 3 huruf,
*          material = MATNR(2) + kode + karakter terakhir MATNR.
*       b) Cadangan MAKT: awalan teks material batch + alias.
*----------------------------------------------------------------------*
FORM ALIAS_CONVERT USING    P_ALIAS TYPE AUSP-ATWRT
                            P_MATNR TYPE MARA-MATNR
                   CHANGING P_AMAT  TYPE MARA-MATNR.
  DATA: LS_CV    TYPE TY_ACONV,
        LV_PFX   TYPE C LENGTH 2,
        LV_LAST  TYPE C LENGTH 1,
        LV_LEN   TYPE I,
        LV_ATZHL TYPE CAWN-ATZHL,
        LV_CODE  TYPE CAWN-ATWRT,
        LV_CMAT  TYPE MARA-MATNR,
        LV_MAKTX TYPE MAKT-MAKTX,
        LV_MAKTG TYPE MAKT-MAKTG,
        LV_LK    TYPE MAKT-MATNR,
        LV_T1    TYPE STRING,
        LV_T2    TYPE STRING,
        LV_S1    TYPE STRING.

  CLEAR P_AMAT.
  LV_LEN = STRLEN( P_MATNR ) - 1.
  IF LV_LEN < 2.
    RETURN.
  ENDIF.
  LV_PFX  = P_MATNR(2).
  LV_LAST = P_MATNR+LV_LEN(1).
  READ TABLE GT_ACONV INTO LS_CV
    WITH TABLE KEY ALIAS = P_ALIAS PFX = LV_PFX LAST = LV_LAST.
  IF SY-SUBRC = 0.
    P_AMAT = LS_CV-AMAT.
    RETURN.
  ENDIF.

  SELECT SINGLE ATZHL INTO LV_ATZHL FROM CAWNT
    WHERE ATINN = ATINN_CODE
      AND ATWTB = P_ALIAS.
  IF SY-SUBRC = 0.
    SELECT SINGLE ATWRT INTO LV_CODE FROM CAWN
      WHERE ATINN = ATINN_CODE
        AND ATZHL = LV_ATZHL.
    IF LV_CODE IS NOT INITIAL.
      CONCATENATE LV_PFX LV_CODE LV_LAST INTO LV_CMAT.
      SELECT SINGLE MATNR INTO P_AMAT FROM MARA
        WHERE MATNR = LV_CMAT.
      IF SY-SUBRC <> 0.
        CLEAR P_AMAT.
      ENDIF.
    ENDIF.
  ENDIF.

  IF P_AMAT IS INITIAL.
    SELECT SINGLE MAKTX INTO LV_MAKTX FROM MAKT
      WHERE MATNR = P_MATNR AND SPRAS = 'E'.
    LV_T1 = LV_MAKTX.
    CLEAR LV_T2.
    FIND REGEX '^(.*\s)\S+\s*$' IN LV_T1 SUBMATCHES LV_T2.
    IF LV_T2 IS NOT INITIAL.
      LV_S1 = P_ALIAS.
      CONDENSE LV_S1.
      CONCATENATE LV_T2 LV_S1 INTO LV_T2 RESPECTING BLANKS.
      TRANSLATE LV_T2 TO UPPER CASE.
      LV_MAKTG = LV_T2.
      CONCATENATE LV_PFX '%' INTO LV_LK.
      SELECT SINGLE MATNR INTO P_AMAT FROM MAKT
        WHERE MAKTG = LV_MAKTG
          AND SPRAS = 'E'
          AND MATNR LIKE LV_LK.
      IF SY-SUBRC <> 0.
        CLEAR P_AMAT.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR LS_CV.
  LS_CV-ALIAS = P_ALIAS.
  LS_CV-PFX   = LV_PFX.
  LS_CV-LAST  = LV_LAST.
  LS_CV-AMAT  = P_AMAT.
  INSERT LS_CV INTO TABLE GT_ACONV.
ENDFORM.                    " ALIAS_CONVERT
*&---------------------------------------------------------------------*
*&      Form  ALIAS_READ_MAP
*&---------------------------------------------------------------------*
*       Mapping material alias (umum + override customer, aturan merge
*       sama dengan mapping as-is). Hasil ke GT_AMAP per VBELN + AMAT.
*----------------------------------------------------------------------*
FORM ALIAS_READ_MAP USING    P_VBELN TYPE LIPS-VBELN
                             P_AMAT  TYPE MARA-MATNR
                             P_KUNNR TYPE KUNNR
                    CHANGING P_STAT.
  DATA: LT_GEN LIKE IT_ZMAP OCCURS 0 WITH HEADER LINE,
        LT_CUS LIKE IT_ZMAP OCCURS 0 WITH HEADER LINE,
        LV_IX  TYPE SY-TABIX.

  SELECT MATNR MIC KUNNR METHOD MAPPING UOM MIC_DESC
         LOWER_LIMIT UPPER_LIMIT SEQ_NO
    INTO CORRESPONDING FIELDS OF TABLE LT_GEN
    FROM ZMAP_COA
    WHERE MATNR    = P_AMAT
      AND KUNNR    = ' '
      AND DELETION NE 'X'.
  IF P_KUNNR IS NOT INITIAL.
    SELECT MATNR MIC KUNNR METHOD MAPPING UOM MIC_DESC
           LOWER_LIMIT UPPER_LIMIT SEQ_NO
      INTO CORRESPONDING FIELDS OF TABLE LT_CUS
      FROM ZMAP_COA
      WHERE MATNR    = P_AMAT
        AND KUNNR    = P_KUNNR
        AND DELETION NE 'X'.
  ENDIF.
  SORT LT_GEN BY MIC ASCENDING.
  LOOP AT LT_CUS.
    READ TABLE LT_GEN WITH KEY MIC = LT_CUS-MIC BINARY SEARCH.
    IF SY-SUBRC = 0.
      LV_IX = SY-TABIX.
      LT_GEN-METHOD   = LT_CUS-METHOD.
      LT_GEN-KUNNR    = LT_CUS-KUNNR.
      LT_GEN-MAPPING  = LT_CUS-MAPPING.
      LT_GEN-UOM      = LT_CUS-UOM.
      LT_GEN-MIC_DESC = LT_CUS-MIC_DESC.
      IF LT_CUS-LOWER_LIMIT IS NOT INITIAL.
        LT_GEN-LOWER_LIMIT = LT_CUS-LOWER_LIMIT.
      ENDIF.
      IF LT_CUS-UPPER_LIMIT IS NOT INITIAL.
        LT_GEN-UPPER_LIMIT = LT_CUS-UPPER_LIMIT.
      ENDIF.
      IF LT_CUS-SEQ_NO IS NOT INITIAL.
        LT_GEN-SEQ_NO = LT_CUS-SEQ_NO.
      ENDIF.
      MODIFY LT_GEN INDEX LV_IX.
    ELSE.
      APPEND LT_CUS TO LT_GEN.
      SORT LT_GEN BY MIC ASCENDING.
    ENDIF.
  ENDLOOP.
  SORT LT_GEN BY MIC ASCENDING.
  DELETE ADJACENT DUPLICATES FROM LT_GEN COMPARING MIC.

  IF LT_GEN[] IS INITIAL.
    P_STAT = 'NOMAP'.
    RETURN.
  ENDIF.
  LOOP AT LT_GEN.
    CLEAR GT_AMAP.
    MOVE-CORRESPONDING LT_GEN TO GT_AMAP.
    GT_AMAP-VBELN = P_VBELN.
    GT_AMAP-MATNR = P_AMAT.
    " Deskripsi COA = deskripsi MIC alias (bukan teks MIC batch)
    IF GT_AMAP-MIC_DESC IS INITIAL.
      SELECT SINGLE KURZTEXT INTO GT_AMAP-MIC_DESC FROM QPMT
        WHERE MKMNR = GT_AMAP-MIC AND SPRACHE = 'E'.
    ENDIF.
    APPEND GT_AMAP.
  ENDLOOP.
ENDFORM.                    " ALIAS_READ_MAP
*&---------------------------------------------------------------------*
*&      Form  ALIAS_LOAD_PLAN
*&---------------------------------------------------------------------*
*       Kamus MIC inspection plan material + JR pasangannya (cache)
*----------------------------------------------------------------------*
FORM ALIAS_LOAD_PLAN USING P_MATNR TYPE MARA-MATNR.
  TYPES: BEGIN OF TY_PM,
           MIC  TYPE PLMK-VERWMERKM,
           DESC TYPE PLMK-KURZTEXT,
         END OF TY_PM.
  DATA: LT_PM TYPE STANDARD TABLE OF TY_PM,
        LS_PM TYPE TY_PM,
        LS_PL TYPE TY_APLAN,
        LV_JR TYPE MARA-MATNR.

  READ TABLE GT_APLAN_DONE TRANSPORTING NO FIELDS
    WITH TABLE KEY TABLE_LINE = P_MATNR.
  IF SY-SUBRC = 0.
    RETURN.
  ENDIF.
  INSERT P_MATNR INTO TABLE GT_APLAN_DONE.
  LV_JR = P_MATNR.
  LV_JR(2) = 'JR'.
  SELECT DISTINCT PLMK~VERWMERKM PLMK~KURZTEXT
    INTO TABLE LT_PM
    FROM MAPL INNER JOIN PLMK
      ON PLMK~PLNTY = MAPL~PLNTY AND PLMK~PLNNR = MAPL~PLNNR
    WHERE ( MAPL~MATNR = P_MATNR OR MAPL~MATNR = LV_JR )
      AND MAPL~PLNTY = 'Q'
      AND MAPL~LOEKZ = ' '
      AND PLMK~LOEKZ = ' '.
  LOOP AT LT_PM INTO LS_PM WHERE MIC IS NOT INITIAL.
    CLEAR LS_PL.
    LS_PL-MATNR = P_MATNR.
    LS_PL-MIC   = LS_PM-MIC.
    LS_PL-DESC  = LS_PM-DESC.
    INSERT LS_PL INTO TABLE GT_APLAN.
  ENDLOOP.
ENDFORM.                    " ALIAS_LOAD_PLAN
*&---------------------------------------------------------------------*
*&      Form  ALIAS_NORM_DESC
*&---------------------------------------------------------------------*
*       Deskripsi MIC tanpa spasi, huruf besar (untuk banding teks)
*----------------------------------------------------------------------*
FORM ALIAS_NORM_DESC USING    P_MATNR TYPE MARA-MATNR
                              P_MIC   TYPE QPMK-MKMNR
                     CHANGING P_TXT   TYPE STRING.
  DATA: LS_PL  TYPE TY_APLAN,
        LV_TXT TYPE QPMT-KURZTEXT.

  CLEAR P_TXT.
  READ TABLE GT_APLAN INTO LS_PL
    WITH TABLE KEY MATNR = P_MATNR MIC = P_MIC.
  IF SY-SUBRC = 0.
    LV_TXT = LS_PL-DESC.
  ENDIF.
  IF LV_TXT IS INITIAL.
    SELECT SINGLE KURZTEXT INTO LV_TXT FROM QPMT
      WHERE MKMNR = P_MIC AND SPRACHE = 'E'.
  ENDIF.
  P_TXT = LV_TXT.
  CONDENSE P_TXT NO-GAPS.
  TRANSLATE P_TXT TO UPPER CASE.
ENDFORM.                    " ALIAS_NORM_DESC
*&---------------------------------------------------------------------*
*&      Form  ALIAS_TRANSLATE_GROUP
*&---------------------------------------------------------------------*
*       MIC mapping alias -> MIC batch per tipe produksi (plan):
*       EXACT -> RULE -> SUFFIX -> DESC (level S/P/A sama) -> NONE.
*       Satu NONE (atau 2 MIC alias ke MIC batch yang sama) = seluruh
*       kelompok fallback.
*----------------------------------------------------------------------*
FORM ALIAS_TRANSLATE_GROUP USING    P_VBELN TYPE LIPS-VBELN
                                    P_AMAT  TYPE MARA-MATNR
                           CHANGING P_STAT
                                    P_NMAT  TYPE I.
  DATA: LT_MAT  TYPE STANDARD TABLE OF MARA-MATNR,
        LV_MAT  TYPE MARA-MATNR,
        LS_AR   TYPE TY_AROLL,
        LS_PL   TYPE TY_APLAN,
        LS_DUP  TYPE TY_AMIC,
        LV_AMIC TYPE QPMK-MKMNR,
        LV_NEW  TYPE QPMK-MKMNR,
        LV_HOW  TYPE C LENGTH 6,
        LV_HIT  TYPE I,
        LV_ADSC TYPE STRING,
        LV_BDSC TYPE STRING,
        LV_LOG  TYPE STRING.

  LOOP AT GT_AROLL INTO LS_AR WHERE VBELN = P_VBELN
                                AND AMAT  = P_AMAT
                                AND PATH  = 'ALIAS'.
    APPEND LS_AR-MATNR TO LT_MAT.
  ENDLOOP.
  SORT LT_MAT.
  DELETE ADJACENT DUPLICATES FROM LT_MAT.
  DESCRIBE TABLE LT_MAT LINES P_NMAT.
  PERFORM ALIAS_LOAD_PLAN USING P_AMAT.

  LOOP AT LT_MAT INTO LV_MAT.
    PERFORM ALIAS_LOAD_PLAN USING LV_MAT.
    LOOP AT GT_AMAP WHERE VBELN = P_VBELN AND MATNR = P_AMAT.
      CLEAR: LV_NEW, LV_HOW, LV_HIT, GS_AMIC.
      LV_AMIC = GT_AMAP-MIC.
      READ TABLE GT_APLAN INTO LS_PL
        WITH TABLE KEY MATNR = LV_MAT MIC = LV_AMIC.
      IF SY-SUBRC = 0.
        LV_NEW = LV_AMIC.
        LV_HOW = 'EXACT'.
      ELSEIF STRLEN( LV_AMIC ) = 8.
        CONCATENATE LV_AMIC(1) LV_MAT+2(3) LV_AMIC+4(4) INTO LV_NEW.
        READ TABLE GT_APLAN INTO LS_PL
          WITH TABLE KEY MATNR = LV_MAT MIC = LV_NEW.
        IF SY-SUBRC = 0.
          LV_HOW = 'RULE'.
        ELSE.
          CLEAR LV_NEW.
          LOOP AT GT_APLAN INTO LS_PL WHERE MATNR = LV_MAT.
            IF STRLEN( LS_PL-MIC ) = 8 AND
               LS_PL-MIC(1) = LV_AMIC(1) AND
               LS_PL-MIC+4(4) = LV_AMIC+4(4).
              LV_HIT = LV_HIT + 1.
              LV_NEW = LS_PL-MIC.
            ENDIF.
          ENDLOOP.
          IF LV_HIT = 1.
            LV_HOW = 'SUFFIX'.
          ELSE.
            CLEAR LV_NEW.
          ENDIF.
        ENDIF.
      ENDIF.
      IF LV_NEW IS INITIAL.
        PERFORM ALIAS_NORM_DESC USING P_AMAT LV_AMIC CHANGING LV_ADSC.
        CLEAR LV_HIT.
        LOOP AT GT_APLAN INTO LS_PL WHERE MATNR = LV_MAT.
          CHECK LS_PL-MIC(1) = LV_AMIC(1).
          LV_BDSC = LS_PL-DESC.
          CONDENSE LV_BDSC NO-GAPS.
          TRANSLATE LV_BDSC TO UPPER CASE.
          IF LV_ADSC IS NOT INITIAL AND LV_ADSC = LV_BDSC.
            LV_HIT = LV_HIT + 1.
            LV_NEW = LS_PL-MIC.
          ENDIF.
        ENDLOOP.
        IF LV_HIT = 1.
          LV_HOW = 'DESC'.
        ELSE.
          CLEAR LV_NEW.
        ENDIF.
      ENDIF.

      GS_AMIC-VBELN = P_VBELN.
      GS_AMIC-AMAT  = P_AMAT.
      GS_AMIC-MATNR = LV_MAT.
      GS_AMIC-AMIC  = LV_AMIC.
      GS_AMIC-BMIC  = LV_NEW.
      GS_AMIC-HOW   = LV_HOW.
      IF LV_NEW IS INITIAL.
        GS_AMIC-HOW = 'NONE'.
        P_STAT = 'NONE'.
        CONCATENATE P_VBELN P_AMAT LV_MAT LV_AMIC 'NONE'
          INTO LV_LOG SEPARATED BY '|'.
        APPEND LV_LOG TO GT_ALOG.
      ELSE.
        LOOP AT GT_AMIC INTO LS_DUP WHERE VBELN = P_VBELN
                                      AND AMAT  = P_AMAT
                                      AND MATNR = LV_MAT
                                      AND BMIC  = LV_NEW.
          P_STAT = 'NONE'.
          CONCATENATE P_VBELN P_AMAT LV_MAT LV_AMIC LV_NEW 'DUPLIKAT'
            INTO LV_LOG SEPARATED BY '|'.
          APPEND LV_LOG TO GT_ALOG.
          EXIT.
        ENDLOOP.
        IF LV_HOW = 'RULE' OR LV_HOW = 'SUFFIX'.
          PERFORM ALIAS_NORM_DESC USING P_AMAT LV_AMIC CHANGING LV_ADSC.
          PERFORM ALIAS_NORM_DESC USING LV_MAT LV_NEW CHANGING LV_BDSC.
          IF LV_ADSC IS NOT INITIAL AND LV_BDSC IS NOT INITIAL
             AND LV_ADSC <> LV_BDSC.
            GS_AMIC-CHK = 'X'.
          ENDIF.
        ENDIF.
      ENDIF.
      INSERT GS_AMIC INTO TABLE GT_AMIC.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " ALIAS_TRANSLATE_GROUP
*&---------------------------------------------------------------------*
*&      Form  ALIAS_FILL_ZMAP
*&---------------------------------------------------------------------*
*       IT_ZMAP untuk roll jalur alias: baris mapping material alias
*       dengan MIC sudah diterjemahkan ke MIC batch, supaya
*       GET_TRACED_LOTS / GET_MIC membaca lot dengan MIC batch.
*----------------------------------------------------------------------*
FORM ALIAS_FILL_ZMAP USING P_VBELN TYPE LIPS-VBELN
                           P_AMAT  TYPE MARA-MATNR
                           P_MATNR TYPE MARA-MATNR.
  CLEAR IT_ZMAP.
  REFRESH IT_ZMAP.
  LOOP AT GT_AMIC INTO GS_AMIC WHERE VBELN = P_VBELN
                                 AND AMAT  = P_AMAT
                                 AND MATNR = P_MATNR.
    READ TABLE GT_AMAP WITH KEY VBELN = P_VBELN
                                MATNR = P_AMAT
                                MIC   = GS_AMIC-AMIC.
    CHECK SY-SUBRC = 0.
    CLEAR IT_ZMAP.
    MOVE-CORRESPONDING GT_AMAP TO IT_ZMAP.
    IT_ZMAP-MATNR = P_MATNR.
    IT_ZMAP-MIC   = GS_AMIC-BMIC.
    APPEND IT_ZMAP.
  ENDLOOP.
  SORT IT_ZMAP BY MIC ASCENDING.
ENDFORM.                    " ALIAS_FILL_ZMAP
*&---------------------------------------------------------------------*
*&      Form  ALIAS_APPLY_LIMIT
*&---------------------------------------------------------------------*
*       Limit COA gabungan. Opsi limit (A / B1 / B2 / C) menunggu
*       keputusan QA, lihat RANCANGAN_PROGRAM_ALIAS_ZQM002.md §6.
*       Sementara: limit mapping material alias (kalau terisi), sisi
*       kosong = spec lot wakil (sama dengan perilaku program sekarang).
*----------------------------------------------------------------------*
FORM ALIAS_APPLY_LIMIT CHANGING PS_DATA LIKE IT_DATA.
  CHECK PS_DATA-COA_PATH = 'ALIAS'.
ENDFORM.                    " ALIAS_APPLY_LIMIT
*&---------------------------------------------------------------------*
*&      Form  ALIAS_MESSAGE
*&---------------------------------------------------------------------*
*       Info jalur alias setelah GET_DATA
*----------------------------------------------------------------------*
FORM ALIAS_MESSAGE.
  DATA: LV_MSG TYPE STRING,
        LV_TXT TYPE STRING,
        LV_NC  TYPE C LENGTH 10,
        LV_N   TYPE I.

  LOOP AT GT_AGRP INTO GS_AGRP.
    LV_N = LV_N + 1.
    CHECK LV_N = 1.
    IF GS_AGRP-STATUS = 'ALIAS'.
      WRITE GS_AGRP-NMAT TO LV_NC LEFT-JUSTIFIED.
      CONCATENATE 'COA gabungan alias' GS_AGRP-ALIAS
                  GS_AGRP-AMAT LV_NC 'tipe produksi'
        INTO LV_MSG SEPARATED BY SPACE.
    ELSE.
      CONCATENATE 'Alias' GS_AGRP-ALIAS 'dicetak per tipe produksi:'
                  GS_AGRP-STATUS
        INTO LV_MSG SEPARATED BY SPACE.
    ENDIF.
  ENDLOOP.
  IF LV_N = 0.
    LOOP AT GT_AROLL INTO GS_AROLL WHERE PATH = 'NOCONV'
                                     OR PATH = 'MIXED'.
      CONCATENATE 'Alias' GS_AROLL-ALIAS 'dicetak per tipe produksi:'
                  GS_AROLL-PATH
        INTO LV_MSG SEPARATED BY SPACE.
      LV_N = 1.
      EXIT.
    ENDLOOP.
  ELSEIF LV_N > 1.
    LV_N = LV_N - 1.
    WRITE LV_N TO LV_NC LEFT-JUSTIFIED.
    CONCATENATE '(+' LV_NC 'kelompok alias lain)' INTO LV_TXT.
    CONCATENATE LV_MSG LV_TXT INTO LV_MSG SEPARATED BY SPACE.
  ENDIF.
  IF LV_MSG IS NOT INITIAL.
    MESSAGE LV_MSG TYPE 'S'.
  ENDIF.
ENDFORM.                    " ALIAS_MESSAGE
