*&---------------------------------------------------------------------*
*& Report  ZMM_GRN_PO
*&
*&---------------------------------------------------------------------*
*&Create by : Whika, Yulius, Gani, Alex
*&Date : 24 Mei 2016
*&---------------------------------------------------------------------*\
* Amendment History
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
* Ref | Date     | Programmer  | Correction | Description              *
* ~~~   ~~~~~~~~   ~~~~~~~~~~    ~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~*
* 001 | 24.05.16 | Whika, dkk  |            | Program Created          *
* 002 | 20.11.19 | Fathir      |            | Insert GRN data to AGS (TTE Only)
*----------------------------------------------------------------------*

REPORT  ZMM_GRN_PO.
INCLUDE ZMM_GRN_PO_GET_CHAR_VAL.

TYPE-POOLS: SLIS.

DATA : FNAME TYPE STRING.
DATA: L_TA_MSG TYPE STANDARD TABLE OF BDCMSGCOLL WITH HEADER LINE.
DATA: COUNT TYPE I.
DATA: ROWS(50) TYPE C.
DATA : BEGIN OF IT_DATA OCCURS 0,
        LFSNR TYPE RM07M-LFSNR, "DELIVERY NOTE
        FRBNR TYPE MKPF-FRBNR,"BILL OF LADING
        BKTXT TYPE MKPF-BKTXT,"DOC HEADER TEXT
        EBELN TYPE RM07M-EBELN,"PO
        EBELP TYPE RM07M-EBELP,"ITEM
        WERKS TYPE RM07M-WERKS,"PLANT
        ERFMG(10) TYPE C,"QTY
        LGORT TYPE RM07M-LGORT,"SLOC
        LICHA TYPE VM07M-LICHA,"VENDOR BATCH
       END OF IT_DATA.

DATA: IT_TEMP LIKE STANDARD TABLE OF IT_DATA WITH HEADER LINE.

DATA : BEGIN OF IT_DATA2 OCCURS 0,
        BLDAT(10), "Document Date
        BUDAT(10), "Posting Date
        LFSNR TYPE RM07M-LFSNR, "DELIVERY NOTE
        FRBNR TYPE MKPF-FRBNR,"BILL OF LADING
        BKTXT TYPE MKPF-BKTXT,"DOC HEADER TEXT
        EBELN TYPE RM07M-EBELN,"PO
        EBELP TYPE RM07M-EBELP,"ITEM
        CHARG TYPE MCHB-CHARG, "Batch
        WERKS TYPE RM07M-WERKS,"PLANT
        ERFMG(10) TYPE C,"QTY
        ERFME TYPE MARA-MEINS, "Uom
        LGORT TYPE RM07M-LGORT,"SLOC
        LICHA TYPE VM07M-LICHA,"VENDOR BATCH
       END OF IT_DATA2.

DATA: IT_TEMP2 LIKE STANDARD TABLE OF IT_DATA2 WITH HEADER LINE.


DATA : BEGIN OF IT_DISPLAY OCCURS 0,
        ICON(4) TYPE C,
        LFSNR TYPE RM07M-LFSNR, "DELIVERY NOTE
        FRBNR TYPE MKPF-FRBNR,"BILL OF LADING
        BKTXT TYPE MKPF-BKTXT,"DOC HEADER TEXT
        EBELN TYPE RM07M-EBELN,"PO
        EBELP TYPE RM07M-EBELP,"ITEM
        WERKS TYPE RM07M-WERKS,"PLANT
        ERFMG(10) TYPE C,"QTY
        LGORT TYPE RM07M-LGORT,"SLOC
        LICHA TYPE VM07M-LICHA,"VENDOR BATCH
        CHARG TYPE MSEG-CHARG,
        MBLNR TYPE MSEG-MBLNR,
        MATNR TYPE MSEG-MATNR,
        STATUS(10) TYPE C,
        TEXT(132) TYPE C,
       END OF IT_DISPLAY.

DATA: BDC_DATA LIKE BDCDATA OCCURS 1000 WITH HEADER LINE,
      WA_L_TA_MSG LIKE BDCMSGCOLL.

DATA: IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
      IT_LAYOUT TYPE SLIS_LAYOUT_ALV,
      T_SORT TYPE SLIS_T_SORTINFO_ALV WITH HEADER LINE.

