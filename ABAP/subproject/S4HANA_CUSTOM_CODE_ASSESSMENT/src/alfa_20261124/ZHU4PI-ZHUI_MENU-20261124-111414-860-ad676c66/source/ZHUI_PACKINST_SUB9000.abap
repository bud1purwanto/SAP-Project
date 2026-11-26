*&---------------------------------------------------------------------*
*&  Include           ZHUI_PACKINST_SUB9000
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_okcode_9000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_UCOMM  text
*----------------------------------------------------------------------*
FORM F_OKCODE_9000  USING FU_OKCODE.
  DATA: ZWERKS LIKE VBAP-WERKS, "ADD NEW COMPANY
        ZVKORG LIKE VBAK-VKORG,
        ZVBELN LIKE VBAP-VBELN,
        ZPOSNR LIKE VBAP-POSNR.

  REFRESH ITAB_PINS.
  CLEAR: ITAB_PINS, ZWERKS, ZVKORG, ZVBELN, ZPOSNR.

  "  ADD NEW COMPANY
  IF SY-TCODE EQ 'ZHU4SO'. "ADD NEW COMPANY
    IF FU_OKCODE EQ 'CREATE' OR FU_OKCODE EQ 'CHANGE' OR FU_OKCODE EQ 'DISPLAY'.
      SELECT SINGLE VBAK~VKORG VBAP~WERKS INTO (ZVKORG , ZWERKS )
        FROM VBAK JOIN VBAP ON VBAK~VBELN = VBAP~VBELN
        WHERE VBAP~VBELN = ZPACK_PCH-VBELN AND VBAP~POSNR = ZPACK_PCH-POSNR.
      IF ZPACK_PCH-VBELN IS NOT INITIAL.
        IF ZVKORG NE '1000'.
          IF ZWERKS EQ '1000' OR ZWERKS EQ '2000'.
          ELSE.
            MESSAGE 'Harus SO Milik Trias' TYPE 'I'.
            LEAVE TO SCREEN 0.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE 'Silahkan Input Data' TYPE 'I'.
        LEAVE SCREEN.
      ENDIF.
    ENDIF.
  ENDIF.

  IF SY-TCODE EQ 'ZHU4FS'.
    IF FU_OKCODE EQ 'CHANGE' OR FU_OKCODE EQ 'DISPLAY' OR FU_OKCODE EQ 'COPY'.
      SELECT SINGLE VBELN POSNR WERKS INTO (ZVBELN, ZPOSNR, ZWERKS )
        FROM ZPACK_PCH WHERE PINNR = ZPACK_PCH-PINNR.
*
*      SELECT SINGLE VBAK~VKORG VBAP~WERKS INTO (ZVKORG , ZWERKS )
*        FROM VBAK JOIN VBAP ON VBAK~VBELN = VBAP~VBELN
*        WHERE VBAP~VBELN = ZVBELN AND VBAP~POSNR = ZPOSNR.

*      IF ZVKORG NE '1000'.
      IF ZWERKS EQ '1000' OR ZWERKS EQ '2000'.
      ELSE.
        MESSAGE 'Harus PI Milik Trias' TYPE 'I'.
        LEAVE TO SCREEN 0.
      ENDIF.
*      ENDIF.
    ENDIF.
  ENDIF. "end ADD NEW COMPANY


  CASE FU_OKCODE.
    WHEN 'CREATE'.   PERFORM F_NEW.
    WHEN 'CHANGE'.   PERFORM F_CHANGE.
    WHEN 'DISPLAY'.  PERFORM F_DISPLAY.
    WHEN 'LIST'.     PERFORM F_LIST.
    WHEN 'COPY'.     PERFORM F_COPY.
    WHEN 'BACK'.     PERFORM F_BACK.
    WHEN 'EXIT'.     PERFORM F_EXIT.
    WHEN 'CANCEL'.   PERFORM F_CANCEL.
    WHEN OTHERS.  CLEAR SY-UCOMM. CLEAR FU_OKCODE.
  ENDCASE.

ENDFORM.                    " f_okcode_9000


