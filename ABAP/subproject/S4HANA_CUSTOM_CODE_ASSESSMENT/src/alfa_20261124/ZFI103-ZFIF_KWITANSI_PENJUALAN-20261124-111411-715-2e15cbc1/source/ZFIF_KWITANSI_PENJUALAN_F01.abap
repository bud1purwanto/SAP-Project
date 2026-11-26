*&---------------------------------------------------------------------*
*&  Include           ZFIF_KWITANSI_PENJUALAN_F01
*&---------------------------------------------------------------------*
INCLUDE Z_PROG_INFO.

INITIALIZATION.
  BUTTON1 = TEXT-010.
  BUTTON2 = TEXT-020.
  BUTTON3 = TEXT-030.
  MYTAB-PROG = SY-REPID.
  MYTAB-DYNNR = 100.
  MYTAB-ACTIVETAB = 'BUTTON1'.
  MOVE 'Program Information' TO INFO.

  IF SY-TCODE = 'ZFI103'.
    P_BUKRS-LOW = '9999'.
    P_BUKRS2-LOW = '9999'.
    P_BUKRS3-LOW = '9999'.
    SET TITLEBAR 'ZTRS'.
    PK_NAMA = 'HANS CHANDRA'.  "CHANGED BY FATHIR ON 14.02.2020
    BK_NAMA = 'BCA'.
    AC_NAMA ='4650501000'.
    CBG_NAMA = 'PEPELEGI - SIDOARJO'.
  ELSEIF SY-TCODE = 'ZFI103UNS'.
    P_BUKRS-LOW = '9800'.
    P_BUKRS2-LOW = '9800'.
    P_BUKRS3-LOW = '9800'.
    SET TITLEBAR 'ZUNS'.
    PK_NAMA = 'HANANTO'.  "CHANGED BY FATHIR ON 14.02.2020
    BK_NAMA = 'Bank Central Asia'.
    AC_NAMA ='4650530000'.
    CBG_NAMA = 'PEPELEGI - SIDOARJO'.
  ELSEIF SY-TCODE = 'ZFI103TTA'.
    P_BUKRS-LOW = '9701'.
    P_BUKRS2-LOW = '9701'.
    P_BUKRS3-LOW = '9701'.
    SET TITLEBAR 'ZTTA'.
    PK_NAMA = 'HANS CHANDRA'. "CHANGED BY FATHIR ON 14.02.2020
    BK_NAMA = 'BCA'.
    AC_NAMA ='4651580000'.
    CBG_NAMA = 'PEPELEGI - SIDOARJO'.
  ELSEIF SY-TCODE = 'ZFI103TTE'.
    P_BUKRS-LOW = '6500'.
    P_BUKRS2-LOW = '6500'.
    P_BUKRS3-LOW = '6500'.
    SET TITLEBAR 'ZTTE'.
    PK_NAMA = 'HANS CHANDRA'. "CHANGED BY FATHIR ON 14.02.2020
    BK_NAMA = 'BCA'.
    AC_NAMA ='4652190000'.
    CBG_NAMA = 'PEPELEGI - SIDOARJO'.
  ENDIF.
  APPEND P_BUKRS.
  APPEND P_BUKRS2.
  APPEND P_BUKRS3.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'PUSH2'.
      MYTAB-DYNNR = 200.
      MYTAB-ACTIVETAB = 'BUTTON2'.
    WHEN 'PUSH3'.
      MYTAB-DYNNR = 300.
      MYTAB-ACTIVETAB = 'BUTTON3'.
    WHEN 'INFO'.
      PERFORM F_PROG_INFO USING V_PROG.
    WHEN 'ONLI'.
      IF PK_KUNNR EQ '' AND  MYTAB-DYNNR = 100.
        MESSAGE 'Customer Number is required' TYPE 'E'.
      ENDIF.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'COM'.
      SCREEN-INPUT = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

*AT SELECTION-SCREEN OUTPUT.
*  PERFORM MOD_SCREEN.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PC_KWTNO-LOW.
  PERFORM GETF4_PCNOKWITL.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PC_KWTNO-HIGH.
  PERFORM GETF4_PCNOKWITH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PR_KWTNO-LOW.
  PERFORM GETF4_PRNOKWITL.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PR_KWTNO-HIGH.
  PERFORM GETF4_PRNOKWITH.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR AC_NAMA.
  PERFORM GETF4_AC_NAMA.

START-OF-SELECTION.
  PERFORM GET_DATA.

  IF MYTAB-DYNNR = 300.
    SET PF-STATUS 'ZSTREPORT'.
    PERFORM CONVERTIDR.
    PERFORM DISPLAY_ALV.
  ELSE.
    PERFORM SET_STATUS.
    PERFORM CONVERTIDR.
    PERFORM DISPLAY_ALV.
  ENDIF.

AT USER-COMMAND.
  CASE SY-UCOMM.
    WHEN 'LEAVE' OR 'BACK'.
*      LEAVE TO TRANSACTION 'ZFI103'.
      LEAVE TO TRANSACTION SY-TCODE.
    WHEN 'PRDOC'.
      PERFORM DOPRINT.
    WHEN 'PRVDOC'.
      PERFORM DOPRINT_PREVIEW.
    WHEN 'SALL'.
      PERFORM DOSELECT_ALL.
    WHEN 'DSALL'.
      PERFORM DODESSELECT_ALL.
    WHEN 'REFDOC'.
      PERFORM DOREFRESH.
    WHEN 'DWL'.
      PERFORM DOWNLOADREPORT.
    WHEN '&CANC'.
      PERFORM CANCEL_KWITANSI.
      PERFORM DOREFRESH.
  ENDCASE.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " DISPLAY_ALV

*&---------------------------------------------------------------------*
*&      Form  DOPRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOPRINT.
  DATA: V_FORMNAME   TYPE TDSFNAME  VALUE 'ZFIF_KWITANSI_PENJUALAN',
        CONTROL_PARAMETERS  LIKE  SSFCTRLOP,
        OUTPUT_OPTIONS  TYPE SSFCOMPOP,
        V_FUNCNAME   TYPE RS38L_FNAM,
        DEVICE LIKE SSFCTRLOP-DEVICE,
        TAB TYPE STANDARD TABLE OF SVAL WITH HEADER LINE,
        RETURNCODE(1),
        DOCUMENT_OUTPUT_INFO  TYPE  SSFCRESPD,
        JOB_OUTPUT_INFO TYPE  SSFCRESCL,
        JOB_OUTPUT_OPTIONS  TYPE  SSFCRESOP,
        P_HEAD TYPE STRING.

  CLEAR : DEVICE, TAB, RETURNCODE, DOCUMENT_OUTPUT_INFO, JOB_OUTPUT_INFO .

  PERFORM READMARKED.
  IF I_ITEM[] IS INITIAL.
    MESSAGE 'No data selected' TYPE 'E'.
  ELSE.
    PERFORM PREPARE_DATAPRINT.

    IF P_BUKRS-LOW = '9999'. "ADD BY REY NEW COMPANY
      P_HEAD = 'PT TRIAS SENTOSA, TBK.'.
      V_FORMNAME = 'ZFIF_KWITANSI_PENJUALAN_TS'.  " Added by William at 30.12.2024 (form kwitansi for TS)
    ELSEIF P_BUKRS-LOW = '9800'.
      P_HEAD = 'PT UNGGUL NIAGA SENTOSA'.
    ELSEIF P_BUKRS-LOW = '9701'.
      P_HEAD = 'PT TRIAS TOYOBO ASTRIA'.
    ELSEIF P_BUKRS-LOW = '6500'.
      P_HEAD = 'PT TOYOBO TRIAS ECOSYAR'.
    ENDIF.

    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME           = V_FORMNAME
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        FM_NAME            = V_FUNCNAME
      EXCEPTIONS
        NO_FORM            = 1
        NO_FUNCTION_MODULE = 2
        OTHERS             = 3.

    IF SY-SUBRC <> 0.
*   Implement suitable error handling here
    ELSE.
      CLEAR : CONTROL_PARAMETERS, OUTPUT_OPTIONS.
      CONTROL_PARAMETERS-PREVIEW = 'X'.
      OUTPUT_OPTIONS-TDNOPREV = 'X'.

      PERFORM SAVETOTABLE.
      CALL FUNCTION V_FUNCNAME "/1BCDWB/SF00000023
          EXPORTING
*                   control_parameters = control_parameters
           OUTPUT_OPTIONS     = OUTPUT_OPTIONS
*                   mail_recipient     = i_recipient
*                   mail_sender        = i_sender
            P_NOKWIT           = V_NOKWIT
            P_FROM             = V_FROM
            P_TOTUSDPP         = V_TOTUSDPP
            P_TOTIDRPPN        = V_TOTIDRPPN
            P_FAKTUR           = V_FAKTUR
            P_FAKTUR1           = V_FAKTUR1
            P_TERBILANGIN      = V_TERBILANGIN
            P_TERBILANG        = V_TERBILANG
            P_TOTUSPPN         = V_TOTUSPPN
            P_TOTUSJLH         = V_TOTUSJLH
            P_TOTIDRDPP        = V_TOTIDRDPP
            P_TOTIDRJLH        = V_TOTIDRJLH
            P_DCETAK           = V_DCETAK
            P_TCETAK           = V_TCETAK
            P_DATE             = V_DATEKWIT "V_DATE
            P_NAMA             = V_NAMA
            P_UANGTXT1         = V_UANGTXT1
            P_UANGTXT2         = V_UANGTXT2
            P_TERBILANGTXT     = V_TERBILANGTXT
            P_TOT1             = V_TOT1T
            P_PLUS             = V_PLUS
            P_TOT2             = V_TOT2T
            P_ROT2             = V_ROT2
            P_ROT1             = V_ROT1
            P_ROT3             = V_ROT3
            TYPECETAKULANG     = TYPEFORM
            P_DATEKWIT         = V_DATEKWIT
            P_BK_BANK          = V_BK_NAMA "add by whika for bank information
            P_IDR              = V_IDR1
            P_AC_NAMA          = V_AC_NAMA
            P_CBG_NAMA         = V_CBG_NAMA "whika
            P_HEAD             = P_HEAD "ADD BY REY NEW COMPANY
          IMPORTING
            DOCUMENT_OUTPUT_INFO  = DOCUMENT_OUTPUT_INFO
            JOB_OUTPUT_INFO	= JOB_OUTPUT_INFO
            JOB_OUTPUT_OPTIONS  = JOB_OUTPUT_OPTIONS
          TABLES
            IT_ITEM            = I_ITEM
          EXCEPTIONS
            FORMATTING_ERROR   = 1
            INTERNAL_ERROR     = 2
            SEND_ERROR         = 3
            USER_CANCELED      = 4
            OTHERS             = 5.

*                PERFORM DOREFRESH.
      IF SY-SUBRC  = 0.
        IF JOB_OUTPUT_INFO-OUTPUTDONE EQ 'X'.
          PERFORM UPDATE_DATA.
        ENDIF.
      ENDIF.
      PERFORM GET_UPDATED.
    ENDIF.
*    ENDIF.
  ENDIF.
ENDFORM.                    " DOPRINT

*&---------------------------------------------------------------------*
*&      Form  DOPRINT_PREVIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOPRINT_PREVIEW.
  DATA:  V_FORMNAME   TYPE TDSFNAME  VALUE 'ZFIF_KWITANSI_PENJUALAN',
         CONTROL_PARAMETERS  LIKE  SSFCTRLOP,
         OUTPUT_OPTIONS  TYPE SSFCOMPOP,
         ZNO LIKE ZKWIT-ZNO,
         AWKEY LIKE ZKWIT-ZAWKEY,
         V_FUNCNAME   TYPE RS38L_FNAM.
  DATA : IT_ZKWIT LIKE STANDARD TABLE OF ZKWIT WITH HEADER LINE,
         WA_ZKWIT LIKE LINE OF IT_ZKWIT,
         SEQ TYPE I,
         ZSEQ LIKE ZKWIT-ZSEQ,
         NOKWIT TYPE C LENGTH 25,
         ZPRINT TYPE I,
         FLAG(1),
         P_HEAD TYPE STRING.

  PERFORM READMARKED.
  IF I_ITEM[] IS INITIAL.
    MESSAGE 'No data selected' TYPE 'E'.
  ELSE.

    PERFORM PREPARE_DATAPRINT.
*    BACA NO KWITANSI
    CLEAR : SEQ, NOKWIT, FLAG, CONTROL_PARAMETERS, OUTPUT_OPTIONS, V_COMCODE.

    IF P_BUKRS-LOW = '9999'.
      V_COMCODE = ''.
    ELSE.
      V_COMCODE = P_BUKRS-LOW.
    ENDIF.

    SELECT MAX( ZSEQ ) INTO ZSEQ
    FROM ZKWIT
      WHERE TYPEFORM IN (11, 22, 33)
        AND BUKRS = V_COMCODE.

    SEQ = ZSEQ.
    SEQ = SEQ + 1.
    NOKWIT = SEQ.
    CONDENSE NOKWIT.
    IF SEQ < 10.
      CONCATENATE '00' NOKWIT INTO NOKWIT.
    ELSEIF SEQ < 100 AND SEQ >= 10.
      CONCATENATE '0' NOKWIT INTO NOKWIT.
    ENDIF.

    CONCATENATE NOKWIT SY-DATUM+4(2) SY-DATUM(4) INTO NOKWIT SEPARATED BY '/'.

*      IF MYTAB-DYNNR = 100.
*        CONCATENATE NOKWIT SY-DATUM+4(2) SY-DATUM(4) INTO NOKWIT SEPARATED BY '/'.
**      ELSE.
    CLEAR: ZNO, AWKEY.
    READ TABLE I_ITEM INDEX 1.
    AWKEY = I_ITEM-ZFDAGANG.
    SELECT SINGLE ZNO
        INTO ZNO
        FROM ZKWIT
        WHERE ZAWKEY = AWKEY AND TYPEFORM IN (11, 22, 33)
          AND BUKRS = V_COMCODE.
    IF ZNO NE ''.
      NOKWIT = ZNO.
    ENDIF.
*      ENDIF.
    V_NOKWIT = NOKWIT.

    IF P_BUKRS-LOW = '9999'. "ADD BY REY NEW COMPANY
      P_HEAD = 'PT TRIAS SENTOSA, TBK.'.
      V_FORMNAME = 'ZFIF_KWITANSI_PENJUALAN_TS'.  " Added by William at 30.12.2024 (form kwitansi for TS)
    ELSEIF P_BUKRS-LOW = '9800'.
      P_HEAD = 'PT UNGGUL NIAGA SENTOSA'.
    ELSEIF P_BUKRS-LOW = '9701'.
      P_HEAD = 'PT TRIAS TOYOBO ASTRIA'.
    ELSEIF P_BUKRS-LOW = '6500'.
      P_HEAD = 'PT TOYOBO TRIAS ECOSYAR'.
    ENDIF.

*    PERFORM SAVETOTABLE.
    CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
      EXPORTING
        FORMNAME           = V_FORMNAME
*       VARIANT            = ' '
*       DIRECT_CALL        = ' '
      IMPORTING
        FM_NAME            = V_FUNCNAME
      EXCEPTIONS
        NO_FORM            = 1
        NO_FUNCTION_MODULE = 2
        OTHERS             = 3.

    IF SY-SUBRC <> 0.
*   Implement suitable error handling here
    ELSE.
      CONTROL_PARAMETERS-NO_DIALOG = 'X'.
      CONTROL_PARAMETERS-PREVIEW = 'X'.
      OUTPUT_OPTIONS-TDNOPRINT = 'X'.
      CALL FUNCTION V_FUNCNAME
        EXPORTING
         CONTROL_PARAMETERS = CONTROL_PARAMETERS
         OUTPUT_OPTIONS     = OUTPUT_OPTIONS
*         mail_recipient     = i_recipient
*         mail_sender        = i_sender
          P_NOKWIT           = V_NOKWIT
          P_FROM             = V_FROM
          P_TOTUSDPP         = V_TOTUSDPP
          P_TOTIDRPPN        = V_TOTIDRPPN
          P_FAKTUR           = V_FAKTUR
          P_FAKTUR1           = V_FAKTUR1
          P_TERBILANGIN      = V_TERBILANGIN
          P_TERBILANG        = V_TERBILANG
          P_TOTUSPPN         = V_TOTUSPPN
          P_TOTUSJLH         = V_TOTUSJLH
          P_TOTIDRDPP        = V_TOTIDRDPP
          P_TOTIDRJLH        = V_TOTIDRJLH
          P_DCETAK           = V_DCETAK
          P_TCETAK           = V_TCETAK
          P_DATE             = V_DATEKWIT "V_DATE
          P_NAMA             = V_NAMA
          P_UANGTXT1         = V_UANGTXT1
          P_UANGTXT2         = V_UANGTXT2
          P_TERBILANGTXT     = V_TERBILANGTXT
          P_TOT1             = V_TOT1T
          P_PLUS             = V_PLUS
          P_TOT2             = V_TOT2T
          P_ROT2             = V_ROT2
          P_ROT1             = V_ROT1
          P_ROT3             = V_ROT3
          TYPECETAKULANG     = TYPEFORM
          P_DATEKWIT         = V_DATEKWIT
          P_BK_BANK          = V_BK_NAMA "add by whika for bank information
          P_IDR              = V_IDR1
          P_AC_NAMA          = V_AC_NAMA
          P_CBG_NAMA         = V_CBG_NAMA "whika
          P_HEAD             = P_HEAD "ADD BY REY NEW COMPANY
*        IMPORTING
*          JOB_OUTPUT_INFO    = LD_INFO
        TABLES
          IT_ITEM            = I_ITEM
        EXCEPTIONS
          FORMATTING_ERROR   = 1
          INTERNAL_ERROR     = 2
          SEND_ERROR         = 3
          USER_CANCELED      = 4
          OTHERS             = 5.

      PERFORM DISPLAY_ALV.
    ENDIF.
  ENDIF.
ENDFORM.                    " DOPRINT_PREVIEW

*&---------------------------------------------------------------------*
*&      Form  DOSELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOSELECT_ALL .
  LOOP AT IT_KWITANSI WHERE SEL NE 'X'.
    IT_KWITANSI-SEL = 'X'.
    MODIFY IT_KWITANSI.
  ENDLOOP.
  PERFORM DISPLAY_ALV.
ENDFORM.                    " DOSELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  DODESSELECT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DODESSELECT_ALL .
  LOOP AT IT_KWITANSI WHERE SEL EQ 'X'.
    CLEAR IT_KWITANSI-SEL.
    MODIFY IT_KWITANSI.
  ENDLOOP.
  PERFORM DISPLAY_ALV.
ENDFORM.                    " DODESSELECT_ALL

*&---------------------------------------------------------------------*
*&      Form  DOREFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOREFRESH .
  PERFORM GET_DATA.
  PERFORM CONVERTIDR.
  PERFORM DISPLAY_ALV.
ENDFORM.                    " DOREFRESH

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR: T_FIELDCAT.
  REFRESH : T_FIELDCAT.
  IF MYTAB-DYNNR = 300.
    PERFORM F_ALV_FIELDCATG_ICON1 USING 'IT_KWITANSI' :
