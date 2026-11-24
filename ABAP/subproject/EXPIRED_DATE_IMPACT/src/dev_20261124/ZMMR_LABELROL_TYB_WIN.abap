*&---------------------------------------------------------------------*
*& Report  ZLABEL_TYB_UNDERWINDOWS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMMR_LABELROL_TYB_WIN.
TABLES: MCHB.

DATA: V_FORMNAME TYPE TDSFNAME VALUE 'ZMMR_LABELROL_TYB_WIN',
      V_FORMNAME2 TYPE TDSFNAME VALUE 'ZMMR_LABELROL_TYB_BLANK',
      V_FORMNAME3 TYPE TDSFNAME VALUE 'ZMMR_LABELROL_TYB_TSS00',
      V_FUNCNAME TYPE RS38L_FNAM.

DATA: ITAB LIKE ZLABEL_TYB_WIN OCCURS 0 WITH HEADER LINE.
DATA: IT_LABEL TYPE ZMAP_LABEL_TYB OCCURS 0 WITH HEADER LINE.

DATA: V_TAB    TYPE API_VALI OCCURS 0 WITH HEADER LINE.
DATA: CONTROL_PARAMETERS TYPE SSFCTRLOP,
      OUTPUT_OPTIONS TYPE SSFCOMPOP.
DATA: BEGIN OF IT_MAP_MATNR OCCURS 0,
        LABELTYPE TYPE C LENGTH 4,
        MATNR LIKE MCH1-MATNR,
      END OF IT_MAP_MATNR.

DATA: BEGIN OF IT_CHARG OCCURS 0,
  CHARG LIKE MCHB-CHARG,
  MATNR LIKE MCHB-MATNR,
  END OF IT_CHARG.

DATA: TOCHAR TYPE P DECIMALS 0,
      TOSTRG TYPE STRING,
      V_TEST(100) VALUE 39,
      V_STRLEN(2).
DATA: VX_ATNROL       LIKE CABN-ATINN,
      VX_ATNUOM       LIKE CABN-ATINN,
      VX_ROLNO        LIKE AUSP-ATWRT,
      VX_UOM          LIKE AUSP-ATWRT,
      VX_MATNR_JR     LIKE MCH1-MATNR,
      VX_CHARG_JR     LIKE MCH1-CHARG,
      VX_MSG(50),
      V_GRD(2),
      V_GRADEDESC(15).
DATA: V_POSTDATE      TYPE MKPF-BUDAT,
      V_CHARG         TYPE MCHB-CHARG,
      V_BLN_GANJIL    TYPE STRING,
      V_BLN_GENAP     TYPE STRING,
      V_BLN           TYPE I,
      V_BLN_A         TYPE I,
      V_BLN_B         TYPE I,
      V_BARC2(21),
      V_MONTH(2),
      V_YEAR(2),
      V_DATE(3).
DATA: V_FTYPE(5),
      V_THICK(3),
      V_WIDTH(4),
      V_LENGTH(5),
      V_BARC1(23),
      V_GRD_LEN TYPE I,
      V_CTG_LEN TYPE I,
      V_BARC1_LEN TYPE I,
      V_LABELCODE(4).
DATA: V_CTG(2),
      V_INS(10),
      V_OUT(10),
      V_SPACE(1) VALUE SPACE.
DATA: V_FLOAT_KG LIKE  CHA_CLASS_DATA-SOLLWERT,
      V_CHAR_KG  LIKE  CHA_CLASS_VIEW-SOLLWERT,
      V_TDNAME   LIKE  STXBITMAPS-TDNAME.

SELECT-OPTIONS: P_CHARG FOR MCHB-CHARG OBLIGATORY.
PARAMETER: V_MATNR LIKE MCHB-MATNR NO-DISPLAY,
           V_COPIES(3) DEFAULT '1'.

