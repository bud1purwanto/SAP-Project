*&---------------------------------------------------------------------*
*&  Include           ZHU_LABEL_1100                                   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_1000 INPUT.

  CASE SY-UCOMM.
    WHEN 'BACK'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'CHANGE'.

    WHEN 'SAVE'.
*      PERFORM save_data.

    WHEN 'FIND'.
      I_HU-EXIDV = ITAB-EXIDV.
      CLEAR  :  I_CHAR, ITAB.
      ITAB-EXIDV = I_HU-EXIDV.
      REFRESH: I_CHAR, I_HU, IT_VEPO, IT_ERSDA, IT_EXIDV.

      PERFORM F_GET_HU_ITEMS.
      PERFORM FIND_DATA.
    WHEN 'PRINT'.
      PERFORM WRITE_KDM.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1000  INPUT
"PMI_TAB_ACTIVE_TAB_GET INPUT

*--- find data
FORM FIND_DATA.
  DATA: V_ROUND TYPE P DECIMALS 2,
        V_VENUM LIKE VEKP-VENUM.

  SELECT SINGLE VENUM INTO V_VENUM FROM VEKP WHERE EXIDV = ITAB-EXIDV.
  LOOP AT IT_VEPO INTO WA_VEPO WHERE VENUM = V_VENUM.
    IF WA_VEPO-SONUM = ''.
      V_VENUM = WA_VEPO-UNVEL.
      LOOP AT IT_VEPO INTO WA_VEPO WHERE VENUM = V_VENUM.
        EXIT.
      ENDLOOP.
    ENDIF.
    EXIT.
  ENDLOOP.

  IF WA_VEPO-SONUM NE ''.
*--- get Part number.
    SELECT SINGLE KDMAT INTO ITAB-PRTNO FROM VBAP WHERE VBELN = WA_VEPO-SONUM+0(10) AND POSNR = WA_VEPO-SONUM+10(6).
    IF SY-SUBRC NE 0.
      CLEAR ITAB-PRTNO.
    ENDIF.

    SELECT SINGLE CUOBJ INTO I_HU-CUOBJ FROM VBAP WHERE VBELN = WA_VEPO-SONUM+0(10) AND POSNR = WA_VEPO-SONUM+10(6).

    IF SY-SUBRC = 0.
      PERFORM GET_LIVE.
      PERFORM GET_SOCHAR.
    ELSE.
      MESSAGE 'Nomor HU atau nomor SO tidak ada...!'  TYPE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'HU tidak terikat SO....!' TYPE 'E'.
  ENDIF.

  DELETE IT_VEPO WHERE VEMNG = 0.

*--- find weight
  CLEAR ITAB-NTGEW.
  LOOP AT IT_VEPO INTO WA_VEPO.
    ITAB-NTGEW = ITAB-NTGEW + WA_VEPO-VEMNG.
  ENDLOOP.
  ITAB-PROLL = ITAB-NTGEW / ITAB-ZCONV.
  V_ROUND = ITAB-NTGEW / ITAB-PROLL.
  ITAB-NTGEW = ITAB-PROLL * V_ROUND.

*--- get ID number
  SELECT SINGLE  PALID NOCOA INTO (V_PALID, V_NOCOA)
  FROM ZHMS WHERE EXIDV = ITAB-PRTNO.
  IF SY-SUBRC = 0.
    CONCATENATE ITAB-PRTSP ' OD :' V_PALID '; ' ' ID :' ITAB-ZCORE INTO ITAB-PRTSP.
    ITAB-PRTDC = V_NOCOA.
  ENDIF.

*--- get PO number
  SELECT SINGLE A~BSTKD INTO (ITAB-BSTKD)
  FROM VBKD AS A JOIN VBAP AS B ON A~VBELN = B~VBELN
  WHERE B~CUOBJ = I_HU-CUOBJ.
  IF SY-SUBRC NE 0.
    CLEAR ITAB-BSTKD.
  ENDIF.

*-- PO number line 2.
  DATA: IT_LINES TYPE TLINE OCCURS 0 WITH HEADER LINE.
  DATA: V_NAME LIKE THEAD-TDNAME.