DATA : MODE(1) TYPE C VALUE 'N',
       UPDATE(1) TYPE C VALUE 'S',
       V_PROGRESS TYPE N VALUE 0,
       V_COUNT(10) TYPE N,
       V_TEXT(132) TYPE C,
       ZDATUM(10) TYPE C,
       TEMP_MSG(132) TYPE C,
       V_PROG LIKE ZPROGINFO-PGMNA VALUE 'ZMM_GRN_PO'.

"-- ADDED FOR AGS BY FATHIR ON 20.11.2019  - Create internal table to contain GR Matdoc and Batch
DATA: BEGIN OF IT_AGSGRN OCCURS 0,
        MBLNR LIKE MKPF-MBLNR,
        CHARG LIKE MCH1-CHARG,
       END OF IT_AGSGRN.
DATA: IT_AGSPARAM LIKE STANDARD TABLE OF IT_AGSGRN.
"-- ADDED FOR AGS BY FATHIR ON 20.11.2019  - Create internal table to contain GR Matdoc and Batch

DATA : BEGIN OF LMSG OCCURS 0,
          MSGID  LIKE SY-MSGID,
          MSGTY  LIKE SY-MSGTY,
          MSGNO  LIKE SY-MSGNO,
          MSGV1  LIKE SY-MSGV1,
          MSGV2  LIKE SY-MSGV2,
          MSGV3  LIKE SY-MSGV3,
          MSGV4  LIKE SY-MSGV4,
          LINENO TYPE MESG-ZEILE,
        END OF LMSG.

DEFINE BDC_DYNPRO.
  CLEAR &1.
  &1-PROGRAM = &2.
  &1-DYNPRO = &3.
  &1-DYNBEGIN = 'X'.
  APPEND &1.
END-OF-DEFINITION.

DEFINE BDC_FIELD.
  CLEAR &1.
  &1-FNAM = &2.
  &1-FVAL = &3.
  APPEND &1.
END-OF-DEFINITION.


SELECTION-SCREEN BEGIN OF BLOCK B1000 WITH FRAME TITLE TEXT-100..
PARAMETERS: P_FILE   LIKE RLGRAP-FILENAME
                     OBLIGATORY
                     DEFAULT 'C:/'.
SELECTION-SCREEN END OF BLOCK B1000.

SELECTION-SCREEN BEGIN OF BLOCK BL003 WITH FRAME TITLE TEXT-200.
PARAMETERS: RB1 RADIOBUTTON GROUP RG1,
            RB2 RADIOBUTTON GROUP RG1.
SELECTION-SCREEN END OF BLOCK BL003.

SELECTION-SCREEN BEGIN OF BLOCK B1002 WITH FRAME.
SELECTION-SCREEN PUSHBUTTON /12(79) INFO USER-COMMAND INFO.
SELECTION-SCREEN END OF BLOCK B1002.

AT SELECTION-SCREEN.
  IF SY-UCOMM = 'INFO'.
    PERFORM F_PROG_INFO USING V_PROG.
  ENDIF.

INITIALIZATION.
  MOVE 'Program Information' TO INFO.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  PERFORM F4_OPEN_FILE.

*&---------------------------------------------------------------------*
*&      Form  F4_OPEN_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F4_OPEN_FILE .
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      PROGRAM_NAME  = SY-CPROG
      DYNPRO_NUMBER = SY-DYNNR
      FIELD_NAME    = ' '
    IMPORTING
      FILE_NAME     = P_FILE.
  IF SY-SUBRC <> 0 OR P_FILE EQ ''.

  ENDIF.
ENDFORM.                    "F4_OPEN_FILE

START-OF-SELECTION.
  PERFORM GET_DATA.
  PERFORM VALIDATE_DATA.

  IF LMSG[] IS INITIAL.
    IF RB1 EQ 'X'.
      PERFORM INSERT_DATA.
    ELSEIF RB2 EQ 'X'.
      PERFORM INSERT_DATA_2.
    ENDIF.
    PERFORM DISPLAY_DATA.
  ELSE.
    CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
      TABLES
        I_MESSAGE_TAB = LMSG.
  ENDIF.