START-OF-SELECTION.
  PERFORM GET_DATA_MAIN.
  IF ITAB[] IS INITIAL.
    MESSAGE 'Data tidak ditemukan' TYPE 'I'.
    EXIT.
  ELSE.
    PERFORM PRINT_DATA.
  ENDIF.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  get_data_main
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA_MAIN.

  "Get data Batch & Material
  REFRESH: IT_CHARG.
  LOOP AT P_CHARG.
    SELECT SINGLE CHARG MATNR INTO IT_CHARG FROM MCH1
      WHERE CHARG = P_CHARG-LOW.
    IF SY-SUBRC = 0.
      APPEND IT_CHARG.
    ENDIF.
  ENDLOOP.
  DELETE ADJACENT DUPLICATES FROM IT_CHARG COMPARING CHARG.

  "Get Data Mapping Label Toyobo
  SELECT * FROM ZMAP_LABEL_TYB INTO CORRESPONDING FIELDS OF TABLE IT_LABEL.

  LOOP AT IT_CHARG.

    IF IT_CHARG-CHARG IS NOT INITIAL AND IT_CHARG-MATNR IS NOT INITIAL.
      REFRESH V_TAB.
      CLEAR V_TAB.
      CALL FUNCTION 'QC01_BATCH_VALUES_READ'
        EXPORTING
          I_VAL_MATNR    = IT_CHARG-MATNR
          I_VAL_CHARGE   = IT_CHARG-CHARG
        TABLES
          T_VAL_TAB      = V_TAB
        EXCEPTIONS
          NO_CLASS       = 1
          INTERNAL_ERROR = 2
          NO_VALUES      = 3
          NO_CHARS       = 4
          OTHERS         = 5.
    ENDIF.

    IF SY-SUBRC NE 0.
      CONTINUE.
    ENDIF.

    "Check Toyobo label Only
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.

    IF SY-SUBRC = 0.
      SELECT SINGLE ZCODE FROM ZMAP_LABEL_TYB INTO V_TAB-ATWRT WHERE ZCODE = V_TAB-ATWRT.
      IF SY-SUBRC NE 0.
        CONTINUE.
      ELSE.
        PERFORM CHECK_ALLOWED_MATERIAL USING V_TAB-ATWRT.
      ENDIF.


    ENDIF.

    CLEAR: ITAB, V_BARC1, V_FTYPE, V_WIDTH, V_LENGTH, V_TDNAME.
    "Get Main Characteristic
    LOOP AT V_TAB.
      ITAB-CHARG = IT_CHARG-CHARG.
      IF V_TAB-ATNAM = 'ZZCODE'.
        ITAB-TYPE = V_TAB-ATWTB.
        READ TABLE V_TAB WITH KEY ATNAM = 'ZZALIAS'.
        IF SY-SUBRC = 0.
          ITAB-TYPE = V_TAB-ATWRT.  "ambil value ALIAS
        ENDIF.
      ELSEIF V_TAB-ATNAM = 'ZZALIAS'.
        ITAB-ALIAS = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZTHICKNESS'.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        PERFORM TY_RIGHT_JUSTIFIED USING 3 TOSTRG.
        ITAB-THIC = TOSTRG.
      ELSEIF V_TAB-ATNAM = 'ZZWIDTH'.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        PERFORM TY_RIGHT_JUSTIFIED USING 4 TOSTRG.
        ITAB-WIDTH = TOSTRG.
      ELSEIF V_TAB-ATNAM = 'ZZLENGTH'.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        PERFORM TY_RIGHT_JUSTIFIED USING 5 TOSTRG.
        ITAB-LENGTH = TOSTRG.
      ELSEIF V_TAB-ATNAM = 'ZZNOROLLTOYOBO'.
        ITAB-TYBROLNO = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZNOROLLTOYOBO2'.
        ITAB-TYBROLNO2 = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZNOLOTTOYOBO'.
        ITAB-TYBLOTNO = V_TAB-ATWTB.
      ELSEIF V_TAB-ATNAM = 'ZZSPLICE-1'.
        TOCHAR = V_TAB-ATFLV.
        ITAB-SPLICE1 = TOCHAR.
        CONDENSE ITAB-SPLICE1.
      ELSEIF V_TAB-ATNAM = 'ZZSPLICE-2'.
        TOCHAR = V_TAB-ATFLV.
        ITAB-SPLICE2 = TOCHAR.
        CONDENSE ITAB-SPLICE2.
      ENDIF.
    ENDLOOP.

    "Mapping Formula for Data Treatment, Grade, Category, Barc-2, Barc-3 by Label Type
    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
    IF SY-SUBRC = 0.
      V_LABELCODE = V_TAB-ATWRT.
      LOOP AT IT_LABEL WHERE ZCODE = V_TAB-ATWRT.
        IF IT_LABEL-ATNAM = 'ZTYBHEADER'.           "HEADER
          ITAB-HEADER = IT_LABEL-VALUE.
          IF ITAB-HEADER IS NOT INITIAL.
            IF ITAB-HEADER+0(4) EQ 'ZTYB'.
              V_FORMNAME = V_FORMNAME2.
              "Check Graphic Avaible or Not
              PERFORM CHECK_IMAGE USING ITAB-HEADER CHANGING VX_MSG.
            ELSE.
              V_FORMNAME = V_FORMNAME3.
            ENDIF.
          ENDIF.
        ELSEIF IT_LABEL-ATNAM = 'ZTYBINSIDE'.       "INSIDE TREATMENT
          IF IT_LABEL-VALUE = 'L'.                  "By Char with Latin
            CLEAR: V_INS.
            READ TABLE V_TAB WITH KEY ATNAM = 'ZZINSIDE'.
            IF SY-SUBRC EQ 0.
              V_INS = V_TAB-ATWRT.
              CONCATENATE V_INS 'L' INTO V_INS.
              ITAB-INSIDE = V_INS.
            ENDIF.
          ELSEIF IT_LABEL-VALUE = 'L2'.                  "By Char with Latin - 2 "Added by Fany (27.10.2026)
            CLEAR: V_INS.
            READ TABLE V_TAB WITH KEY ATNAM = 'ZZINSIDE'.
            IF SY-SUBRC EQ 0.
              V_INS = V_TAB-ATWRT.
              CONCATENATE V_INS 'L2' INTO V_INS.
              ITAB-INSIDE = V_INS.
            ENDIF.
          ELSEIF IT_LABEL-VALUE = 'C'.              "By Char No Latin
            READ TABLE V_TAB WITH KEY ATNAM = 'ZZINSIDE'.
            IF SY-SUBRC EQ 0.
              ITAB-INSIDE = V_TAB-ATWRT.
            ENDIF.
          ELSE.                                     "By Mapping
            ITAB-INSIDE = IT_LABEL-VALUE.
          ENDIF.
          IF ITAB-INSIDE NE 'NO' AND ITAB-INSIDE NE 'NOL' AND ITAB-INSIDE NE 'NOL2' AND ITAB-INSIDE IS NOT INITIAL.
            ITAB-INSIDE = 'ZTYB_' && ITAB-INSIDE.

            "Check Graphic Avaible or Not
            PERFORM CHECK_IMAGE USING ITAB-INSIDE CHANGING VX_MSG.
          ELSE.
            CLEAR ITAB-INSIDE.
          ENDIF.
        ELSEIF IT_LABEL-ATNAM = 'ZTYBOUTSIDE'.      "OUTSIDE TREATMENT
          IF IT_LABEL-VALUE = 'L'.                  "By Char with Latin
            CLEAR: V_OUT.
            READ TABLE V_TAB WITH KEY ATNAM = 'ZZOUTSIDE'.
            IF SY-SUBRC EQ 0.
              V_OUT = V_TAB-ATWRT.
              CONCATENATE V_OUT 'L' INTO V_OUT.
              ITAB-OUTSIDE = V_OUT.
            ENDIF.
          ELSEIF IT_LABEL-VALUE = 'L2'.                  "By Char with Latin - 2
            CLEAR: V_OUT.
            READ TABLE V_TAB WITH KEY ATNAM = 'ZZOUTSIDE'.
            IF SY-SUBRC EQ 0.
              V_OUT = V_TAB-ATWRT.
              CONCATENATE V_OUT 'L2' INTO V_OUT.
              ITAB-OUTSIDE = V_OUT.
            ENDIF.
          ELSEIF IT_LABEL-VALUE = 'C'.              "By Char No Latin
            READ TABLE V_TAB WITH KEY ATNAM = 'ZZOUTSIDE'.
            IF SY-SUBRC EQ 0.
              ITAB-OUTSIDE = V_TAB-ATWRT.
            ENDIF.
          ELSE.                                     "By Mapping
            ITAB-OUTSIDE = IT_LABEL-VALUE.
          ENDIF.
          IF ITAB-OUTSIDE NE 'NO' AND ITAB-OUTSIDE NE 'NOL' AND ITAB-OUTSIDE NE 'NOL2' AND ITAB-OUTSIDE IS NOT INITIAL.
            ITAB-OUTSIDE = 'ZTYB_' && ITAB-OUTSIDE.
            "Check Graphic Avaible or Not
            PERFORM CHECK_IMAGE USING ITAB-OUTSIDE CHANGING VX_MSG.
          ELSE.
            CLEAR ITAB-OUTSIDE.
          ENDIF.
        ELSEIF IT_LABEL-ATNAM = 'ZTYBGRADE'.        "GRADE TOYOBO
          IF IT_LABEL-VALUE = 'GRDFORMULA2'.        "Formula 2 - By JR Position (UoM)
            CLEAR: V_GRD.
            V_MATNR = IT_CHARG-MATNR.
            V_CHARG = IT_CHARG-CHARG.
            PERFORM GET_GRDFORMULA2 USING V_GRD.
            IF VX_MSG IS NOT INITIAL.
              MESSAGE VX_MSG TYPE 'E' DISPLAY LIKE 'A'.
              EXIT.
            ENDIF.
            ITAB-TYBGRADE = V_GRD.
          ELSEIF IT_LABEL-VALUE = 'GRDFORMULA3'.    "Formula 3 - By Characteristic
            CLEAR: V_GRD.
            READ TABLE V_TAB WITH KEY ATNAM = 'ZZGRADE'.
            IF SY-SUBRC EQ 0.
              SPLIT V_TAB-ATWTB AT '-' INTO V_GRD V_GRADEDESC.
              ITAB-TYBGRADE = V_GRD.
            ENDIF.
          ELSEIF IT_LABEL-VALUE = 'GRDFORMULA4'.    "Formula 4 - By Characteristic  "Added by Fany 21.07.2026
            CLEAR: V_GRD.
            READ TABLE V_TAB WITH KEY ATNAM = 'ZZGRADE'.
            IF SY-SUBRC EQ 0.
              IF V_TAB-ATWTB CS '-'.
                SPLIT V_TAB-ATWTB AT '-' INTO V_GRD V_GRADEDESC.
                ITAB-TYBGRADE = V_GRD.
              ELSE.
                ITAB-TYBGRADE = V_TAB-ATWRT.
              ENDIF.

            ENDIF.
          ELSE.                                     "Formula 1 - Harcode Data
            ITAB-TYBGRADE = IT_LABEL-VALUE.
          ENDIF.
        ELSEIF IT_LABEL-ATNAM = 'ZTYBCATEGORY'.     "CATEGORY TOYOBO
          IF IT_LABEL-VALUE = 'CTGFORMULA2'.        "Formula 2 - By Slitting Position
            CLEAR: V_CTG.
            PERFORM GET_CTGFORMULA2 USING V_CTG.
            IF VX_MSG IS NOT INITIAL.
              MESSAGE VX_MSG TYPE 'E' DISPLAY LIKE 'A'.
              EXIT.
            ENDIF.
            ITAB-TAILOR = V_CTG.
          ELSEIF IT_LABEL-VALUE = 'CTGFORMULA3'.    "Formula 3 - By Joint-1 Condition
            CLEAR: V_CTG.
            PERFORM GET_CTGFORMULA3 USING V_CTG.
            IF VX_MSG IS NOT INITIAL.
              MESSAGE VX_MSG TYPE 'E' DISPLAY LIKE 'A'.
              EXIT.
            ENDIF.
            ITAB-TAILOR = V_CTG.
          ELSEIF IT_LABEL-VALUE = 'CTGFORMULA4'.    "Formula 4 - By Joint-2 Condition
            CLEAR: V_CTG.
            PERFORM GET_CTGFORMULA4 USING V_CTG.
            IF VX_MSG IS NOT INITIAL.
              MESSAGE VX_MSG TYPE 'E' DISPLAY LIKE 'A'.
              EXIT.
            ENDIF.
            ITAB-TAILOR = V_CTG.
          ELSEIF IT_LABEL-VALUE = 'CTGFORMULA5'.    "Formula 5 - By Characteristic
            CLEAR: V_CTG.
            READ TABLE V_TAB WITH KEY ATNAM = 'ZZTAILORED'.
            IF SY-SUBRC EQ 0.
              V_CTG = V_TAB-ATWRT.
              "Clear for No Category
              IF V_CTG EQ 'NC'.
                CLEAR V_CTG.
              ENDIF.
              ITAB-TAILOR = V_CTG.
            ENDIF.
          ELSE.                                     "Formula 1 - Harcode Data
            ITAB-TAILOR = IT_LABEL-VALUE.
          ENDIF.
        ELSEIF IT_LABEL-ATNAM = 'ZTYBBARCODE2'.     "BARCODE-2 TOYOBO
          IF IT_LABEL-VALUE = 'BARC2FORMULA1'.      "Formula 1 - By Roll & Lot No
            CLEAR: V_BARC2.
            PERFORM GET_BARC2FORMULA1 USING V_BARC2.
            CONCATENATE V_BARC2 ITAB-TYBROLNO ITAB-TYBLOTNO '000' INTO V_BARC2.
            ITAB-BARC2 = V_BARC2.
          ELSEIF IT_LABEL-VALUE = 'BARC2FORMULA2'.  "Formula 2 - By Production Date
            CLEAR: V_BARC2, V_MATNR, V_CHARG.
            V_MATNR = IT_CHARG-MATNR.
            V_CHARG = IT_CHARG-CHARG.
            PERFORM GET_BARC2FORMULA2 USING V_BARC2 V_MATNR V_CHARG.
            CONCATENATE V_BARC2 ITAB-TYBROLNO ITAB-TYBLOTNO '000' INTO V_BARC2.
            ITAB-BARC2 = V_BARC2.
          ENDIF.
        ELSEIF IT_LABEL-ATNAM = 'ZTYBBARCODE3'.     "BARCODE-3 TOYOBO
          IF IT_LABEL-VALUE = 'M'.
            PERFORM GET_MOTHER_ROLL.
          ENDIF.
          ITAB-BARC3 = IT_LABEL-VALUE.
        ELSEIF IT_LABEL-ATNAM = 'ZTYBWEIGHT'.       "WEIGHT
          IF IT_LABEL-VALUE = 'W'.                  "With Weight
            READ TABLE V_TAB WITH KEY ATNAM = 'ZZCONVERSIONROLLKG'.
            IF SY-SUBRC EQ 0.
              CLEAR: V_FLOAT_KG, V_CHAR_KG.
              V_FLOAT_KG = V_TAB-ATFLV.

              CALL FUNCTION 'QSS0_FLTP_TO_CHAR_CONVERSION'
                EXPORTING
                  I_NUMBER_OF_DIGITS       = 2
                  I_FLTP_VALUE             = V_FLOAT_KG
                  I_VALUE_NOT_INITIAL_FLAG = 'X'
                  I_SCREEN_FIELDLENGTH     = 16
                IMPORTING
                  E_CHAR_FIELD             = V_CHAR_KG.

              CONDENSE V_CHAR_KG NO-GAPS.
              ITAB-WEIGHT = V_CHAR_KG.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
    "Customing Data Characteristic for Barcode-1 & Barctext-1
    V_FTYPE  = ITAB-TYPE.
    V_THICK  = ITAB-THIC.
    V_WIDTH  = ITAB-WIDTH.
    V_LENGTH = ITAB-LENGTH.
    V_GRD    = ITAB-TYBGRADE.
    V_CTG    = ITAB-TAILOR.
    PERFORM GET_DATA_CUSTOM USING V_BARC1 V_FTYPE V_THICK V_WIDTH V_LENGTH V_GRD V_CTG.

    ITAB-BARC1         = V_BARC1.
    ITAB-QRCODE+0(21)  = V_BARC1.
    ITAB-QRCODE+21(21) = V_BARC2.

    DO V_COPIES TIMES.
      APPEND ITAB.
    ENDDO.

    IF V_FORMNAME EQ V_FORMNAME3.
      DO 3 * V_COPIES TIMES.
        APPEND ITAB.
      ENDDO.
    ENDIF.
  ENDLOOP.
