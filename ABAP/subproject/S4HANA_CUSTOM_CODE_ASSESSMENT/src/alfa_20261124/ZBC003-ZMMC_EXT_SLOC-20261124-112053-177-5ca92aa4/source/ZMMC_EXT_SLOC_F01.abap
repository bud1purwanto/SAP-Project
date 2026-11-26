*&---------------------------------------------------------------------*
*&  Include           ZMMC_EXT_SLOC_F01
*&---------------------------------------------------------------------*

INCLUDE Z_PROG_INFO.

START-OF-SELECTION.
AT SELECTION-SCREEN.
    CASE SY-UCOMM.
      WHEN 'INFO'.
        PERFORM F_PROG_INFO USING V_PROG.
    ENDCASE.
        PERFORM GET_DATA.
        PERFORM UPLOADDATA.
        PERFORM DISPLAYREPORT.

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
       LINE TYPE I,
       NOERR TYPE I,
       MESSAGE LIKE BAPIRET2-MESSAGE,
       MESSAGE_V1 LIKE  BAPIRET2-MESSAGE_V1,
       MESSAGE_V2 LIKE  BAPIRET2-MESSAGE_V2,
       MESSAGE_V3 LIKE  BAPIRET2-MESSAGE_V3,
       MESSAGE_V4 LIKE  BAPIRET2-MESSAGE_V4,
       ID LIKE  BAPIRET2-ID,
       NUMBER LIKE  BAPIRET2-NUMBER,
       WA_MSGS LIKE LINE OF MSGS,
       CTR TYPE I,
       LGORT TYPE MARD-LGORT.

  CLEAR IT_REPORT. REFRESH IT_REPORT.
  IF ITAB[] IS NOT INITIAL.
    CLEAR : LINE.
    LOOP AT ITAB.
      CLEAR: BDCDATA, MESSTAB, MSGS, LGORT.
      REFRESH: BDCDATA, MESSTAB, MSGS.
      CLEAR : NOERR.
      LINE = LINE + 1.

      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          INPUT              = ITAB-MATNR
       IMPORTING
         OUTPUT             = ITAB-MATNR
       EXCEPTIONS
         LENGTH_ERROR       = 1
         OTHERS             = 2
                .
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.

      SELECT SINGLE LGORT
        INTO LGORT
        FROM MARD
        WHERE MATNR = ITAB-MATNR AND
              LGORT EQ ITAB-LGORT AND
              WERKS = ITAB-WERKS. " add for new company

      IF CTUMODE EQ 'A'.
        perform bdc_dynpro      using 'SAPMM03M' '0105'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'RM03M-NFLAG'.
        perform bdc_field       using 'BDC_OKCODE'
                                      '/00'.
        perform bdc_field       using 'RM03M-MATNR'
                                       ITAB-MATNR. "'IRM03'.
        perform bdc_field       using 'RM03M-WERKS'
                                       ITAB-WERKS. "'2000'.
        perform bdc_field       using 'RM03M-LFLAG'
                                       ''. "ITAB-LFLAG. "''.
        perform bdc_field       using 'RM03M-NFLAG'
                                       'X'. "ITAB-NFLAG. "'X'.
        perform bdc_dynpro      using 'SAPMM03M' '0195'.
        perform bdc_field       using 'BDC_CURSOR'
                                      'RM03M-LGORT(09)'. " kalau (01) terkadang field terisi
        perform bdc_field       using 'BDC_OKCODE'
                                      '=BU'.
        perform bdc_field       using 'RM03M-LGORT(09)'
                                      ITAB-LGORT. "'2002'.
*        perform bdc_transaction using 'MMSC'.
        CALL TRANSACTION 'MMSC' USING BDCDATA
                                    MODE CTUMODE
                                    UPDATE 'S'
                                    MESSAGES INTO MSGS.
      ELSE.
        IF LGORT EQ ''.
          perform bdc_dynpro      using 'SAPMM03M' '0105'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'RM03M-NFLAG'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '/00'.
          perform bdc_field       using 'RM03M-MATNR'
                                         ITAB-MATNR. "'IRM03'.
          perform bdc_field       using 'RM03M-WERKS'
                                         ITAB-WERKS. "'2000'.
          perform bdc_field       using 'RM03M-LFLAG'
                                         ''. "ITAB-LFLAG. "''.
          perform bdc_field       using 'RM03M-NFLAG'
                                         'X'. "ITAB-NFLAG. "'X'.
          perform bdc_dynpro      using 'SAPMM03M' '0195'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'RM03M-LGORT(09)'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=BU'.
          perform bdc_field       using 'RM03M-LGORT(09)'
                                        ITAB-LGORT. "'2002'.
*          perform bdc_transaction using 'MMSC'.
          CALL TRANSACTION 'MMSC' USING BDCDATA
                                      MODE CTUMODE
                                      UPDATE 'S'
                                      MESSAGES INTO MSGS.
        ENDIF.
      ENDIF.

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
          IT_REPORT-WERKS = ITAB-WERKS.
          IT_REPORT-LFLAG = ITAB-LFLAG.
          IT_REPORT-NFLAG = ITAB-NFLAG.
          IT_REPORT-LGORT = ITAB-LGORT.
          APPEND IT_REPORT.
        ENDIF.
      ELSE.
            CLEAR: MESSAGE.
            NOERR = NOERR + 1.
            CONCATENATE 'Storage Location Variant fo Material ' ITAB-MATNR 'Created' INTO MESSAGE SEPARATED BY SPACE.
            IT_REPORT-LINE = LINE.
            IT_REPORT-STAT = GCF_S1.
            IT_REPORT-MESSAGE = MESSAGE.
            IT_REPORT-NOERR = NOERR.
            IT_REPORT-MATNR = ITAB-MATNR.
            IT_REPORT-WERKS = ITAB-WERKS.
            IT_REPORT-LFLAG = ITAB-LFLAG.
            IT_REPORT-NFLAG = ITAB-NFLAG.
            IT_REPORT-LGORT = ITAB-LGORT.
            APPEND IT_REPORT.
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
  CLEAR T_FIELDCAT. REFRESH T_FIELDCAT.
    PERFORM F_ALV_FIELDCATG_ICON USING 'IT_REPORT' :
        'LINE' '' ''  '' ''  'Line'      '' ' ' '' '',
        'STAT' '' ''  '' ''  'Status'      '' ' ' '' '',
        'MESSAGE' '' ''  '' ''  'Message'      '' ' ' '' '',
        'MATNR' '' ''  '' ''  'Material Number'      '' ' ' '' '',
        'WERKS' '' ''  '' ''  'Plant'      '' ' ' '' '',
        'LFLAG' '' ''  '' ''  'List All Existing Storage Locations (Collective Entry)'      '' ' ' '' '',
        'NFLAG' '' ''  '' ''  'List Extendable Storage Locations Only (Collective Entry)'      '' ' ' '' '',
        'LGORT' '' ''  '' ''  'Storage Location'      '' ' ' '' ''.
ENDFORM.                    " F_FIELD_CATALOG

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

ENDFORM.