*           'SEL'   ''  ''  '' 10   'Sel.'  '' ''   '' '' 'X' 'X',
       'ZNO'     ''  ''  '' 12   'Kwitansi No.' '' ''  '' '' '' '',
       'BUKRS'     ''  ''  '' 4   'Company Code' '' ''  '' '' '' '', "ADD BY REY NEW COMPANY
       'KWITDATE'     ''  ''  '' 17   'Tanggal Kwitansi'  '' '' '' '' '' '',
       'KUNNR'     ''  ''  '' 20   'Customer Code'  '' '' '' '' '' '',
       'NAME1'     ''  ''  '' 50   'Customer Name'  '' '' '' '' '' '',
       'AWKEY'     ''  ''  '' 20   'Faktur Dagang' '' ''  '' '' '' '',
       'BLDAT'     ''  ''  '' 17   'Tanggal Faktur' '' ''  '' '' '' '',
       'WAERS'     ''  ''  '' 8   'Currency'  '' '' '' '' '' '',
       'TWRBTRDPP'     ''  ''  '' 20   'DPP' ''  ''   'R'  '' '' '',
       'TWRBTRPPN'     ''  ''  '' 20   'PPN' '' ''   'R'  '' '' '',
       'TWRBTRTOT'     ''  ''  '' 20   'Total' '' ''   'R'  '' '' '',
       'TDMBTRDPP'     ''  ''  '' 20   'IDR DPP' '' ''   'R'  '' '' '',
       'TDMBTRPPN'     ''  ''  '' 20   'IDR PPN' '' ''   'R'  '' '' '',
       'TDMBTRTOT'     ''  ''  '' 20   'IDR Total' '' ''   'R'  '' '' ''.
  ELSEIF MYTAB-DYNNR = 200.
    PERFORM F_ALV_FIELDCATG_ICON1 USING 'IT_KWITANSI' :
       'SEL'   ''  ''  '' 10   'Sel.'  '' ''   '' '' 'X' 'X',
       'BUKRS'     ''  ''  '' 4   'Company Code' '' ''  '' '' '' '', "ADD BY REY NEW COMPANY
       'AWKEY'     ''  ''  '' 20   'Faktur Dagang' '' ''  '' '' '' '',
       'KUNNR'     ''  ''  '' 20   'Customer Code'  '' '' '' '' '' '',
       'NAME1'     ''  ''  '' 50   'Customer Name'  '' '' '' '' '' '',
       'ZNO'     ''  ''  '' 12   'Kwitansi No.' '' ''  '' '' '' '',
       'KWITDATE' ''  ''  '' 12   'Tanggal Kwitansi' '' ''  '' '' '' '',
       'BLDAT'     ''  ''  '' 10   'Tanggal Faktur'  '' '' '' '' '' '',
       'WAERS'     ''  ''  '' 8   'Currency'  '' '' '' '' '' '',
       'TWRBTRDPP'     ''  ''  '' 20   'DPP' ''  ''   'R'  '' '' '',
       'TWRBTRPPN'     ''  ''  '' 20   'PPN' '' ''   'R'  '' '' '',
       'TWRBTRTOT'     ''  ''  '' 20   'Total' '' ''   'R'  '' '' '',
       'TDMBTRDPP'     ''  ''  '' 20   'IDR DPP' '' ''   'R'  '' '' '',
       'TDMBTRPPN'     ''  ''  '' 20   'IDR PPN' '' ''   'R'  '' '' '',
       'TDMBTRTOT'     ''  ''  '' 20   'IDR Total' '' ''   'R'  '' '' '',
       'ZPRINT' ''  ''  '' 10   'Print' '' ''   'R'  '' '' '',
       'ICON'     ''  ''  '' 10   'Icon' '' ''   'C'  'X' '' ''.
  ELSEIF MYTAB-DYNNR = 100.
    IF P_STAT1 EQ 'X'.
      IF ROT1 EQ 'X'.
        PERFORM F_ALV_FIELDCATG_ICON1 USING 'IT_KWITANSI' :
         'SEL'   ''  ''  '' 10   'Sel.'  '' ''   '' '' 'X' 'X',
         'BUKRS'     ''  ''  '' 4   'Company Code' '' ''  '' '' '' '', "ADD BY REY NEW COMPANY
         'AWKEY'     ''  ''  '' 20   'Faktur Dagang' '' ''  '' '' '' '',
         'KUNNR'     ''  ''  '' 20   'Customer Number'  '' '' '' '' '' '',
         'NAME1'     ''  ''  '' 50   'Customer Name'  '' '' '' '' '' '',
         'BLDAT'     ''  ''  '' 10   'Tanggal'  '' '' '' '' '' '',
         'WAERS'     ''  ''  '' 8   'Currency'  '' '' '' '' '' '',
         'TWRBTRDPP'     ''  ''  '' 20   'DPP' ''  ''   'R'  '' '' '',
         'TWRBTRPPN'     ''  ''  '' 20   'PPN' '' ''   'R'  '' '' '',
         'TWRBTRTOT'     ''  ''  '' 20   'Total' '' ''   'R'  '' '' '',
         'ZNO'     ''  ''  '' 12   'Kwitansi No.' '' ''  '' '' '' '',
         'ZPRINT' ''  ''  '' 10   'Print' '' ''   'R'  '' '' '',
         'ICON'     ''  ''  '' 10   'Icon' '' ''   'C'  'X' '' ''.
      ELSEIF ROT2 EQ 'X'.
        PERFORM F_ALV_FIELDCATG_ICON1 USING 'IT_KWITANSI' :
         'SEL'   ''  ''  '' 10   'Sel.'  '' ''   '' '' 'X' 'X',
         'BUKRS'     ''  ''  '' 4   'Company Code' '' ''  '' '' '' '', "ADD BY REY NEW COMPANY
         'AWKEY'     ''  ''  '' 20   'Faktur Dagang' '' ''  '' '' '' '',
         'KUNNR'     ''  ''  '' 20   'Customer Code'  '' '' '' '' '' '',
         'NAME1'     ''  ''  '' 50   'Customer Name'  '' '' '' '' '' '',
         'BLDAT'     ''  ''  '' 10   'Tanggal'  '' '' '' '' '' '',
         'WAERS'     ''  ''  '' 8   'Currency'  '' '' '' '' '' '',
         'TWRBTRDPP'     ''  ''  '' 20   'DPP' ''  ''   'R'  '' '' '',
         'TWRBTRPPN'     ''  ''  '' 20   'PPN' '' ''   'R'  '' '' '',
         'TWRBTRTOT'     ''  ''  '' 20   'Total' '' ''   'R'  '' '' '',
         'TDMBTRDPP'     ''  ''  '' 20   'IDR DPP' '' ''   'R'  '' '' '',
         'TDMBTRPPN'     ''  ''  '' 20   'IDR PPN' '' ''   'R'  '' '' '',
         'TDMBTRTOT'     ''  ''  '' 20   'IDR Total' '' ''   'R'  '' '' '',
         'ZNO'     ''  ''  '' 12   'Kwitansi No.' '' ''  '' '' '' '',
         'ZPRINT' ''  ''  '' 10   'Print' '' ''   'R'  '' '' '',
         'ICON'     ''  ''  '' 10   'Icon' '' ''   'C'  'X' '' ''.
      ELSEIF ROT3 EQ 'X'.
        PERFORM F_ALV_FIELDCATG_ICON1 USING 'IT_KWITANSI' :
         'SEL'   ''  ''  '' 10   'Sel.'  '' ''   '' '' 'X' 'X',
         'BUKRS'     ''  ''  '' 4   'Company Code' '' ''  '' '' '' '', "ADD BY REY NEW COMPANY
         'AWKEY'     ''  ''  '' 20   'Faktur Dagang' '' ''  '' '' '' '',
         'KUNNR'     ''  ''  '' 20   'Customer Code'  '' '' '' '' '' '',
         'NAME1'     ''  ''  '' 50   'Customer Name'  '' '' '' '' '' '',
         'BLDAT'     ''  ''  '' 10   'Tanggal'  '' '' '' '' '' '',
         'WAERS'     ''  ''  '' 8   'Currency'  '' '' '' '' '' '',
         'TDMBTRDPP'     ''  ''  '' 20   'IDR DPP' '' ''   'R'  '' '' '',
         'TDMBTRPPN'     ''  ''  '' 20   'IDR PPN' '' ''   'R'  '' '' '',
         'TDMBTRTOT'     ''  ''  '' 20   'IDR Total' '' ''   'R'  '' '' '',
         'ZNO'     ''  ''  '' 12   'Kwitansi No.' '' ''  '' '' '' '',
         'ZPRINT' ''  ''  '' 10   'Print' '' ''   'R'  '' '' '',
         'ICON'     ''  ''  '' 10   'Icon' '' ''   'C'  'X' '' ''.
      ENDIF.
    ELSEIF P_STAT2 = 'X'.
      IF ROT1 EQ 'X'.
        PERFORM F_ALV_FIELDCATG_ICON1 USING 'IT_KWITANSI' :
         'SEL'   ''  ''  '' 10   'Sel.'  '' ''   '' '' 'X' 'X',
         'BUKRS'     ''  ''  '' 4   'Company Code' '' ''  '' '' '' '', "ADD BY REY NEW COMPANY
         'AWKEY'     ''  ''  '' 20   'Faktur Dagang' '' ''  '' '' '' '',
         'KUNNR'     ''  ''  '' 15   'Customer' '' ''  '' '' '' '',
         'NAME1'     ''  ''  '' 40   'Customer Name'  '' '' '' '' '' '',
         'BLART'     ''  ''  '' 10   'Doc Type'  '' '' '' '' '' '',
         'BLDAT'     ''  ''  '' 10   'Tanggal'  '' '' '' '' '' '',
         'WAERS'     ''  ''  '' 8   'Currency'  '' '' '' '' '' '',
         'KURSK'     ''  ''  '' 12   'Kurs' '' ''  '' '' '' '',
         'TWRBTRDPP'     ''  ''  '' 20   'DPP' ''  ''   'R'  '' '' '',
         'TWRBTRPPN'     ''  ''  '' 20   'PPN' '' ''   'R'  '' '' '',
         'TWRBTRTOT'     ''  ''  '' 20   'Total' '' ''   'R'  '' '' '',
         'ZNO'     ''  ''  '' 12   'Kwitansi No.' '' ''  '' '' '' '',
         'ZPRINT' ''  ''  '' 10   'Print' '' ''   'R'  '' '' '',
         'ICON'     ''  ''  '' 10   'Icon' '' ''   'C'  'X' '' ''.
      ELSEIF ROT2 EQ 'X'.
        PERFORM F_ALV_FIELDCATG_ICON1 USING 'IT_KWITANSI' :
         'SEL'   ''  ''  '' 10   'Sel.'  '' ''   '' '' 'X' 'X',
         'BUKRS'     ''  ''  '' 4   'Company Code' '' ''  '' '' '' '', "ADD BY REY NEW COMPANY
         'AWKEY'     ''  ''  '' 20   'Faktur Dagang' '' ''  '' '' '' '',
         'KUNNR'     ''  ''  '' 15   'Customer' '' ''  '' '' '' '',
         'NAME1'     ''  ''  '' 40   'Customer Name'  '' '' '' '' '' '',
         'BLART'     ''  ''  '' 10   'Doc Type'  '' '' '' '' '' '',
         'BLDAT'     ''  ''  '' 10   'Tanggal'  '' '' '' '' '' '',
         'WAERS'     ''  ''  '' 8   'Currency'  '' '' '' '' '' '',
         'KURSK'     ''  ''  '' 12   'Kurs' '' ''  '' '' '' '',
         'TWRBTRDPP'     ''  ''  '' 20   'DPP' ''  ''   'R'  '' '' '',
         'TWRBTRPPN'     ''  ''  '' 20   'PPN' '' ''   'R'  '' '' '',
         'TWRBTRTOT'     ''  ''  '' 20   'Total' '' ''   'R'  '' '' '',
         'TDMBTRDPP'     ''  ''  '' 20   'IDR DPP' '' ''   'R'  '' '' '',
         'TDMBTRPPN'     ''  ''  '' 20   'IDR PPN' '' ''   'R'  '' '' '',
         'TDMBTRTOT'     ''  ''  '' 20   'IDR Total' '' ''   'R'  '' '' '',
         'ZNO'     ''  ''  '' 12   'Kwitansi No.' '' ''  '' '' '' '',
         'ZPRINT' ''  ''  '' 10   'Print' '' ''   'R'  '' '' '',
         'ICON'     ''  ''  '' 10   'Icon' '' ''   'C'  'X' '' ''.
      ELSEIF ROT3 EQ 'X'.
        PERFORM F_ALV_FIELDCATG_ICON1 USING 'IT_KWITANSI' :
         'SEL'   ''  ''  '' 10   'Sel.'  '' ''   '' '' 'X' 'X',
         'BUKRS'     ''  ''  '' 4   'Company Code' '' ''  '' '' '' '', "ADD BY REY NEW COMPANY
         'AWKEY'     ''  ''  '' 20   'Faktur Dagang' '' ''  '' '' '' '',
         'KUNNR'     ''  ''  '' 15   'Customer' '' ''  '' '' '' '',
         'NAME1'     ''  ''  '' 40   'Customer Name'  '' '' '' '' '' '',
         'BLART'     ''  ''  '' 10   'Doc Type'  '' '' '' '' '' '',
         'BLDAT'     ''  ''  '' 10   'Tanggal'  '' '' '' '' '' '',
         'WAERS'     ''  ''  '' 8   'Currency'  '' '' '' '' '' '',
         'KURSK'     ''  ''  '' 12   'Kurs' '' ''  '' '' '' '',
         'TDMBTRDPP'     ''  ''  '' 20   'IDR DPP' '' ''   'R'  '' '' '',
         'TDMBTRPPN'     ''  ''  '' 20   'IDR PPN' '' ''   'R'  '' '' '',
         'TDMBTRTOT'     ''  ''  '' 20   'IDR Total' '' ''   'R'  '' '' '',
         'ZNO'     ''  ''  '' 12   'Kwitansi No.' '' ''  '' '' '' '',
         'ZPRINT' ''  ''  '' 10   'Print' '' ''   'R'  '' '' '',
         'ICON'     ''  ''  '' 10   'Icon' '' ''   'C'  'X' '' ''.
      ENDIF.
    ENDIF.
  ENDIF.
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
  CLEAR WA_LAYOUT.
  WA_LAYOUT-NO_INPUT          = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  WA_LAYOUT-TOTALS_TEXT       = 'Totals'(201).
ENDFORM.                    " F_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  SORT IT_KWITANSI BY NO.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_TOP_OF_PAGE   = 'TOP_OF_PAGE'
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
      IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = T_FIELDCAT[]
      IT_EVENTS                = I_EVENT "t_events[]
      IT_EVENT_EXIT            = T_EVENT_EXIT[]
      I_DEFAULT                = 'X'
      I_SAVE                   = 'A'
      IS_VARIANT               = WA_VARIANTE
      IS_PRINT                 = T_PRINT
      IT_SORT                  = T_SORT[]
      IT_EXCLUDING             = T_EXCLUDING[]
      I_BYPASSING_BUFFER       = 'X'
    TABLES
      T_OUTTAB                 = IT_KWITANSI
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  IF MYTAB-DYNNR = 300.
    SET PF-STATUS 'ZSTREPORT'.
  ELSEIF MYTAB-DYNNR = 200.
*    SET PF-STATUS 'ZSTATUS_KWITANSI'.
    PERFORM SET_STATUS.
  ELSEIF MYTAB-DYNNR = 100.
*    SET PF-STATUS 'ZSTATUS_KWITANSI'.
    PERFORM SET_STATUS.
  ENDIF.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  SY-LSIND = 0.
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      E_GRID = LS_REF1.

  CALL METHOD LS_REF1->CHECK_CHANGED_DATA .

  DATA : WA_KWITANSI LIKE LINE OF IT_KWITANSI.
  SY-LSIND = 0.
  CASE FU_UCOMM.
    WHEN 'BACK' OR 'LEAVE'.
*      LEAVE TO TRANSACTION 'ZFI103'.
      LEAVE TO TRANSACTION SY-TCODE.
      CLEAR FU_UCOMM.
    WHEN 'DWL'.
      PERFORM DOWNLOADREPORT.
    WHEN 'PRDOC'.
      IF MYTAB-DYNNR = 200.
        PERFORM DOPRINT2.
      ELSE.
        PERFORM DOPRINT.
      ENDIF.
    WHEN 'PRVDOC'. "preview doc
      IF MYTAB-DYNNR = 200.
        PERFORM PRINT_PREVIEW2.
      ELSE.
        PERFORM DOPRINT_PREVIEW.
      ENDIF.
    WHEN 'SALL'.
      PERFORM DOSELECT_ALL.
    WHEN 'DSALL'.
      PERFORM DODESSELECT_ALL.
    WHEN 'REFDOC'.
      PERFORM DOREFRESH.
    WHEN '&CANC'.
      PERFORM CANCEL_KWITANSI.
      PERFORM DOREFRESH.
    WHEN '&ASC'.
      CLEAR T_SORT. REFRESH T_SORT.
*      SORT IT_KWITANSI BY FU_SELFIELD-FIELDNAME ASCENDING.
      T_SORT-FIELDNAME = FU_SELFIELD-FIELDNAME.
      T_SORT-UP = 'X'.
      APPEND T_SORT.
      PERFORM DISPLAY_ALV.
    WHEN '&DES'.
      CLEAR T_SORT. REFRESH T_SORT.
*      SORT IT_KWITANSI BY FU_SELFIELD-FIELDNAME DESCENDING.
      T_SORT-FIELDNAME = FU_SELFIELD-FIELDNAME.
      T_SORT-DOWN = 'X'.
      APPEND T_SORT.
      PERFORM DISPLAY_ALV.
    WHEN '&IC1'.
      CHECK IT_KWITANSI[] IS NOT INITIAL.
      READ TABLE IT_KWITANSI INDEX FU_SELFIELD-TABINDEX.
      IF IT_KWITANSI-BLART EQ 'RX' OR IT_KWITANSI-BLART EQ 'RV' OR
         IT_KWITANSI-BLART EQ 'RK' OR IT_KWITANSI-BLART EQ 'RL'.
        SET PARAMETER ID 'VF' FIELD IT_KWITANSI-AWKEY.
        SET PARAMETER ID 'BUK' FIELD P_BUKRS.
        SET PARAMETER ID 'GJR' FIELD IT_KWITANSI-GJAHR. "SY-DATUM(4).
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      ELSE.
        SET PARAMETER ID 'BLN' FIELD IT_KWITANSI-AWKEY.
        SET PARAMETER ID 'BUK' FIELD P_BUKRS.
        SET PARAMETER ID 'GJR' FIELD IT_KWITANSI-GJAHR. "SY-DATUM(4).
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_icon1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON1 USING FU_TYPES
                                FU_FNAME
                                FU_REFTB
                                FU_REFLD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_HOTSP
                                FU_JUST
                                FU_ICON
                                FU_CHK
                                FU_EDIT.
  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
*  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
  T_FIELDCAT-CHECKBOX      = FU_CHK.
  T_FIELDCAT-EDIT          = FU_EDIT.
*  T_FIELDCAT-NO_ZERO       = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg_icon1

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  IF MYTAB-DYNNR = 100.
    IF P_STAT1 = 'X'.
      PERFORM F_SELECT_DATA_FI.
    ELSEIF P_STAT2 = 'X'.
      PERFORM F_SELECT_DATA_SD.
    ENDIF.
  ELSE.
    PERFORM F_SELECT_DATA_FI.
    SORT IT_KWITANSI BY ZNO ASCENDING.
  ENDIF.
  PERFORM GET_CUSTOMER.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
FORM  TOP_OF_PAGE.
  DATA : CUST TYPE C LENGTH 100,
         LI_HEADER TYPE SLIS_T_LISTHEADER,
         W_HEADER  LIKE LINE OF LI_HEADER.

  W_HEADER-TYP  = 'H'.
  SELECT SINGLE BUTXT INTO W_HEADER-INFO FROM T001 WHERE BUKRS EQ P_BUKRS-LOW. "ADD NEW COMPANY

  APPEND W_HEADER TO LI_HEADER.
  CLEAR W_HEADER.

  W_HEADER-TYP  = 'H'.
  W_HEADER-TYP  = 'H'.
  W_HEADER-INFO = 'List of Kwitansi Penjualan'.
  APPEND W_HEADER TO LI_HEADER.
  CLEAR W_HEADER.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = LI_HEADER.

ENDFORM.                    " top_of_page

*&---------------------------------------------------------------------*
*&      Form  SUB_GET_EVENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SUB_GET_EVENT .
  CONSTANTS : C_FORMNAME_TOTAL_TEXT TYPE SLIS_FORMNAME VALUE 'TOTAL_TEXT'.
  DATA: L_S_EVENT TYPE SLIS_ALV_EVENT.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      I_LIST_TYPE     = 4
    IMPORTING
      ET_EVENTS       = I_EVENT
    EXCEPTIONS
      LIST_TYPE_WRONG = 0
      OTHERS          = 0.

* Subtotal
  READ TABLE I_EVENT  INTO L_S_EVENT
                    WITH KEY NAME = SLIS_EV_SUBTOTAL_TEXT.
  IF SY-SUBRC = 0.
    MOVE C_FORMNAME_TOTAL_TEXT TO L_S_EVENT-FORM.
    MODIFY I_EVENT FROM L_S_EVENT INDEX SY-TABIX.
  ENDIF.
ENDFORM.                    " SUB_GET_EVENT

*&---------------------------------------------------------------------*
*&      Form  TOTAL_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TOTAL        text
*      -->P_SUBTOT_TEXT  text
*----------------------------------------------------------------------*
FORM TOTAL_TEXT CHANGING
               P_TOTAL TYPE ANY
               P_SUBTOT_TEXT TYPE SLIS_SUBTOT_TEXT.

* Material level sub total
  IF P_SUBTOT_TEXT-CRITERIA = 'TOT'.
    P_SUBTOT_TEXT-DISPLAY_TEXT_FOR_SUBTOTAL
    = 'Total'(009).
  ENDIF.