ENDFORM.  "data_main

*&---------------------------------------------------------------------*
*&      Form  GET_GRDFORMULA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->V_GRD     text
*  <--V_GRD     text
*----------------------------------------------------------------------*
FORM GET_GRDFORMULA2 USING V_GRD.  "BACA KODE POSISI JR DI CHARACTERISTIC ZZUNITOFMEASURE

  CLEAR: VX_ATNROL,VX_ATNUOM,VX_ROLNO,VX_MATNR_JR,VX_CHARG_JR,VX_UOM.

  SELECT SINGLE ATINN INTO VX_ATNROL FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.
  SELECT SINGLE ATINN INTO VX_ATNUOM FROM CABN WHERE ATNAM = 'ZZUNITOFMEASURE'.

  SELECT SINGLE  AUSP~ATWRT INTO VX_ROLNO
    FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
    WHERE MCH1~MATNR = V_MATNR AND MCH1~CHARG = IT_CHARG-CHARG AND AUSP~ATINN = VX_ATNROL.

  VX_ROLNO = VX_ROLNO+0(13).

  "Get Batch JR 101 Only, case cancelled JR
  SELECT SINGLE MSEG~MATNR MSEG~CHARG
    INTO (VX_MATNR_JR, VX_CHARG_JR)
    FROM MSEG
  JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR AND MSEG~MJAHR EQ MKPF~MJAHR
    WHERE MSEG~BWART EQ '101'
    AND MKPF~BKTXT = VX_ROLNO.

  IF SY-SUBRC NE 0.
    CONCATENATE 'Data Mother Roll Batch' IT_CHARG-CHARG 'tidak ditemukan..!' INTO VX_MSG SEPARATED BY SPACE.
    EXIT.
  ENDIF.

  "BACA KODE POSISI JR DI CHARACTERISTIC ZZUNITOFMEASURE
  SELECT SINGLE  AUSP~ATWRT INTO VX_UOM
    FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
    WHERE MCH1~MATNR = VX_MATNR_JR AND MCH1~CHARG = VX_CHARG_JR AND AUSP~ATINN = VX_ATNUOM.

  IF SY-SUBRC NE 0.
    CONCATENATE 'Kode Posisi Batch' IT_CHARG-CHARG 'tidak ditemukan..!' INTO VX_MSG SEPARATED BY SPACE.
    EXIT.
  ENDIF.

  ITAB-CHARG_JR = VX_CHARG_JR.

  V_GRD = VX_UOM.
  CONCATENATE 'A' V_GRD INTO V_GRD.