*&---------------------------------------------------------------------*
*&      Form  f_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_NEW .
  DATA B_IS_DUPLICATE TYPE FLAG.

  IF D_ISFREESTOCK = C_NO. "SO based
    IF ZPACK_PCH-POSNR IS INITIAL OR ZPACK_PCH-VBELN IS INITIAL.
      MESSAGE I010.

    ELSE.
      D_DISPMODE = C_DISP_NEW.

      DATA N_COUNT TYPE I.
      SELECT COUNT( * ) INTO N_COUNT FROM VBAP WHERE VBELN = ZPACK_PCH-VBELN
        AND POSNR = ZPACK_PCH-POSNR.

      IF N_COUNT EQ 0.
        MESSAGE I011.
        RETURN.
      ENDIF.

      ZPACK_PCH-PINST = C_PINST_INACTIVE.

      DATA N_ERRNO TYPE I.
      PERFORM F_LOCK_SONUM CHANGING N_ERRNO.
      IF N_ERRNO NE 0.
        MESSAGE I012.
      ENDIF.

      PERFORM F_CHECK_DUPLICATES CHANGING B_IS_DUPLICATE.

      IF B_IS_DUPLICATE = C_YES.
        MESSAGE I013.

      ELSE.
        CLEAR:
            ZPACK_PCH-ZZCRITERIABF,
            ZPACK_PCH-ZZCRITERIA1,
            ZPACK_PCH-ZZCRITERIA2,
            ZPACK_PCH-ZZCRITERIAR,
            ZPACK_PCH-ZZWIDTH,
            ZPACK_PCH-ZZCORE3,
            ZPACK_PCH-ZZCORE6,
            ZPACK_PCH-ZZSHEET,
            ZPACK_PCH-DESCR.

        REFRESH ITAB_PINS.
        SELECT SINGLE MATNR INTO ZPACK_PCH-MATNR FROM VBAP
          WHERE VBELN = ZPACK_PCH-VBELN AND POSNR = ZPACK_PCH-POSNR.

*       --ship to party
        PERFORM F_LOAD_SO_PARTNER
          USING ZPACK_PCH-VBELN ZPACK_PCH-POSNR C_PARTNER_SHIPTO
          CHANGING D_SHIPTO D_SHIPTO_T.

*       --sold to party
        PERFORM F_LOAD_SO_PARTNER
          USING ZPACK_PCH-VBELN ZPACK_PCH-POSNR C_PARTNER_SOLDTO
          CHANGING D_SOLDTO D_SOLDTO_T.

        LEAVE TO SCREEN 9001.
      ENDIF.
    ENDIF.

  ELSE.
    D_DISPMODE = C_DISP_NEW.
    CLEAR ZPACK_PCH.
    ZPACK_PCH-PINST = C_PINST_INACTIVE.

    LEAVE TO SCREEN 9001.

  ENDIF.

ENDFORM.                    " f_new


*&---------------------------------------------------------------------*
*&      Form  f_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHANGE .
  DATA LD_ERRNO LIKE SY-SUBRC.

  D_DISPMODE = C_DISP_CHANGE.
  PERFORM F_LOAD_DOC CHANGING LD_ERRNO.
  IF LD_ERRNO EQ 0.
    PERFORM F_LOCK CHANGING LD_ERRNO.
    IF LD_ERRNO NE 0.
      ROLLBACK WORK.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_change

*&---------------------------------------------------------------------*
*&      Form  f_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_DISPLAY .
  DATA LD_ERRNO LIKE SY-SUBRC.

  D_DISPMODE = C_DISP_DISPLAY.
  PERFORM F_LOAD_DOC CHANGING LD_ERRNO.

ENDFORM.                    " f_display


*&---------------------------------------------------------------------*
*&      Form  f_list
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST .
  SET PARAMETER ID 'TSOURCE' FIELD SY-TCODE. "ADD NEW COMPANY
  CALL TRANSACTION 'ZHU4LS'.
ENDFORM.                    " f_list


