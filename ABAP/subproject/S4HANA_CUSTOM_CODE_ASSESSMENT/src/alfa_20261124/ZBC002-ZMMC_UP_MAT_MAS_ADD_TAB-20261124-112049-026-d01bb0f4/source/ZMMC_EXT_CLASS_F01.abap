*&---------------------------------------------------------------------*
*&  Include           ZMMC_EXT_CLASS_F01
*&---------------------------------------------------------------------*
INCLUDE Z_PROG_INFO.

START-OF-SELECTION.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'INFO'.
      PERFORM F_PROG_INFO USING V_PROG.
    WHEN OTHERS.
      PERFORM GET_DATA.
      PERFORM UPLOADDATA.
      PERFORM DISPLAYREPORT.
  ENDCASE.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .
  DATA: FILENAME1 TYPE STRING.

  MOVE FILENAME TO FILENAME1.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      FILENAME            = FILENAME1
      FILETYPE            = 'ASC'
      HAS_FIELD_SEPARATOR = 'X'
    TABLES
      DATA_TAB            = ITAB
    EXCEPTIONS
      CONVERSION_ERROR    = 1
      INVALID_TABLE_WIDTH = 2
      INVALID_TYPE        = 3
      NO_BATCH            = 4
      UNKNOWN_ERROR       = 5
      FILE_OPEN_ERROR     = 6
      FILE_READ_ERROR     = 7
      OTHERS              = 8.

  IF SY-SUBRC <> 0.
    MESSAGE I000(0K) WITH 'File cannot be opened'.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  UPLOADDATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPLOADDATA .
  DATA : MSGS  LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE,
         WA_MSGS LIKE LINE OF MSGS,
         LINE TYPE I,
         CTR TYPE I,
         NOERR TYPE I,
         MESSAGE LIKE BAPIRET2-MESSAGE,
         MESSAGE_V1 LIKE  BAPIRET2-MESSAGE_V1,
         MESSAGE_V2 LIKE  BAPIRET2-MESSAGE_V2,
         MESSAGE_V3 LIKE  BAPIRET2-MESSAGE_V3,
         MESSAGE_V4 LIKE  BAPIRET2-MESSAGE_V4,
         ID LIKE  BAPIRET2-ID,
         NUMBER LIKE  BAPIRET2-NUMBER.

  CLEAR IT_REPORT. REFRESH IT_REPORT.
  IF ITAB[] IS NOT INITIAL.
    CLEAR LINE.
    ITAB2[] = ITAB[].