ENDFORM.                    "subtotal_text

*&---------------------------------------------------------------------*
*&      Form  PREPARE_DATAPRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PREPARE_DATAPRINT .
  DATA : DAT(10), V_TOTUSDPPTXT(15),
         TIME(10), V_TOTIDRPPNTXT(15), V_TOTIDRDPPTXT(15),
         ZFDAGANG(10),
         CTR TYPE I, CTRT TYPE CHAR5,
         ZTUSDPP TYPE P DECIMALS 2,
         ZTUSPPN TYPE P DECIMALS 2,
         ZTUSTOT TYPE P DECIMALS 2,
         ZTIDRDPP TYPE P DECIMALS 2,
         ZTIDRPPN TYPE P DECIMALS 2,
         ZTIDRTOT TYPE P DECIMALS 2,
         V_TOT TYPE P DECIMALS 2,
         WAERS LIKE BKPF-WAERS,
         WAERS1 LIKE BKPF-WAERS,
         ZNO LIKE ZKWIT-ZNO,
         KEYDATE LIKE ZKWIT-KEYDATE,
         PNT LIKE ZKWIT-PNT,
         AMT(20), AMT1(20).

  CLEAR : DAT, TIME, CTR, CTRT, V_TOT, V_TERBILANGIN, V_FAKTUR, V_FAKTUR1,
          ZTUSDPP, ZTUSPPN, ZTUSTOT, ZTIDRDPP, ZTIDRPPN, ZTIDRTOT,
          V_UANGTXT1, V_UANGTXT2, V_TERBILANGTXT, WAERS, WAERS1,
          V_TOT1, V_PLUS, V_TOT2, V_ROT2, TYPEFORM, ZNO, KEYDATE, PNT, V_DATEKW, V_TOT1T, V_TOT2T.

*cek apakah cetak ulang (untuk cetak ulang berarti per nomor faktur)
  IF MYTAB-DYNNR = 200.
    CLEAR: TYPEFORM, ZNO, V_COMCODE.
    READ TABLE I_ITEM INDEX 1.

    IF P_BUKRS2-LOW = '9999'.
      V_COMCODE = ''.
    ELSE.
      V_COMCODE = P_BUKRS2-LOW.
    ENDIF.

    SELECT SINGLE TYPEFORM ZNO KEYDATE PNT
            INTO (TYPEFORM, ZNO, KEYDATE, PNT)
            FROM ZKWIT
            WHERE ZAWKEY = I_ITEM-ZFDAGANG AND TYPEFORM IN (11, 22, 33)
              AND BUKRS = V_COMCODE.

    CLEAR: I_ITEM, WA_ITEM. REFRESH I_ITEM.
    CLEAR CTR.
    LOOP AT IT_KWITANSI WHERE ZNO EQ ZNO.
      CLEAR DAT.
      CTR = CTR + 1.
      WA_ITEM-ZNO = CTR.
      WA_ITEM-ZFDAGANG  = IT_KWITANSI-AWKEY.

      CONCATENATE IT_KWITANSI-BLDAT+6(2) IT_KWITANSI-BLDAT+4(2) IT_KWITANSI-BLDAT+2(2) INTO DAT SEPARATED BY '.'.
      PERFORM CONVERTDATE USING DAT WA_ITEM-ZTANGGAL.
*      WA_ITEM-ZTANGGAL  = IT_KWITANSI-BLDAT.
      WA_ITEM-ZUSDPP = IT_KWITANSI-WRBTRDPP.
      WA_ITEM-ZUSPPN = IT_KWITANSI-WRBTRPPN.
      WA_ITEM-ZUSTOT = IT_KWITANSI-WRBTRTOT.
      WA_ITEM-ZIDRDPP = IT_KWITANSI-DMBTRDPP.
      WA_ITEM-ZIDRPPN = IT_KWITANSI-DMBTRPPN.
      WA_ITEM-ZIDRTOT = IT_KWITANSI-DMBTRTOT.
      APPEND WA_ITEM TO I_ITEM.
    ENDLOOP.

    CLEAR : ROT1, ROT2, ROT3.
    IF TYPEFORM = 11.
      ROT1 = 'X'.
    ELSEIF TYPEFORM = 22.
      ROT2 = 'X'.
    ELSEIF TYPEFORM = 33.
      ROT3 = 'X'.
    ENDIF.
  ENDIF.

  CLEAR CTR.
  LOOP AT I_ITEM.
    CLEAR ZFDAGANG.
    ZFDAGANG = I_ITEM-ZFDAGANG.
    SHIFT ZFDAGANG LEFT DELETING LEADING '0'.
    CONDENSE ZFDAGANG.
    CTR = CTR + 1.
    IF CTR = 1.
      V_FAKTUR = ZFDAGANG.
    ELSE.
      IF CTR  > 7.
        IF CTR = 8.
          V_FAKTUR1 = ZFDAGANG.
        ELSE.
          CONCATENATE V_FAKTUR1 ZFDAGANG INTO V_FAKTUR1 SEPARATED BY ','.
        ENDIF.
      ELSE.
        CONCATENATE V_FAKTUR ZFDAGANG INTO V_FAKTUR SEPARATED BY ','.
      ENDIF.
    ENDIF.

    ZTUSDPP = ZTUSDPP + I_ITEM-ZUSDPP.
    ZTUSPPN = ZTUSPPN + I_ITEM-ZUSPPN.
    ZTUSTOT = ZTUSTOT + I_ITEM-ZUSTOT.
    ZTIDRDPP = ZTIDRDPP + I_ITEM-ZIDRDPP.
    ZTIDRPPN = ZTIDRPPN + I_ITEM-ZIDRPPN.
    ZTIDRTOT = ZTIDRTOT + I_ITEM-ZIDRTOT.
  ENDLOOP.

  IF V_FAKTUR1 NE ''.
    CONCATENATE V_FAKTUR ',' INTO V_FAKTUR.
  ENDIF.

* GET CUSTOMER
  IF MYTAB-DYNNR = 100.
    V_NAMA  = PK_NAMA.
*    V_FROM  = CUSTOMER.
    READ TABLE IT_KWITANSI WITH KEY KUNNR = PK_KUNNR.
    V_FROM  = IT_KWITANSI-NAME1.
    CLEAR DAT.
    CONCATENATE PK_TGLKW+6(2) PK_TGLKW+4(2) PK_TGLKW(4) INTO DAT SEPARATED BY '.'.
    PERFORM CONVERTDATE USING DAT V_DATEKWIT.
    V_DATEKW = PK_TGLKW.
  ELSE.
    CLEAR: V_FROM, DAT.
    CONCATENATE KEYDATE+6(2) KEYDATE+4(2) KEYDATE(4) INTO DAT SEPARATED BY '.'.
    PERFORM CONVERTDATE USING DAT V_DATEKWIT.
    V_DATEKW = KEYDATE.
    V_NAMA  =  PNT.
    READ TABLE I_ITEM INDEX 1.
    LOOP AT IT_KWITANSI WHERE AWKEY EQ I_ITEM-ZFDAGANG.
      V_FROM = IT_KWITANSI-NAME1.
      IF V_FROM NE ''.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  V_TOTUSDPP  = ZTUSDPP.
  V_TOTIDRPPN = ZTIDRPPN.
  V_TOTUSPPN  = ZTUSPPN.
  V_TOTUSJLH  = ZTUSTOT.
  V_TOTIDRDPP = ZTIDRDPP.
  V_TOTIDRJLH = ZTIDRTOT.


  IF IDR1 EQ 'X'. "add by whika for bank information
    V_IDR1 = 'IDR'.
  ELSEIF IDR2 EQ 'X'.
    V_IDR1 = 'USD'.
  ENDIF.
  V_AC_NAMA = AC_NAMA.
  V_BK_NAMA = BK_NAMA.
  V_CBG_NAMA = CBG_NAMA.


  CLEAR : V_TOTUSDPPTXT, V_TOTIDRPPNTXT, V_TOTIDRDPPTXT, V_ROT1, V_ROT2, V_ROT3.

  IF ROT1 EQ 'X'.
    V_TERBILANGIN = 'US$'.
    V_TOT = V_TOT + V_TOTUSJLH. "V_TOTUSDPP.
    WAERS = 'USD'.
    V_TOTUSDPPTXT = V_TOTUSJLH. "V_TOTUSDPP.

    V_TOT1 = V_TOTUSJLH. "V_TOTUSDPP.
    PERFORM TERBILANG USING V_TOTUSJLH V_UANGTXT1 'USD'. "V_TOTUSDPP V_UANGTXT1 'USD'.
    V_ROT1 = 'X'.
  ELSEIF ROT2 EQ 'X'.
    V_TERBILANGIN = 'US$'.
    V_TOT = V_TOT + V_TOTUSDPP + V_TOTIDRPPN.
    WAERS = 'USD'.
    V_TOTIDRPPNTXT = V_TOTIDRPPN.
    V_TOTUSDPPTXT = V_TOTUSDPP.

    V_TOT1 = V_TOTUSDPP.
    V_PLUS = '+ Ppn Rp'.
    V_TOT2 = V_TOTIDRPPN.
    V_ROT2 = 'X'.

    PERFORM TERBILANG USING V_TOTUSDPP V_UANGTXT1 'USD'.
    PERFORM TERBILANGIDR USING V_TOTIDRPPN V_UANGTXT2. " 'IDR'.
    CONDENSE : V_UANGTXT1, V_UANGTXT2.
    CONCATENATE V_UANGTXT1 'Plus Ppn' V_UANGTXT2 INTO V_UANGTXT1 SEPARATED BY SPACE.
    V_ROT2 = 'X'.
  ELSEIF ROT3 = 'X'.
    V_TERBILANGIN = 'Rp'.
    V_TOT = V_TOT + V_TOTIDRDPP.
    WAERS = 'IDR'.
    V_TOTIDRDPPTXT = V_TOTIDRJLH. "V_TOTIDRDPP.
    V_TOT1 = V_TOTIDRJLH.
    PERFORM TERBILANGIDR USING V_TOTIDRJLH V_UANGTXT1 .
    V_ROT3 = 'X'.
  ENDIF.

  V_TERBILANG = V_TOT.
  CONDENSE V_TERBILANGTXT.

  CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM(4) INTO DAT SEPARATED BY '.'.
  CONCATENATE SY-UZEIT+0(2) SY-UZEIT+2(2) INTO TIME SEPARATED BY ':'.
  CONDENSE TIME.
  V_TCETAK  = TIME.

  PERFORM CONVERTDCETAK USING DAT V_DCETAK .
  PERFORM CONVERTDATE USING DAT V_DATE.

*  CHECK TOTAL TXT
  IF ROT1 = 'X'.
    WRITE V_TOT1 TO V_TOT1T EXPONENT 0 DECIMALS 2.
    WRITE V_TOT2 TO V_TOT2T EXPONENT 0 DECIMALS 2.
    CONDENSE : V_TOT1T, V_TOT2T.
  ELSEIF ROT2 = 'X'.
    WRITE V_TOT1 TO V_TOT1T EXPONENT 0 DECIMALS 2.
    WRITE V_TOT2 TO V_TOT2T EXPONENT 0 DECIMALS 0.
    CONDENSE : V_TOT1T, V_TOT2T.
  ELSEIF ROT3 = 'X'.
    WRITE V_TOT1 TO V_TOT1T EXPONENT 0 DECIMALS 0.
    WRITE V_TOT2 TO V_TOT2T EXPONENT 0 DECIMALS 0.
    CONDENSE : V_TOT1T, V_TOT2T.
  ENDIF.
  CONDENSE : V_TERBILANGIN, V_PLUS.
ENDFORM.                    " PREPARE_DATAPRINT


*&---------------------------------------------------------------------*
*&      Form  READMARKED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READMARKED .
  CLEAR : CTR, DAT, I_ITEM. REFRESH I_ITEM.
  CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM(4) INTO DAT SEPARATED BY '.'.
  IF MYTAB-DYNNR = 100.
    IF ROT1 EQ 'X'.
      PERFORM READMARKED1.
    ELSEIF ROT2 EQ 'X'.
      PERFORM READMARKED2.
    ELSEIF ROT3 EQ 'X'.
      PERFORM READMARKED3.
    ENDIF.
  ELSE.
    PERFORM READMARKED2.
    PERFORM CEK_NOKWIT.
  ENDIF.
ENDFORM.                    " READMARKED
*&---------------------------------------------------------------------*
*&      Form  CONVERTDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT  text
*      -->P_DATT1  text
*----------------------------------------------------------------------*
FORM CONVERTDATE  USING    P_DAT
                           P_DATT.
  DATA : DT(2),
         MT(2),
         YR(4),
         MTT(3),
         DAT(10).
  SPLIT P_DAT AT '.' INTO DT MT YR.
  CASE MT.
    WHEN '01'.
      MTT = 'Jan'.
    WHEN '02'.
      MTT = 'Feb'.
    WHEN '03'.
      MTT = 'Mar'.
    WHEN '04'.
      MTT = 'Apr'.
    WHEN '05'.
      MTT = 'May'.
    WHEN '06'.
      MTT = 'Jun'.
    WHEN '07'.
      MTT = 'Jul'.
    WHEN '08'.
      MTT = 'Aug'.
    WHEN '09'.
      MTT = 'Sep'.
    WHEN '10'.
      MTT = 'Oct'.
    WHEN '11'.
      MTT = 'Nov'.
    WHEN '12'.
      MTT = 'Dec'.
  ENDCASE.
  CONCATENATE DT MTT YR INTO P_DATT SEPARATED BY '-'.
ENDFORM.                    " CONVERTDATE

*&---------------------------------------------------------------------*
*&      Form  SAVETOTABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVETOTABLE .
  CLEAR : SEQ, NOKWIT, FLAG, AWKEY, ZSEQ, NOKWIT, AWKEY, ZNO, V_COMCODE.

  IF MYTAB-DYNNR = 100.
    IF P_BUKRS-LOW = '9999'.
      V_COMCODE = ''.
    ELSE.
      V_COMCODE = P_BUKRS-LOW.
    ENDIF.
  ELSEIF MYTAB-DYNNR = 200.
    IF P_BUKRS2-LOW = '9999'.
      V_COMCODE = ''.
    ELSE.
      V_COMCODE = P_BUKRS2-LOW.
    ENDIF.
  ENDIF.


  SELECT MAX( ZSEQ ) INTO ZSEQ
  FROM ZKWIT
    WHERE TYPEFORM IN (11, 22, 33)
      AND BUKRS = V_COMCODE.

  SEQ = ZSEQ.
  SEQ = SEQ + 1.
  NOKWIT = SEQ.
  CONDENSE NOKWIT.
  IF SEQ < 10.
    CONCATENATE '00' NOKWIT INTO NOKWIT.
  ELSEIF SEQ < 100 AND SEQ >= 10.
    CONCATENATE '0' NOKWIT INTO NOKWIT.
  ENDIF.

  IF MYTAB-DYNNR = 100.
    CLEAR : TYPEFORM.
    READ TABLE I_ITEM INDEX 1.
    SELECT SINGLE ZNO TYPEFORM ZSEQ INTO (ZNO , TYPEFORM, ZSEQ)  "tambah pengecekan agar nomor yg sama tidak counter
        FROM ZKWIT WHERE ZAWKEY = I_ITEM-ZFDAGANG AND TYPEFORM IN (11, 22, 33) AND BUKRS = V_COMCODE.
    IF ZNO NE ''.
      NOKWIT = ZNO.
      SEQ = ZSEQ.
    ELSE.
      CONCATENATE NOKWIT SY-DATUM+4(2) SY-DATUM(4) INTO NOKWIT SEPARATED BY '/'.
      IF ROT1 = 'X'.
        TYPEFORM = 11.
      ELSEIF ROT2 = 'X'.
        TYPEFORM = 22.
      ELSEIF ROT3 = 'X'.
        TYPEFORM = 33.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR : TYPEFORM.
    READ TABLE I_ITEM INDEX 1.
    AWKEY = I_ITEM-ZFDAGANG.
    SELECT SINGLE ZNO TYPEFORM
        INTO (ZNO , TYPEFORM)
        FROM ZKWIT
        WHERE ZAWKEY = AWKEY AND TYPEFORM IN (11, 22, 33)
          AND BUKRS = V_COMCODE.
    IF ZNO NE ''.
      NOKWIT = ZNO.
    ENDIF.
  ENDIF.

  V_NOKWIT = NOKWIT.
ENDFORM.                    " SAVETOTABLE


*&---------------------------------------------------------------------*
*&      Form  TERBILANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_TOTUSDPP  text
*      -->P_V_TOTIDRPPN  text
*      -->P_V_UANGTXT1  text
*----------------------------------------------------------------------*
FORM TERBILANG  USING    P_V_TOTUSDPP
                         P_V_UANGTXT1
                         LC_CURRENCY.
  DATA : LC_SPELL LIKE  SPELL.
  DATA : DECI LIKE SPELL-NUMBER,
         V_TER TYPE CHAR255,
         V_TERBILANG TYPE CHAR255,
         KTEXT_CURT LIKE TCURT-KTEXT.

  CLEAR: LC_SPELL, KTEXT_CURT.

  CALL FUNCTION 'SPELL_AMOUNT'
    EXPORTING
      AMOUNT    = P_V_TOTUSDPP
      CURRENCY  = LC_CURRENCY
      FILLER    = ' '
      LANGUAGE  = 'E'
    IMPORTING
      IN_WORDS  = LC_SPELL
    EXCEPTIONS
      NOT_FOUND = 1
      TOO_LARGE = 2
      OTHERS    = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

  CLEAR KTEXT_CURT.
  SELECT SINGLE KTEXT
    INTO KTEXT_CURT
    FROM TCURT
    WHERE SPRAS EQ 'EN' AND
    WAERS EQ LC_CURRENCY.

  CONDENSE KTEXT_CURT.
  IF LC_CURRENCY NE 'IDR'.
    IF LC_SPELL-DECIMAL NE '0'.
      PERFORM TERBILANGTXT USING V_TERBILANG LC_SPELL-NUMBER.
      DECI = LC_SPELL-DECIMAL(2).

      PERFORM TERBILANGTXT USING V_TER DECI.

      CONCATENATE V_TERBILANG KTEXT_CURT V_TER 'Sen' INTO V_TERBILANG SEPARATED BY SPACE.
    ELSE.
      PERFORM TERBILANGTXT USING V_TERBILANG LC_SPELL-NUMBER.
      CONCATENATE V_TERBILANG KTEXT_CURT INTO V_TERBILANG SEPARATED BY SPACE.
    ENDIF.
  ELSE.
    PERFORM TERBILANGTXT USING V_TERBILANG LC_SPELL-NUMBER.
    CONCATENATE V_TERBILANG KTEXT_CURT INTO V_TERBILANG SEPARATED BY SPACE.
  ENDIF.

  P_V_UANGTXT1 = V_TERBILANG .
ENDFORM.                    " TERBILANG