*&---------------------------------------------------------------------*
*&      Form  f_copy
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_COPY .
  DATA WA_PCH TYPE ZPACK_PCH.
  SELECT SINGLE * INTO WA_PCH FROM ZPACK_PCH WHERE PINNR =
  ZPACK_PCH-PINNR.

  IF SY-SUBRC NE 0.
    MESSAGE E002 WITH 'Packing instruction' ZPACK_PCH-PINNR
    'tidak ada.'.

  ELSE.
    WA_PCH-CRNAM = SY-UNAME.
    WA_PCH-CRDAT = SY-DATUM.
    WA_PCH-CRTIM = SY-UZEIT.
    WA_PCH-PINST = C_PINST_INACTIVE.
    WA_PCH-LOEVR = C_NO.

    CLEAR:
      WA_PCH-PINNR,
      WA_PCH-AENAM,
      WA_PCH-AEDAT,
      WA_PCH-AETIM.

    REFRESH ITAB_PINS.
    SELECT * INTO TABLE ITAB_PINS FROM ZPACK_PC WHERE PINNR =
    ZPACK_PCH-PINNR.
    LOOP AT ITAB_PINS.
      CLEAR  ITAB_PINS-PINNR.
      MODIFY ITAB_PINS INDEX SY-TABIX.
    ENDLOOP.

    D_DISPMODE = C_DISP_NEW.
    MOVE-CORRESPONDING WA_PCH TO ZPACK_PCH.

    LEAVE TO SCREEN 9001.
  ENDIF.
ENDFORM.                    " f_copy

*&---------------------------------------------------------------------*
*&      Form  f_check_entry
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_ENTRY CHANGING FC_RETVAL.
  FC_RETVAL = 0.

  IF D_ISFREESTOCK IS INITIAL.
    IF ZPACK_PCH-VBELN IS INITIAL.
      FC_RETVAL = 2.

    ELSEIF ZPACK_PCH-POSNR IS INITIAL.
      FC_RETVAL = 3.

    ENDIF.

  ELSE.
    IF ZPACK_PCH-PINNR IS INITIAL.
      FC_RETVAL = 1.

    ENDIF.

  ENDIF.

ENDFORM.                    " f_check_entry


*&---------------------------------------------------------------------*
*&      Form  f_back
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_BACK .
  SET SCREEN 0.
  LEAVE SCREEN.
ENDFORM.                    " f_back


*&---------------------------------------------------------------------*
*&      Form  f_exit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_EXIT .
  LEAVE PROGRAM.
ENDFORM.                    " f_exit


*&---------------------------------------------------------------------*
*&      Form  f_cancel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CANCEL .
  PERFORM F_EXIT.
ENDFORM.                    " f_cancel


*&---------------------------------------------------------------------*
*&      Form  f_load_so
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LOAD_SO_PARTNER
  USING FU_SO FU_SOITEM FU_PARTNERTYPE
  CHANGING FC_PARTNERNO FC_PARTNERNAME.

  DATA LD_PARTNERNO     TYPE KUNNR.
  DATA LD_PARTNERNAME  TYPE NAME1_GP.

  SELECT SINGLE KNA1~KUNNR KNA1~NAME1
    INTO (LD_PARTNERNO, LD_PARTNERNAME)
    FROM KNA1 INNER JOIN VBPA ON KNA1~KUNNR = VBPA~KUNNR
    WHERE VBPA~VBELN = ZPACK_PCH-VBELN
      AND VBPA~PARVW = FU_PARTNERTYPE.

  IF SY-SUBRC EQ 0.
    FC_PARTNERNO   = LD_PARTNERNO.
    FC_PARTNERNAME = LD_PARTNERNAME.

  ELSE.
    CLEAR: FC_PARTNERNO, FC_PARTNERNAME.

  ENDIF.

ENDFORM.                    " f_load_so


*&---------------------------------------------------------------------*
*&      Form  f_load_pins_h
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LOAD_PINS_H CHANGING FC_ERRNO.

  IF D_ISFREESTOCK = C_NO.
    PERFORM F_LOCK_SONUM CHANGING FC_ERRNO.
    IF FC_ERRNO NE 0.
      RETURN.
    ENDIF.

    SELECT SINGLE * INTO ZPACK_PCH FROM ZPACK_PCH
      WHERE VBELN = ZPACK_PCH-VBELN
        AND POSNR = ZPACK_PCH-POSNR.

    IF SY-SUBRC NE 0.
      FC_ERRNO = SY-SUBRC.
    ELSE.
*       --ship to party
      PERFORM F_LOAD_SO_PARTNER
        USING ZPACK_PCH-VBELN ZPACK_PCH-POSNR C_PARTNER_SHIPTO
        CHANGING D_SHIPTO D_SHIPTO_T.