*       DELETE ADJACENT DUPLICATES FROM ITAB COMPARING MATNR KLART1 KLART2.
    LOOP AT ITAB.
      CLEAR: BDCDATA, MESSTAB, MSGS, NOERR, WA_MSGS, CTR.
      REFRESH: BDCDATA, MESSTAB, MSGS.
      LINE = LINE + 1.
      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0060'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'RMMG1-MATNR'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=ENTR'.
      PERFORM BDC_FIELD       USING 'RMMG1-MATNR'
                                     ITAB-MATNR.  "'LSMW41'.
      PERFORM BDC_FIELD       USING 'RMMG1-MBRSH'
                                     ITAB-MBRSH.  "'M'.
      PERFORM BDC_FIELD       USING 'RMMG1-MTART'
                                     ITAB-MTART.  "'ZSFG'.


      PERFORM BDC_DYNPRO      USING 'SAPLMGMM' '0070'.
      PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                    'MSICHTAUSW-DYTXT(03)'.
      PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                    '=ENTR'.
      PERFORM BDC_FIELD       USING 'MSICHTAUSW-KZSEL(03)'
                                    'X'.

      IF ITAB-KLART2 = ' '.
        LOOP AT ITAB2 WHERE MATNR = ITAB-MATNR AND KLART1 = ITAB-KLART1 AND KLART2 = ITAB-KLART2.
          PERFORM BDC_DYNPRO      USING 'SAPLCLCA' '0602'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RMCLF-KLART'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ENTE'.
          PERFORM BDC_FIELD       USING 'RMCLF-KLART'
                                         ITAB2-KLART1. "'023'.


          PERFORM BDC_DYNPRO      USING 'SAPLCLFM' '0500'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RMCLF-CLASS(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '/00'.
          PERFORM BDC_FIELD       USING 'RMCLF-CLASS(01)'
                                         ITAB2-CLASS1. "'ZZJRBOPET'.


          PERFORM BDC_DYNPRO      USING 'SAPLCTMS' '0109'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RCTMS-MWERT(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=BACK'.
          PERFORM BDC_FIELD       USING 'RCTMS-MNAME(01)'
                                         ITAB2-MNAME1.  "'ZZCODE'.
          PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'
                                         ITAB2-MWERT1. "'VPC'.

          PERFORM BDC_DYNPRO      USING 'SAPLCLFM' '0500'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RMCLF-CLASS(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=SAVE'.
*      *          perform bdc_field       using 'RMCLF-PAGPOS'
*      *                                        '1'.
        ENDLOOP.
      ELSE.
        LOOP AT ITAB2 WHERE MATNR = ITAB-MATNR AND KLART1 = ITAB-KLART1 AND KLART2 = ITAB-KLART2.
          PERFORM BDC_DYNPRO      USING 'SAPLCLCA' '0602'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RMCLF-KLART'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ENTE'.
          PERFORM BDC_FIELD       USING 'RMCLF-KLART'
                                         ITAB2-KLART1. "'023'.


          PERFORM BDC_DYNPRO      USING 'SAPLCLFM' '0500'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RMCLF-CLASS(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '/00'.
          PERFORM BDC_FIELD       USING 'RMCLF-CLASS(01)'
                                         ITAB2-CLASS1. "'ZZJRBOPET'.


          PERFORM BDC_DYNPRO      USING 'SAPLCTMS' '0109'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RCTMS-MWERT(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=BACK'.
          PERFORM BDC_FIELD       USING 'RCTMS-MNAME(01)'
                                         ITAB2-MNAME1.  "'ZZCODE'.
          PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'
                                         ITAB2-MWERT1. "'VPC'.


          PERFORM BDC_DYNPRO      USING 'SAPLCLFM' '0500'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RMCLF-CLASS(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=WECH'.
          PERFORM BDC_FIELD       USING 'RMCLF-PAGPOS'
                                        '1'.


          PERFORM BDC_DYNPRO      USING 'SAPLCLCA' '0602'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RMCLF-KLART'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=ENTE'.
          PERFORM BDC_FIELD       USING 'RMCLF-KLART'
                                         ITAB2-KLART2. "'300'.


          PERFORM BDC_DYNPRO      USING 'SAPLCLFM' '0500'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RMCLF-CLASS(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '/00'.
          PERFORM BDC_FIELD       USING 'RMCLF-CLASS(01)'
                                         ITAB2-CLASS2. "'ZZSRNORM'.


          PERFORM BDC_DYNPRO      USING 'SAPLCTMS' '0109'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RCTMS-MWERT(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=BACK'.
          PERFORM BDC_FIELD       USING 'RCTMS-MNAME(01)'
                                         ITAB2-MNAME2. "'ZZCODE'.
          PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'
                                         ITAB2-MWERT2. "'PEO'.


          PERFORM BDC_DYNPRO      USING 'SAPLCLFM' '0500'.
          PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                        'RMCLF-CLASS(01)'.
          PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                        '=SAVE'.
          PERFORM BDC_FIELD       USING 'RMCLF-PAGPOS'
                                        '1'.
        ENDLOOP.
      ENDIF.

*     perform bdc_transaction using 'MM01'.
      CALL TRANSACTION 'MM01' USING BDCDATA
                                  MODE CTUMODE
                                  UPDATE 'S'
                                  MESSAGES INTO MSGS.

      IF MSGS[] IS NOT INITIAL.
        CLEAR : WA_MSGS, CTR.
        CTR = LINES( MSGS ).
        READ TABLE MSGS INDEX CTR.
        WA_MSGS = MSGS.
          IF WA_MSGS-MSGTYP NE ''.
                    CLEAR MESSAGE.
                    CLEAR: MESSAGE, MESSAGE_V1, MESSAGE_V2, MESSAGE_V3, MESSAGE_V4, ID, NUMBER.
                    ID = WA_MSGS-MSGID.
                    NUMBER =  WA_MSGS-MSGNR.
                    MESSAGE_V1 = WA_MSGS-MSGV1.
                    MESSAGE_V2 = WA_MSGS-MSGV2.
                    MESSAGE_V3 = WA_MSGS-MSGV3.
                    MESSAGE_V4 = WA_MSGS-MSGV4.

                      CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
                      EXPORTING
                        ID         = ID
                        NUMBER     = NUMBER
                        LANGUAGE   = SY-LANGU
                        TEXTFORMAT = 'HTM'
                        MESSAGE_V1 = MESSAGE_V1
                        MESSAGE_V2 = MESSAGE_V2
                        MESSAGE_V3 = MESSAGE_V3
                        MESSAGE_V4 = MESSAGE_V4
                      IMPORTING
                        MESSAGE    = MESSAGE.

                  NOERR = NOERR + 1.
                  IT_REPORT-LINE = LINE.
                  IF WA_MSGS-MSGTYP EQ 'E'.
                    IT_REPORT-STAT = GCF_E1.
                  ELSE.
                    IT_REPORT-STAT = GCF_S1.
                  ENDIF.
                  IT_REPORT-MESSAGE = MESSAGE.
                  IT_REPORT-NOERR = NOERR.
                  IT_REPORT-MATNR = ITAB-MATNR.
                  IT_REPORT-MBRSH = ITAB-MBRSH.
                  IT_REPORT-MTART = ITAB-MTART.
                  IT_REPORT-KLART1 = ITAB-KLART1.
                  IT_REPORT-CLASS1 = ITAB-CLASS1.
                  IT_REPORT-MNAME1 = ITAB-MNAME1.
                  IT_REPORT-MWERT1 = ITAB-MWERT1.
                  IT_REPORT-KLART2 = ITAB-KLART2.
                  IT_REPORT-CLASS2 = ITAB-CLASS2.
                  IT_REPORT-MNAME2 = ITAB-MNAME2.
                  IT_REPORT-MWERT2 = ITAB-MWERT2.
                  APPEND IT_REPORT.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " UPLOADDATA

*&---------------------------------------------------------------------*
*&      Form  DISPLAYREPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAYREPORT .
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    " DISPLAYREPORT

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR: T_FIELDCAT. REFRESH T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_REPORT' :
      'LINE' '' ''  '' ''  'Line'      '' ' ' '' '',
      'STAT' '' ''  '' ''  'Status'      '' ' ' '' '',
      'MESSAGE' '' ''  '' ''  'Message'      '' ' ' '' '',
      'MATNR' '' ''  '' ''  'Material Number'      '' ' ' '' '',
      'MBRSH' '' ''  '' ''  'Industry sector'      '' ' ' '' '',
      'MTART' '' ''  '' ''  'Material Type'      '' ' ' '' '',
      'KLART1' '' ''  '' ''  'Class Type 1'      '' ' ' '' '',
      'CLASS1' '' ''  '' ''  'Class number 1'      '' ' ' '' '',
      'MNAME1' '' ''  '' ''  'Characteristic description 1'      '' ' ' '' '',
      'MWERT1' '' ''  '' ''  'Characteristic Value 1'      '' ' ' '' '',
      'KLART2' '' ''  '' ''  'Class Type 2'      '' ' ' '' '',
      'CLASS2' '' ''  '' ''  'Class number 2'      '' ' ' '' '',
      'MNAME2' '' ''  '' ''  'Characteristic description 2'      '' ' ' '' '',
      'MWERT2' '' ''  '' ''  'Characteristic Value 2'      '' ' ' '' ''.
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
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
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
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM      = D_REPID
      I_CALLBACK_USER_COMMAND = 'F_USER_COMMAND'
      IS_LAYOUT               = WA_LAYOUT
      IT_FIELDCAT             = T_FIELDCAT[]
      IT_EVENTS               = T_EVENTS[]
      IT_EVENT_EXIT           = T_EVENT_EXIT[]
      I_DEFAULT               = 'X'
      I_SAVE                  = 'A'
      IS_VARIANT              = WA_VARIANTE
      IS_PRINT                = T_PRINT
      IT_SORT                 = T_SORT[]
      IT_EXCLUDING            = T_EXCLUDING[]
      I_BYPASSING_BUFFER      = 'X'
    TABLES
      T_OUTTAB                = IT_REPORT
    EXCEPTIONS
      PROGRAM_ERROR           = 1
      OTHERS                  = 2.
ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_ALV_FIELDCATG_ICON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_ALV_FIELDCATG_ICON USING FU_TYPES
                                FU_FNAME
                                FU_REFTB
                                FU_REFLD
                                FU_NOOUT
                                FU_OUTLN
                                FU_FLTXT
                                FU_DOSUM
                                FU_HOTSP
                                FU_JUST
                                FU_ICON.


  CLEAR: T_FIELDCAT.
  T_FIELDCAT-TABNAME       = FU_TYPES.
  T_FIELDCAT-FIELDNAME     = FU_FNAME.
  T_FIELDCAT-REF_TABNAME   = FU_REFTB.
  T_FIELDCAT-REF_FIELDNAME = FU_REFLD.
  T_FIELDCAT-NO_OUT        = FU_NOOUT.
  T_FIELDCAT-OUTPUTLEN     = FU_OUTLN.
  T_FIELDCAT-SELTEXT_L     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
*  T_FIELDCAT-NO_ZERO       = 'X'.
  T_FIELDCAT-FIX_COLUMN    = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " F_ALV_FIELDCATG_ICON

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM  = PROGRAM.
  BDCDATA-DYNPRO   = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.                    "BDC_DYNPRO
*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.
ENDFORM.                    "BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_UCOMM     text
*      -->FU_SELFIELD  text
*----------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
*  DATA: LT_HUS TYPE HUM_VENUM_T.
*
*  SY-LSIND = 0.
*  CASE FU_UCOMM.
*    WHEN '&IC1'.
*      READ TABLE ITAB INDEX FU_SELFIELD-TABINDEX ASSIGNING <FS_ITEM1>.
*      CASE FU_SELFIELD-SEL_TAB_FIELD.
*        WHEN 'ITAB-EQUNR'.
*          SET PARAMETER ID 'EQN' FIELD <FS_ITEM1>-EQUNR.
*          CALL TRANSACTION 'IE03' AND SKIP FIRST SCREEN.
*      ENDCASE.
*  ENDCASE.

ENDFORM.                    "F_USER_COMMAND