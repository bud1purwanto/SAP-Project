*&---------------------------------------------------------------------*
*&  Include           ZPPI_JR_EXEC_LYT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SET_ALV_ORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ALV.
  CLEAR : WA_LAYOUT.
  DATA : G_SAVE VALUE 'A'.
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_SELINFOS = 'X'.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  PERFORM LAYOUT_INIT_BOX USING WA_LAYOUT.
*  PERFORM EVENTTAB_BUILD USING T_EVENTS[].
  WA_VARIANTE-REPORT = D_REPID.
  PERFORM BUILD_FIELDCAT.
  PERFORM COMMENT_BUILD USING GT_LIST_TOP_OF_PAGE[].
*  PERFORM BUILD_SORTCAT.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'"'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS'"'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = IT_EXEC.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " SET_ALV

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_ORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM SET_ALV_ORD.
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_SELINFOS = 'X'.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  PERFORM LAYOUT_INIT_BOX USING WA_LAYOUT.
*  PERFORM EVENTTAB_BUILD USING T_EVENTS[].
  WA_VARIANTE-REPORT = D_REPID.
  PERFORM BUILD_FIELDCAT_ORD.
  PERFORM COMMENT_BUILD USING GT_LIST_TOP_OF_PAGE[].
*  PERFORM BUILD_SORTCAT.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'USER_COMMAND_ORD'"'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS_ORD'"'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = T_EVENTS[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = IT_ORDER.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " SET_ALV
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT.
  REFRESH T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON_WT_ZERO USING 'IT_EXEC' :
         'ICON' '' '' C_NO 4 'Monitor ' '' '' 'CENTER' '',
         'GSTRP'   ''  ''  C_NO  12   'Start Date'  ''   ''  ''  '',
         'GSUZP'   ''  ''  C_NO  12   'Start Time'  ''   ''  ''  '',
         'PLNBEZ'   ''  ''  C_NO  20   'Material'  ''   ''  ''  '',
         'MAKTX'   ''  ''  C_NO  40   'Material Description'  ''   ''  ''  '',
         'AUFNR'   ''  ''  C_NO  18   'Proccess Order'  ''  ''  ''  '',
         'WERKS'   ''  ''  C_NO  6   'Plant '  ''   ''  ''  '',
         'TXT30'   ''  ''  C_NO  15   'Status'  ''   ''  ''  ''.
ENDFORM.                    " BUILD_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT_ORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUILD_FIELDCAT_ORD.
  REFRESH T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_WT_ZERO USING 'IT_ORDER' :
         'AUFNR'   ''  ''  C_NO  14   'Order'  ''   ''  '',
         'PLNBEZ'   ''  ''  C_NO  20   'Material'  ''   ''  '',
         'MAKTX'   ''  ''  C_NO  40   'Material Description'  ''   ''  '',
         'CHARG'   ''  ''  C_NO  11   'Batch'  ''   ''  '',
         'ATWTB'   ''  ''  C_NO  31   'Nomor JR'  ''   ''  '',
         'TRTMT'   ''  ''  C_NO  ''   'Treatment'  ''   ''  '',
         'ZZPJG'   ''  ''  C_NO  ''   'Panjang Aktual'  ''   ''  '',
         'ZZLBR'   ''  ''  C_NO  ''   'Lebar Aktual'  ''   ''  '',
         'ISM01'   ''  ''  C_NO  ''   'Process Time'  ''   ''  '',
         'ZSTAT'   ''  ''  C_NO  ''   'Status JR'  ''   ''  '',

*         'GSUZP'   ''  ''  C_NO  11   'Basic Start Time'  ''   ''  '',
*         'TSTAT'   ''  ''  C_NO  40   'System Status'  ''   ''  '',
         'DESC'   ''  ''  C_NO  ''   'Ket. Winder'  ''   ''  ''.
ENDFORM.                    " BUILD_FIELDCAT