*&---------------------------------------------------------------------*
*&      Form  TERBILANG
*&---------------------------------------------------------------------*
FORM TERBILANGTXT USING V_TERB AMOUNT LIKE SPELL-NUMBER.

  DATA : ANGKA2 LIKE BSEG-WRBTR,
         ANGKA LIKE BSEG-WRBTR.
  CLEAR : ANGKA2, HASIL, NUMERIK.

  ANGKA = AMOUNT.
  IF ANGKA < 0.
    ANGKA = ANGKA * -1.
  ENDIF.

  MOVE ANGKA TO ANGKA2.
  BUFFER   = ANGKA2.

  LEN = LEN = STRLEN( BUFFER ).
  M = 0.

  DO LEN TIMES.
    C = BUFFER+M(1).
    IF C = '.'.
      EXIT.
    ELSE.
      CONCATENATE NUMERIK C INTO NUMERIK.
    ENDIF.
    M = M + 1.
  ENDDO.

  WRITE NUMERIK TO NUMERIK RIGHT-JUSTIFIED.
  SHIFT NUMERIK LEFT CIRCULAR BY 1 PLACES.

  DO 14 TIMES.
    SHIFT NUMERIK RIGHT CIRCULAR.
    T = NUMERIK+13(1).
    CHECK T NE SPACE.
    PERFORM TEKS.

    CASE SY-INDEX.
      WHEN 1.
        CHECK T NE 0.
        IF NUMERIK+12(1) NE 1.
          CONCATENATE H HASIL INTO HASIL SEPARATED BY SPACE.
        ELSE.
          IF T EQ 1.
            CONCATENATE 'Sebelas' HASIL INTO HASIL SEPARATED BY SPACE.
          ELSEIF T NE 0.
            CONCATENATE H 'Belas' HASIL INTO HASIL SEPARATED BY SPACE.
          ENDIF.
        ENDIF.
      WHEN 2.
        CHECK T NE 0.
        PERFORM PULUH.
      WHEN 3.
        CHECK T NE 0.
        PERFORM RATUS.
      WHEN 4.
        IF NUMERIK+11(2) EQ 00.
          CHECK T NE 0.
        ELSEIF T EQ 0.
          CLEAR H.
        ENDIF.
        IF T EQ 1.
          PERFORM TEKS.
          IF NUMERIK+12(1) NE 1.
            IF NUMERIK+11(2) EQ 00.
              CONCATENATE 'Seribu' HASIL INTO HASIL SEPARATED BY SPACE.
            ELSE.
              CONCATENATE H 'Ribu' HASIL INTO HASIL SEPARATED BY SPACE.
            ENDIF.
          ELSEIF T NE 0.
            CONCATENATE 'Sebelas Ribu' HASIL INTO HASIL SEPARATED BY SPACE.
          ENDIF.
        ELSE.
          IF NUMERIK+12(1) NE 1.
            CONCATENATE H 'Ribu' HASIL INTO HASIL SEPARATED BY SPACE.
          ELSEIF T NE 0.
            CONCATENATE H 'Belas Ribu' HASIL INTO HASIL SEPARATED BY SPACE.
          ELSEIF NUMERIK+12(1) NE 0.
            CONCATENATE H 'Ribu' HASIL INTO HASIL SEPARATED BY SPACE.
          ENDIF.
        ENDIF.
      WHEN 5.
        CHECK T NE 0.
        PERFORM PULUH.
      WHEN 6.
        CHECK T NE 0.
        PERFORM RATUS.
      WHEN 7.
        IF NUMERIK+11(2) EQ 00.
          CHECK T NE 0.
        ELSEIF T EQ 0.
          CLEAR H.
        ENDIF.
        IF NUMERIK+12(1) NE 1.
          CONCATENATE H 'Juta' HASIL INTO HASIL SEPARATED BY SPACE.
        ELSEIF T NE 1 AND T NE 0.
          CONCATENATE H 'Belas Juta' HASIL INTO HASIL SEPARATED BY SPACE.
        ELSEIF T NE 0.
          CONCATENATE 'Sebelas Juta' HASIL INTO HASIL SEPARATED BY SPACE.
        ELSEIF NUMERIK+12(1) NE 0.
          CONCATENATE H 'Juta' HASIL INTO HASIL SEPARATED BY SPACE.
        ENDIF.
      WHEN 8.
        CHECK T NE 0.
        PERFORM PULUH.
      WHEN 9.
        CHECK T NE 0.
        PERFORM RATUS.
      WHEN 10.
        IF NUMERIK+11(2) EQ 00.
          CHECK T NE 0.
        ELSEIF T EQ 0.
          CLEAR H.
        ENDIF.
        IF NUMERIK+12(1) NE 1.
          CONCATENATE H 'Miliar' HASIL INTO HASIL SEPARATED BY SPACE.
        ELSEIF T NE 1 AND T NE 0.
          CONCATENATE H 'Belas Miliar' HASIL INTO HASIL SEPARATED BY SPACE.
        ELSEIF T NE 0.
          CONCATENATE 'Sebelas Miliar' HASIL INTO HASIL SEPARATED BY SPACE.
        ELSEIF NUMERIK+12(1) NE 0.
          CONCATENATE H 'Miliar' HASIL INTO HASIL SEPARATED BY SPACE.
        ENDIF.
      WHEN 11.
        CHECK T NE 0.
        PERFORM PULUH.
      WHEN 12.
        CHECK T NE 0.
        PERFORM RATUS.
      WHEN 13.
        IF NUMERIK+11(2) EQ 00.
          CHECK T NE 0.
        ELSEIF T EQ 0.
          CLEAR H.
        ENDIF.
        IF NUMERIK+12(1) NE 1.
          CONCATENATE H 'Triliun' HASIL INTO HASIL SEPARATED BY SPACE.
        ELSEIF T NE 1 AND T NE 0.
          CONCATENATE H 'Belas Triliun' HASIL INTO HASIL SEPARATED BY SPACE.
        ELSEIF T NE 0.
          CONCATENATE 'Sebelas Triliun' HASIL INTO HASIL SEPARATED BY SPACE.
        ELSEIF NUMERIK+12(1) NE 0.
          CONCATENATE H 'Triliun' HASIL INTO HASIL SEPARATED BY SPACE.
        ENDIF.
      WHEN 14.
        CHECK T NE 0.
        PERFORM PULUH.
    ENDCASE.
  ENDDO.
  CONDENSE HASIL.
  IF ANGKA EQ 0.
    HASIL = 'Nol'.
  ENDIF.
  MOVE HASIL TO V_TERB.
ENDFORM.                    " TERBILANG


*&---------------------------------------------------------------------*
*&      Form  PULUH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PULUH.
  IF T NE 1.
    CONCATENATE H 'Puluh' HASIL INTO HASIL SEPARATED BY SPACE.
  ELSEIF NUMERIK(1) EQ 0.
    CONCATENATE 'Sepuluh' HASIL INTO HASIL SEPARATED BY SPACE.
  ENDIF.
ENDFORM.                    " PULUH

*&---------------------------------------------------------------------*
*&      Form  RATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM RATUS.
  IF T EQ 1.
    CONCATENATE 'Seratus' HASIL INTO HASIL SEPARATED BY SPACE.
  ELSE.
    CONCATENATE H 'Ratus' HASIL INTO HASIL SEPARATED BY SPACE.
  ENDIF.
ENDFORM.                    " RATUS

*&---------------------------------------------------------------------*
*&      Form  SPLIT
*&---------------------------------------------------------------------*
FORM SPLIT.
  CONCATENATE HASIL 'Rupiah' INTO HASIL SEPARATED BY SPACE.
  ASAL = HASIL.
  CONCATENATE ASAL  '.' INTO ASAL SEPARATED BY SPACE.

  LEN = STRLEN( ASAL ).
  M   = 0.
  DO LEN TIMES.
    N = SY-INDEX.
    C = ASAL+M(1).
    CONCATENATE BUFF C INTO BUFF.
    IF C IS INITIAL.
      KATA = BUFF.
      LEN2 = STRLEN( DESCR1 ).
      LEN4 = STRLEN( DESCR2 ).
      LEN5 = STRLEN( DESCR3 ).
      LEN6 = STRLEN( DESCR4 ).
      LEN7 = STRLEN( DESCR5 ).
      LEN3 = STRLEN( BUFF ).
      LEN2 = LEN2 + 1 + LEN3 + LEN4 + LEN5 + LEN6 + LEN7.
      IF LEN2 < 51.
        CONCATENATE DESCR1 BUFF INTO DESCR1 SEPARATED BY SPACE.
      ELSEIF LEN4 < 51.
        CONCATENATE DESCR2 BUFF INTO DESCR2 SEPARATED BY SPACE.
      ELSEIF LEN5 < 51.
        CONCATENATE DESCR3 BUFF INTO DESCR3 SEPARATED BY SPACE.
      ELSEIF LEN6 < 51.
        CONCATENATE DESCR4 BUFF INTO DESCR4 SEPARATED BY SPACE.
      ELSE.
        CONCATENATE DESCR5 BUFF INTO DESCR5 SEPARATED BY SPACE.
      ENDIF .
      CLEAR BUFF.
    ENDIF.
    M = M + 1.
  ENDDO.

ENDFORM.                    " SPLIT


*&---------------------------------------------------------------------*
*&      Form  TEKS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TEKS.
  CASE T.
    WHEN 1.
      H = T1.
    WHEN 2.
      H = T2.
    WHEN 3.
      H = T3.
    WHEN 4.
      H = T4.
    WHEN 5.
      H = T5.
    WHEN 6.
      H = T6.
    WHEN 7.
      H = T7.
    WHEN 8.
      H = T8.
    WHEN 9.
      H = T9.
  ENDCASE.
ENDFORM.                    " TEKS

*&---------------------------------------------------------------------*
*&      Form  CONVERTDCETAK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DAT  text
*      -->P_V_DCETAK  text
*----------------------------------------------------------------------*
FORM CONVERTDCETAK  USING    P_DAT
                             P_V_DCETAK.
  DATA : DT(2),
         MT(2),
         YR(4),
         MTT(3),
         DAT(10).
  SPLIT P_DAT AT '.' INTO DT MT YR.
  CASE MT.
    WHEN '01'.
      MTT = 'Jan'.
    WHEN '02'.
      MTT = 'Feb'.
    WHEN '03'.
      MTT = 'Mar'.
    WHEN '04'.
      MTT = 'Apr'.
    WHEN '05'.
      MTT = 'May'.
    WHEN '06'.
      MTT = 'Jun'.
    WHEN '07'.
      MTT = 'Jul'.
    WHEN '08'.
      MTT = 'Aug'.
    WHEN '09'.
      MTT = 'Sep'.
    WHEN '10'.
      MTT = 'Oct'.
    WHEN '11'.
      MTT = 'Nov'.
    WHEN '12'.
      MTT = 'Dec'.
  ENDCASE.
  CONCATENATE DT MTT YR+2(2) INTO P_V_DCETAK SEPARATED BY '-'.
ENDFORM.                    " CONVERTDCETAK

*&---------------------------------------------------------------------*
*&      Form  GET_UPDATED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_UPDATED .
  DATA : ZNO LIKE ZKWIT-ZNO,
         ZPRINT LIKE ZKWIT-ZPRINT.

  LOOP AT IT_KWITANSI.
    CLEAR : ZNO, ZPRINT, V_COMCODE.

    IF IT_KWITANSI-BUKRS = '9999'.
      V_COMCODE = ''.
    ELSE.
      V_COMCODE = IT_KWITANSI-BUKRS.
    ENDIF.

    SELECT SINGLE ZNO ZPRINT
      INTO (ZNO, ZPRINT)
      FROM ZKWIT WHERE ZAWKEY EQ IT_KWITANSI-AWKEY AND TYPEFORM IN (11, 22, 33)
                   AND BUKRS EQ V_COMCODE.

    IF SY-SUBRC = 0.
      IT_KWITANSI-ZNO = ZNO.
      IT_KWITANSI-ZPRINT = ZPRINT.
      IF IT_KWITANSI-ZPRINT > 0.
        IT_KWITANSI-ICON = ICON_LED_GREEN.
      ELSE.
        IT_KWITANSI-ICON = ICON_LED_YELLOW.
      ENDIF.
      MODIFY IT_KWITANSI.
    ENDIF.
  ENDLOOP.

  PERFORM DISPLAY_ALV.
ENDFORM.                    " GET_UPDATED


*&---------------------------------------------------------------------*
*&      Form  DOWNLOADREPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOWNLOADREPORT . " DOWNLOAD TO EXCEL
  TABLES RLGRAP.
  DATA:  DEF_PATH LIKE RLGRAP-FILENAME.
  DATA: TMP_FILENAME LIKE RLGRAP-FILENAME.
  DATA: V_FILENAME TYPE STRING,
        P_FILE LIKE RLGRAP-FILENAME.
  DATA : BEGIN OF IT_KWITREP OCCURS 0,
          ZNO LIKE ZKWIT-ZNO, "Kwitansi No
          BLDAT LIKE BKPF-BLDAT, "Tanggal
          KUNNR LIKE BSID-KUNNR,
          NAME1 LIKE KNA1-NAME1,
          AWKEY LIKE BKPF-AWKEY, "Faktur Dagang
          WAERS LIKE BSID-WAERS,
          WRBTRDPP LIKE BSEG-WRBTR, "USD DPP
          WRBTRPPN LIKE BSEG-WRBTR, "USD PPN
          WRBTRTOT LIKE BSEG-WRBTR, "USD Total
          DMBTRDPP LIKE BSEG-DMBTR, "IDR DPP
          DMBTRPPN LIKE BSEG-DMBTR, "IDR PPN
          DMBTRTOT LIKE BSEG-DMBTR, "IDR Total
         END OF IT_KWITREP.

  CLEAR : P_FILE.
  CLEAR IT_KWITREP. REFRESH IT_KWITREP.

  LOOP AT IT_KWITANSI.
    IT_KWITREP-ZNO  = IT_KWITANSI-ZNO.
    IT_KWITREP-BLDAT = IT_KWITANSI-BLDAT.
    IT_KWITREP-KUNNR = IT_KWITANSI-KUNNR.
    IT_KWITREP-NAME1 = IT_KWITANSI-NAME1.
    IT_KWITREP-AWKEY = IT_KWITANSI-AWKEY.
    IT_KWITREP-WAERS = IT_KWITANSI-WAERS.
    IT_KWITREP-WRBTRDPP = IT_KWITANSI-WRBTRDPP.
    IT_KWITREP-WRBTRPPN = IT_KWITANSI-WRBTRPPN.
    IT_KWITREP-WRBTRTOT = IT_KWITANSI-WRBTRTOT.
    IT_KWITREP-DMBTRDPP = IT_KWITANSI-DMBTRDPP.
    IT_KWITREP-DMBTRPPN = IT_KWITANSI-DMBTRPPN.
    IT_KWITREP-DMBTRTOT = IT_KWITANSI-DMBTRTOT.
    APPEND IT_KWITREP.
  ENDLOOP.
**fill header
  PERFORM ASSIGN_FIELD USING 'Kwitansi No.'.
  PERFORM ASSIGN_FIELD USING 'Tanggal'.
  PERFORM ASSIGN_FIELD USING 'Customer Code'.
  PERFORM ASSIGN_FIELD USING 'Customer Name'.
  PERFORM ASSIGN_FIELD USING 'Faktur Dagang'.
  PERFORM ASSIGN_FIELD USING 'Currency'.
  PERFORM ASSIGN_FIELD USING 'DPP'.
  PERFORM ASSIGN_FIELD USING 'PPN'.
  PERFORM ASSIGN_FIELD USING 'Total'.
  PERFORM ASSIGN_FIELD USING 'IDR DPP'.
  PERFORM ASSIGN_FIELD USING 'IDR PPN'.
  PERFORM ASSIGN_FIELD USING 'IDR Total'.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_FILENAME     = RLGRAP-FILENAME
      DEF_PATH         = DEF_PATH
      MASK             = ',*.xls.'
      MODE             = 'S'
      TITLE            = TEXT-011
    IMPORTING
      FILENAME         = TMP_FILENAME
    EXCEPTIONS
      INV_WINSYS       = 01
      NO_BATCH         = 02
      SELECTION_CANCEL = 03
      SELECTION_ERROR  = 04.
  IF SY-SUBRC = 0.
    RLGRAP-FILENAME = TMP_FILENAME.
  ELSE.
    EXIT.
  ENDIF.

  V_FILENAME = RLGRAP-FILENAME.

  IF V_FILENAME CS '.xls'.
  ELSE.
    CONCATENATE V_FILENAME '.xls'INTO V_FILENAME.
  ENDIF.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      FILENAME              = V_FILENAME
      FILETYPE              = 'ASC'
*     MODE                  = ' '
      WRITE_FIELD_SEPARATOR = 'X'
      CONFIRM_OVERWRITE     = 'X'
      SHOW_TRANSFER_STATUS  = 'X'
*     WK1_N_SIZE            = 30
*     WK1_T_SIZE            = 30
    TABLES
      DATA_TAB              = IT_KWITREP
      FIELDNAMES            = IT_FIELDNAMES.

  IF SY-SUBRC <> 0.
    MESSAGE I000(0K) WITH 'Download error'.
    STOP.
  ENDIF.

ENDFORM.                    " DOWNLOADREPORT

*&---------------------------------------------------------------------*
*&      Form  READMARKED2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READMARKED2 .
  CLEAR CTR.
  LOOP AT IT_KWITANSI WHERE SEL EQ 'X'.
    CLEAR : WA_ITEM, DAT, DEC, DATT.
    CONCATENATE IT_KWITANSI-BLDAT+6(2) IT_KWITANSI-BLDAT+4(2) IT_KWITANSI-BLDAT+0(4) INTO DAT SEPARATED BY '.'.
    PERFORM CONVERTDATE USING DAT DATT.
    CTR = CTR + 1.
    WA_ITEM-ZNO = CTR.
    WA_ITEM-ZFDAGANG = IT_KWITANSI-AWKEY.
    WA_ITEM-WAERS = IT_KWITANSI-WAERS.
    CONCATENATE DATT(6) DATT+9(2) INTO DATT SEPARATED BY '-'.
    WA_ITEM-ZTANGGAL = DATT.
    WA_ITEM-ZUSDPP = IT_KWITANSI-WRBTRDPP.
    WA_ITEM-ZUSPPN = IT_KWITANSI-WRBTRPPN.
    WA_ITEM-ZUSTOT = IT_KWITANSI-WRBTRTOT.
    WA_ITEM-ZIDRDPP = IT_KWITANSI-DMBTRDPP.
    WA_ITEM-ZIDRPPN = IT_KWITANSI-DMBTRPPN.
    WA_ITEM-ZIDRTOT = IT_KWITANSI-DMBTRTOT.
    SHIFT WA_ITEM-ZNO LEFT DELETING LEADING '0'.
    APPEND WA_ITEM TO I_ITEM.
  ENDLOOP.
ENDFORM.                    " READMARKED2

*&---------------------------------------------------------------------*
*&      Form  READMARKED1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READMARKED1 .
  CLEAR CTR.
  LOOP AT IT_KWITANSI WHERE SEL EQ 'X'.
    CLEAR : WA_ITEM, DAT, DEC, DATT.
    CONCATENATE IT_KWITANSI-BLDAT+6(2) IT_KWITANSI-BLDAT+4(2) IT_KWITANSI-BLDAT+0(4) INTO DAT SEPARATED BY '.'.
    PERFORM CONVERTDATE USING DAT DATT.
    CTR = CTR + 1.
    WA_ITEM-ZNO = CTR.
    WA_ITEM-ZFDAGANG = IT_KWITANSI-AWKEY.
    WA_ITEM-WAERS = IT_KWITANSI-WAERS.
    CONCATENATE DATT(6) DATT+9(2) INTO DATT SEPARATED BY '-'.
    WA_ITEM-ZTANGGAL = DATT.
    WA_ITEM-ZUSDPP = IT_KWITANSI-WRBTRDPP.
    WA_ITEM-ZUSPPN = IT_KWITANSI-WRBTRPPN.
    WA_ITEM-ZUSTOT = IT_KWITANSI-WRBTRTOT.
    SHIFT WA_ITEM-ZNO LEFT DELETING LEADING '0'.
    APPEND WA_ITEM TO I_ITEM.
  ENDLOOP.
ENDFORM.                    " READMARKED1


*&---------------------------------------------------------------------*
*&      Form  READMARKED3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READMARKED3 .
  CLEAR CTR.
  LOOP AT IT_KWITANSI WHERE SEL EQ 'X'.
    CLEAR : WA_ITEM, DAT, DEC, DATT.
    CONCATENATE IT_KWITANSI-BLDAT+6(2) IT_KWITANSI-BLDAT+4(2) IT_KWITANSI-BLDAT+0(4) INTO DAT SEPARATED BY '.'.
    PERFORM CONVERTDATE USING DAT DATT.
    CTR = CTR + 1.
    WA_ITEM-ZNO = CTR.
    WA_ITEM-ZFDAGANG = IT_KWITANSI-AWKEY.
    WA_ITEM-WAERS = IT_KWITANSI-WAERS.
    CONCATENATE DATT(6) DATT+9(2) INTO DATT SEPARATED BY '-'.
    WA_ITEM-ZTANGGAL = DATT.
    WA_ITEM-ZIDRDPP = IT_KWITANSI-DMBTRDPP.
    WA_ITEM-ZIDRPPN = IT_KWITANSI-DMBTRPPN.
    WA_ITEM-ZIDRTOT = IT_KWITANSI-DMBTRTOT.
    SHIFT WA_ITEM-ZNO LEFT DELETING LEADING '0'.
    APPEND WA_ITEM TO I_ITEM.
  ENDLOOP.
ENDFORM.                    " READMARKED3

*&---------------------------------------------------------------------*
*&      Form  TERBILANGIDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_TOTIDRPPN  text
*      -->P_V_UANGTXT2  text
*      -->P_2406   text
*----------------------------------------------------------------------*
FORM TERBILANGIDR  USING P_V_TOTUSDPP
                         P_V_UANGTXT1.
  DATA : V_TERBILANG TYPE CHAR255.
  DATA : UANG LIKE SPELL-NUMBER.
  CLEAR: UANG, V_TERBILANG.
  UANG  = P_V_TOTUSDPP.
  PERFORM TERBILANGTXT USING V_TERBILANG UANG.
  CONCATENATE V_TERBILANG 'Rupiah' INTO V_TERBILANG SEPARATED BY SPACE.

  P_V_UANGTXT1 = V_TERBILANG .
