*----------------------------------------------------------------------*
***INCLUDE ZFIC_IB_AUC_AIAB_TRANSF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  AIAB_TRANS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AIAB_TRANS .
  LOOP AT IDATA_AIAB.
    CLEAR : IT_BDCMSGCOLL, IT_BDCDATA.
    REFRESH : IT_BDCMSGCOLL, IT_BDCDATA.

      perform bdc_dynpro      using 'SAPMA15B' '0110'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'AICOM-ANLN1'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=AUSF'.
      perform bdc_field       using 'AICOM-BUKRS'
                                    IDATA_AIAB-BUKRS.
      perform bdc_field       using 'AICOM-ANLN1'
                                    IDATA_AIAB-ANLN1.
      perform bdc_field       using 'AICOM-ANLN2'
                                    IDATA_AIAB-ANLN2.

      perform bdc_dynpro      using 'SAPMSSY0' '0120'.
      perform bdc_field       using 'BDC_CURSOR'
                                    '07/03'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=&ALL'.

      perform bdc_dynpro      using 'SAPMSSY0' '0120'.
      perform bdc_field       using 'BDC_CURSOR'
                                    '07/03'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=BURG'.

      perform bdc_dynpro      using 'SAPLKOBS' '0130'.
*      perform bdc_field       using 'BDC_CURSOR'
*                                    'COBRB-PROZS(01)'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=CHCK'.
      perform bdc_field       using 'COBRB-KONTY(01)'
                                    IDATA_AIAB-KONTY.
      perform bdc_field       using 'DKOBR-EMPGE(01)'
                                    IDATA_AIAB-EMPGE.
*      perform bdc_field       using 'COBRB-PROZS(01)'
*                                    IDATA_AIAB-PROZS.

      perform bdc_dynpro      using 'SAPLKOBS' '0130'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=BACK'.

      perform bdc_dynpro      using 'SAPMSSY0' '0120'.
      perform bdc_field       using 'BDC_CURSOR'
                                    '07/03'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=SAVE'.


    CALL TRANSACTION 'AIAB' USING IT_BDCDATA "GANTI TCODENYA
          MODE  'N'
          UPDATE 'S'
          MESSAGES INTO IT_BDCMSGCOLL.

    PERFORM CREATE_MESSAGE.

  ENDLOOP.
ENDFORM.                    " AIAB_TRANS
*&---------------------------------------------------------------------*
*&      Form  AIBU_TRANS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AIBU_TRANS .
  LOOP AT IDATA_AIBU.
    CLEAR : IT_BDCMSGCOLL, IT_BDCDATA, VBLDAT, VBZDAT, VBUDAT.
    REFRESH : IT_BDCMSGCOLL, IT_BDCDATA.

    CONCATENATE IDATA_AIBU-BLDAT+0(2) IDATA_AIBU-BLDAT+3(2) IDATA_AIBU-BLDAT+6(4) INTO VBLDAT.
    CONCATENATE IDATA_AIBU-BZDAT+0(2) IDATA_AIBU-BZDAT+3(2) IDATA_AIBU-BZDAT+6(4) INTO VBZDAT.
    CONCATENATE IDATA_AIBU-BUDAT+0(2) IDATA_AIBU-BUDAT+3(2) IDATA_AIBU-BUDAT+6(4) INTO VBUDAT.

      perform bdc_dynpro      using 'SAPMA12B' '0100'.
      perform bdc_field       using 'BDC_CURSOR'
                                    'LKO74-TESTLAUF'.
      perform bdc_field       using 'BDC_OKCODE'
                                    '=AUSF'.
      perform bdc_field       using 'ANLA-BUKRS'
                                    IDATA_AIBU-BUKRS.
      perform bdc_field       using 'ANLA-ANLN1'
                                    IDATA_AIBU-ANLN1.
      perform bdc_field       using 'ANLA-ANLN2'
                                    IDATA_AIBU-ANLN2.
      perform bdc_field       using 'ANEK-BLDAT'
                                    VBLDAT.
      perform bdc_field       using 'ANEP-BZDAT'
                                    VBZDAT.
      perform bdc_field       using 'ANEK-BUDAT'
                                    VBUDAT.
      perform bdc_field       using 'ANBZ-MONAT'
                                    IDATA_AIBU-MONAT.
      perform bdc_field       using '*KOMK3-SGTXT'
                                    IDATA_AIBU-SGTXT.
      perform bdc_field       using '*KOMK1-BLART'
                                    IDATA_AIBU-BLART.
      perform bdc_field       using '*KOMK3-ZUONR'
                                    IDATA_AIBU-ZUONR.
      perform bdc_field       using 'LKO74-TESTLAUF'
                                    ''.