V_NAME = WA_VEPO-SONUM+0(10).
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      CLIENT                  = SY-MANDT
      ID                      = 'Z012'
      LANGUAGE                = 'E'
      NAME                    = V_NAME
      OBJECT                  = 'VBBK'
    TABLES
      LINES                   = IT_LINES
    EXCEPTIONS
      ID                      = 1
      LANGUAGE                = 2
      NAME                    = 3
      NOT_FOUND               = 4
      OBJECT                  = 5
      REFERENCE_CHECK         = 6
      WRONG_ACCESS_TO_ARCHIVE = 7
      OTHERS                  = 8.

  IF SY-SUBRC = 0.
    LOOP AT IT_LINES WHERE TDLINE NE ''.
      ITAB-BSTKD_E = IT_LINES-TDLINE+0(35).
    ENDLOOP.
  ENDIF.

ENDFORM.                    "find_data


*--- get SO Characteristic.
FORM GET_SOCHAR.
  CALL FUNCTION 'MILL_SE_GET_CHAR_AND_VALUE'
    EXPORTING
      INSTANCE                = I_HU-CUOBJ
    TABLES
      ET_VALUE                = I_CHAR
    EXCEPTIONS
      MATERIAL_HAS_NO_PROFIL  = 1
      NO_CONFIGURATION_PARAMS = 2
      FATAL_ERROR             = 3
      OTHERS                  = 4.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.

    CLEAR: ITAB-ZTYPE, ITAB-ZTYPE, ITAB-THICK, ITAB-WIDTH,
           ITAB-LENGT, ITAB-ZCORE, ITAB-ZCONV, ITAB-PROLL.
    LOOP AT I_CHAR.
      CASE I_CHAR-CHARC.
*        WHEN 'ZZSPECIALTOUCH-1'.
*          itab-prtno = i_char-value_txt.
        WHEN 'ZZTYPE'.
          ITAB-ZTYPE = I_CHAR-VALUE.
        WHEN 'ZZTHICKNESS'.
          V_ROUND = I_CHAR-VALUE.
          WRITE V_ROUND TO ITAB-THICK LEFT-JUSTIFIED.
        WHEN 'ZZWIDTH'.
          ITAB-WIDTH = I_CHAR-VALUE_TXT.
          REPLACE ',' IN ITAB-WIDTH  WITH '.'.
        WHEN 'ZZLENGTH'.
          ITAB-LENGT = I_CHAR-VALUE_TXT.
          REPLACE ',' IN ITAB-LENGT  WITH '.'.
        WHEN 'ZZCORE'.
          ITAB-ZCORE = I_CHAR-VALUE_TXT.
        WHEN 'ZZCONVERSIONROLLKG'.
          ITAB-ZCONV = I_CHAR-VALUE.
          REPLACE ',' WITH '' INTO ITAB-ZCONV.   "T005X
          CONDENSE ITAB-ZCONV NO-GAPS.
*        WHEN 'ZZSPECIALTOUCH-1'.
*          itab-prtno = i_char-value.

      ENDCASE.
    ENDLOOP.

    CONCATENATE ITAB-ZTYPE '-' ITAB-THICK ', ( ' ITAB-WIDTH ' mm x  ' ITAB-LENGT ' m); ' INTO ITAB-PRTSP.
*    itab-proll = itab-ntgew / itab-zconv.
  ENDIF.
ENDFORM.                    "get_sochar