ENDFORM.                    " GET_GRDFORMULA2


*&---------------------------------------------------------------------*
*&      Form  GET_CTGFORMULA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  V_CTG        text
*  <--  V_CTG        text
*----------------------------------------------------------------------*
FORM GET_CTGFORMULA2 USING V_CTG.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZNOROLLTOYOBO'.
  IF SY-SUBRC = 0.
    IF V_TAB-ATWTB+8(1) = '5' OR V_TAB-ATWTB+8(1) = '6'.
      V_CTG = 'AC'.
    ELSEIF V_TAB-ATWTB+8(1) = ''.
      CONCATENATE 'No Roll Toyobo pada Batch' IT_CHARG-CHARG 'tidak sesuai..!' INTO VX_MSG SEPARATED BY SPACE.
      EXIT.
    ELSE.
      V_CTG = 'A'.
    ENDIF.
  ELSE.
    CONCATENATE 'No Roll Toyobo pada Batch' IT_CHARG-CHARG 'tidak sesuai..!' INTO VX_MSG SEPARATED BY SPACE.
    EXIT.
  ENDIF.

ENDFORM.                    " GET_CTGFORMULA2
*&---------------------------------------------------------------------*
*&      Form  GET_CTGFORMULA3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  V_CTG     text
*  <--  V_CTG     text
*----------------------------------------------------------------------*
FORM GET_CTGFORMULA3 USING V_CTG.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPLICE-1'.
  IF SY-SUBRC = 0.
    IF V_TAB-ATWRT NE ''.
      V_CTG = 'J1'.
    ENDIF.
  ENDIF.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPLICE-2'.
  IF SY-SUBRC = 0.
    IF V_TAB-ATWRT NE ''.
      V_CTG = 'J2'.
    ENDIF.
  ENDIF.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZGRADE'.
  IF SY-SUBRC = 0.
    IF V_TAB-ATWRT = 'JS' OR V_TAB-ATWRT = 'JD'.
      IF V_CTG = 'J1' OR V_CTG = 'JS' OR V_CTG = 'JD'.
        V_CTG = V_TAB-ATWRT.
      ELSEIF V_CTG = 'J2'.
        CONCATENATE 'Batch' IT_CHARG-CHARG 'tidak boleh Join 2...!' INTO VX_MSG SEPARATED BY SPACE.
        EXIT.
      ENDIF.
    ELSEIF V_CTG = 'J1'.
      CONCATENATE 'Grade Batch' IT_CHARG-CHARG 'harus JD / JS...!' INTO VX_MSG SEPARATED BY SPACE.
      EXIT.
    ELSEIF V_CTG = 'J2'.
      CONCATENATE 'Batch' IT_CHARG-CHARG 'tidak boleh Join 2...!' INTO VX_MSG SEPARATED BY SPACE.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_CTGFORMULA3