END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM GET_DATA.
  CONCATENATE SY-DATUM+6(2) SY-DATUM+4(2) SY-DATUM(4) INTO ZDATUM SEPARATED BY '.'.

  IF RB1 EQ 'X'.
    MOVE P_FILE TO FNAME.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        FILENAME                = FNAME
        HAS_FIELD_SEPARATOR     = 'X' "FILL : READ BY TAB, NO FILL : READ BY SPACE
        READ_BY_LINE            = 'X' "FILL : READ  PER ROW, NO FILL : READ PER COLUMN"
      TABLES
        DATA_TAB                = IT_DATA
      EXCEPTIONS
        FILE_OPEN_ERROR         = 1
        FILE_READ_ERROR         = 2
        NO_BATCH                = 3
        GUI_REFUSE_FILETRANSFER = 4
        INVALID_TYPE            = 5
        NO_AUTHORITY            = 6
        UNKNOWN_ERROR           = 7
        BAD_DATA_FORMAT         = 8
        HEADER_NOT_ALLOWED      = 9
        SEPARATOR_NOT_ALLOWED   = 10
        HEADER_TOO_LONG         = 11
        UNKNOWN_DP_ERROR        = 12
        ACCESS_DENIED           = 13
        DP_OUT_OF_MEMORY        = 14
        DISK_FULL               = 15
        DP_TIMEOUT              = 16
        OTHERS                  = 17.

  ELSEIF RB2 EQ 'X'. "add for UNS
    MOVE P_FILE TO FNAME.
    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        FILENAME                = FNAME
        HAS_FIELD_SEPARATOR     = 'X' "FILL : READ BY TAB, NO FILL : READ BY SPACE
        READ_BY_LINE            = 'X' "FILL : READ  PER ROW, NO FILL : READ PER COLUMN"
      TABLES
        DATA_TAB                = IT_DATA2
      EXCEPTIONS
        FILE_OPEN_ERROR         = 1
        FILE_READ_ERROR         = 2
        NO_BATCH                = 3
        GUI_REFUSE_FILETRANSFER = 4
        INVALID_TYPE            = 5
        NO_AUTHORITY            = 6
        UNKNOWN_ERROR           = 7
        BAD_DATA_FORMAT         = 8
        HEADER_NOT_ALLOWED      = 9
        SEPARATOR_NOT_ALLOWED   = 10
        HEADER_TOO_LONG         = 11
        UNKNOWN_DP_ERROR        = 12
        ACCESS_DENIED           = 13
        DP_OUT_OF_MEMORY        = 14
        DISK_FULL               = 15
        DP_TIMEOUT              = 16
        OTHERS                  = 17.

  ENDIF.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    "GET_DATA