ENDFORM.                    " TERBILANGIDR
*&---------------------------------------------------------------------*
*&      Form  CEK_NOKWIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CEK_NOKWIT.
  CLEAR IT_KWITANSITMP. REFRESH IT_KWITANSITMP.
  CLEAR WA_KWITANSI.

  LOOP AT I_ITEM.
    LOOP AT IT_KWITANSI WHERE AWKEY EQ I_ITEM-ZFDAGANG.
      CLEAR WA_KWITANSI.
      WA_KWITANSI = IT_KWITANSI.
      APPEND WA_KWITANSI TO IT_KWITANSITMP.
    ENDLOOP.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM IT_KWITANSITMP COMPARING ZNO.

  IF LINES( IT_KWITANSITMP ) > 1.
    IF SY-UCOMM EQ 'DOCFLOW'.
      MESSAGE 'Anda hanya dapat memilih satu faktur dagang!' TYPE 'E'.
    ELSE.
      MESSAGE 'Anda hanya dapat mencetak 1 nomor kwitansi!' TYPE 'E'.
    ENDIF.
  ENDIF.
ENDFORM.                    " CEK_NOKWIT


*&---------------------------------------------------------------------*
*&      Form  GETF4_NOKWIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETF4_NOKWIT .
  REFRESH GT_KWITNO.
  SELECT ZNO
    INTO CORRESPONDING FIELDS OF TABLE GT_KWITNO
    FROM ZKWIT
    WHERE TYPEFORM IN (11, 22, 33).

  SORT GT_KWITNO BY ZNO ASCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_KWITNO COMPARING ZNO.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZNO'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_KWITNO
      RETURN_TAB      = GT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE GT_RETURN INTO GWA_RETURN INDEX 1.
  IF SY-SUBRC = 0.
    PC_KWTNO = GWA_RETURN-FIELDVAL.
  ENDIF.
ENDFORM.                    " GETF4_NOKWIT


*&---------------------------------------------------------------------*
*&      Form  GETF4_PRNOKWIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETF4_PRNOKWIT .
  REFRESH GT_KWITNO.
  SELECT ZNO
    INTO CORRESPONDING FIELDS OF TABLE GT_KWITNO
    FROM ZKWIT
    WHERE TYPEFORM IN (11, 22, 33).

  SORT GT_KWITNO BY ZNO ASCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_KWITNO COMPARING ZNO.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZNO'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_KWITNO
      RETURN_TAB      = GT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE GT_RETURN INTO GWA_RETURN INDEX 1.
  IF SY-SUBRC = 0.
    PR_KWTNO = GWA_RETURN-FIELDVAL.
  ENDIF.
ENDFORM.                    " GETF4_PRNOKWIT


*&---------------------------------------------------------------------*
*&      Form  GETF4_PCNOKWITL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETF4_PCNOKWITL .
  REFRESH GT_KWITNO.
  SELECT ZNO
    INTO CORRESPONDING FIELDS OF TABLE GT_KWITNO
    FROM ZKWIT
    WHERE TYPEFORM IN (11, 22, 33)
      AND BUKRS IN P_BUKRS2.

  SORT GT_KWITNO BY ZNO ASCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_KWITNO COMPARING ZNO.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZNO'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_KWITNO
      RETURN_TAB      = GT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE GT_RETURN INTO GWA_RETURN INDEX 1.
  IF SY-SUBRC = 0.
    PC_KWTNO-LOW = GWA_RETURN-FIELDVAL.
  ENDIF.
ENDFORM.                    " GETF4_PCNOKWITL

*&---------------------------------------------------------------------*
*&      Form  GETF4_PCNOKWITH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETF4_PCNOKWITH .
  REFRESH GT_KWITNO.
  SELECT ZNO
    INTO CORRESPONDING FIELDS OF TABLE GT_KWITNO
    FROM ZKWIT
    WHERE TYPEFORM IN (11, 22, 33)
      AND BUKRS IN P_BUKRS2.

  SORT GT_KWITNO BY ZNO ASCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_KWITNO COMPARING ZNO.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZNO'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_KWITNO
      RETURN_TAB      = GT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE GT_RETURN INTO GWA_RETURN INDEX 1.
  IF SY-SUBRC = 0.
    PC_KWTNO-HIGH = GWA_RETURN-FIELDVAL.
  ENDIF.
ENDFORM.                    " GETF4_PCNOKWITH


*&---------------------------------------------------------------------*
*&      Form  GETF4_PRNOKWITH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETF4_PRNOKWITH .
  REFRESH GT_KWITNO.
  SELECT ZNO
    INTO CORRESPONDING FIELDS OF TABLE GT_KWITNO
    FROM ZKWIT
    WHERE TYPEFORM IN (11, 22, 33)
      AND BUKRS IN P_BUKRS3.

  SORT GT_KWITNO BY ZNO ASCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_KWITNO COMPARING ZNO.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZNO'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_KWITNO
      RETURN_TAB      = GT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE GT_RETURN INTO GWA_RETURN INDEX 1.
  IF SY-SUBRC = 0.
    PR_KWTNO-HIGH = GWA_RETURN-FIELDVAL.
  ENDIF.
ENDFORM.                    " GETF4_PRNOKWITH

*&---------------------------------------------------------------------*
*&      Form  GETF4_PRNOKWITL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GETF4_PRNOKWITL .
  REFRESH GT_KWITNO.
  SELECT ZNO
    INTO CORRESPONDING FIELDS OF TABLE GT_KWITNO
    FROM ZKWIT
    WHERE TYPEFORM IN (11, 22, 33)
      AND BUKRS IN P_BUKRS3.

  SORT GT_KWITNO BY ZNO ASCENDING.
  DELETE ADJACENT DUPLICATES FROM GT_KWITNO COMPARING ZNO.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'ZNO'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = GT_KWITNO
      RETURN_TAB      = GT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE GT_RETURN INTO GWA_RETURN INDEX 1.
  IF SY-SUBRC = 0.
    PR_KWTNO-LOW = GWA_RETURN-FIELDVAL.
  ENDIF.
ENDFORM.                    " GETF4_PRNOKWITL

*&---------------------------------------------------------------------*
*&      Form  GETF4_AC_NAMA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GETF4_AC_NAMA.
  REFRESH IT_AC.
  CLEAR IT_AC.
  DATA : TXT LIKE T012T-TEXT1.

  SELECT T012K~BUKRS T012K~BANKN T012K~HBKID
    INTO CORRESPONDING FIELDS OF TABLE IT_AC
    FROM T012K.

  LOOP AT IT_AC.

    SELECT T012T~TEXT1
      INTO TXT
      FROM T012T
      WHERE
      T012T~BUKRS EQ IT_AC-BUKRS AND
      T012T~HBKID EQ IT_AC-HBKID.
    ENDSELECT.
    IT_AC-TEXT1 = TXT.

    MODIFY IT_AC.
    CLEAR TXT.
  ENDLOOP.


  DELETE ADJACENT DUPLICATES FROM IT_AC COMPARING BANKN.
  SORT IT_AC BY BUKRS ASCENDING.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'BANKN'
      VALUE_ORG       = 'S'
    TABLES
      VALUE_TAB       = IT_AC
      RETURN_TAB      = GT_AC
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE GT_AC INTO GWA_AC INDEX 1.
  IF SY-SUBRC = 0.
    AC_NAMA = GWA_AC-FIELDVAL.
  ENDIF.

ENDFORM.                    "GETF4_AC_NAMA

*&---------------------------------------------------------------------*
*&      Form  UPDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_DATA .
  LOOP AT I_ITEM.
    CLEAR : WA_KWITANSI.
    LOOP AT IT_KWITANSI WHERE AWKEY = I_ITEM-ZFDAGANG.
      CLEAR : WA_ZKWIT,ZPRINT, ZSEQ, IT_ZKWIT, V_COMCODE. REFRESH IT_ZKWIT.

      IF IT_KWITANSI-BUKRS = '9999'.
        V_COMCODE = ''.
        WA_ZKWIT-BUKRS = ''.
      ELSE.
        V_COMCODE = IT_KWITANSI-BUKRS.
        WA_ZKWIT-BUKRS = IT_KWITANSI-BUKRS.
      ENDIF.

*     tambah pengecekan agar nomor tidak counter teruss
*      SELECT SINGLE ZNO INTO (WA_ZKWIT-ZNO ) FROM ZKWIT
*        WHERE ZAWKEY = IT_KWITANSI-AWKEY AND TYPEFORM IN (11, 22, 33) AND BUKRS = V_COMCODE.
*      IF SY-SUBRC <> 0.
*        WA_ZKWIT-ZNO = NOKWIT.
*      ENDIF.
      WA_ZKWIT-ZNO = NOKWIT.
      WA_ZKWIT-KUNNR = IT_KWITANSI-KUNNR.
      WA_ZKWIT-ZAWKEY = IT_KWITANSI-AWKEY.
      WA_ZKWIT-GJAHR = IT_KWITANSI-GJAHR.
      WA_ZKWIT-ZBLDAT = IT_KWITANSI-BLDAT.
      WA_ZKWIT-WAERS  = IT_KWITANSI-WAERS.
      WA_ZKWIT-HWRBTR = IT_KWITANSI-WRBTRDPP.
      WA_ZKWIT-IWRBTR = IT_KWITANSI-WRBTRPPN.
      WA_ZKWIT-KDMBTR = IT_KWITANSI-DMBTRDPP.
      WA_ZKWIT-LDMBTR = IT_KWITANSI-DMBTRPPN.
      WA_ZKWIT-BLART = IT_KWITANSI-BLART.
      WA_ZKWIT-TYPEFORM = TYPEFORM.
      WA_ZKWIT-PNT = V_NAMA.

      SELECT SINGLE ZPRINT ZSEQ
        INTO (ZPRINT , ZSEQ)
        FROM ZKWIT
        WHERE ZAWKEY = WA_ZKWIT-ZAWKEY AND TYPEFORM IN (11, 22, 33)
          AND BUKRS = V_COMCODE.

      WA_ZKWIT-ZPRINT = ZPRINT + 1.
*      WA_ZKWIT-ZSTAT = WA_KWITANSI-ZSTAT.
      APPEND WA_ZKWIT TO IT_ZKWIT.

      IF IT_KWITANSI-ZNO EQ '' AND ( IT_KWITANSI-ZPRINT <= 0 OR IT_KWITANSI-ZPRINT EQ '000000000000' OR IT_KWITANSI-ZPRINT EQ '' AND SEQ = 0 ).
        WA_ZKWIT-ZPRINT = WA_KWITANSI-ZPRINT + 1.
        WA_ZKWIT-KEYDATE = V_DATEKW.
        SHIFT WA_ZKWIT-ZPRINT LEFT DELETING LEADING '0'.
        INSERT INTO ZKWIT VALUES WA_ZKWIT.
        COMMIT WORK AND WAIT.
      ELSE.
        WA_ZKWIT-ZSEQ = ZSEQ.
        WA_ZKWIT-KEYDATE = V_DATEKW.
        UPDATE ZKWIT FROM WA_ZKWIT.
        COMMIT WORK AND WAIT.
      ENDIF.
      IT_KWITANSI-ZNO = NOKWIT.
      MODIFY IT_KWITANSI.
      FLAG = 'X'.
    ENDLOOP.
  ENDLOOP.

  IF MYTAB-DYNNR = 100.
*    UPDATE ZKWIT SET ZSEQ = SEQ WHERE ZAWKEY NE '' AND TYPEFORM NE 2.
    UPDATE ZKWIT SET ZSEQ = SEQ WHERE ZAWKEY NE '' AND TYPEFORM NE 2 AND BUKRS = V_COMCODE AND ZNO = NOKWIT.
    COMMIT WORK AND WAIT.
  ENDIF.
ENDFORM.                    " UPDATE_DATA

*&---------------------------------------------------------------------*
*&      Form  CONVERTIDR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONVERTIDR .
  CHECK IT_KWITANSI[] IS NOT INITIAL.
  LOOP AT IT_KWITANSI.
    CLEAR : IT_KWITANSI-TDMBTRDPP, IT_KWITANSI-TDMBTRPPN, IT_KWITANSI-TDMBTRTOT.
    IF IT_KWITANSI-WAERS = 'IDR'.
      WRITE IT_KWITANSI-WRBTRDPP TO IT_KWITANSI-TWRBTRDPP EXPONENT 0 DECIMALS 0.
      WRITE IT_KWITANSI-WRBTRPPN TO IT_KWITANSI-TWRBTRPPN EXPONENT 0 DECIMALS 0.
      WRITE IT_KWITANSI-WRBTRTOT TO IT_KWITANSI-TWRBTRTOT EXPONENT 0 DECIMALS 0.
    ELSE.
      WRITE IT_KWITANSI-WRBTRDPP TO IT_KWITANSI-TWRBTRDPP EXPONENT 0 DECIMALS 2.
      WRITE IT_KWITANSI-WRBTRPPN TO IT_KWITANSI-TWRBTRPPN EXPONENT 0 DECIMALS 2.
      WRITE IT_KWITANSI-WRBTRTOT TO IT_KWITANSI-TWRBTRTOT EXPONENT 0 DECIMALS 2.
    ENDIF.
    WRITE IT_KWITANSI-DMBTRDPP TO IT_KWITANSI-TDMBTRDPP EXPONENT 0 DECIMALS 0.
    WRITE IT_KWITANSI-DMBTRPPN TO IT_KWITANSI-TDMBTRPPN EXPONENT 0 DECIMALS 0.
    WRITE IT_KWITANSI-DMBTRTOT TO IT_KWITANSI-TDMBTRTOT EXPONENT 0 DECIMALS 0.
    MODIFY IT_KWITANSI.
  ENDLOOP.
ENDFORM.                    " CONVERTIDR


*&---------------------------------------------------------------------*
*&      Form  ASSIGN_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ASSIGN_FIELD USING FTEXT.
  IT_FIELDNAMES-FIELD = FTEXT.
  APPEND IT_FIELDNAMES.
  CLEAR  IT_FIELDNAMES.
ENDFORM.                    " ASSIGN_FIELD


*&---------------------------------------------------------------------*
*&      Form  f_select_data_sd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECT_DATA_SD .
  DATA: VROUND TYPE  P LENGTH 13 DECIMALS 2.  "like vbrk-MWSBK. "u/ pembulatan 2 digit.
  DATA : KUNRG TYPE VBRK-KUNRG.
  DATA : D0 TYPE P LENGTH 13 DECIMALS 0,
         D2 TYPE P LENGTH 13 DECIMALS 2.

  CLEAR KUNRG.
  KUNRG = PK_KUNNR.

  CLEAR : IVBRP.
  REFRESH : IVBRP.

  SELECT A~VBELN A~GJAHR B~POSNR A~FKDAT A~KUNRG A~WAERK A~FKART
         B~NETWR B~VGBEL B~VGPOS B~FKIMG B~AUBEL B~AUPOS C~NETPR
         C~KPEIN A~KUNRG C~VRKME A~BUKRS
  INTO TABLE IVBRP
  FROM ( VBRK AS A JOIN VBRP AS B ON A~VBELN EQ B~VBELN ) LEFT JOIN VBAP AS C ON B~AUBEL EQ C~VBELN AND B~AUPOS EQ C~POSNR
  WHERE A~VBELN IN VBELN AND A~FKDAT IN PK_BLDAT AND A~FKSTO EQ SPACE AND ( A~VBTYP = 'M' OR A~VBTYP = 'O' ) AND
        A~TAXK1 <> 0 AND A~KUNRG = KUNRG AND A~BUKRS IN P_BUKRS.
*        and a~gjahr in gjahr.
*        A~VBELN IN VBELN.

  IF IVBRP[] IS INITIAL.
    MESSAGE 'Data tidak ditemukan..!' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

  CLEAR : ILIPS. REFRESH :ILIPS.
  SELECT VBELN POSNR CHARG LFIMG VRKME BRGEW NTGEW UECHA CUOBJ INTO TABLE ILIPS FROM LIPS
    FOR ALL ENTRIES IN IVBRP WHERE VBELN = IVBRP-VGBEL
    %_HINTS ORACLE 'INDEX(LIPS"Z01")'.

  IF MYTAB-DYNNR = 100 AND ROT1 = 'X'.
    DELETE IVBRP WHERE WAERS NE 'USD'.
  ELSEIF MYTAB-DYNNR = 100 AND ROT2 = 'X'.
    DELETE IVBRP WHERE WAERS NE 'USD'.
  ELSEIF MYTAB-DYNNR = 100 AND ROT3 = 'X'.
    DELETE IVBRP WHERE WAERS NE 'IDR'.
  ENDIF.

  CLEAR: RECORD, TOTAL.
  DESCRIBE TABLE IVBRP LINES TOTAL.

  CLEAR ITAB2. REFRESH ITAB2.
  LOOP AT IVBRP.
*    Informasi data progress dalam prosentase
    ADD 1 TO RECORD.
    CONCATENATE 'Processing record no. : ' RECORD '/' TOTAL INTO TEXT.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = 100
        TEXT       = TEXT.

    CLEAR ITAB2.
    CLEAR WA_KWITANSI.

    ITAB2-BUDAT  =  IVBRP-FKDAT.
    ITAB2-BELNR  =  IVBRP-VBELN.
    ITAB2-GJAHR = IVBRP-GJAHR.
    ITAB2-POSNR  =  IVBRP-POSNR.
    ITAB2-KUNNR  =  IVBRP-KUNNR.
    ITAB2-WAERS  =  IVBRP-WAERS.
    ITAB2-FKART  =  IVBRP-FKART.
    ITAB2-NETPR  =  IVBRP-NETPR / IVBRP-KPEIN.
    ITAB2-VRKME  =  IVBRP-VRKME.
    ITAB2-FKIMG = ROUND( VAL = IVBRP-FKIMG DEC = 2 ).
    ITAB2-BUKRS = IVBRP-BUKRS.

    PERFORM GET_PPN.
    ITAB2-PPN_PRC = V_PPN_PRC.

    CLEAR: RFMNG, TEMP.
    LOOP AT ILIPS WHERE VBELN = IVBRP-VGBEL AND LFIMG GT 0.
      CLEAR: RFMNG, TEMP.
      CHECK ILIPS-POSNR = IVBRP-VGPOS OR ILIPS-UECHA = IVBRP-VGPOS.

      IF ILIPS-CHARG NE ''.
        PERFORM FILL_QTY.
        IF ILIPS-VRKME = 'KG'.
          ITAB2-QTY   =  ITAB2-QTY + RFMNG.
          ITAB2-BRGEW = ITAB2-BRGEW + RFMNG.
        ELSE.
          ITAB2-QTY   =  ITAB2-QTY + SATUAN.
          ITAB2-BRGEW = ITAB2-BRGEW + RFMNG.
        ENDIF.
      ELSE.
        ITAB2-QTY   =  ITAB2-QTY + ILIPS-LFIMG.
        ITAB2-BRGEW = ITAB2-BRGEW + ILIPS-BRGEW.
      ENDIF.
    ENDLOOP.

    SELECT SINGLE NAME1 STCEG INTO (ITAB2-NAME1, ITAB2-NPWP) FROM KNA1 WHERE KUNNR = IVBRP-KUNRG.
    REPLACE ALL OCCURRENCES OF '.' IN ITAB2-NPWP WITH ''.
    REPLACE ALL OCCURRENCES OF '-' IN ITAB2-NPWP WITH ''.

    ITAB2-VGBEL = IVBRP-VGBEL.
    ITAB2-WRBTR = ( IVBRP-NETPR / IVBRP-KPEIN ) * ITAB2-QTY.

    CLEAR: BELNR, ITAB2-BLART.
    SELECT SINGLE BLART INTO ITAB2-BLART
            FROM BSID
            WHERE VBELN =  IVBRP-VBELN AND
                  BLART IN ('RV', 'RX', 'RK', 'RL').
    IF ITAB2-BLART EQ ''.
      SELECT SINGLE BLART INTO ITAB2-BLART
        FROM BSAD
        WHERE VBELN =  IVBRP-VBELN AND
        BLART IN ('RV', 'RX', 'RK', 'RL').
    ENDIF.

    IF ITAB2-BLART NE ''.
      APPEND ITAB2.
    ENDIF.
  ENDLOOP.

  CLEAR IT_KWITANSI. REFRESH IT_KWITANSI.

  LOOP AT ITAB2.
    CLEAR : V_RATE, V_WAERS.