*--- get live
FORM GET_LIVE.
  DATA I_BATCH LIKE API_VALI OCCURS 0 WITH HEADER LINE.

  ITAB-MATNR = WA_VEPO-MATNR.
  ITAB-CHARG = WA_VEPO-CHARG.

  CALL FUNCTION 'QC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR  = ITAB-MATNR
      I_VAL_CHARGE = ITAB-CHARG
    TABLES
      T_VAL_TAB    = I_BATCH.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    READ TABLE I_BATCH WITH KEY ATNAM = 'ZZEXPIREDLIVE'.
    IF SY-SUBRC = 0.
      ITAB-VLIVE = I_BATCH-ATWRT.
      SELECT SINGLE ERSDA INTO ITAB-PDATE FROM MCH1
      WHERE MATNR = ITAB-MATNR AND CHARG = ITAB-CHARG.

      IF SY-SUBRC = 0.
        ITAB-EDATE = ITAB-PDATE + ITAB-VLIVE.
      ENDIF.
    ENDIF.

    DELETE IT_VEPO WHERE VEMNG = 0.
    SELECT MATNR CHARG ERSDA INTO TABLE IT_ERSDA FROM MCH1
    FOR ALL ENTRIES IN IT_VEPO WHERE CHARG = IT_VEPO-CHARG.

    SORT IT_ERSDA BY ERSDA DESCENDING.
    READ TABLE IT_ERSDA INDEX 1.
    ITAB-PDATE = IT_ERSDA-ERSDA.

    ITAB-EDATE = ITAB-PDATE + ITAB-VLIVE.
  ENDIF.

ENDFORM.                    "get_live



*--- write label
FORM WRITE_KDM.
  DATA: V_EXIDV LIKE VEKP-EXIDV.

  DATA: LS_PRINT_DATA_TO_READ TYPE LEDLV_PRINT_DATA_TO_READ.

  DATA: LS_RECIPIENT          TYPE SWOTOBJID.
  DATA: LS_SENDER             TYPE SWOTOBJID.
  DATA: LS_ADDR_KEY           LIKE ADDR_KEY.

* Get Function Module name of SmartForms
* --------------------------------------
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  IF SY-SUBRC = 0.

    WRITE: ITAB-EXIDV TO V_EXIDV NO-ZERO.

    CALL FUNCTION V_FUNCNAME
      EXPORTING
        CONTROL_PARAMETERS = I_SSFCTRLOP
        OUTPUT_OPTIONS     = I_SSFCOMPOP
        MAIL_RECIPIENT     = I_RECIPIENT
        MAIL_SENDER        = I_SENDER
        EXIDV              = V_EXIDV   "itab-exidv
        BSTKD              = ITAB-BSTKD
        BSTKD_E            = ITAB-BSTKD_E
        PRTNO              = ITAB-PRTNO
        PRTDC              = ITAB-PRTDC
        PRTSP              = ITAB-PRTSP
        NTGEW              = ITAB-NTGEW
        BRGEW              = ITAB-BRGEW
        PROLL              = ITAB-PROLL
        PDATE              = ITAB-PDATE
        EDATE              = ITAB-EDATE
        TITLE              = V_TITLE.
  ENDIF.

ENDFORM.                    " write_form



*&---------------------------------------------------------------------*
*&      Form  save_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SAVE_DATA.
  CHECK ITAB-EXIDV NE ''.
  SELECT SINGLE * FROM ZHMS WHERE EXIDV = ITAB-EXIDV.
  IF SY-SUBRC = 0.
    UPDATE ZHMS SET GWEIGHT = ITAB-BRGEW WHERE EXIDV = ITAB-EXIDV.

    IF SY-SUBRC = 0.
      MESSAGE 'Update succesfull..!' TYPE 'I'.
    ELSE.
      MESSAGE 'Update fail........!' TYPE 'I'.
    ENDIF.
  ELSE.
    CLEAR ZHMS.
    ZHMS-EXIDV = ITAB-EXIDV.
    ZHMS-GWEIGHT = ITAB-BRGEW.

    INSERT ZHMS.

    IF SY-SUBRC = 0.
      MESSAGE 'Insert data succesfull..!' TYPE 'I'.
    ELSE.
      MESSAGE 'Insert data fail........!' TYPE 'I'.
    ENDIF.
  ENDIF.
ENDFORM.                    "save_data


*&---------------------------------------------------------------------*
*&      Module  screen_type  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCREEN_TYPE OUTPUT.
  IF V_TITLE = 'PT. KARYADIBYA MAHARDIKA'.
    LOOP AT SCREEN.
      IF SCREEN-NAME = 'ITAB-BRGEW'.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " screen_type  OUTPUT