*&--------------------------------------------------------------------*
*&      Form  comment_build
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->LT_TOP_OF_Ptext
*---------------------------------------------------------------------*
FORM COMMENT_BUILD USING LT_TOP_OF_PAGE TYPE
                                        SLIS_T_LISTHEADER.
  DATA: LS_LINE TYPE SLIS_LISTHEADER.

  CLEAR LS_LINE.
  REFRESH LT_TOP_OF_PAGE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = 'Execution Jumbo Roll'.
  APPEND LS_LINE TO LT_TOP_OF_PAGE.

ENDFORM.                    " COMMENT_BUILD

*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZPEJRR'.
ENDFORM.                    "SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS_ORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM SET_PF_STATUS_ORD USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZPEJRR_ORD'.
ENDFORM.                    "SET_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.
  CASE R_UCOMM.
    WHEN '&EXEC'.
      CLEAR : RCREATED, ZDCODE, VLINE.
      CLEAR : IT_TEMP. REFRESH : IT_TEMP.
      LOOP AT IT_EXEC WHERE BOX = 'X'.
        IT_TEMP-DPLNBEZ = IT_EXEC-PLNBEZ.
        IT_TEMP-DWERKS = IT_EXEC-WERKS.
        IT_TEMP-DAUFNR = IT_EXEC-AUFNR.
        IT_TEMP-DAUART = IT_EXEC-AUART.
        IT_TEMP-DOBJNR = IT_EXEC-OBJNR.
        IT_TEMP-DARBPL = IT_EXEC-ARBPL.
        IT_TEMP-DGAMNG = IT_EXEC-GAMNG.
        IT_TEMP-DGMEIN = IT_EXEC-GMEIN.
        IT_TEMP-DSDATE = SY-DATUM.
        IT_TEMP-DERFZEIT = SY-UZEIT.
        APPEND IT_TEMP.
        EXIT.
      ENDLOOP.

      "add by yulius CHECK MATERIAL NOT IN TOYOBO 14.06.2016
      IF IT_TEMP IS NOT INITIAL AND SY-TCODE <> 'ZTYB01'.
        DATA : ZMATNR TYPE MARA-MATNR.
        SELECT SINGLE MATNR
          INTO ZMATNR
          FROM ZMRTYB
          WHERE MATNR = IT_EXEC-PLNBEZ AND NOTES = 'MASTERTOYOBO'.
        IF SY-SUBRC = 0.
          MESSAGE 'Material Toyobo tidak dapat dieksekusi di sini.' TYPE 'E'.
        ENDIF.
      ENDIF.
      "END CHECK MATERIAL NOT IN TOYOBO 14.06.2016

      "ADDED EXLAM 11.01.2019 - Restrict execution of ExLam Order Type
      IF IT_TEMP IS NOT INITIAL AND ( IT_EXEC-AUART EQ 'ZP12' OR IT_EXEC-AUART EQ 'ZTR7' ).
        MESSAGE 'Order Type Exlam tidak dapat dieksekusi di sini!' TYPE 'E'.
      ENDIF.

*      CHECK IT_EXEC-TXT30 NE 'Completed'.
      DCREATED = 0.
      IF IT_TEMP IS NOT INITIAL.
        CLEAR : FCHARG.
        IF IT_EXEC-AUART = 'ZP01' OR IT_EXEC-AUART = 'ZP02' OR IT_EXEC-AUART = 'ZP10' OR IT_EXEC-AUART = 'ZP11' OR IT_EXEC-AUART = 'ZTR1' OR IT_EXEC-AUART = 'ZTR3'
        " Added by William at 24.07.2022 (OPP7 CPP1)
        OR IT_EXEC-AUART = 'ZP13' OR IT_EXEC-AUART = 'ZP15' OR IT_EXEC-AUART = 'ZP17'
        OR IT_EXEC-AUART = 'ZTR8' OR IT_EXEC-AUART = 'ZTR9' OR IT_EXEC-AUART = 'ZTRA' OR IT_EXEC-AUART = 'ZTRB' OR IT_EXEC-AUART = 'ZTRC'.
        " End added by William at 24.07.2022 (OPP7 CPP1)
          CALL SCREEN 1200.
        ELSE.
          CALL SCREEN 800.
        ENDIF.
      ENDIF.
    WHEN '&ORDERS'.

      "ADDED EXLAM 11.01.2019 - Restrict to show ExLam Order
      IF IT_EXEC-AUART EQ 'ZP12' OR IT_EXEC-AUART EQ 'ZTR7'.
        MESSAGE 'Order Exlam tidak dapat dilihat di sini!' TYPE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.

      PERFORM GET_DATA_ORD.
      PERFORM SET_ALV_ORD.
    WHEN '&RFRSH'.
      PERFORM GET_DATA.
      RS_SELFIELD-REFRESH = 'X'.
  ENDCASE.