*    v_rate = itab2-kursk.
    CALL FUNCTION 'BAPI_EXCHANGERATE_GETDETAIL'
      EXPORTING
        RATE_TYPE  = 'M'
        FROM_CURR  = ITAB2-WAERS
        TO_CURRNCY = 'IDR'
        DATE       = ITAB2-BUDAT
      IMPORTING
        EXCH_RATE  = V_RATE.
    IF SY-SUBRC <> 0.
      MESSAGE I000(0K) WITH 'Currency Exchange Rates  Error!'.
      STOP.
    ENDIF.

    IF ITAB2-WAERS = 'IDR' OR ITAB2-WAERS = 'JPY'.
      IF ITAB2-WAERS <> 'IDR'.
        ITAB2-DMBTR = (  V_RATE-EXCH_RATE * ( V_RATE-FROM_FACTOR * V_RATE-TO_FACTOR ) * 100 )
                      * ITAB2-WRBTR.
      ELSE.
        ITAB2-DMBTR = V_RATE-EXCH_RATE * ITAB2-WRBTR * 100.
      ENDIF.
    ELSE.
      ITAB2-DMBTR = (  V_RATE-EXCH_RATE * ( V_RATE-FROM_FACTOR * V_RATE-TO_FACTOR ) )
                    * ITAB2-WRBTR.
    ENDIF.
    ITAB2-RATE = V_RATE-EXCH_RATE.

***    FILL KWITANSI

    CLEAR : V_NETWR, V_KNUMV, V_KBETR, V_KPEIN,
            ZKPEIN, ZWAERS, ZNETWR, ZZKPEIN, ZNETWR1.
    CLEAR WA_KWITANSI.
    SELECT SINGLE VBRK~KNUMV
          INTO V_KNUMV
          FROM VBRK
          WHERE VBRK~VBELN = ITAB2-BELNR.

    V_WAERS = ITAB2-WAERS.
    IF ITAB2-FKART EQ 'ZDSF' OR
       ITAB2-FKART EQ 'ZDSN' OR
       ITAB2-FKART EQ 'ZDSV'.
      SELECT SINGLE KONV~KBETR KONV~KPEIN KONV~WAERS
      INTO (V_KBETR, V_KPEIN, ZWAERS)
      FROM KONV
      WHERE KONV~KNUMV = V_KNUMV
        AND KONV~KPOSN = ITAB2-POSNR
        AND KONV~KSCHL IN ('ZSCW', 'ZSCR', 'ZCSV')
        AND KONV~KBETR <> 0
        AND KONV~KINAK NE 'Y'.

    ELSEIF ITAB2-FKART EQ 'ZDIN' OR
           ITAB2-FKART EQ 'ZEIN' OR
           ITAB2-FKART EQ 'ZDG2' OR
           ITAB2-FKART EQ 'ZEG2' OR
           ITAB2-FKART EQ 'ZERE' OR
           ITAB2-FKART EQ 'ZDSI' OR "Add by Fany at 15-May-2025 for Laminator Subcont Project
           ITAB2-FKART EQ 'ZDRE'.
      SELECT SINGLE KONV~KBETR KONV~KPEIN KONV~WAERS
      INTO (V_KBETR, V_KPEIN, ZWAERS)
      FROM KONV
      WHERE KONV~KNUMV = V_KNUMV
        AND KONV~KPOSN = ITAB2-POSNR
        AND KONV~KSCHL IN ('ZD00', 'ZDD0', 'ZE00', 'ZED0')
        AND KONV~KBETR <> 0
        AND KONV~KINAK NE 'Y'.
    ENDIF.
    "- Length KPEIN
    ZZKPEIN = V_KPEIN.
    CONDENSE ZZKPEIN NO-GAPS.
    ZCOUNT = STRLEN( ZZKPEIN ) - 1.

    CLEAR : ZKPEIN, ZNETWR, ZZTOT.
    ZNETWR = V_KBETR.
    PERFORM AMOUNT USING ZWAERS ZNETWR.
    "- Price Currency
    IF ITAB2-WAERS EQ 'IDR'.
      V_IDR = V_NETWR / V_KPEIN.
      WRITE V_IDR TO ZZTOT.
    ELSE.
      IF ZCOUNT = 0 OR ZCOUNT = 1 OR ZCOUNT = 2.
        V_DEC2 = V_NETWR / V_KPEIN.
        WRITE V_DEC2 TO ZZTOT.
      ELSEIF ZCOUNT = 3.
        V_DEC3 = V_NETWR / V_KPEIN.
        WRITE V_DEC3 TO ZZTOT.
      ELSEIF ZCOUNT = 4.
        V_DEC4 = V_NETWR / V_KPEIN.
        WRITE V_DEC4 TO ZZTOT.
      ELSEIF ZCOUNT = 5.
        V_DEC5 = V_NETWR / V_KPEIN.
        WRITE V_DEC5 TO ZZTOT.
      ENDIF.
    ENDIF.

    ZKPEIN = V_NETWR / V_KPEIN.
    CONDENSE ZZTOT NO-GAPS.
    "- Total Currency
*    PERFORM GET_EXCHANGE_RATE USING V_WAERS ZWAERS.
    ZNETWR1 = ZKPEIN * ITAB2-FKIMG.

    "- Total USD
    IF ITAB2-WAERS EQ 'USD'.
      ITAB2-WRBTR = ZNETWR1.
    ELSEIF ITAB2-WAERS EQ 'IDR'.
      ITAB2-WRBTR = ZNETWR1.
    ELSE.
*      PERFORM GET_EXCHANGE_RATE USING 'USD' V_WAERS.
      ITAB2-WRBTR = ZNETWR1 * ITAB2-RATE. "V_EXCHR.
    ENDIF.

    IF ROT1 EQ 'X'.
*      ITAB2-WRBTRPPN = ITAB2-WRBTR * 10 / 100.
      ITAB2-WRBTRPPN = ITAB2-WRBTR * ITAB2-PPN_PRC.
      ITAB2-WRBTRTOT = ITAB2-WRBTR + ITAB2-WRBTRPPN.
    ELSEIF ROT2 EQ 'X'.
*      ITAB2-WRBTRPPN = ITAB2-WRBTR * 10 / 100.
      ITAB2-WRBTRPPN = ITAB2-WRBTR * ITAB2-PPN_PRC.
      ITAB2-WRBTRTOT = ITAB2-WRBTR + ITAB2-WRBTRPPN.
      ITAB2-DMBTRDPP = ITAB2-WRBTR * ITAB2-RATE * V_RATE-TO_FACTOR.
      CLEAR: D0, D2.
      D0 = ITAB2-DMBTRDPP.
      ITAB2-DMBTRDPP = D0.
*      D2 = D0 * 10 / 100.
      D2 = D0 * ITAB2-PPN_PRC.
      CLEAR D0.
      D0 = D2.
      ITAB2-DMBTRPPN = D0. "itab2-DMBTRDPP * 10 / 100. "
      ITAB2-DMBTRTOT = ITAB2-DMBTRDPP + ITAB2-DMBTRPPN.
    ELSEIF ROT3 EQ 'X'.
      ITAB2-DMBTRDPP = ITAB2-WRBTR.
      CLEAR: D0, D2.
      D0 = ITAB2-DMBTRDPP.
      ITAB2-DMBTRDPP = D0.
*      D2 = D0 * 10 / 100.
      D2 = D0 * ITAB2-PPN_PRC.
      CLEAR D0.
      D0 = D2.
      ITAB2-DMBTRPPN = D0.
*      itab2-DMBTRPPN = itab2-DMBTRDPP * 10 / 100.
      ITAB2-DMBTRTOT = ITAB2-DMBTRDPP + ITAB2-DMBTRPPN.

      " Added by William at 24.02.2025 (case rounding)
      ITAB2-DMBTRDPP_1 = ITAB2-WRBTR.
      ITAB2-DMBTRPPN_1 = ITAB2-DMBTRDPP_1 * ITAB2-PPN_PRC.
      ITAB2-DMBTRTOT_1 = ITAB2-DMBTRDPP_1 + ITAB2-DMBTRPPN_1.
      " End added by William at 24.02.2025 (case rounding)
    ENDIF.
    MODIFY ITAB2 TRANSPORTING NAME1 RATE WRBTR DMBTR WRBTRPPN WRBTRTOT DMBTRDPP DMBTRPPN DMBTRTOT
                              DMBTRDPP_1 DMBTRPPN_1 DMBTRTOT_1 " Added by William at 24.02.2025 (case rounding)
    WHERE BELNR = ITAB2-BELNR AND POSNR = ITAB2-POSNR.
  ENDLOOP.

  IF ITAB2[] IS NOT INITIAL.
    LOOP AT ITAB2.
      WA_KWITANSI-AWKEY = ITAB2-BELNR.
      WA_KWITANSI-GJAHR = ITAB2-GJAHR.
      WA_KWITANSI-BLART = ITAB2-BLART.
      WA_KWITANSI-BLDAT = ITAB2-BUDAT.
      WA_KWITANSI-WAERS = ITAB2-WAERS.
*      WA_KWITANSI-SHKZG = ITAB2-SHKZG.
      WA_KWITANSI-KUNNR = ITAB2-KUNNR.
      WA_KWITANSI-NAME1 = ITAB2-NAME1.
      WA_KWITANSI-KURSK = ITAB2-RATE.
      WA_KWITANSI-BUKRS = ITAB2-BUKRS.

      WA_KWITANSI-PPN_PRC = ITAB2-PPN_PRC.

      IF ITAB2-BLART = 'RL'.
        WA_KWITANSI-WRBTRDPP = ITAB2-WRBTR * -1.
        WA_KWITANSI-WRBTRPPN = ITAB2-WRBTRPPN * -1.
        WA_KWITANSI-WRBTRTOT = ITAB2-WRBTRTOT * -1.
        WA_KWITANSI-DMBTRDPP = ITAB2-DMBTRDPP * -1.
        WA_KWITANSI-DMBTRPPN = ITAB2-DMBTRPPN * -1.
        WA_KWITANSI-DMBTRTOT = ITAB2-DMBTRTOT * -1.
        WA_KWITANSI-DMBTRDPP_1 = ITAB2-DMBTRDPP_1 * -1.
        WA_KWITANSI-DMBTRPPN_1 = ITAB2-DMBTRPPN_1 * -1.
        WA_KWITANSI-DMBTRTOT_1 = ITAB2-DMBTRTOT_1 * -1.
      ELSE.
        WA_KWITANSI-WRBTRDPP = ITAB2-WRBTR.
        WA_KWITANSI-WRBTRPPN = ITAB2-WRBTRPPN.
        WA_KWITANSI-WRBTRTOT = ITAB2-WRBTRTOT.
        WA_KWITANSI-DMBTRDPP = ITAB2-DMBTRDPP.
        WA_KWITANSI-DMBTRPPN = ITAB2-DMBTRPPN.
        WA_KWITANSI-DMBTRTOT = ITAB2-DMBTRTOT.
        WA_KWITANSI-DMBTRDPP_1 = ITAB2-DMBTRDPP_1.
        WA_KWITANSI-DMBTRPPN_1 = ITAB2-DMBTRPPN_1.
        WA_KWITANSI-DMBTRTOT_1 = ITAB2-DMBTRTOT_1.
      ENDIF.
      WA_KWITANSI-ICON = ICON_LED_YELLOW.
      APPEND WA_KWITANSI TO IT_KWITANSI.
    ENDLOOP.
  ENDIF.

  DATA : IT_KWITANSIT LIKE STANDARD TABLE OF IT_KWITANSI WITH HEADER LINE.
  CLEAR IT_KWITANSIT. REFRESH IT_KWITANSIT.
  IT_KWITANSIT[] = IT_KWITANSI[].

  SORT IT_KWITANSI BY AWKEY ASCENDING.
  DELETE ADJACENT DUPLICATES FROM IT_KWITANSI COMPARING AWKEY.
  LOOP AT IT_KWITANSI.
*    CLEAR : IT_KWITANSI-WRBTRDPP, IT_KWITANSI-WRBTRPPN, IT_KWITANSI-WRBTRTOT,
*            IT_KWITANSI-DMBTRDPP,
*            IT_KWITANSI-DMBTRPPN, IT_KWITANSI-DMBTRTOT.
*    LOOP AT IT_KWITANSIT WHERE AWKEY = IT_KWITANSI-AWKEY.
*      IT_KWITANSI-WRBTRDPP = IT_KWITANSI-WRBTRDPP + IT_KWITANSIT-WRBTRDPP.
**      IT_KWITANSI-WRBTRPPN = IT_KWITANSI-WRBTRPPN + IT_KWITANSIT-WRBTRPPN.
*      IT_KWITANSI-WRBTRTOT = IT_KWITANSI-WRBTRTOT + IT_KWITANSIT-WRBTRTOT.
*      IT_KWITANSI-DMBTRDPP = IT_KWITANSI-DMBTRDPP + IT_KWITANSIT-DMBTRDPP.
**      IT_KWITANSI-DMBTRPPN = IT_KWITANSI-DMBTRPPN + IT_KWITANSIT-DMBTRPPN.
*      IT_KWITANSI-DMBTRTOT = IT_KWITANSI-DMBTRTOT + IT_KWITANSIT-DMBTRTOT.
*    ENDLOOP.
**    IT_KWITANSI-WRBTRPPN = ( 10 / 100 ) * IT_KWITANSI-WRBTRDPP.
*    IT_KWITANSI-WRBTRPPN = IT_KWITANSI-PPN_PRC * IT_KWITANSI-WRBTRDPP.
**    IT_KWITANSI-DMBTRPPN = ( 10 / 100 ) * IT_KWITANSI-DMBTRDPP.
*    IT_KWITANSI-DMBTRPPN = IT_KWITANSI-PPN_PRC * IT_KWITANSI-DMBTRDPP.
*    IT_KWITANSI-DMBTRPPN = FLOOR( IT_KWITANSI-DMBTRPPN ).   " Rounded PPN

    PERFORM GET_TOTAL TABLES IT_KWITANSIT.

    MODIFY IT_KWITANSI.
  ENDLOOP.

*  CHECK NOKWIT
  LOOP AT IT_KWITANSI.
    CLEAR : ZNO, ZPRINT, V_COMCODE.

    IF IT_KWITANSI-BUKRS = '9999'.
      V_COMCODE = ''.
    ELSE.
      V_COMCODE = IT_KWITANSI-BUKRS.
    ENDIF.

    SELECT SINGLE ZNO ZPRINT
       INTO (ZNO, ZPRINT)
       FROM ZKWIT WHERE ZAWKEY EQ IT_KWITANSI-AWKEY AND TYPEFORM IN (11, 22, 33)
                    AND BUKRS = V_COMCODE.

    IF ZNO NE ''.
      DELETE IT_KWITANSI.
      CONTINUE.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " f_select_data_sd


*&---------------------------------------------------------------------
*&      Fill Qty base on Conversion
*&---------------------------------------------------------------------
FORM FILL_QTY.
  CLEAR ZCONV.
  PERFORM GET_CONV_VALUES USING ILIPS-CUOBJ.
  CLEAR SATUAN.
  IF ZCONV > 1.
    SATUAN = ILIPS-NTGEW / ZCONV.
  ENDIF.
  IF SATUAN > 1.
    TEMP = ZCONV.
    TEMP = TEMP * SATUAN.
    RFMNG = RFMNG + TEMP.
  ELSE.
    TEMP = ILIPS-NTGEW.
    RFMNG = RFMNG + TEMP.
  ENDIF.
ENDFORM.                    "fill_qty

*&---------------------------------------------------------------------
*&      Get Characteristic Value
*&---------------------------------------------------------------------
FORM GET_CONV_VALUES USING ILIPS-CUOBJ.
* 0000001227 -> ZZCONVERSIONROLLKG
  SELECT SINGLE C~ATFLV INTO ZCONV
    FROM ( IBIN AS A JOIN IBINVALUES AS B ON A~IN_RECNO EQ B~IN_RECNO )
    JOIN IBSYMBOL AS C ON C~SYMBOL_ID EQ B~SYMBOL_ID
   WHERE A~INSTANCE EQ ILIPS-CUOBJ AND  C~ATINN EQ '0000001227'.  "in Production
*    where a~instance eq ilips-cuobj and c~atinn eq '0000001225'.   "in Development

* 0000000856 -> ZZCONVERSIONMTRKG
  IF SY-SUBRC NE 0.
    SELECT SINGLE C~ATFLV INTO ZCONV
   FROM ( IBIN AS A JOIN IBINVALUES AS B ON A~IN_RECNO EQ B~IN_RECNO )
   JOIN IBSYMBOL AS C ON C~SYMBOL_ID EQ B~SYMBOL_ID
  WHERE A~INSTANCE EQ ILIPS-CUOBJ AND  C~ATINN EQ '0000000856'.  "in Production
*    where a~instance eq ilips-cuobj and c~atinn eq '0000001225'.   "in Development
  ENDIF.
ENDFORM.                    "get_conv_values

*&---------------------------------------------------------------------*
*&      Form  F_SELECT_DATA_FI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_SELECT_DATA_FI .
  DATA : ZSEQ LIKE ZKWIT-ZSEQ,
         ZNO LIKE ZKWIT-ZNO,
         ZPRINT LIKE ZKWIT-ZPRINT,
         AMOUNT_INTERNAL  LIKE  WMTO_S-AMOUNT,
         AMOUNT_TODISPLAY LIKE  WMTO_S-AMOUNT,
         BELNR LIKE BSID-BELNR,
         HWBAS LIKE BSET-HWBAS, "DPP IDR
         HWSTE LIKE BSET-HWSTE, "PPN IDR
         FWBAS LIKE BSET-FWBAS, "USD DPP/ IDR PPN
         FWSTE LIKE BSET-FWSTE, "PPN USD
         SHKZG LIKE BSET-SHKZG,
         MWSKZ LIKE BSET-MWSKZ,
         VAWKEY(10),
         V_COMPANY(4).

  CLEAR IT_KWITANSI[].
  REFRESH IT_KWITANSI[].

  CLEAR : ZSEQ, ZNO, VAWKEY, V_COMPANY.

  IF MYTAB-DYNNR = 100.
    SELECT BKPF~AWKEY BSID~BLART BKPF~BLDAT BSID~KUNNR
           BSID~WAERS BSID~BELNR BSID~BUKRS BKPF~GJAHR
      INTO CORRESPONDING FIELDS OF TABLE IT_KWITANSI
      FROM BKPF JOIN BSID ON BKPF~BELNR = BSID~BELNR
      WHERE BKPF~BLDAT IN PKBLDATF "PK_BLDAT
           AND BSID~KUNNR = PK_KUNNR
           AND BKPF~GJAHR IN PKGJAHRF
           AND BSID~BELNR IN PK_BELNR
           AND BSID~BLART IN ('DG', 'DH', 'DR', 'DS') "'RX', 'RV', 'RK', 'RL', (SD)
           AND BKPF~BUKRS IN P_BUKRS.

    IF IT_KWITANSI[] IS INITIAL.
      MESSAGE 'Data tidak ditemukan..!' TYPE 'I'.
      LEAVE LIST-PROCESSING.
    ENDIF.

    SORT IT_KWITANSI BY AWKEY.
    LOOP AT IT_KWITANSI.
      CLEAR : ZNO, ZSEQ, ZPRINT, AMOUNT_INTERNAL, AMOUNT_TODISPLAY,
              HWBAS, HWSTE, FWBAS, FWSTE, SHKZG, MWSKZ, V_COMCODE.
      IT_KWITANSI-AWKEY = IT_KWITANSI-AWKEY(10).

      IF IT_KWITANSI-BUKRS = '9999'.
        V_COMCODE = ''.
      ELSE.
        V_COMCODE = IT_KWITANSI-BUKRS.
      ENDIF.

      SELECT SINGLE ZNO ZPRINT
        INTO (ZNO, ZPRINT)
        FROM ZKWIT WHERE ZAWKEY EQ IT_KWITANSI-AWKEY AND TYPEFORM IN (11, 22, 33)
                     AND BUKRS EQ V_COMCODE.
*                     AND BUKRS EQ IT_KWITANSI-BUKRS.

      IF ZNO NE ''.
        DELETE IT_KWITANSI.
        CONTINUE.
      ELSE.
*        isi kolom amount berdasarkan selection screen
        SELECT SINGLE FWBAS FWSTE HWBAS HWSTE SHKZG MWSKZ
          INTO (FWBAS, FWSTE, HWBAS, HWSTE, SHKZG, MWSKZ)
          FROM BSET
          WHERE BELNR EQ IT_KWITANSI-BELNR AND
                GJAHR EQ IT_KWITANSI-GJAHR AND "SY-DATUM(4) AND
                BUKRS EQ IT_KWITANSI-BUKRS AND