*      perform bdc_dynpro      using 'SAPMSSY0' '0120'.
*      perform bdc_field       using 'BDC_OKCODE'
*                                    '=BACK'.



    CALL TRANSACTION 'AIBU' USING IT_BDCDATA "GANTI TCODENYA
          MODE  'N'
          UPDATE 'S'
          MESSAGES INTO IT_BDCMSGCOLL.

    PERFORM CREATE_MESSAGE.

  ENDLOOP.
ENDFORM.                    " AIBU_TRANS
*&--------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->PROG       text
*      -->SCR        text
*---------------------------------------------------------------------*
FORM bdc_dynpro USING prog scr.
  CLEAR it_bdcdata.
  it_bdcdata-program = prog.
  it_bdcdata-dynpro  = scr.
  it_bdcdata-dynbegin = 'X'.
  APPEND it_bdcdata.
ENDFORM.                    "BDC_DYNPRO
*&--------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR it_bdcdata.
  it_bdcdata-fnam = fnam.
  it_bdcdata-fval  = fval.
  APPEND it_bdcdata.
ENDFORM.                    "bdc_field
*&---------------------------------------------------------------------*
*&      Form  CREATE_MESSAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_MESSAGE .
  IF sy-subrc <> 0.
    clear : vtext.
    LOOP AT IT_BDCMSGCOLL WHERE MSGTYP = 'E' or MSGTYP = 'S'.
      IF IT_BDCMSGCOLL-MSGV1 = ''. IT_BDCMSGCOLL-MSGV1 = '*'. ENDIF.
      IF IT_BDCMSGCOLL-MSGV2 = ''. IT_BDCMSGCOLL-MSGV2 = '*'. ENDIF.
      IF IT_BDCMSGCOLL-MSGV3 = ''. IT_BDCMSGCOLL-MSGV3 = '*'. ENDIF.
      IF IT_BDCMSGCOLL-MSGV4 = ''. IT_BDCMSGCOLL-MSGV4 = '*'. ENDIF.
      write it_bdcmsgcoll-MSGV1 to vtext1.
      write it_bdcmsgcoll-MSGV2 to vtext2.
      write it_bdcmsgcoll-MSGV3 to vtext3.
      write it_bdcmsgcoll-MSGV4 to vtext4.
      write it_bdcmsgcoll-msgnr to v_dum.
      CALL FUNCTION '/SAPTRX/GET_MESSAGE_TEXT'
        EXPORTING
          msgid       = it_bdcmsgcoll-msgid
          msgno       = v_dum
          msgv1       = vtext1
          msgv2       = vtext2
          msgv3       = vtext3
          msgv4       = vtext4
        IMPORTING
          MESSAGETEXT = vtext.
    ENDLOOP.
    if R1 EQ 'X'.
      IRESULT-ANLN1  = IDATA_AIAB-ANLN1.
    else.
      IRESULT-ANLN1  = IDATA_AIBU-ANLN1.
    endif.
    if vtext = 'No batch input data for screen SAPLSPO2 0100'.
      IRESULT-DRESULT = 'Error, Distribution has created'.
    else.
      concatenate 'Error,' vtext into IRESULT-DRESULT separated by space.
    endif.
    APPEND IRESULT.
  ELSE.
    IF IT_BDCMSGCOLL[] IS INITIAL.
      IRESULT-ANLN1  = IDATA_AIAB-ANLN1.
      IRESULT-DRESULT = 'SUCCESSFULLY'.
      APPEND IRESULT.
    ELSE.
      LOOP AT IT_BDCMSGCOLL WHERE MSGTYP = 'S'. "AND MSGNR = '398' AND MSGV2 ='' AND MSGV3 = space.
        if R1 EQ 'X'.
          IRESULT-ANLN1  = IDATA_AIAB-ANLN1.
        else.
          IRESULT-ANLN1  = IDATA_AIBU-ANLN1.
        endif.
        IRESULT-DRESULT = 'SUCCESSFULLY'.
        APPEND IRESULT.
     ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " CREATE_MESSAGE