*     --sold to party
      PERFORM F_LOAD_SO_PARTNER
        USING ZPACK_PCH-VBELN ZPACK_PCH-POSNR C_PARTNER_SOLDTO
        CHANGING D_SOLDTO D_SOLDTO_T.
    ENDIF.

  ELSE.
    SELECT SINGLE * INTO ZPACK_PCH FROM ZPACK_PCH
      WHERE PINNR = ZPACK_PCH-PINNR
        AND VBELN = SPACE.

    IF SY-SUBRC NE 0.
      FC_ERRNO = SY-SUBRC.
    ENDIF.

  ENDIF.


ENDFORM.                    " f_load_pins_h


*&---------------------------------------------------------------------*
*&      Form  f_load_pins
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LOAD_PINS CHANGING FC_ERRNO .
  CLEAR ITAB_PINS.
  SELECT * INTO TABLE ITAB_PINS FROM ZPACK_PC
    WHERE PINNR = ZPACK_PCH-PINNR.

ENDFORM.                    " f_load_pins

*&---------------------------------------------------------------------*
*&      Form  f_status_9000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_STATUS_9000 .
  IF SY-TCODE = C_TCODE_FREESTOCK.
    SET TITLEBAR '9000A'.
    D_ISFREESTOCK = C_YES.
    SET PF-STATUS '9000'.
  ELSEIF SY-TCODE = C_TCODE_SO.
    SET TITLEBAR '9000'.
    D_ISFREESTOCK = C_NO.
    SET PF-STATUS '9000' EXCLUDING 'COPY'.
  ENDIF.

  LOOP AT SCREEN.
    IF D_ISFREESTOCK = C_YES.

      IF SCREEN-GROUP1 = 'SO'.
        SCREEN-INVISIBLE = '1'.
        SCREEN-INPUT = '0'.

      ELSE.
        SCREEN-INVISIBLE = '0'.
        SCREEN-INPUT = '1'.

      ENDIF.


    ELSE.
      IF SCREEN-GROUP1 = 'FS'.
        SCREEN-INVISIBLE = '1'.
        SCREEN-INPUT = '0'.

      ELSE.
        SCREEN-INVISIBLE = '0'.
        SCREEN-INPUT = '1'.

      ENDIF.

    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

  CLEAR SY-UCOMM.
ENDFORM.                    " f_status_9000

*&---------------------------------------------------------------------*
*&      Form  f_check_so
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_SO .
  IF SY-UCOMM = 'DISPLAY' AND SY-TCODE = C_TCODE_SO.
    IF ZPACK_PCH-VBELN IS INITIAL OR ZPACK_PCH-POSNR IS INITIAL.
      MESSAGE E014.
      CLEAR SY-UCOMM.

    ELSE.
      DATA LD_VBELN TYPE VBELN_VA.
      DATA LD_POSNR TYPE POSNR_VA.

      SELECT SINGLE VBELN POSNR INTO (LD_VBELN, LD_POSNR)
        FROM ZPACK_PCH
        WHERE VBELN = ZPACK_PCH-VBELN
          AND POSNR = ZPACK_PCH-POSNR.

      IF SY-SUBRC NE 0.
        MESSAGE E015 WITH 'Cant find Packing Instruction for Sales Document'
        ZPACK_PCH-VBELN '-' ZPACK_PCH-POSNR.
        CLEAR SY-UCOMM.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.                    " f_check_so


*&---------------------------------------------------------------------*
*&      Form  f_check_pinnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_CHECK_PINNR .
  IF ( SY-UCOMM = 'DISPLAY' OR SY-UCOMM = 'COPY' ) AND SY-TCODE =
  C_TCODE_FREESTOCK.
    IF ZPACK_PCH-PINNR IS INITIAL.
      MESSAGE S016.
      CLEAR SY-UCOMM.

    ELSE.
      DATA LD_PINNR TYPE ZPINNR.

      SELECT SINGLE PINNR INTO (LD_PINNR)
        FROM ZPACK_PCH
        WHERE PINNR = ZPACK_PCH-PINNR.

      IF SY-SUBRC NE 0.
        MESSAGE S018 WITH ZPACK_PCH-PINNR.

        CLEAR SY-UCOMM.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.                    " f_check_pinnr