ENDFORM. "user_command

*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_ORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM USER_COMMAND_ORD USING R_UCOMM LIKE SY-UCOMM
                        RS_SELFIELD TYPE SLIS_SELFIELD.
  CASE R_UCOMM.
    WHEN '&RFRESH'.
      PERFORM GET_DATA_ORD.
      RS_SELFIELD-REFRESH = 'X'.
*    WHEN '&EORDER'.
*      READ TABLE IT_ORDER WITH KEY BOX = 'X'.
*      IF SY-SUBRC = 0.
*        SET PARAMETER ID 'BR1' FIELD IT_ORDER-AUFNR.
*        CALL TRANSACTION 'COR2' AND SKIP FIRST SCREEN.
*        LEAVE SCREEN.
*      ENDIF.
*    WHEN '&DORDER'.
*      READ TABLE IT_ORDER WITH KEY BOX = 'X'.
*      IF SY-SUBRC = 0.
*        SET PARAMETER ID 'BR1' FIELD IT_ORDER-AUFNR.
*        CALL TRANSACTION 'COR3' AND SKIP FIRST SCREEN.
*        LEAVE SCREEN.
*      ENDIF.
    WHEN '&RPRINT'.
      RANGES: TORD FOR AFPO-ABLAD.
      DATA: V_COUNT TYPE I.
      CLEAR V_COUNT.

      LOOP AT IT_ORDER WHERE BOX = 'X'.
        V_COUNT = V_COUNT + 1.
        TORD-SIGN   = 'I'.
        TORD-OPTION = 'EQ'.
        TORD-LOW = IT_ORDER-CHARG.
        APPEND TORD.
      ENDLOOP.

      IF V_COUNT < 1.
        MESSAGE 'Tidak ada line item yang dipilih.' TYPE 'E'.
      ELSEIF V_COUNT > 1.
        MESSAGE 'Silahkan mencetak satu line item saja.' TYPE 'E'.
      ELSE.
        SUBMIT ZMMR_LABELJR WITH P_CHARG IN TORD
                            WITH P_NDLOG = 'X' AND RETURN.
      ENDIF.

    WHEN '&CLAB'.
      READ TABLE IT_ORDER WITH KEY BOX = 'X'.
      IF SY-SUBRC = 0.
        SUBMIT RQEEAL10 WITH QL_MATNR-LOW = IT_ORDER-PLNBEZ
                        WITH QL_WERKS-LOW = IT_ORDER-WERKS
                        WITH QL_CHARG-LOW = IT_ORDER-CHARG
                AND RETURN.
        LEAVE SCREEN.
      ENDIF.
    WHEN '&BATAL'.
      READ TABLE IT_ORDER WITH KEY BOX = 'X'.
      IF SY-SUBRC = 0.
        CLEAR : DCHARG, DAUFNR.
        BCHARG = IT_ORDER-CHARG.
        DCHARG = IT_ORDER-CHARG.
        DAUFNR = IT_ORDER-AUFNR.
        DAUART = IT_ORDER-AUART.
        DBATAL = 1.
        CLEAR : TXTREASON, TXTNIK.
        CALL SCREEN 1100 STARTING AT 30 6.
        LEAVE SCREEN.
      ENDIF.
    WHEN '&REXEC'.
      RCREATED = 1.
      CLEAR : FCHARG, FTXTQTY, FTXTQTYTBP, WA_INPT, FTXTPERNR, FTXTSPD, FTXTPCS, FTXTSTUP, FTXTLOC, FTXTLBR, FTXTPJ, FTXTWINDER, AUFK, CRHD, BSVX, AFKO, CAWNT, AFPO,ZDCODE.
      REFRESH : IT_INPT.
      AUFK-SDATE = '19990101'.