*&---------------------------------------------------------------------*
*&      Form  GET_CTGFORMULA4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  V_CTG     text
*  <--  V_CTG     text
*----------------------------------------------------------------------*
FORM GET_CTGFORMULA4  USING  V_CTG.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPLICE-1'.
  IF SY-SUBRC = 0.
    IF V_TAB-ATWRT NE ''.
      V_CTG = 'J1'.
    ENDIF.
  ENDIF.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZSPLICE-2'.
  IF SY-SUBRC = 0.
    IF V_TAB-ATWRT NE ''.
      V_CTG = 'J2'.
    ENDIF.
  ENDIF.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZGRADE'.
  IF SY-SUBRC = 0.
    IF V_TAB-ATWRT = 'JS' OR V_TAB-ATWRT = 'JD'.
      IF V_CTG = 'J1' OR V_CTG = 'JS' OR V_CTG = 'JD' OR V_CTG = 'J2'.
        V_CTG = V_TAB-ATWRT.
      ENDIF.
    ELSEIF V_CTG = 'J1'.
      CONCATENATE 'Grade Batch' IT_CHARG-CHARG 'harus JD / JS...!' INTO VX_MSG SEPARATED BY SPACE.
      EXIT.
    ELSEIF V_CTG = 'J2'.
      CONCATENATE 'Grade Batch' IT_CHARG-CHARG 'harus JD / JS...!' INTO VX_MSG SEPARATED BY SPACE.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_CTGFORMULA4