*&---------------------------------------------------------------------*
*&      Form  INSERT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_DATA.

  "add by AFIR 19-05-2021
  CLEAR IT_TEMP. REFRESH IT_TEMP.
  IT_TEMP[] = IT_DATA[].
  SORT IT_TEMP BY WERKS.
  READ TABLE IT_TEMP WITH KEY WERKS = 'UNS2'.
  IF SY-SUBRC EQ 0.
    MESSAGE 'PO milik UNS, Pilih GRN from PO UNS.' TYPE 'I'.
    EXIT.
  ENDIF.

  RANGES: R_BWKEY FOR T001K-BWKEY.
  SELECT BWKEY AS LOW INTO CORRESPONDING FIELDS OF TABLE R_BWKEY FROM T001K.
  R_BWKEY-SIGN = 'I'.
  R_BWKEY-OPTION = 'EQ'.
  MODIFY R_BWKEY TRANSPORTING SIGN OPTION WHERE LOW NE ''.

  DELETE IT_TEMP WHERE WERKS NOT IN R_BWKEY.
  IF SY-SUBRC EQ 0.
    MESSAGE 'Terdapat error pada template.' TYPE 'I'.
    EXIT.
  ENDIF.
  "add by AFIR 19-05-2021

  DESCRIBE TABLE IT_DATA LINES V_COUNT.

  LOOP AT IT_DATA.
    CLEAR : L_TA_MSG, IT_DISPLAY.
    REFRESH  L_TA_MSG.
    ADD 1 TO V_PROGRESS .
    CONCATENATE 'PROCESSING' V_PROGRESS 'OF' V_COUNT INTO V_TEXT SEPARATED BY SPACE.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = V_PROGRESS
        TEXT       = V_TEXT.

    REFRESH BDC_DATA[].

    BDC_DYNPRO   BDC_DATA  'SAPMM07M' '0200'.
    BDC_FIELD    BDC_DATA  'BDC_CURSOR' 'RM07M-EBELP'.
    BDC_FIELD    BDC_DATA  'BDC_OKCODE' '/00'.
    BDC_FIELD    BDC_DATA  'MKPF-BLDAT' ZDATUM.
    BDC_FIELD    BDC_DATA  'MKPF-BUDAT' ZDATUM.
    BDC_FIELD    BDC_DATA  'RM07M-LFSNR'  IT_DATA-LFSNR.
    BDC_FIELD    BDC_DATA  'MKPF-FRBNR' IT_DATA-FRBNR.
    BDC_FIELD    BDC_DATA  'MKPF-BKTXT' IT_DATA-BKTXT.
    BDC_FIELD    BDC_DATA  'RM07M-BWARTWE' '101'.
    BDC_FIELD    BDC_DATA  'RM07M-EBELN' IT_DATA-EBELN.
    BDC_FIELD    BDC_DATA  'RM07M-EBELP' IT_DATA-EBELP.
    BDC_FIELD    BDC_DATA  'RM07M-WERKS' IT_DATA-WERKS.
    BDC_FIELD    BDC_DATA  'RM07M-LGORT' IT_DATA-LGORT.
    BDC_FIELD    BDC_DATA  'XFULL' 'X'.
    BDC_FIELD    BDC_DATA  'RM07M-WVERS1' 'X'.

    BDC_DYNPRO   BDC_DATA  'SAPMM07M' '0221'.
    BDC_FIELD    BDC_DATA  'BDC_CURSOR' 'MSEG-ERFMG(01)'.
    BDC_FIELD       BDC_DATA 'BDC_OKCODE' '=SP'.
    BDC_FIELD    BDC_DATA  'MSEG-ERFMG(01)' IT_DATA-ERFMG.
    BDC_DYNPRO   BDC_DATA  'SAPMM07M' '0210'.
    BDC_FIELD    BDC_DATA  'BDC_OKCODE' '=BU'.
    BDC_FIELD    BDC_DATA  'VM07M-LICHA' IT_DATA-LICHA.

    CALL TRANSACTION 'MB01' USING BDC_DATA
                                     MODE MODE
                                     UPDATE UPDATE
                                     MESSAGES INTO L_TA_MSG.
    COMMIT WORK AND WAIT.

    CLEAR : L_TA_MSG, IT_DISPLAY.
