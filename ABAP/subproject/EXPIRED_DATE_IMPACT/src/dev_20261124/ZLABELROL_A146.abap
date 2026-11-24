*&---------------------------------------------------------------------*
*& Report  ZMMR_LABELROL_KTNG
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZLABELROL_A146.

TABLES: MCHB.

DATA : V_FORMNAME  TYPE TDSFNAME  VALUE 'ZLABELROL_A146',
       V_FUNCNAME  TYPE RS38L_FNAM,
       V_TAB       TYPE API_VALI OCCURS 0 WITH HEADER LINE,
       CONTROL_PARAMETERS TYPE SSFCTRLOP,
       OUTPUT_OPTIONS TYPE SSFCOMPOP.

DATA: ITAB LIKE ZLABEL_WINDOWS OCCURS 0 WITH HEADER LINE.

DATA: TOCHAR TYPE P DECIMALS 0,
      TOCHAR1 TYPE P DECIMALS 2,
      TOCHAR2 TYPE P DECIMALS 1,
      TOSTRG TYPE STRING,
      V_MESSAGE(50),
      V_ERR(1),
      V_DATE(3),
      V_CODERESOURCE(1),
      V_POSTDATE TYPE MKPF-BUDAT,
      V_VBELN       LIKE MSKA-VBELN,
      V_POSNR       LIKE MSKA-POSNR,
      V_OBJEK         LIKE AUSP-OBJEK,
      V_CHARG         LIKE MCH1-CHARG,
      V_ATINN         LIKE CABN-ATINN,
      V_MAINSLIT(4),
      V_PRODDATE(6),
      V_ROLLJR(30),
      V_LINE(5),
      V_CODE(5),
      V_MOYE(5),
      V_SEQ(5),
      V_GRADE(5),
      V_JUMLAH TYPE I.

DATA: BEGIN OF IT_CHARG OCCURS 0,
        CHARG LIKE MCHB-CHARG,
        MATNR LIKE MCHB-MATNR,
      END OF IT_CHARG.

SELECT-OPTIONS: P_CHARG FOR MCHB-CHARG.
PARAMETER: V_MATNR LIKE MCHB-MATNR NO-DISPLAY,
           V_COPIES(3) DEFAULT '1'.

START-OF-SELECTION.
  PERFORM GET_DATA_MAIN.
  IF V_ERR EQ 'X'.
    MESSAGE V_MESSAGE TYPE 'I'.
    EXIT.
  ELSEIF ITAB[] IS INITIAL.
    MESSAGE 'Data tidak ditemukan' TYPE 'I'.
    EXIT.
  ELSE.
    PERFORM PRINT_DATA.
  ENDIF.