*&---------------------------------------------------------------------*
*&      Form  GET_BARC2FORMULA1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  V_BARC2   text
*  <--  V_BARC2   text
*----------------------------------------------------------------------*
FORM GET_BARC2FORMULA1 USING V_BARC2.

  READ TABLE V_TAB WITH KEY ATNAM = 'ZZNOROLLTOYOBO'.
  IF SY-SUBRC = 0.
    V_YEAR  =  V_TAB-ATWTB+0(1).
    V_MONTH =  V_TAB-ATWTB+1(1).
    V_DATE  =  V_TAB-ATWTB+2(2).

    CALL FUNCTION 'CONVERT_STRING_TO_INTEGER'
      EXPORTING
        P_STRING = V_MONTH
      IMPORTING
        P_INT    = V_BLN.

    V_BLN_A = V_BLN * 2 - 1.
    V_BLN_GANJIL = V_BLN_A.
    V_BLN_B = V_BLN * 2.
    V_BLN_GENAP = V_BLN_B.

    IF V_DATE <= 50.
      IF V_BLN_GANJIL < 10.
        CONCATENATE  V_YEAR '0' V_BLN_GANJIL INTO V_BARC2.
      ELSEIF V_BLN_GANJIL >= 10.
        CONCATENATE  V_YEAR V_BLN_GANJIL INTO V_BARC2.
      ENDIF.
    ELSEIF V_DATE > 50.
      IF V_BLN_GENAP < 10.
        CONCATENATE  V_YEAR '0' V_BLN_GENAP INTO V_BARC2.
      ELSEIF V_BLN_GENAP >= 10.
        CONCATENATE  V_YEAR V_BLN_GENAP INTO V_BARC2.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " GET_BARC2FORMULA1