*    REFRESH : L_TA_MSG, IT_DISPLAY.
    MOVE-CORRESPONDING IT_DATA TO IT_DISPLAY.
    READ TABLE L_TA_MSG INTO WA_L_TA_MSG WITH KEY MSGNR ='060'.
    IF SY-SUBRC = 0.
      IT_DISPLAY-ICON = ICON_GREEN_LIGHT.
      IT_DISPLAY-MBLNR = WA_L_TA_MSG-MSGV1.
      IT_DISPLAY-STATUS = 'SUCCESS'.

      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          MSGID               = WA_L_TA_MSG-MSGID
          MSGNR               = WA_L_TA_MSG-MSGNR
          MSGV1               = WA_L_TA_MSG-MSGV1
          MSGV2               = WA_L_TA_MSG-MSGV2
          MSGV3               = WA_L_TA_MSG-MSGV3
          MSGV4               = WA_L_TA_MSG-MSGV4
        IMPORTING
          MESSAGE_TEXT_OUTPUT = TEMP_MSG.

      IT_DISPLAY-TEXT = TEMP_MSG.
      SELECT SINGLE CHARG INTO IT_DISPLAY-CHARG FROM MSEG WHERE MBLNR = WA_L_TA_MSG-MSGV1.
      SELECT SINGLE MATNR INTO IT_DISPLAY-MATNR FROM MSEG WHERE MBLNR = WA_L_TA_MSG-MSGV1.
      "Add new company - Copy Characteristic TYB Lot & Roll Number when plant TTE
      IF IT_DISPLAY-WERKS EQ 'TTE'.
        PERFORM GET_CHAR_VAL USING IT_DISPLAY-LICHA IT_DISPLAY-MATNR IT_DISPLAY-CHARG.
      ENDIF.
      "End add new company - Copy Characteristic TYB Lot & Roll Number when plant TTE
      APPEND IT_DISPLAY.
    ELSE.
      DATA : COUNT_MSG TYPE N LENGTH 2.
      DESCRIBE TABLE L_TA_MSG LINES COUNT_MSG.
      COUNT_MSG = COUNT_MSG - 1.
      READ TABLE L_TA_MSG INTO WA_L_TA_MSG INDEX COUNT_MSG.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          MSGID               = WA_L_TA_MSG-MSGID
          MSGNR               = WA_L_TA_MSG-MSGNR
          MSGV1               = WA_L_TA_MSG-MSGV1
          MSGV2               = WA_L_TA_MSG-MSGV2
          MSGV3               = WA_L_TA_MSG-MSGV3
          MSGV4               = WA_L_TA_MSG-MSGV4
        IMPORTING
          MESSAGE_TEXT_OUTPUT = TEMP_MSG.
      IT_DISPLAY-TEXT = TEMP_MSG.
      IT_DISPLAY-ICON = ICON_RED_LIGHT.
      IT_DISPLAY-STATUS = 'FAILED'.
      APPEND IT_DISPLAY.
    ENDIF.
  ENDLOOP.

  "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Insert GRN to AGS SQL
  REFRESH IT_AGSGRN.
  IF IT_DISPLAY[] IS NOT INITIAL.
    READ TABLE IT_DISPLAY WITH KEY WERKS = 'TTE'.

    IF SY-SUBRC EQ 0.
      LOOP AT IT_DISPLAY WHERE STATUS = 'SUCCESS' AND WERKS = 'TTE'.
        CLEAR IT_AGSGRN.
        IT_AGSGRN-CHARG = IT_DISPLAY-CHARG.
        IT_AGSGRN-MBLNR = IT_DISPLAY-MBLNR.
        APPEND IT_AGSGRN.
      ENDLOOP.

      IF SY-SUBRC EQ 0.
        PERFORM F_INSERTAGS_SQL TABLES IT_AGSGRN.
      ENDIF.
    ENDIF.
  ENDIF.
  "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Insert GRN to AGS SQL

ENDFORM.                    "INSERT_DATA

*&---------------------------------------------------------------------*
*&      Form  insert_data_uns
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INSERT_DATA_2.

  CLEAR IT_TEMP. REFRESH IT_TEMP.
  IT_TEMP2[] = IT_DATA2[].
  SORT IT_TEMP2 BY WERKS.
  DELETE IT_TEMP2 WHERE WERKS NE 'UNS2'.
  IF SY-SUBRC EQ 0.
    MESSAGE 'PO selain milik UNS, Pilih GRN from PO.' TYPE 'I'.
    EXIT.
  ENDIF.

  DESCRIBE TABLE IT_DATA2 LINES V_COUNT.

  LOOP AT IT_DATA2.
    CLEAR : L_TA_MSG, IT_DISPLAY.
    REFRESH  L_TA_MSG.
    ADD 1 TO V_PROGRESS .
    CONCATENATE 'PROCESSING' V_PROGRESS 'OF' V_COUNT INTO V_TEXT SEPARATED BY SPACE.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        PERCENTAGE = V_PROGRESS
        TEXT       = V_TEXT.

    REFRESH BDC_DATA[].

    BDC_DYNPRO   BDC_DATA  'SAPMM07M' '0200'.
    BDC_FIELD    BDC_DATA  'BDC_CURSOR' 'RM07M-EBELP'.
    BDC_FIELD    BDC_DATA  'BDC_OKCODE' '/00'.

    IF IT_DATA2-BLDAT NE '' AND IT_DATA2-BUDAT NE ''. "add get date from template when not initial by Afir
      BDC_FIELD    BDC_DATA  'MKPF-BLDAT' IT_DATA2-BLDAT.
      BDC_FIELD    BDC_DATA  'MKPF-BUDAT' IT_DATA2-BUDAT.
    ELSE.
      BDC_FIELD    BDC_DATA  'MKPF-BLDAT' ZDATUM.
      BDC_FIELD    BDC_DATA  'MKPF-BUDAT' ZDATUM.
    ENDIF.

    BDC_FIELD    BDC_DATA  'RM07M-LFSNR'  IT_DATA2-LFSNR.
    BDC_FIELD    BDC_DATA  'MKPF-FRBNR'   IT_DATA2-FRBNR.
    BDC_FIELD    BDC_DATA  'MKPF-BKTXT'   IT_DATA2-BKTXT.
    BDC_FIELD    BDC_DATA  'RM07M-BWARTWE' '101'.
    BDC_FIELD    BDC_DATA  'RM07M-EBELN'  IT_DATA2-EBELN.
    BDC_FIELD    BDC_DATA  'RM07M-EBELP'  IT_DATA2-EBELP.
    BDC_FIELD    BDC_DATA  'RM07M-WERKS'  IT_DATA2-WERKS.
    BDC_FIELD    BDC_DATA  'RM07M-LGORT'  IT_DATA2-LGORT.
    BDC_FIELD    BDC_DATA  'XFULL' 'X'.
    BDC_FIELD    BDC_DATA  'RM07M-WVERS1' 'X'.

    BDC_DYNPRO   BDC_DATA  'SAPMM07M' '0221'.

    IF IT_DATA2-WERKS EQ 'UNS2' AND IT_DATA2-CHARG NE ''. "add Batch external and uom from template by Afir
      BDC_FIELD  BDC_DATA 'MSEG-CHARG(01)' IT_DATA2-CHARG.
      SHIFT IT_DATA2-ERFME LEFT DELETING LEADING SPACE.
      BDC_FIELD  BDC_DATA 'MSEG-ERFME(01)' IT_DATA2-ERFME.
    ENDIF.

    BDC_FIELD    BDC_DATA  'BDC_CURSOR' 'MSEG-ERFMG(01)'.
    BDC_FIELD    BDC_DATA  'BDC_OKCODE' '=SP'.
    BDC_FIELD    BDC_DATA  'MSEG-ERFMG(01)' IT_DATA2-ERFMG.
    BDC_DYNPRO   BDC_DATA  'SAPMM07M' '0210'.
    BDC_FIELD    BDC_DATA  'BDC_OKCODE' '=BU'.
    BDC_FIELD    BDC_DATA  'VM07M-LICHA' IT_DATA2-LICHA.