*                    MWSKZ IN ('C3', 'C2') AND
                KTOSL EQ 'MWS'.

*cek debit atau credit
        IF MWSKZ EQ 'C2' OR MWSKZ EQ 'C3'.
          FWBAS = FWBAS * -1.
        ENDIF.

        IF IT_KWITANSI-WAERS EQ 'IDR'.
          CLEAR : AMOUNT_INTERNAL, AMOUNT_TODISPLAY.
          AMOUNT_INTERNAL = FWBAS.
          CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
            EXPORTING
              CURRENCY        = 'IDR'
              AMOUNT_INTERNAL = AMOUNT_INTERNAL
            IMPORTING
              AMOUNT_DISPLAY  = AMOUNT_TODISPLAY
            EXCEPTIONS
              INTERNAL_ERROR  = 1
              OTHERS          = 2.
          IF SY-SUBRC <> 0.
*           Implement suitable error handling here
          ELSE.
            IT_KWITANSI-WRBTRDPP = AMOUNT_TODISPLAY.
          ENDIF.

          CLEAR : AMOUNT_INTERNAL, AMOUNT_TODISPLAY.
          AMOUNT_INTERNAL = FWSTE.
          CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
            EXPORTING
              CURRENCY        = 'IDR'
              AMOUNT_INTERNAL = AMOUNT_INTERNAL
            IMPORTING
              AMOUNT_DISPLAY  = AMOUNT_TODISPLAY
            EXCEPTIONS
              INTERNAL_ERROR  = 1
              OTHERS          = 2.
          IF SY-SUBRC <> 0.
*           Implement suitable error handling here
          ELSE.
            IT_KWITANSI-WRBTRPPN = AMOUNT_TODISPLAY.
          ENDIF.
        ELSE.
          IT_KWITANSI-WRBTRDPP = FWBAS.
          IT_KWITANSI-WRBTRPPN = FWSTE.
        ENDIF.

        CLEAR : AMOUNT_INTERNAL, AMOUNT_TODISPLAY.
        AMOUNT_INTERNAL = HWBAS.
        CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
          EXPORTING
            CURRENCY        = 'IDR'
            AMOUNT_INTERNAL = AMOUNT_INTERNAL
          IMPORTING
            AMOUNT_DISPLAY  = AMOUNT_TODISPLAY
          EXCEPTIONS
            INTERNAL_ERROR  = 1
            OTHERS          = 2.
        IF SY-SUBRC <> 0.
*         Implement suitable error handling here
        ELSE.
          IT_KWITANSI-DMBTRDPP = AMOUNT_TODISPLAY.
        ENDIF.

        CLEAR : AMOUNT_INTERNAL, AMOUNT_TODISPLAY.
        AMOUNT_INTERNAL = HWSTE.
        CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
          EXPORTING
            CURRENCY        = 'IDR'
            AMOUNT_INTERNAL = AMOUNT_INTERNAL
          IMPORTING
            AMOUNT_DISPLAY  = AMOUNT_TODISPLAY
          EXCEPTIONS
            INTERNAL_ERROR  = 1
            OTHERS          = 2.
        IF SY-SUBRC <> 0.
*         Implement suitable error handling here
        ELSE.
          IT_KWITANSI-DMBTRPPN = AMOUNT_TODISPLAY.
        ENDIF.

        IF IT_KWITANSI-BLART EQ 'DG' OR IT_KWITANSI-BLART EQ 'RL'. " CREDIT NOTE
          IF IT_KWITANSI-WRBTRDPP > 0.
            IT_KWITANSI-WRBTRDPP = IT_KWITANSI-WRBTRDPP * -1.
          ENDIF.
          IF IT_KWITANSI-WRBTRPPN > 0.
            IT_KWITANSI-WRBTRPPN = IT_KWITANSI-WRBTRPPN * -1.
          ENDIF.
          IF IT_KWITANSI-DMBTRDPP > 0.
            IT_KWITANSI-DMBTRDPP = IT_KWITANSI-DMBTRDPP * -1.
          ENDIF.
          IF IT_KWITANSI-DMBTRPPN > 0.
            IT_KWITANSI-DMBTRPPN = IT_KWITANSI-DMBTRPPN * -1.
          ENDIF.
        ENDIF.
        IT_KWITANSI-WRBTRTOT = IT_KWITANSI-WRBTRDPP + IT_KWITANSI-WRBTRPPN.
        IT_KWITANSI-DMBTRTOT = IT_KWITANSI-DMBTRDPP + IT_KWITANSI-DMBTRPPN.
        IT_KWITANSI-ICON = ICON_LED_YELLOW.
        MODIFY IT_KWITANSI.
      ENDIF.
    ENDLOOP.

  ELSEIF MYTAB-DYNNR = 200.

    V_COMPANY = P_BUKRS2-LOW.
    IF SY-TCODE = 'ZFI103'.
      CLEAR: P_BUKRS2. REFRESH: P_BUKRS2.
    ENDIF.

    CLEAR IT_KWITANSI. REFRESH IT_KWITANSI.
    SELECT ZAWKEY AS AWKEY
           ZBLDAT AS BLDAT
           HWRBTR AS WRBTRDPP
           IWRBTR AS WRBTRPPN
           KDMBTR AS DMBTRDPP
           LDMBTR AS DMBTRPPN
           ZNO
           ZPRINT
           KUNNR AS KUNNR
           KEYDATE AS KWITDATE
           WAERS
           BLART
           GJAHR
           BUKRS
    INTO CORRESPONDING FIELDS OF TABLE IT_KWITANSI
    FROM ZKWIT
    WHERE ZNO IN PC_KWTNO AND TYPEFORM IN (11, 22, 33)
      AND BUKRS IN P_BUKRS2.

    SORT IT_KWITANSI BY AWKEY.
    LOOP AT IT_KWITANSI.
      CLEAR : IT_KWITANSI-ICON, VAWKEY.
      IT_KWITANSI-WRBTRTOT = IT_KWITANSI-WRBTRDPP + IT_KWITANSI-WRBTRPPN.
      IT_KWITANSI-DMBTRTOT = IT_KWITANSI-DMBTRDPP + IT_KWITANSI-DMBTRPPN.
      IF IT_KWITANSI-ZPRINT > 0.
        IT_KWITANSI-ICON = ICON_LED_GREEN.
      ELSE.
        IT_KWITANSI-ICON = ICON_LED_YELLOW.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = IT_KWITANSI-AWKEY
        IMPORTING
          OUTPUT = VAWKEY.

      SELECT SINGLE BUKRS INTO (IT_KWITANSI-BUKRS ) FROM VBRK WHERE VBELN = VAWKEY.
      MODIFY IT_KWITANSI.
    ENDLOOP.
    DELETE IT_KWITANSI WHERE BUKRS NE V_COMPANY.
  ELSE.
**    PERFORM GET_REPORTDATA.
    V_COMPANY = P_BUKRS3-LOW.
    IF SY-TCODE = 'ZFI103'.
      CLEAR: P_BUKRS3. REFRESH: P_BUKRS3.  "COMPANY TRIAS DI ZKWIT KOSONG
    ENDIF.

    CLEAR IT_KWITANSI. REFRESH IT_KWITANSI.
    SELECT ZAWKEY AS AWKEY
           ZBLDAT AS BLDAT  "TANGGAL FAKTUR
           HWRBTR AS WRBTRDPP
           IWRBTR AS WRBTRPPN
           KDMBTR AS DMBTRDPP
           LDMBTR AS DMBTRPPN
           ZNO AS ZNO
           ZPRINT AS ZPRINT
           KUNNR AS KUNNR
           WAERS AS WAERS
           BLART AS BLART
           GJAHR AS GJAHR
           KEYDATE AS KWITDATE "TANGGAL KWITANSI
           BUKRS
    INTO CORRESPONDING FIELDS OF TABLE IT_KWITANSI
    FROM ZKWIT
    WHERE ZNO IN PR_KWTNO AND
          KEYDATE IN PR_BLDAT AND
          ZAWKEY IN P_ZAWKEY AND
          KUNNR IN P_KUNNR AND
          TYPEFORM IN (11, 22, 33) AND
          BUKRS IN P_BUKRS3.

    SORT IT_KWITANSI BY AWKEY.
    LOOP AT IT_KWITANSI.
      CLEAR : V_FROM, IT_KWITANSI-NAME1, IT_KWITANSI-WRBTRTOT, IT_KWITANSI-DMBTRTOT,
              IT_KWITANSI-ICON, VAWKEY.

      IF IT_KWITANSI-KUNNR BETWEEN 1700000000 AND 1799999999.
        SELECT SINGLE NAME1 INTO IT_KWITANSI-NAME1
        FROM BSEC
        WHERE BELNR = IT_KWITANSI-BELNR AND GJAHR = IT_KWITANSI-GJAHR.
      ELSE.
        SELECT SINGLE NAME1
           INTO IT_KWITANSI-NAME1
           FROM KNA1
           WHERE KUNNR = IT_KWITANSI-KUNNR.
      ENDIF.
      IT_KWITANSI-WRBTRTOT = IT_KWITANSI-WRBTRDPP + IT_KWITANSI-WRBTRPPN.
      IT_KWITANSI-DMBTRTOT = IT_KWITANSI-DMBTRDPP + IT_KWITANSI-DMBTRPPN.
      IF IT_KWITANSI-ZPRINT > 0.
        IT_KWITANSI-ICON = ICON_LED_GREEN.
      ELSE.
        IT_KWITANSI-ICON = ICON_LED_YELLOW.
      ENDIF.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = IT_KWITANSI-AWKEY
        IMPORTING
          OUTPUT = VAWKEY.

      SELECT SINGLE BUKRS INTO (IT_KWITANSI-BUKRS ) FROM VBRK WHERE VBELN = VAWKEY.
      MODIFY IT_KWITANSI.
    ENDLOOP.
    DELETE IT_KWITANSI WHERE BUKRS NE V_COMPANY.
  ENDIF.

ENDFORM.                    " F_SELECT_DATA_FI

*&---------------------------------------------------------------------*
*&      Form  AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->WAERK      text
*      -->NETWR      text
*----------------------------------------------------------------------*
FORM AMOUNT  USING    WAERK
                      NETWR.

  CLEAR : V_NETWR, V_NETWR2.
  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      CURRENCY        = WAERK
      AMOUNT_INTERNAL = NETWR
    IMPORTING
      AMOUNT_DISPLAY  = V_NETWR
    EXCEPTIONS
      INTERNAL_ERROR  = 1
      OTHERS          = 2.

ENDFORM.                    " AMOUNT

*&---------------------------------------------------------------------*
*&      Form  GET_EXCHANGE_RATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1708   text
*      -->P_ZWAERS  text
*----------------------------------------------------------------------*
FORM GET_EXCHANGE_RATE  USING    VALUE(P_1708)
                                 ZWAERS.
  CLEAR : V_EXCHR.
  CALL FUNCTION 'RKC_SINGLE_EXCHANGE_RATE_GET'
    EXPORTING
      DATUM         = ITAB2-BUDAT
      KURST         = 'M'
      NCURR         = P_1708
      VCURR         = ZWAERS
    IMPORTING
      EXCHR         = V_EXCHR
    EXCEPTIONS
      NO_RATE_FOUND = 1
      OTHERS        = 2.

ENDFORM.                    " GET_EXCHANGE_RATE


*FOR SCREEN CETAK ULANG
FORM PRINT_PREVIEW2.
  DATA: V_FORMNAME   TYPE TDSFNAME  VALUE 'ZFIF_KWITANSI_PENJUALAN',
        CONTROL_PARAMETERS  LIKE  SSFCTRLOP,
        OUTPUT_OPTIONS  TYPE SSFCOMPOP,
        ZNO LIKE ZKWIT-ZNO,
        AWKEY LIKE ZKWIT-ZAWKEY,
        V_FUNCNAME   TYPE RS38L_FNAM.
  DATA : IT_ZKWIT LIKE STANDARD TABLE OF ZKWIT WITH HEADER LINE,
     WA_ZKWIT LIKE LINE OF IT_ZKWIT,
     SEQ TYPE I,
     ZSEQ LIKE ZKWIT-ZSEQ,
     NOKWIT TYPE C LENGTH 25,
     ZPRINT TYPE I,
     FLAG(1),
     P_HEAD TYPE STRING.

  CLEAR IT_KWITANSI2. REFRESH IT_KWITANSI2.
  CLEAR WA_KWITANSI2.
  IT_KWITANSI2[] = IT_KWITANSI[].
  DELETE IT_KWITANSI2 WHERE SEL NE 'X'.
  SORT IT_KWITANSI2 BY ZNO ASCENDING.
  DELETE ADJACENT DUPLICATES FROM IT_KWITANSI2 COMPARING ZNO.

  IF IT_KWITANSI2[] IS INITIAL.
    MESSAGE 'No data selected' TYPE 'E'.
  ELSE.
    LOOP AT IT_KWITANSI2.
      CLEAR CTR.
      CLEAR I_ITEM. REFRESH I_ITEM.
      LOOP AT IT_KWITANSI WHERE ZNO = IT_KWITANSI2-ZNO.
        CLEAR : WA_ITEM, DAT, DEC, DATT.
        CONCATENATE IT_KWITANSI-BLDAT+6(2) IT_KWITANSI-BLDAT+4(2) IT_KWITANSI-BLDAT+0(4) INTO DAT SEPARATED BY '.'.
        PERFORM CONVERTDATE USING DAT DATT.
        CTR = CTR + 1.
        WA_ITEM-ZNO = CTR.
        WA_ITEM-ZFDAGANG = IT_KWITANSI-AWKEY.
        WA_ITEM-WAERS = IT_KWITANSI-WAERS.
        CONCATENATE DATT(6) DATT+9(2) INTO DATT SEPARATED BY '-'.
        WA_ITEM-ZTANGGAL = DATT.
        WA_ITEM-ZUSDPP = IT_KWITANSI-WRBTRDPP.
        WA_ITEM-ZUSPPN = IT_KWITANSI-WRBTRPPN.
        WA_ITEM-ZUSTOT = IT_KWITANSI-WRBTRTOT.
        WA_ITEM-ZIDRDPP = IT_KWITANSI-DMBTRDPP.
        WA_ITEM-ZIDRPPN = IT_KWITANSI-DMBTRPPN.
        WA_ITEM-ZIDRTOT = IT_KWITANSI-DMBTRTOT.
        SHIFT WA_ITEM-ZNO LEFT DELETING LEADING '0'.
        APPEND WA_ITEM TO I_ITEM.
      ENDLOOP.

      PERFORM PREPARE_DATAPRINT.
*          BACA NO KWITANSI
      CLEAR : SEQ, NOKWIT, FLAG, CONTROL_PARAMETERS, OUTPUT_OPTIONS, V_COMCODE.

      IF IT_KWITANSI2-BUKRS = '9999'.
        V_COMCODE = ''.
      ELSE.
        V_COMCODE = IT_KWITANSI2-BUKRS.
      ENDIF.

      SELECT MAX( ZSEQ ) INTO ZSEQ
      FROM ZKWIT
        WHERE TYPEFORM IN (11, 22, 33)
          AND BUKRS = V_COMCODE.

      SEQ = ZSEQ.
      SEQ = SEQ + 1.
      NOKWIT = SEQ.
      CONDENSE NOKWIT.
      IF SEQ < 10.
        CONCATENATE '00' NOKWIT INTO NOKWIT.
      ELSEIF SEQ < 100 AND SEQ >= 10.
        CONCATENATE '0' NOKWIT INTO NOKWIT.
      ENDIF.

      CONCATENATE NOKWIT SY-DATUM+4(2) SY-DATUM(4) INTO NOKWIT SEPARATED BY '/'.

      IF MYTAB-DYNNR = 100.
        CONCATENATE NOKWIT SY-DATUM+4(2) SY-DATUM(4) INTO NOKWIT SEPARATED BY '/'.
      ELSE.
        CLEAR: ZNO, AWKEY.
        READ TABLE I_ITEM INDEX 1.
        AWKEY = I_ITEM-ZFDAGANG.
        SELECT SINGLE ZNO
            INTO ZNO
            FROM ZKWIT
            WHERE ZAWKEY = AWKEY AND TYPEFORM IN (11, 22, 33)
              AND BUKRS = V_COMCODE.
        IF ZNO NE ''.
          NOKWIT = ZNO.
        ENDIF.
      ENDIF.
      V_NOKWIT = NOKWIT.

      IF IT_KWITANSI2-BUKRS = '9999'. "ADD BY REY NEW COMPANY
        P_HEAD = 'PT TRIAS SENTOSA, TBK.'.
        V_FORMNAME = 'ZFIF_KWITANSI_PENJUALAN_TS'.  " Added by William at 30.12.2024 (form kwitansi for TS)
      ELSEIF IT_KWITANSI2-BUKRS = '9800'.
        P_HEAD = 'PT UNGGUL NIAGA SENTOSA'.
      ELSEIF IT_KWITANSI2-BUKRS = '9701'.
        P_HEAD = 'PT TRIAS TOYOBO ASTRIA'.
      ELSEIF P_BUKRS2-LOW = '6500'.
        P_HEAD = 'PT TOYOBO TRIAS ECOSYAR'.
      ENDIF.

*          PERFORM SAVETOTABLE.
      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME           = V_FORMNAME
*         VARIANT            = ' '
*         DIRECT_CALL        = ' '
        IMPORTING
          FM_NAME            = V_FUNCNAME
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.

      IF SY-SUBRC <> 0.
*         Implement suitable error handling here
      ELSE.
        CONTROL_PARAMETERS-NO_DIALOG = 'X'.
        CONTROL_PARAMETERS-PREVIEW = 'X'.
        OUTPUT_OPTIONS-TDNOPRINT = 'X'.
        CALL FUNCTION V_FUNCNAME
          EXPORTING
           CONTROL_PARAMETERS = CONTROL_PARAMETERS
           OUTPUT_OPTIONS     = OUTPUT_OPTIONS
*               mail_recipient     = i_recipient
*               mail_sender        = i_sender
            P_NOKWIT           = V_NOKWIT
            P_FROM             = V_FROM
            P_TOTUSDPP         = V_TOTUSDPP
            P_TOTIDRPPN        = V_TOTIDRPPN
            P_FAKTUR           = V_FAKTUR
            P_FAKTUR1           = V_FAKTUR1
            P_TERBILANGIN      = V_TERBILANGIN
            P_TERBILANG        = V_TERBILANG
            P_TOTUSPPN         = V_TOTUSPPN
            P_TOTUSJLH         = V_TOTUSJLH
            P_TOTIDRDPP        = V_TOTIDRDPP
            P_TOTIDRJLH        = V_TOTIDRJLH
            P_DCETAK           = V_DCETAK
            P_TCETAK           = V_TCETAK
            P_DATE             = V_DATEKWIT "V_DATE
            P_NAMA             = V_NAMA
            P_UANGTXT1         = V_UANGTXT1
            P_UANGTXT2         = V_UANGTXT2
            P_TERBILANGTXT     = V_TERBILANGTXT
            P_TOT1             = V_TOT1T
            P_PLUS             = V_PLUS
            P_TOT2             = V_TOT2T
            P_ROT2             = V_ROT2
            P_ROT1             = V_ROT1
            P_ROT3             = V_ROT3
            TYPECETAKULANG     = TYPEFORM
            P_DATEKWIT         = V_DATEKWIT
            P_BK_BANK          = V_BK_NAMA "add by whika for bank information
            P_IDR              = V_IDR1
            P_AC_NAMA          = V_AC_NAMA
            P_CBG_NAMA         = V_CBG_NAMA "whika
            P_HEAD             = P_HEAD "ADD BY REY NEW COMPANY
*              IMPORTING
*                JOB_OUTPUT_INFO    = LD_INFO
          TABLES
            IT_ITEM            = I_ITEM
          EXCEPTIONS
            FORMATTING_ERROR   = 1
            INTERNAL_ERROR     = 2
            SEND_ERROR         = 3
            USER_CANCELED      = 4
            OTHERS             = 5.
      ENDIF.
    ENDLOOP.
    PERFORM DISPLAY_ALV.
  ENDIF.
ENDFORM.                    "PRINT_PREVIEW2