*&---------------------------------------------------------------------*
*&      Form  GET_BARC2FORMULA2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  V_BARC2   text
*  <--  V_BARC2   text
*  -->  V_MATNR   text
*  -->  V_CHARG   text
*----------------------------------------------------------------------*
FORM GET_BARC2FORMULA2 USING V_BARC2 V_MATNR V_CHARG.

  CLEAR V_POSTDATE.
  IF V_MATNR IS NOT INITIAL AND V_CHARG IS NOT INITIAL.
    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = V_MATNR
        CHARG = V_CHARG
      IMPORTING
        PDATE = V_POSTDATE.
    CONCATENATE V_POSTDATE+3(1) V_POSTDATE+4(2) INTO V_BARC2.
  ENDIF.

ENDFORM.                    " GET_BARC2FORMULA2

*&---------------------------------------------------------------------*
*&      Form  GET_MOTHER_ROLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_MOTHER_ROLL.  "GET MOTHER ROLL

  CLEAR: VX_ATNROL,VX_ATNUOM,VX_ROLNO,VX_MATNR_JR,VX_CHARG_JR,VX_UOM.

  SELECT SINGLE ATINN INTO VX_ATNROL FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.
  SELECT SINGLE ATINN INTO VX_ATNUOM FROM CABN WHERE ATNAM = 'ZZUNITOFMEASURE'.

  SELECT SINGLE  AUSP~ATWRT INTO VX_ROLNO
    FROM AUSP JOIN MCH1 ON AUSP~OBJEK = MCH1~CUOBJ_BM
    WHERE MCH1~MATNR = V_MATNR AND MCH1~CHARG = IT_CHARG-CHARG AND AUSP~ATINN = VX_ATNROL.

  VX_ROLNO = VX_ROLNO+0(13).

  "Get Batch JR 101 Only, case cancelled JR
  SELECT SINGLE MSEG~MATNR MSEG~CHARG
    INTO (VX_MATNR_JR, VX_CHARG_JR)
    FROM MSEG
  JOIN MKPF ON MSEG~MBLNR = MKPF~MBLNR AND MSEG~MJAHR EQ MKPF~MJAHR
    WHERE MSEG~BWART EQ '101'
    AND MKPF~BKTXT = VX_ROLNO.

  IF SY-SUBRC NE 0.
    CONCATENATE 'Data Mother Roll Batch' IT_CHARG-CHARG 'tidak ditemukan..!' INTO VX_MSG SEPARATED BY SPACE.
    EXIT.
  ENDIF.

  ITAB-CHARG_JR = VX_CHARG_JR.