*    MODE = 'A'.
*    BREAK-POINT.
    CALL TRANSACTION 'MB01' USING BDC_DATA
                                     MODE MODE
                                     UPDATE UPDATE
                                     MESSAGES INTO L_TA_MSG.
    COMMIT WORK AND WAIT.

    CLEAR : L_TA_MSG, IT_DISPLAY.
    MOVE-CORRESPONDING IT_DATA2 TO IT_DISPLAY.
    READ TABLE L_TA_MSG INTO WA_L_TA_MSG WITH KEY MSGNR ='060'.
    IF SY-SUBRC = 0.
      IT_DISPLAY-ICON = ICON_GREEN_LIGHT.
      IT_DISPLAY-MBLNR = WA_L_TA_MSG-MSGV1.
      IT_DISPLAY-STATUS = 'SUCCESS'.

      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          MSGID               = WA_L_TA_MSG-MSGID
          MSGNR               = WA_L_TA_MSG-MSGNR
          MSGV1               = WA_L_TA_MSG-MSGV1
          MSGV2               = WA_L_TA_MSG-MSGV2
          MSGV3               = WA_L_TA_MSG-MSGV3
          MSGV4               = WA_L_TA_MSG-MSGV4
        IMPORTING
          MESSAGE_TEXT_OUTPUT = TEMP_MSG.

      IT_DISPLAY-TEXT = TEMP_MSG.
      SELECT SINGLE CHARG INTO IT_DISPLAY-CHARG FROM MSEG WHERE MBLNR = WA_L_TA_MSG-MSGV1.
      SELECT SINGLE MATNR INTO IT_DISPLAY-MATNR FROM MSEG WHERE MBLNR = WA_L_TA_MSG-MSGV1.
      APPEND IT_DISPLAY.
    ELSE.
      DATA : COUNT_MSG TYPE N LENGTH 2.
      DESCRIBE TABLE L_TA_MSG LINES COUNT_MSG.
      COUNT_MSG = COUNT_MSG - 1.
      READ TABLE L_TA_MSG INTO WA_L_TA_MSG INDEX COUNT_MSG.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          MSGID               = WA_L_TA_MSG-MSGID
          MSGNR               = WA_L_TA_MSG-MSGNR
          MSGV1               = WA_L_TA_MSG-MSGV1
          MSGV2               = WA_L_TA_MSG-MSGV2
          MSGV3               = WA_L_TA_MSG-MSGV3
          MSGV4               = WA_L_TA_MSG-MSGV4
        IMPORTING
          MESSAGE_TEXT_OUTPUT = TEMP_MSG.
      IT_DISPLAY-TEXT = TEMP_MSG.
      IT_DISPLAY-ICON = ICON_RED_LIGHT.
      IT_DISPLAY-STATUS = 'FAILED'.
      APPEND IT_DISPLAY.
    ENDIF.
  ENDLOOP.

  "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Insert GRN to AGS SQL
  REFRESH IT_AGSGRN.
  IF IT_DISPLAY[] IS NOT INITIAL.
    READ TABLE IT_DISPLAY WITH KEY WERKS = 'TTE'.

    IF SY-SUBRC EQ 0.
      LOOP AT IT_DISPLAY WHERE STATUS = 'SUCCESS' AND WERKS = 'TTE'.
        CLEAR IT_AGSGRN.
        IT_AGSGRN-CHARG = IT_DISPLAY-CHARG.
        IT_AGSGRN-MBLNR = IT_DISPLAY-MBLNR.
        APPEND IT_AGSGRN.
      ENDLOOP.

      IF SY-SUBRC EQ 0.
        PERFORM F_INSERTAGS_SQL TABLES IT_AGSGRN.
      ENDIF.
    ENDIF.
  ENDIF.
  "-- ADDED FOR AGS BY FATHIR ON 20.11.2019 - Insert GRN to AGS SQL