END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_MAIN
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

  LOOP AT IT_CHARG.

    ITAB-VBATCH = IT_CHARG-CHARG.

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

    READ TABLE V_TAB WITH KEY ATNAM = 'ZZLABEL'.
    IF SY-SUBRC = 0.
      IF V_TAB-ATWRT NE 'A146'.
        CONTINUE.
      ENDIF.
    ENDIF.

    "Check SO
    SELECT SINGLE VBELN POSNR INTO (ITAB-VVBELN, ITAB-VPOSNR)
      FROM MSKA
     WHERE MATNR = IT_CHARG-MATNR
       AND CHARG = IT_CHARG-CHARG
       AND ( KALAB > 0 OR KAINS > 0 OR KASPE > 0 ).

    "Get Cust Material
    IF SY-SUBRC = 0.
      SELECT SINGLE KDMAT INTO ITAB-VPARTNO FROM VBAP WHERE VBELN = ITAB-VVBELN AND POSNR = ITAB-VPOSNR.
      IF SY-SUBRC NE 0.
        V_MESSAGE = 'Customer material belum ada...!'.
        V_ERR = 'X'.
        EXIT.
      ENDIF.

      CLEAR V_JUMLAH.
      V_JUMLAH = STRLEN( ITAB-VPARTNO ).
      IF V_JUMLAH NE 5.
        V_MESSAGE = 'Jumlah karakter customer material tidak sesuai (5 Karakter)...!'.
        V_ERR = 'X'.
        EXIT.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ITAB-VVBELN
        IMPORTING
          OUTPUT = ITAB-VVBELN.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = ITAB-VPOSNR
        IMPORTING
          OUTPUT = ITAB-VPOSNR.
      CONCATENATE ITAB-VVBELN ITAB-VPOSNR INTO ITAB-VSONUM_ITEM SEPARATED BY '/'.
    ELSE.
      CONCATENATE 'Batch' IT_CHARG-CHARG 'tidak terikat SO..!' INTO V_MESSAGE SEPARATED BY SPACE.
      V_ERR = 'X'.
      EXIT.
    ENDIF.

    "Get Main Characteristic
    LOOP AT V_TAB.
      IF V_TAB-ATNAM = 'ZZCODE'.
        ITAB-VTYPE = V_TAB-ATWTB.
        READ TABLE V_TAB WITH KEY ATNAM = 'ZZALIAS'.
        IF SY-SUBRC = 0.
          ITAB-VTYPE = V_TAB-ATWRT.
        ENDIF.
      ELSEIF V_TAB-ATNAM = 'ZZWIDTH'.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        ITAB-VWIDTH = TOSTRG.
      ELSEIF V_TAB-ATNAM = 'ZZLENGTH'.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        ITAB-VLENGTH = TOSTRG.
      ELSEIF V_TAB-ATNAM = 'ZZTHICKNESS'.
        TOCHAR = V_TAB-ATFLV.
        TOSTRG = TOCHAR.
        ITAB-VTHICK = TOSTRG.
      ELSEIF V_TAB-ATNAM = 'ZZNOMORROLL'.
        ITAB-VROLL = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVEMS'.
        ITAB-VDERIVATIVEMS = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM = 'ZZPOSITIONMS'.
        ITAB-VPOSITIONMS = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM = 'ZZDERIVATIVESS'.
        ITAB-VDERIVATIVESS = V_TAB-ATWRT.
      ELSEIF V_TAB-ATNAM = 'ZZPOSITIONSS'.
        ITAB-VPOSITIONSS = V_TAB-ATWRT.
      ENDIF.
    ENDLOOP.

    "Get Production Date
    CALL FUNCTION 'Z_GET_PRODUCTION_DATE'
      EXPORTING
        MATNR = IT_CHARG-MATNR
        CHARG = IT_CHARG-CHARG
      IMPORTING
        PDATE = V_POSTDATE.

    IF SY-SUBRC EQ 0.
      CONCATENATE V_POSTDATE+2(2) V_POSTDATE+4(4) INTO V_PRODDATE.
      CONCATENATE V_POSTDATE(4) V_POSTDATE+4(2) V_POSTDATE+6(2) INTO ITAB-VPOSTDATE SEPARATED BY '/'.
    ELSE.
      V_MESSAGE =  'Production date belum ada...!' .
      V_ERR = 'X'.
      EXIT.
    ENDIF.

    PERFORM GET_JUMBO_ROLL.
    PERFORM GET_RESOURCE.

    CONCATENATE ITAB-VDERIVATIVEMS ITAB-VPOSITIONMS INTO V_MAINSLIT.
    IF V_MAINSLIT EQ ''.
      V_MESSAGE = 'Turunan dan posisi mainslit tidak ditemukan...!'.
      V_ERR = 'X'.
      EXIT.
    ENDIF.
    IF ITAB-VDERIVATIVESS EQ ''.
      ITAB-VDERIVATIVESS = '00'.
    ENDIF.
    IF ITAB-VPOSITIONSS EQ ''.
      ITAB-VPOSITIONSS = '00'.
    ENDIF.

    "Set Barcode
    CONCATENATE 'L' ITAB-VPARTNO 'B3' V_PRODDATE '00' V_CODERESOURCE ITAB-VPOINT V_MAINSLIT ITAB-VDERIVATIVESS ITAB-VPOSITIONSS
    INTO ITAB-VBARCTEXTCUST SEPARATED BY '-'.

    CONCATENATE 'L' ITAB-VPARTNO 'B3' V_PRODDATE '00' V_CODERESOURCE ITAB-VPOINT V_MAINSLIT ITAB-VDERIVATIVESS ITAB-VPOSITIONSS
    INTO ITAB-VBARCODECUST.

    CLEAR V_JUMLAH.
    V_JUMLAH = STRLEN( ITAB-VBARCTEXTCUST ).
    IF V_JUMLAH NE 40.
      V_MESSAGE = 'Jumlah karakter barcode tidak sesuai (40 Karakter)...!'.
      V_ERR = 'X'.
      EXIT.
    ENDIF.

    DO V_COPIES TIMES.
      APPEND ITAB.
    ENDDO.
    CLEAR: ITAB.
  ENDLOOP.