*&---------------------------------------------------------------------*
*&      Form  DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY .
  IF IRESULT[] IS INITIAL.
    MESSAGE 'No Data Upload' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
ENDFORM.                    " DISPLAY
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  DATA: XFIELDCAT TYPE SLIS_FIELDCAT_ALV,
        N TYPE I.

  REFRESH GT_FIELDCAT.
  N = 0.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME     = 'ANLN1'. "DISESUAIKAN DENGAN PROGRAM
  XFIELDCAT-TABNAME       = 'IRESULT'."DISESUAIKAN DENGAN TABEL YANG ADA
  XFIELDCAT-ROW_POS       = 1.
  XFIELDCAT-COL_POS       = N.
  XFIELDCAT-REPTEXT_DDIC  = 'Asset'.
  XFIELDCAT-OUTPUTLEN     = 20.
  APPEND XFIELDCAT TO GT_FIELDCAT.

  N = N + 1.
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME     = 'DRESULT'. "DISESUAIKAN DENGAN PROGRAM
  XFIELDCAT-TABNAME       = 'IRESULT'."DISESUAIKAN DENGAN TABEL YANG ADA
  XFIELDCAT-ROW_POS       = 1.
  XFIELDCAT-COL_POS       = N.
  XFIELDCAT-REPTEXT_DDIC  = 'Messages'.
  XFIELDCAT-OUTPUTLEN     = 70.
  APPEND XFIELDCAT TO GT_FIELDCAT.
ENDFORM.                    " F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM        = G_REPID
      "I_CALLBACK_TOP_OF_PAGE    = 'TOP-OF-PAGE'
      IS_LAYOUT                 = GS_LAYOUT
      IT_FIELDCAT               = GT_FIELDCAT[]
      IS_PRINT                  = Y_PRINT
      I_SAVE                    = G_SAVE
      IS_VARIANT                = GS_VARIANT
      IT_EVENTS                 = GT_EVENTS[]
    TABLES
      T_OUTTAB                  = IRESULT
    EXCEPTIONS
      PROGRAM_ERROR             = 1
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " F_LAYOUT
*-------------------------------------------------------------------*
* FORM  TOP-OF-PAGE                                                 *
*-------------------------------------------------------------------*
* ALV REPORT HEADER                                                 *
*-------------------------------------------------------------------*
FORM TOP-OF-PAGE.
*ALV HEADER DECLARATIONS
  DATA: T_HEADER TYPE SLIS_T_LISTHEADER,
        WA_HEADER TYPE SLIS_LISTHEADER,
        T_LINE LIKE WA_HEADER-INFO,
        LD_LINES TYPE I,
        LD_LINESC(10) TYPE C.
*
** TITLE
*  WA_HEADER-TYP  = 'H'.
*  WA_HEADER-INFO = 'Log Upload Shipment Cost'.
*  APPEND WA_HEADER TO T_HEADER.
*  CLEAR WA_HEADER.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = T_HEADER.
ENDFORM. "TOP-OF-PAGE