ENDFORM.                    "insert_data_uns

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_DATA .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " DISPLAY_DATA
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  DATA : NO TYPE N LENGTH 3 VALUE 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'ICON'.
  WA_FIELDCAT-SELTEXT_M = 'Icon'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'EBELN'.
  WA_FIELDCAT-SELTEXT_M = 'PO Number'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'EBELP'.
  WA_FIELDCAT-SELTEXT_M = 'PO Item'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'MBLNR'.
  WA_FIELDCAT-SELTEXT_M = 'Material Doc'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'MATNR'.
  WA_FIELDCAT-SELTEXT_M = 'Material'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'CHARG'.
  WA_FIELDCAT-SELTEXT_M = 'Batch'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'LICHA'.
  WA_FIELDCAT-SELTEXT_M = 'Vendor Batch'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'WERKS'.
  WA_FIELDCAT-SELTEXT_M = 'Plant'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'LGORT'.
  WA_FIELDCAT-SELTEXT_M = 'Storage Location'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'ERFMG'.
  WA_FIELDCAT-SELTEXT_M = 'Quantity'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'LFSNR'.
  WA_FIELDCAT-SELTEXT_M = 'Delivery Note'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'FRBNR'.
  WA_FIELDCAT-SELTEXT_M = 'Bill of Lading'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'BKTXT'.
  WA_FIELDCAT-SELTEXT_M = 'Doc Header Text'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR WA_FIELDCAT.
  NO = NO + 1.

  WA_FIELDCAT-COL_POS = NO.
  WA_FIELDCAT-TABNAME = 'IT_DISPLAY'.
  WA_FIELDCAT-FIELDNAME = 'TEXT'.
  WA_FIELDCAT-SELTEXT_M = 'Keterangan'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.


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
  IT_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
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
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IS_LAYOUT     = IT_LAYOUT
      IT_FIELDCAT   = IT_FIELDCAT
    TABLES
      T_OUTTAB      = IT_DISPLAY
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.

ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_PROG_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_PROG     text
*----------------------------------------------------------------------*
FORM F_PROG_INFO USING V_PROG LIKE ZPROGINFO-PGMNA.

  DATA: BEGIN OF LINES OCCURS 50.
          INCLUDE STRUCTURE TLINE.
  DATA: END OF LINES.

  DATA: IT_PROG LIKE ZPROGINFO OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF EXCLUDE OCCURS 10,
          FUNC LIKE RSNEWLENG-FCODE,
        END OF EXCLUDE.

  DATA: HINFO LIKE HELP_INFO.

  HINFO-TITLE = 'Program Documentation'.