ENDFORM.                    "GET_DATA_MAIN

*&---------------------------------------------------------------------*
*&      Form  PRINT_DATA
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
    TABLES
      ITAB               = ITAB.

ENDFORM.                    "PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_JUMBO_ROLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_JUMBO_ROLL .
  CLEAR: V_OBJEK, V_CHARG, V_LINE, V_CODE, V_MOYE, V_SEQ, V_GRADE.

  SELECT SINGLE ATINN INTO V_ATINN FROM CABN WHERE ATNAM = 'ZZNOMORROLL'.
  SPLIT ITAB-VROLL AT SPACE INTO V_LINE V_CODE V_MOYE V_SEQ V_GRADE.
  CONCATENATE V_LINE V_CODE V_MOYE V_SEQ INTO V_ROLLJR SEPARATED BY SPACE.

  SELECT SINGLE OBJEK INTO V_OBJEK FROM AUSP WHERE ATINN = V_ATINN AND KLART = '023' AND ATWRT = V_ROLLJR.
  IF SY-SUBRC EQ 0.
    SELECT SINGLE CHARG INTO V_CHARG FROM MCH1 WHERE CUOBJ_BM = V_OBJEK.
    IF SY-SUBRC EQ 0.
      ITAB-VPOINT = V_CHARG+4(6).
    ENDIF.
  ENDIF.

  IF ITAB-VPOINT EQ ''.
    V_MESSAGE = 'Batch jumbo roll tidak ditemukan...!'.
    V_ERR = 'X'.
    EXIT.
  ENDIF.
ENDFORM.                    " GET_JUMBO_ROLL

*&---------------------------------------------------------------------*
*&      Form  GET_RESOURCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_RESOURCE.
  DATA: V_AUFNR LIKE MSEG-AUFNR,
        V_MBLNR LIKE MSEG-MBLNR,
        V_SMBLN LIKE MSEG-SMBLN,
        V_COMBI LIKE AFPO-AUFNR,
        V_RESOURCE LIKE CRHD-ARBPL.

  CLEAR: V_AUFNR, V_MBLNR, V_SMBLN, V_COMBI, V_RESOURCE,
         V_CODERESOURCE.

  SELECT AUFNR MBLNR INTO (V_AUFNR, V_MBLNR) FROM MSEG WHERE CHARG = IT_CHARG-CHARG AND BWART = '101'.
    SELECT SINGLE SMBLN INTO V_SMBLN FROM MSEG WHERE SMBLN = V_MBLNR. " CEK ADA PEMBATALAN (102) ATAU TIDAK
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.
  ENDSELECT.

  IF V_AUFNR = ''.
    V_MESSAGE = 'Order tidak ditemukan...!'.
    V_ERR = 'X'.
    EXIT.
  ENDIF.

  SELECT SINGLE AUFNR INTO V_COMBI FROM AFPO WHERE MILL_OC_AUFNR_U = V_AUFNR.
  IF SY-SUBRC NE 0.
    V_MESSAGE = 'Order tidak ditemukan...!'.
    V_ERR = 'X'.
    EXIT.
  ENDIF.

  SELECT SINGLE CRHD~ARBPL INTO V_RESOURCE
    FROM AFRU JOIN CRHD ON AFRU~ARBID = CRHD~OBJID WHERE AFRU~AUFNR = V_COMBI.

  IF V_RESOURCE EQ 'PATL04-W'.
    V_CODERESOURCE = 1.
  ELSEIF V_RESOURCE EQ 'PATL05-W'.
    V_CODERESOURCE = 2.
  ELSEIF V_RESOURCE EQ 'PATL06-W'.
    V_CODERESOURCE = 3.
  ELSEIF V_RESOURCE EQ 'PATL07-W'.
    V_CODERESOURCE = 4.
  ELSEIF V_RESOURCE EQ 'PATL08-W'.
    V_CODERESOURCE = 5.
  ELSEIF V_RESOURCE EQ 'PDAHUA-W'.
    V_CODERESOURCE = 6.
  ELSEIF V_RESOURCE EQ 'PPSM-W'.
    V_CODERESOURCE = 8.
  ENDIF.

  IF V_CODERESOURCE EQ ''.
    V_MESSAGE = 'Resource tidak ditemukan...!'.
    V_ERR = 'X'.
    EXIT.
  ENDIF.

ENDFORM.                    "GET_RESOURCE