*&---------------------------------------------------------------------*
*&      Form  f_load_doc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LOAD_DOC CHANGING FCN_ERRNO.
  PERFORM F_LOAD_PINS_H CHANGING FCN_ERRNO.

  IF FCN_ERRNO NE 0.
    MESSAGE S001(00) WITH 'Cant find the document.'.

  ELSE.
    PERFORM F_LOAD_PINS CHANGING FCN_ERRNO.
    IF FCN_ERRNO EQ 0.  LEAVE TO SCREEN '9001'. ENDIF.

  ENDIF.


ENDFORM.                    " f_load_doc


*&---------------------------------------------------------------------*
*&      Form  f_check_duplicates
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_B_IS_DUPLICATE  text
*----------------------------------------------------------------------*
FORM F_CHECK_DUPLICATES  CHANGING FCB_IS_DUPLICATE.
  SELECT SINGLE * FROM ZPACK_PCH
    WHERE VBELN = ZPACK_PCH-VBELN
      AND POSNR = ZPACK_PCH-POSNR.

  IF SY-SUBRC EQ 0.
    FCB_IS_DUPLICATE = C_YES.

  ELSE.
    FCB_IS_DUPLICATE = C_NO.

  ENDIF.

ENDFORM.                    " f_check_duplicates


*&---------------------------------------------------------------------*
*&      Form  f_load_specification
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZPACK_PCH_VBELN  text
*      -->P_ZPACK_PCH_POSNR  text
*      <--P_ZPACK_PCH_MATNR  text
*      <--P_ZPACK_PCH_ZZCRITERIA1  text
*      <--P_ZPACK_PCH_ZZCRITERIA2  text
*      <--P_ZPACK_PCH_ZZCRITERIA3  text
*      <--P_ZPACK_PCH_ZZWIDTH  text
*----------------------------------------------------------------------*
FORM F_LOAD_SPECIFICATION  USING    FUS_VBELN
                                    FUS_POSNR
                           CHANGING FCS_MATNR
                                    FCS_ZZCRITERIABF
                                    FCS_ZZCRITERIA1
                                    FCS_ZZCRITERIA2
                                    FCS_ZZCRITERIAR
                                    FCS_ZZWIDTH
                                    FCS_CORE3
                                    FCS_CORE6
                                    FCS_SHEET.

  DATA S_WERKS LIKE VBAP-WERKS.
  DATA S_LGORT LIKE VBAP-LGORT.
  DATA S_CHARG LIKE VBAP-CHARG.
  DATA ITAB_CH_VALUES  TYPE TABLE OF API_VALI WITH HEADER LINE.


  SELECT SINGLE MATNR WERKS LGORT CHARG
    INTO (FCS_MATNR, S_WERKS, S_LGORT, S_CHARG)
    FROM VBAP
    WHERE VBELN = FUS_VBELN AND POSNR = FUS_POSNR.

  CHECK SY-SUBRC EQ 0.


  CALL FUNCTION 'QC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR    = FCS_MATNR
      I_VAL_WERKS    = S_WERKS
      I_VAL_CHARGE   = S_CHARG
    TABLES
      T_VAL_TAB      = ITAB_CH_VALUES
    EXCEPTIONS
      NO_CLASS       = 1
      INTERNAL_ERROR = 2
      NO_VALUES      = 3
      NO_CHARS       = 4
      OTHERS         = 5.
  IF SY-SUBRC <> 0.
    IF SY-MSGTY IS INITIAL.
      MESSAGE ID SY-MSGID TYPE 'E' NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  READ TABLE ITAB_CH_VALUES WITH KEY ATNAM = 'ZZWIDTH'.
  IF SY-SUBRC EQ 0.
    FCS_ZZWIDTH = ITAB_CH_VALUES-ATWRT.
  ENDIF.

  READ TABLE ITAB_CH_VALUES WITH KEY ATNAM = 'ZZCRITERIA'.
  IF SY-SUBRC EQ 0.
    CLEAR: FCS_ZZCRITERIA1, FCS_ZZCRITERIA2, FCS_ZZCRITERIAR.
    CASE ITAB_CH_VALUES-ATWRT.
      WHEN '1'.  FCS_ZZCRITERIA1 = C_YES.
      WHEN '2'.  FCS_ZZCRITERIA2 = C_YES.
      WHEN 'R'.  FCS_ZZCRITERIAR = C_YES.
    ENDCASE.
  ENDIF.
ENDFORM.                    " f_load_specification