*  hinfo-docuid = 'DT'.
*  hinfo-DOCUOBJECT = '%_SELSCREEN_1000'.

  EXCLUDE-FUNC = 'DEIN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIE'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFUN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DINF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'ERHI'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DMEN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DWFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'VPFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DTRA'. APPEND EXCLUDE.

  EXCLUDE-FUNC = 'DBF4'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DPRB'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DEIN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIE'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFUN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DINF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'ERHI'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DMEN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DWFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'VPFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DTRA'. APPEND EXCLUDE.

  EXCLUDE-FUNC = 'DEIN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIE'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFIF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DFUN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DINF'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'ERHI'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DMEN'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DWFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'VPFL'. APPEND EXCLUDE.
  EXCLUDE-FUNC = 'DTRA'. APPEND EXCLUDE.

*--- get program documentation
  SELECT * INTO TABLE IT_PROG
  FROM ZPROGINFO
  WHERE PGMNA = V_PROG.

  SORT IT_PROG BY LINE.
  IF SY-SUBRC = 0.
    LOOP AT IT_PROG.
      LINES-TDFORMAT = IT_PROG-TDFORMAT.
      LINES-TDLINE   = IT_PROG-TDLINE.
      APPEND LINES.
    ENDLOOP.
  ELSE.
    LINES-TDFORMAT = 'AS'.
    LINES-TDLINE   = 'Program Untuk Upload GRN By PO'.
    APPEND LINES.
  ENDIF.

  CALL FUNCTION 'HELP_DOCULINES_SHOW'
    EXPORTING
      CUCOL             = 10
      CUROW             = 3
      HELP_INFOS        = HINFO
      NOT_HELP          = 'X'
      CLASSIC_SAPSCRIPT = 'X'
    TABLES
      EXCLUDEFUN        = EXCLUDE
      HELPLINES         = LINES.

ENDFORM.                    "f_prog_info                  " F_LIST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_INSERTAGS_SQL
*&---------------------------------------------------------------------*
*       Insert GR data to AGS SQL database (TTE Only)
*
*       ADDED FOR AGS BY FATHIR ON 20.11.2019
*----------------------------------------------------------------------*
*      -->PIN_GRN    text
*----------------------------------------------------------------------*
FORM F_INSERTAGS_SQL
  TABLES PIN_GRN LIKE IT_AGSPARAM.

  RANGES: R_MBLNR FOR MKPF-MBLNR,
          R_CHARG FOR MCH1-CHARG.
  REFRESH: R_MBLNR,
           R_CHARG.
  CLEAR: R_MBLNR,
         R_CHARG.

  IF PIN_GRN[] IS NOT INITIAL.

    LOOP AT PIN_GRN.

      CLEAR R_MBLNR.
      R_MBLNR-SIGN = 'I'.
      R_MBLNR-OPTION = 'EQ'.
      R_MBLNR-LOW = PIN_GRN-MBLNR.
      APPEND R_MBLNR.

      CLEAR R_CHARG.
      R_CHARG-SIGN = 'I'.
      R_CHARG-OPTION = 'EQ'.
      R_CHARG-LOW = PIN_GRN-CHARG.
      APPEND R_CHARG.

    ENDLOOP.

    SUBMIT ZTMM_GRN_PO_AGS
      WITH S_MBLNR IN R_MBLNR
      WITH S_CHARG IN R_CHARG
      AND RETURN.
  ENDIF.
ENDFORM.                    "F_INSERTAGS_SQL

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM VALIDATE_DATA.

  DATA : VMENGE LIKE MSEG-MENGE.
  DATA : LSEQ TYPE I VALUE 0,
         VMSG TYPE STRING.
  REFRESH LMSG.
  CLEAR LMSG.

  LOOP AT IT_DATA.
    CLEAR VMENGE.

    IF IT_DATA-LICHA IS NOT INITIAL.

      SELECT MENGE INTO VMENGE
        FROM MSEG
        WHERE CHARG = IT_DATA-LICHA AND BWART = '601'.
      ENDSELECT.

      IF SY-SUBRC = 0.
        IF VMENGE <> IT_DATA-ERFMG.
          LSEQ = LSEQ + 1.
          LMSG-MSGID = '00'.
          LMSG-MSGTY = 'E'.
          LMSG-MSGNO = '1'.
          CONCATENATE 'Quantity GR pada Batch Vendor ' IT_DATA-LICHA ' Berbeda' INTO LMSG-MSGV1 SEPARATED BY SPACE.
          MOVE LSEQ TO LMSG-LINENO.
          APPEND LMSG.
          CLEAR LMSG.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "VALIDATE_DATA