*&---------------------------------------------------------------------*
*&      Form  DOPRINT2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DOPRINT2 .
  DATA: V_FORMNAME   TYPE TDSFNAME  VALUE 'ZFIF_KWITANSI_PENJUALAN',
        CONTROL_PARAMETERS  LIKE  SSFCTRLOP,
        OUTPUT_OPTIONS  TYPE SSFCOMPOP,
        V_FUNCNAME   TYPE RS38L_FNAM,
        DEVICE LIKE SSFCTRLOP-DEVICE,
        TAB TYPE STANDARD TABLE OF SVAL WITH HEADER LINE,
        RETURNCODE(1),
        DOCUMENT_OUTPUT_INFO  TYPE  SSFCRESPD,
        JOB_OUTPUT_INFO TYPE  SSFCRESCL,
        JOB_OUTPUT_OPTIONS  TYPE  SSFCRESOP.
  DATA : ZNO LIKE ZKWIT-ZNO,
         ZPRINT LIKE ZKWIT-ZPRINT,
         P_HEAD TYPE STRING.

  CLEAR : DEVICE, TAB, RETURNCODE, DOCUMENT_OUTPUT_INFO, JOB_OUTPUT_INFO .

  CLEAR IT_KWITANSI2. REFRESH IT_KWITANSI2.
  CLEAR WA_KWITANSI2.
  IT_KWITANSI2[] = IT_KWITANSI[].
  DELETE IT_KWITANSI2 WHERE SEL NE 'X'.
  SORT IT_KWITANSI2 BY ZNO ASCENDING.
  DELETE ADJACENT DUPLICATES FROM IT_KWITANSI2 COMPARING ZNO.

  IF IT_KWITANSI2[] IS INITIAL.
    MESSAGE 'No data selected' TYPE 'E'.
  ELSE.
    LOOP AT IT_KWITANSI2.
      CLEAR CTR.
      CLEAR I_ITEM. REFRESH I_ITEM.
      LOOP AT IT_KWITANSI WHERE ZNO = IT_KWITANSI2-ZNO.
        CLEAR : WA_ITEM, DAT, DEC, DATT.
        CONCATENATE IT_KWITANSI-BLDAT+6(2) IT_KWITANSI-BLDAT+4(2) IT_KWITANSI-BLDAT+0(4) INTO DAT SEPARATED BY '.'.
        PERFORM CONVERTDATE USING DAT DATT.
        CTR = CTR + 1.
        WA_ITEM-ZNO = CTR.
        WA_ITEM-ZFDAGANG = IT_KWITANSI-AWKEY.
        WA_ITEM-WAERS = IT_KWITANSI-WAERS.
        CONCATENATE DATT(6) DATT+9(2) INTO DATT SEPARATED BY '-'.
        WA_ITEM-ZTANGGAL = DATT.
        WA_ITEM-ZUSDPP = IT_KWITANSI-WRBTRDPP.
        WA_ITEM-ZUSPPN = IT_KWITANSI-WRBTRPPN.
        WA_ITEM-ZUSTOT = IT_KWITANSI-WRBTRTOT.
        WA_ITEM-ZIDRDPP = IT_KWITANSI-DMBTRDPP.
        WA_ITEM-ZIDRPPN = IT_KWITANSI-DMBTRPPN.
        WA_ITEM-ZIDRTOT = IT_KWITANSI-DMBTRTOT.
        SHIFT WA_ITEM-ZNO LEFT DELETING LEADING '0'.
        APPEND WA_ITEM TO I_ITEM.
      ENDLOOP.

      CLEAR : CTR, DAT.
      CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM(4) INTO DAT SEPARATED BY '.'.
*          PERFORM READMARKED.
      PERFORM PREPARE_DATAPRINT.

      IF P_BUKRS2-LOW = '9999' OR P_BUKRS2-LOW = '' OR P_BUKRS2-LOW IS INITIAL. "ADD BY REY NEW COMPANY
        P_HEAD = 'PT TRIAS SENTOSA, TBK.'.
        V_FORMNAME = 'ZFIF_KWITANSI_PENJUALAN_TS'.  " Added by William at 30.12.2024 (form kwitansi for TS)
      ELSEIF P_BUKRS2-LOW = '9800'.
        P_HEAD = 'PT UNGGUL NIAGA SENTOSA'.
      ELSEIF P_BUKRS2-LOW = '9701'.
        P_HEAD = 'PT TRIAS TOYOBO ASTRIA'.
      ELSEIF P_BUKRS2-LOW = '6500'.
        P_HEAD = 'PT TOYOBO TRIAS ECOSYAR'.
      ENDIF.

      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
        EXPORTING
          FORMNAME           = V_FORMNAME
*         VARIANT            = ' '
*         DIRECT_CALL        = ' '
        IMPORTING
          FM_NAME            = V_FUNCNAME
        EXCEPTIONS
          NO_FORM            = 1
          NO_FUNCTION_MODULE = 2
          OTHERS             = 3.

      IF SY-SUBRC <> 0.
*         Implement suitable error handling here
      ELSE.
        CLEAR : CONTROL_PARAMETERS, OUTPUT_OPTIONS.
        CONTROL_PARAMETERS-PREVIEW = 'X'.
        OUTPUT_OPTIONS-TDNOPREV = 'X'.

        PERFORM SAVETOTABLE.
        CALL FUNCTION V_FUNCNAME "/1BCDWB/SF00000023
            EXPORTING
*                         control_parameters = control_parameters
             OUTPUT_OPTIONS     = OUTPUT_OPTIONS
*                         mail_recipient     = i_recipient
*                         mail_sender        = i_sender
              P_NOKWIT           = V_NOKWIT
              P_FROM             = V_FROM
              P_TOTUSDPP         = V_TOTUSDPP
              P_TOTIDRPPN        = V_TOTIDRPPN
              P_FAKTUR           = V_FAKTUR
              P_FAKTUR1           = V_FAKTUR1
              P_TERBILANGIN      = V_TERBILANGIN
              P_TERBILANG        = V_TERBILANG
              P_TOTUSPPN         = V_TOTUSPPN
              P_TOTUSJLH         = V_TOTUSJLH
              P_TOTIDRDPP        = V_TOTIDRDPP
              P_TOTIDRJLH        = V_TOTIDRJLH
              P_DCETAK           = V_DCETAK
              P_TCETAK           = V_TCETAK
              P_DATE             = V_DATEKWIT "V_DATE
              P_NAMA             = V_NAMA
              P_UANGTXT1         = V_UANGTXT1
              P_UANGTXT2         = V_UANGTXT2
              P_TERBILANGTXT     = V_TERBILANGTXT
              P_TOT1             = V_TOT1T
              P_PLUS             = V_PLUS
              P_TOT2             = V_TOT2T
              P_ROT2             = V_ROT2
              P_ROT1             = V_ROT1
              P_ROT3             = V_ROT3
              TYPECETAKULANG     = TYPEFORM
              P_DATEKWIT         = V_DATEKWIT
              P_BK_BANK          = V_BK_NAMA "add by whika for bank information
              P_IDR              = V_IDR1
              P_AC_NAMA          = V_AC_NAMA
              P_CBG_NAMA         = V_CBG_NAMA "whika
              P_HEAD             = P_HEAD "ADD BY REY NEW COMPANY
            IMPORTING
              DOCUMENT_OUTPUT_INFO  = DOCUMENT_OUTPUT_INFO
              JOB_OUTPUT_INFO	= JOB_OUTPUT_INFO
              JOB_OUTPUT_OPTIONS  = JOB_OUTPUT_OPTIONS
            TABLES
              IT_ITEM            = I_ITEM
            EXCEPTIONS
              FORMATTING_ERROR   = 1
              INTERNAL_ERROR     = 2
              SEND_ERROR         = 3
              USER_CANCELED      = 4
              OTHERS             = 5.
*                      PERFORM DOREFRESH.
        IF SY-SUBRC  = 0.
          IF JOB_OUTPUT_INFO-OUTPUTDONE EQ 'X'.
            PERFORM UPDATE_DATA.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    PERFORM GET_UPDATED.
  ENDIF.
ENDFORM.                    " DOPRINT2

*&---------------------------------------------------------------------*
*&      Form  GET_CUSTOMER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_CUSTOMER .
  DATA :
        I_XVBADR  LIKE  SADRVB OCCURS 0 WITH HEADER LINE,
        I_XVBPA LIKE  VBPAVB OCCURS 0 WITH HEADER LINE,
        I_YVBADR  LIKE  SADRVB OCCURS 0 WITH HEADER LINE,
        I_YVBPA LIKE  VBPAVB  OCCURS 0 WITH HEADER LINE,
        I_XVBPA2  LIKE  VBPA2VB OCCURS 0 WITH HEADER LINE,
        I_YVBPA2  LIKE  VBPA2VB OCCURS 0 WITH HEADER LINE,
        VBELN LIKE VBRP-VBELN.

  LOOP AT IT_KWITANSI.
    IF IT_KWITANSI-KUNNR BETWEEN 1700000000 AND 1799999999.
      IF IT_KWITANSI-BLART = 'DG' OR IT_KWITANSI-BLART = 'DH'
         OR IT_KWITANSI-BLART = 'DR' OR IT_KWITANSI-BLART = 'DS'. "FI
        SELECT SINGLE NAME1 INTO IT_KWITANSI-NAME1
             FROM BSEC
             WHERE BELNR = IT_KWITANSI-AWKEY AND GJAHR = IT_KWITANSI-GJAHR.
      ELSEIF IT_KWITANSI-BLART = 'RV' OR IT_KWITANSI-BLART = 'RX'
         OR IT_KWITANSI-BLART = 'RK' OR IT_KWITANSI-BLART = 'RL'. "SD
        CLEAR : I_XVBADR[], I_XVBPA[], I_YVBADR[], I_YVBPA[], I_XVBPA2[], I_YVBPA2[], VBELN.
        REFRESH : I_XVBADR[], I_XVBPA[], I_YVBADR[], I_YVBPA[], I_XVBPA2[], I_YVBPA2[].

        VBELN = IT_KWITANSI-AWKEY.
        CALL FUNCTION 'SD_PARTNER_READ'
          EXPORTING
            F_VBELN          = VBELN
            OBJECT           = 'VBPA'
*           NO_MASTER_ADRESS = ' '
*           IV_NO_INIT       = ' '
*           IV_PARVW         =
*           IV_POSNR         =
          TABLES
            I_XVBADR         = I_XVBADR
            I_XVBPA          = I_XVBPA
            I_YVBADR         = I_YVBADR
            I_YVBPA          = I_YVBPA
            I_XVBPA2         = I_XVBPA2
            I_YVBPA2         = I_YVBPA2.
        CLEAR: KNA1.
        READ TABLE  I_XVBADR INDEX 1.
        KNA1-ADRNR = I_XVBADR-ADRNR.
        KNA1-ANRED = I_XVBADR-ANRED.
        KNA1-NAME1 = I_XVBADR-NAME1.
        KNA1-NAME2 = I_XVBADR-NAME2.
        KNA1-NAME3 = I_XVBADR-NAME3.
        KNA1-NAME4 = I_XVBADR-NAME4.
        KNA1-PSTLZ = I_XVBADR-PSTLZ.

        IT_KWITANSI-NAME1 =  KNA1-NAME1.
      ENDIF.
    ELSE.
      SELECT SINGLE KNA1~NAME1
          INTO IT_KWITANSI-NAME1
          FROM KNA1
          WHERE KUNNR = IT_KWITANSI-KUNNR. "PK_KUNNR.
    ENDIF .
    MODIFY IT_KWITANSI.
  ENDLOOP.
ENDFORM.                    " GET_CUSTOMER


*&---------------------------------------------------------------------*
*&      Form  MOD_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MOD_SCREEN .
  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'PS1' AND MYTAB-DYNNR NE 100.
      SCREEN-ACTIVE = '0'.
      MODIFY SCREEN.
      CONTINUE.
    ELSE.
      SCREEN-ACTIVE = '1'.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  IF MYTAB-DYNNR = 100 AND P_STAT2 = 'X'. "SD
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'MO2'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
        CONTINUE.
      ELSE.
        SCREEN-ACTIVE = '1'.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ELSEIF MYTAB-DYNNR = 100 AND P_STAT1 = 'X'.
    LOOP AT SCREEN .
      IF SCREEN-GROUP1 = 'MO1'.
        SCREEN-ACTIVE = '0'.
        MODIFY SCREEN.
        CONTINUE.
      ELSE.
        SCREEN-ACTIVE = '1'.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " MOD_SCREEN

*&---------------------------------------------------------------------*
*&      Form  CANCEL_KWITANSI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CANCEL_KWITANSI .
  DATA : ZNOK LIKE ZKWIT-ZNO,
         COUNT TYPE I,
         ANSWER(1) TYPE C.

  CLEAR : COUNT, ANSWER.
  LOOP AT IT_KWITANSI WHERE SEL EQ 'X'.
    COUNT = COUNT + 1.
    EXIT.
  ENDLOOP.

  IF COUNT > 0.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
       TITLEBAR                    = 'Cancel Kwitansi'
*       DIAGNOSE_OBJECT             = ' '
        TEXT_QUESTION               = 'Kwitansi akan dicancel. Apakah anda yakin?'
       TEXT_BUTTON_1               = 'Ya'(001)
*       ICON_BUTTON_1               = ' '
       TEXT_BUTTON_2               = 'Tidak'(002)
*       ICON_BUTTON_2               = ' '
*       DEFAULT_BUTTON              = '1'
       DISPLAY_CANCEL_BUTTON       = ' '
*       USERDEFINED_F1_HELP         = ' '
*       START_COLUMN                = 25
*       START_ROW                   = 6
*       POPUP_TYPE                  =
*       IV_QUICKINFO_BUTTON_1       = ' '
*       IV_QUICKINFO_BUTTON_2       = ' '
     IMPORTING
       ANSWER                      = ANSWER
*     TABLES
*       PARAMETER                   =
     EXCEPTIONS
       TEXT_NOT_FOUND              = 1
       OTHERS                      = 2
              .
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ELSE.
      IF ANSWER = '1'.
        LOOP AT IT_KWITANSI WHERE SEL EQ 'X'.
          CLEAR ZNOK.
          ZNOK = IT_KWITANSI-ZNO.
          DELETE FROM ZKWIT WHERE ZNO = ZNOK.
          IF SY-SUBRC = 0.
            COMMIT WORK.
          ENDIF.
          DELETE IT_KWITANSI WHERE ZNO = ZNOK.
          CONTINUE.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.                    " CANCEL_KWITANSI

*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_STATUS .
  CLEAR ITAB. REFRESH ITAB.
  IF MYTAB-DYNNR = 200.
    SET PF-STATUS 'ZSTATUS_KWITANSI'.
  ELSE.
    APPEND '&CANC' TO ITAB.
    SET PF-STATUS 'ZSTATUS_KWITANSI' EXCLUDING ITAB.
  ENDIF.
ENDFORM.                    " SET_STATUS


*&---------------------------------------------------------------------*
*&      Form  GET_PPN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_PPN.
  DATA: V_KNUMV LIKE KONV-KNUMV,
        LV_COUNC LIKE KNA1-COUNC. " Add by Dila 05.08.2026
  CLEAR: V_PPN_PRC, V_KNUMV.

  SELECT KNUMV INTO V_KNUMV
FROM VBRK WHERE VBRK~VBELN = IVBRP-VBELN.
    SELECT SINGLE KBETR INTO V_PPN_PRC FROM KONV WHERE KNUMV = V_KNUMV AND KSCHL = 'ZPPN'.
    V_PPN_PRC = V_PPN_PRC / 1000.
    EXIT.
  ENDSELECT.

*   -- Kawasan berikat: county code '07' -> PPN 0, Rupiah Jumlah = Rupiah DPP <Add by Dila 23.07.2026>
  CLEAR LV_COUNC.
  SELECT SINGLE COUNC INTO LV_COUNC
    FROM KNA1 WHERE KUNNR = IVBRP-KUNRG.
  IF LV_COUNC = '07'.
    CLEAR V_PPN_PRC.
  ENDIF.
ENDFORM.                    "get_ppn

*&---------------------------------------------------------------------*
*&      Form  get_total
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_TOTAL TABLES LT_KWITANSIT.
  DATA: V_WRBTRDPP LIKE BSEG-WRBTR,
        V_WRBTRPPN LIKE BSEG-WRBTR,
        V_WRBTRTOT LIKE BSEG-WRBTR,
        V_DMBTRDPP LIKE BSEG-DMBTR,
        V_DMBTRPPN LIKE BSEG-DMBTR,
        V_DMBTRTOT LIKE BSEG-DMBTR.

  DATA: V_KWIT_DATE(8).

  DATA: IT_KWITANSIT LIKE STANDARD TABLE OF IT_KWITANSI WITH HEADER LINE.

  CLEAR : V_WRBTRDPP, V_WRBTRPPN, V_WRBTRTOT, V_DMBTRDPP, V_DMBTRPPN, V_DMBTRTOT.

  IT_KWITANSIT[] = LT_KWITANSIT[].

  V_WRBTRDPP = IT_KWITANSI-WRBTRDPP.
  V_WRBTRPPN = IT_KWITANSI-WRBTRPPN.
  V_WRBTRTOT = IT_KWITANSI-WRBTRTOT.
  V_DMBTRDPP = IT_KWITANSI-DMBTRDPP.
  V_DMBTRPPN = IT_KWITANSI-DMBTRPPN.
  V_DMBTRTOT = IT_KWITANSI-DMBTRTOT.

  CLEAR: IT_KWITANSI-WRBTRDPP, IT_KWITANSI-WRBTRPPN, IT_KWITANSI-WRBTRTOT,
         IT_KWITANSI-DMBTRDPP, IT_KWITANSI-DMBTRPPN, IT_KWITANSI-DMBTRTOT.

  CLEAR VBRK.
  SELECT SINGLE * INTO VBRK FROM VBRK WHERE VBELN = IT_KWITANSI-AWKEY.
*- Doc Currency
  WRITE VBRK-NETWR TO VBRK-STCEG CURRENCY VBRK-WAERK NO-GROUPING.
  IT_KWITANSI-WRBTRDPP = VBRK-STCEG.
*- EXIT get PPN from KNUMV for Kawasan berikat
  IF VBRK-TAXK1 = '8'.
    PERFORM GET_PPN_KNUMV.
  ENDIF.
*- end of EXIT get PPN from KNUMV for Kawasan berikat
  WRITE VBRK-MWSBK TO VBRK-STCEG CURRENCY VBRK-WAERK NO-GROUPING.
  IT_KWITANSI-WRBTRPPN = VBRK-STCEG.
  IT_KWITANSI-WRBTRTOT = IT_KWITANSI-WRBTRDPP + IT_KWITANSI-WRBTRPPN.

*- IDR Currency
  IT_KWITANSI-DMBTRDPP = IT_KWITANSI-WRBTRDPP * V_RATE-TO_FACTOR.
  IT_KWITANSI-DMBTRPPN = IT_KWITANSI-WRBTRPPN * V_RATE-TO_FACTOR.
  " Added by William at 08.02.2025 (value tax not from table but manual calculate with round commercial)
  V_KWIT_DATE = SY-DATUM.
  IF V_KWIT_DATE GE 20250101.
    CLEAR: IT_KWITANSI-DMBTRDPP, IT_KWITANSI-DMBTRPPN.
    LOOP AT IT_KWITANSIT WHERE AWKEY = IT_KWITANSI-AWKEY.
      IT_KWITANSI-DMBTRDPP = IT_KWITANSI-DMBTRDPP + IT_KWITANSIT-DMBTRDPP_1.
      IT_KWITANSI-DMBTRPPN = IT_KWITANSI-DMBTRPPN + IT_KWITANSIT-DMBTRPPN_1.
    ENDLOOP.
    IT_KWITANSI-DMBTRDPP = ROUND( VAL = IT_KWITANSI-DMBTRDPP DEC = 0 ).
    IT_KWITANSI-DMBTRPPN = ROUND( VAL = IT_KWITANSI-DMBTRPPN DEC = 0 ).
  ENDIF.
  " End added by William at 08.02.2025 (value tax not from table but manual calculate with round commercial)
  IT_KWITANSI-DMBTRTOT = IT_KWITANSI-DMBTRDPP + IT_KWITANSI-DMBTRPPN.

ENDFORM.                    "get_total


*&---------------------------------------------------------------------*
*&      Form  GET_PPN_KNUMV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_PPN_KNUMV.
  DATA: V_KWERT LIKE KONV-KWERT.

  CLEAR: VBRK-MWSBK.
  SELECT KWERT INTO V_KWERT FROM KONV WHERE KNUMV = VBRK-KNUMV AND KSCHL = 'ZPPN'.
    VBRK-MWSBK = VBRK-MWSBK + V_KWERT.
  ENDSELECT.
ENDFORM.                    "get_ppn_kn "get_ppn_knumv