*      AUFK-ERFZEIT = SY-UZEIT.
*      READ TABLE IT_ORDER WITH KEY BOX = 'X'.
*      IF SY-SUBRC = 0.
      CRHD-ARBPL = IT_ORDER-ARBPL.
      CLEAR : FCHARG, VTMPCHARG.
      IF IT_ORDER-AUART = 'ZP01' OR IT_ORDER-AUART = 'ZP02' OR IT_EXEC-AUART = 'ZP10' OR IT_EXEC-AUART = 'ZP11' OR IT_EXEC-AUART = 'ZTR1' OR IT_EXEC-AUART = 'ZTR3'
      " Added by William at 24.07.2022 (OPP7 CPP1)
      OR IT_ORDER-AUART = 'ZP13' OR IT_ORDER-AUART = 'ZP15' OR IT_ORDER-AUART = 'ZP17'
      OR IT_ORDER-AUART = 'ZTR8' OR IT_ORDER-AUART = 'ZTR9' OR IT_ORDER-AUART = 'ZTRA' OR IT_ORDER-AUART = 'ZTRB' OR IT_ORDER-AUART = 'ZTRC'.
      " End added by William at 24.07.2022 (OPP7 CPP1)
        CALL SCREEN 1200.
      ELSE.
        CALL SCREEN 800.
      ENDIF.
      LEAVE SCREEN.
*      ENDIF.
    WHEN '&CHD'.
      DATA : ZSVAL LIKE STANDARD TABLE OF SVAL WITH HEADER LINE.
      DATA : DRETURN TYPE C.

      ZSVAL-TABNAME = 'DFBATCH'.
      ZSVAL-FIELDNAME = 'KZTXT'.
      ZSVAL-FIELDTEXT = 'Keterangan Winder'.
      APPEND ZSVAL.

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          POPUP_TITLE = 'Change Winder'
        IMPORTING
          RETURNCODE  = DRETURN
        TABLES
          FIELDS      = ZSVAL.

      IF DRETURN NE 'A'.
        READ TABLE ZSVAL INDEX 1.
        IF SY-SUBRC = 0.
          READ TABLE IT_ORDER WITH KEY BOX = 'X'.
          IF SY-SUBRC = 0.
            CLEAR IT_BDCDATA. REFRESH IT_BDCDATA.
            PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=SNST'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'DFBATCH-LGORT'.
            PERFORM BDC_FIELD       USING 'DFBATCH-MATNR'
                                          IT_ORDER-PLNBEZ.
            PERFORM BDC_FIELD       USING 'DFBATCH-CHARG'
                                          IT_ORDER-CHARG.
            PERFORM BDC_FIELD       USING 'DFBATCH-WERKS'
                                          IT_ORDER-WERKS.
            PERFORM BDC_FIELD       USING 'DFBATCH-LGORT'
                                          IT_ORDER-LGORT.
            PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
            PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                          '=SAVE'.
            PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                          'DFBATCH-KZTXT'.
            PERFORM BDC_FIELD       USING 'DFBATCH-KZTXT'
                                          ZSVAL-VALUE.
            PERFORM BDC_TRANSACTION USING 'MSC2N'.
            PERFORM INSERT_SQL USING IT_ORDER-CHARG
                                     '' ''.
          ENDIF.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    "USER_COMMAND_ORD

*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT_BOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*----------------------------------------------------------------------*
FORM LAYOUT_INIT_BOX USING RS_LAYOUT TYPE SLIS_LAYOUT_ALV.
  RS_LAYOUT-DETAIL_POPUP      = 'X'.
  RS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  RS_LAYOUT-ZEBRA             = 'X'.
  RS_LAYOUT-BOX_FIELDNAME     = 'BOX'.
*rs_layout-no_totalline      = 'X'.
ENDFORM.                    " LAYOUT_INIT