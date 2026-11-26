*&---------------------------------------------------------------------*
*&  Include           ZMMC_PROP_F01
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
       VPSTAT LIKE MARA-PSTAT.

  CLEAR IT_REPORT. REFRESH IT_REPORT.
  IF ITAB[] IS NOT INITIAL.
     LOOP AT ITAB.
       CLEAR: BDCDATA, MESSTAB, MSGS, NOERR.
       REFRESH: BDCDATA, MESSTAB, MSGS.
          LINE = LINE + 1.

          perform bdc_dynpro      using 'SAPLMGMM' '0060'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'RMMG1-MATNR'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=ENTR'.
          perform bdc_field       using 'RMMG1-MATNR'
                                         ITAB-MATNR.  "'PU1'.

          perform bdc_dynpro      using 'SAPLMGMM' '0070'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'MSICHTAUSW-DYTXT(02)'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=ENTR'.

          perform bdc_field       using 'MSICHTAUSW-KZSEL(02)'
                                        'X'.

          perform bdc_dynpro      using 'SAPLMGMM' '4004'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=ZU01'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'MARA-KZKFG'.
          IF ITAB-MATNR(2) EQ 'SR' AND  ITAB-MATNR+5(1) EQ 'A'.
            perform bdc_field       using 'MARA-KZKFG'
                                          ''.
          ELSEIF ITAB-MATNR(2) EQ 'SR'.
            perform bdc_field       using 'MARA-KZKFG'
                                          'X'.
          ELSEIF ITAB-MATNR(2) EQ 'JR'.
            CLEAR: VPSTAT.
            SELECT SINGLE PSTAT FROM MARA INTO VPSTAT WHERE MATNR = ITAB-MATNR.
            IF VPSTAT CS 'V'.
              perform bdc_field       using 'MARA-KZKFG'
                                          'X'.
            ENDIF.
          ENDIF.

          perform bdc_dynpro      using 'SAPLMGMM' '4300'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=ZU09'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'SKTEXT-SPRAS(01)'.

          perform bdc_dynpro      using 'SAPLMGMM' '4300'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=WSPR'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'SMEINH_WS-ATWRT(01)'.
          perform bdc_field       using 'MARA-KZWSM'
                                        'B'.

          perform bdc_dynpro      using 'SAPLMGMM' '4300'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '/00'.
          perform bdc_field       using 'BDC_CURSOR'
                                        'SMEINH_WS-WSMEI(03)'.
          perform bdc_field       using 'MARA-KZWSM'
                                        'B'.
          perform bdc_field       using 'SMEINH_WS-ATNAM(01)'
                                         ITAB-ATNAM1. "'ZZCONVERSIONROLLKG'.
          perform bdc_field       using 'SMEINH_WS-ATNAM(02)'
                                         ITAB-ATNAM2. "'ZZCONVERSIONKGM2'.
          perform bdc_field       using 'SMEINH_WS-ATNAM(03)'
                                         ITAB-ATNAM3. "'ZZCONVERSIONMTRKG'.
          perform bdc_field       using 'SMEINH_WS-ATWRT(01)'
                                         ITAB-ATWRT1. "'1'.
          perform bdc_field       using 'SMEINH_WS-ATWRT(02)'
                                         ITAB-ATWRT2. "'20'.
          perform bdc_field       using 'SMEINH_WS-ATWRT(03)'
                                         ITAB-ATWRT3. "'3'.
          perform bdc_field       using 'SMEINH_WS-WSMEI(01)'
                                         ITAB-WESMEI1.  "'ROL'.
          perform bdc_field       using 'SMEINH_WS-WSMEI(02)'
                                         ITAB-WESMEI2.  "'M2'.
          perform bdc_field       using 'SMEINH_WS-WSMEI(03)'
                                         ITAB-WESMEI3.  "'M'.

          perform bdc_dynpro      using 'SAPLMGMM' '4300'.
          perform bdc_field       using 'BDC_OKCODE'
                                        '=BU'.

*          perform bdc_transaction using 'MM02'.
          CALL TRANSACTION 'MM02' USING BDCDATA
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
                IT_REPORT-ATNAM1 = ITAB-ATNAM1.
                IT_REPORT-ATWRT1 = ITAB-ATWRT1.
                IT_REPORT-WESMEI1 = ITAB-WESMEI1.
                IT_REPORT-ATNAM2 = ITAB-ATNAM2.
                IT_REPORT-ATWRT2 = ITAB-ATWRT2.
                IT_REPORT-WESMEI2 = ITAB-WESMEI2.
                IT_REPORT-ATNAM3 = ITAB-ATNAM3.
                IT_REPORT-ATWRT3 = ITAB-ATWRT3.
                IT_REPORT-WESMEI3 = ITAB-WESMEI3.
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
        'ATNAM1' '' ''  '' ''  'Characteristic Name 1'      '' ' ' '' '',
        'ATWRT1' '' ''  '' ''  'Planned value for unit of meas. (planned proport./convers.)1'      '' ' ' '' '',
        'WESMEI1' '' ''  '' ''  'Batch-specific matl unit of measure (proportion/prod. unit)1'      '' ' ' '' '',
        'ATNAM2' '' ''  '' ''  'Characteristic Name 2'      '' ' ' '' '',
        'ATWRT2' '' ''  '' ''  'Planned value for unit of meas. (planned proport./convers.)2'      '' ' ' '' '',
        'WESMEI2' '' ''  '' ''  'Batch-specific matl unit of measure (proportion/prod. unit)2'      '' ' ' '' '',
        'ATNAM3' '' ''  '' ''  'Characteristic Name 3'      '' ' ' '' '',
        'ATWRT3' '' ''  '' ''  'Planned value for unit of meas. (planned proport./convers.)3'      '' ' ' '' '',
        'WESMEI3' '' ''  '' ''  'Batch-specific matl unit of measure (proportion/prod. unit)3'      '' ' ' '' ''.
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