ENDFORM.                    "GET_MOTHER_ROLL

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_CUSTOM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA_CUSTOM USING V_BARC1 V_FTYPE V_THICK V_WIDTH V_LENGTH V_GRD V_CTG.

  CLEAR: V_GRD_LEN.
  IF V_GRD IS NOT INITIAL.
    V_GRD_LEN = STRLEN( V_GRD ).
    V_CTG_LEN = STRLEN( V_CTG ).
    IF V_GRD_LEN = 1.
      CONCATENATE V_FTYPE V_THICK V_WIDTH V_LENGTH V_GRD INTO V_BARC1.
      CONCATENATE V_BARC1 V_CTG INTO V_BARC1 SEPARATED BY SPACE.
    ELSE.
      CONCATENATE V_FTYPE V_THICK V_WIDTH V_LENGTH V_GRD V_CTG INTO V_BARC1.
    ENDIF.
  ENDIF.

ENDFORM.                    "GET_DATA_CUSTOM
*&---------------------------------------------------------------------*
*&      Form  TY_RIGHT_JUSTIFIED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_CHARLEN   text
*      -->V_VALUE     text
*----------------------------------------------------------------------*
FORM TY_RIGHT_JUSTIFIED  USING V_CHARLEN V_VALUE.

  CLEAR V_STRLEN.
  CONDENSE V_VALUE NO-GAPS.
  REPLACE ALL OCCURRENCES OF '.00' IN V_VALUE WITH ' '.
  REPLACE ALL OCCURRENCES OF '.0' IN V_VALUE WITH ' '.

  PERFORM CLEARDOTCOMMA USING V_VALUE.

  V_STRLEN = V_CHARLEN - STRLEN( V_VALUE ).
  SHIFT V_VALUE BY V_STRLEN PLACES RIGHT.

ENDFORM.                    " TY_RIGHT_JUSTIFIED
*&---------------------------------------------------------------------*
*&      Form  CLEARDOTCOMMA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_VALUE  text
*----------------------------------------------------------------------*
FORM CLEARDOTCOMMA  USING  V_TY_INPUT.
  V_TEST = V_TY_INPUT.
  CONDENSE V_TEST NO-GAPS.
  REPLACE ALL OCCURRENCES OF '.' IN V_TEST WITH ''.
  REPLACE ALL OCCURRENCES OF ',' IN V_TEST WITH ''.
  V_TY_INPUT = V_TEST.
ENDFORM.                    " CLEARDOTCOMMA

*&---------------------------------------------------------------------*
*&      Form  CHECK_IMAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IMAGE      text
*----------------------------------------------------------------------*
FORM CHECK_IMAGE USING IMAGE CHANGING MESSAGE.
  SELECT SINGLE TDNAME INTO V_TDNAME FROM STXBITMAPS WHERE TDID = 'BMAP' AND TDOBJECT = 'GRAPHICS' AND TDNAME = IMAGE.
  IF SY-SUBRC NE 0.
    CONCATENATE 'Image' IMAGE 'not found...!' INTO MESSAGE SEPARATED BY SPACE.
    MESSAGE MESSAGE TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
    CLEAR IMAGE.
  ENDIF.
ENDFORM.                    "CHECK_IMAGE

*&---------------------------------------------------------------------*
*&      Form  print_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM PRINT_DATA.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  CONTROL_PARAMETERS-NO_DIALOG = 'X'.
  CONTROL_PARAMETERS-PREVIEW = 'X'.

  CALL FUNCTION V_FUNCNAME
    EXPORTING
      CONTROL_PARAMETERS = CONTROL_PARAMETERS
      OUTPUT_OPTIONS     = OUTPUT_OPTIONS
      V_CTG_LEN          = V_CTG_LEN
    TABLES
      ITAB               = ITAB.

ENDFORM.                    "print_data

*&---------------------------------------------------------------------*
*&      Form  CHECK_ALLOWED_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LABELCODE  text
*----------------------------------------------------------------------*
FORM CHECK_ALLOWED_MATERIAL USING LABELCODE.
 SELECT LABELTYPE VALUE FROM ZLABELMAP_TYB_AL INTO TABLE IT_MAP_MATNR WHERE CODE = 'ZTYBMAT' AND LABELTYPE = LABELCODE.
  IF SY-SUBRC EQ 0.
    READ TABLE IT_MAP_MATNR WITH KEY MATNR = IT_CHARG-MATNR.
    IF SY-SUBRC NE 0.
      CONCATENATE 'Material' IT_CHARG-MATNR 'is not allowed for label' LABELCODE INTO VX_MSG SEPARATED BY SPACE.
      MESSAGE VX_MSG TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.
ENDFORM.                    "CHECK_ALLOWED_MATERIAL