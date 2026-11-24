*&---------------------------------------------------------------------*
*&  Report     :  ZMMR_LABELROL_KTNG_REPRINT                           *
*&  Appl. Area :  MM                                                   *
*&  Created by :  Mualifi                                              *
*&  Created on :  28 April 2020                                        *
*&---------------------------------------------------------------------*

REPORT  ZMMR_LABELROL_KTNG_REPRINT.
DATA  : P_FILE  TYPE STRING,
        FNAME   TYPE STRING,
        FPATH   TYPE IBIPPARMS-PATH,
        MATID   TYPE MBLPO.

DATA  : FILENAME1 TYPE STRING,
        NOMER     TYPE P.

TYPES: BEGIN OF T_TAB.
        INCLUDE STRUCTURE ZLABEL_WINDOWS.
TYPES: BOX(1).
TYPES: COLOR(4).
TYPES: REMARKS(100).
TYPES: END OF T_TAB.

DATA: ITAB TYPE STANDARD TABLE OF T_TAB WITH HEADER LINE,
      ITAB2 LIKE ITAB OCCURS 0 WITH HEADER LINE,
      ITAB3 LIKE ITAB OCCURS 0 WITH HEADER LINE.

DATA : V_FORMNAME  TYPE TDSFNAME,  "VALUE 'ZLABELROL_A131',
       V_FUNCNAME  TYPE RS38L_FNAM,
       CRKMNG(10)  TYPE C,
       V_TAB    TYPE API_VALI OCCURS 0 WITH HEADER LINE,
       CONTROL_PARAMETERS TYPE SSFCTRLOP,
       OUTPUT_OPTIONS TYPE SSFCOMPOP,
       V_COPY TYPE P,
       V_CHARG LIKE MCHA-CHARG,
       V_ROW TYPE P,
       V_SPLIT(10),
       VBARCTEXTCUST_TEMP(40),
       VBARCODECUST_TEMP(40).
*-----------------------------------
TABLES: MCHA.
DATA: V_COUNT LIKE SY-TABIX.

DATA: BEGIN OF IT_CHARG OCCURS 0,
      CHARG LIKE MCHA-CHARG,
      MATNR LIKE MCHA-MATNR,
      BOX(1),
      END OF IT_CHARG.

RANGES: TORD FOR AFPO-ABLAD.

DATA: V_TEMP TYPE N LENGTH 18.
DATA: V_PROG LIKE ZPROGINFO-PGMNA VALUE 'ZMMR_LABELROL_REPRINT'.

INCLUDE ZABAPALV.                " Include Function ALV.
*INCLUDE Z_PROG_INFO.             "Program Documentation

SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
PARAMETERS: FILENAME LIKE RLGRAP-FILENAME LOWER CASE OBLIGATORY DEFAULT 'D:\'.
PARAMETERS: P_COPIES TYPE N LENGTH 3 DEFAULT '1'.
SELECTION-SCREEN END OF BLOCK BLK1.

SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
PARAMETER: V_131 RADIOBUTTON GROUP RAD USER-COMMAND FRAD1,
           V_138 RADIOBUTTON GROUP RAD,
           V_139 RADIOBUTTON GROUP RAD,
           V_149 RADIOBUTTON GROUP RAD DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK BLK2.

SELECTION-SCREEN BEGIN OF BLOCK BLK3 WITH FRAME TITLE TEXT-003.
PARAMETER: V_ROLL  RADIOBUTTON GROUP RAD2 USER-COMMAND FRAD2 DEFAULT 'X',
           V_BATCH RADIOBUTTON GROUP RAD2.
SELECTION-SCREEN END OF BLOCK BLK3.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR FILENAME.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      DEF_PATH         = 'JAL:\'
      MASK             = ',*.*,*.*.'
      MODE             = 'O'
    IMPORTING
      FILENAME         = FILENAME
    EXCEPTIONS
      INV_WINSYS       = 1
      NO_BATCH         = 2
      SELECTION_CANCEL = 3
      SELECTION_ERROR  = 4
      OTHERS           = 5.

START-OF-SELECTION.
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

END-OF-SELECTION.

START-OF-SELECTION.
  PERFORM F_GET_DATA.
  PERFORM F_DISPLAY_ALV.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_GET_DATA.
  LOOP AT ITAB.
    CLEAR: VBARCTEXTCUST_TEMP, VBARCODECUST_TEMP.
    VBARCTEXTCUST_TEMP = ITAB-VBARCTEXTCUST.
    REPLACE ALL OCCURRENCES OF '-' IN VBARCTEXTCUST_TEMP WITH ''.
    CONCATENATE VBARCTEXTCUST_TEMP '1' INTO VBARCODECUST_TEMP.
    ITAB-VBARCODECUST = VBARCODECUST_TEMP.

    IF V_149 = 'X'.
      ITAB-VPARTNO = ITAB-VBARCODECUST+1(10).
      CONCATENATE ITAB-VUSED+0(4) ITAB-VBARCTEXTCUST+15(2) ITAB-VBARCTEXTCUST+17(2) INTO ITAB-VPOSTDATE SEPARATED BY '/'.
      ITAB-VBARCODECUST = ITAB-VBARCTEXTCUST.
    ENDIF.

    IF ITAB-VUSED NE ITAB-VUSED+0(2) && ITAB-VBARCTEXTCUST+13(2) && '.' && ITAB-VBARCTEXTCUST+15(2).
      ITAB-REMARKS = 'Manuf date tidak sama dengan manuf di no. KT&G'.
      ITAB-COLOR = 'C600'.
    ENDIF.

    MODIFY ITAB.
  ENDLOOP.

  IF V_ROLL = 'X'.
    SORT ITAB BY VBARCTEXTCUST.
  ELSEIF V_BATCH = 'X'.
    SORT ITAB BY VBATCH.
  ENDIF.
ENDFORM.                    "f_get_data


*--- Display Items
FORM F_DISPLAY_ALV.
  PERFORM F_FIELD_CATALOG.
  PERFORM F_LAYOUT.
  PERFORM F_LIST_DETAIL.
ENDFORM.                    "f_display_alv


*&---------------------------------------------------------------------*
*&      Form  f_field_catalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  CLEAR T_FIELDCAT.
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB' :
    'VBATCH'         '' ''  '' '10'  'Batch'                  '' '' '' '',
    'VTYPE'          '' ''  '' '6'   'Type'                   '' '' '' '',
    'VCORE'          '' ''  '' '5'   'Core'                   '' '' '' '',
    'VNWEIGHT'       '' ''  '' '5'   'Weight'                 '' '' '' '',
    'VTHICK'         '' ''  '' '5'   'Thick'                  '' '' '' '',
    'VWIDTH'         '' ''  '' '5'   'Width'                  '' '' '' '',
    'VLENGTH'        '' ''  '' '6'   'Length'                 '' '' '' '',
    'VUSED'          '' ''  '' '10'  'Manuf. Date'            '' '' '' '',
    'VBARCTEXTCUST'  '' ''  '' '40'  'No. Roll KT&G'          '' '' '' '',
    'VBARCODECUST'   '' ''  '' '20'  'Barcode Cust'           '' '' '' '',
    'VVBELN'         '' ''  '' '10'  'SO Number'              '' '' '' '',
    'VPOSNR'         '' ''  '' '10'  'SO Item'                '' '' '' '',
    'VSONUM_ITEM'    '' ''  '' '20'  'SO Item 2'              '' '' '' '',
    'VDERIVATIVEMS'  '' ''  '' '15'  'Derivatives MS'         '' '' '' '',
    'VPOSITIONMS'    '' ''  '' '15'  'Position MS'            '' '' '' '',
    'VDERIVATIVESS'  '' ''  '' '15'  'Derivatives SS'         '' '' '' '',
    'VPOSITIONSS'    '' ''  '' '15'  'Position SS'            '' '' '' '',
    'VGRADE'         '' ''  '' '15'  'Grade'                  '' '' '' '',
    'VBARCTEXTTRIAS' '' ''  '' '20'  'Barcode Text'           '' '' '' '',
    'VBARCODETRIAS'  '' ''  '' '20'  'Barcode'                '' '' '' '',
    'VROLL'          '' ''  '' '25'  'Roll'                   '' '' '' '',
    'VINSIDE'        '' ''  '' '10'  'Inside'                 '' '' '' '',
    'VOUTSIDE'       '' ''  '' '10'  'Outside'                '' '' '' '',
    'VLIVE'          '' ''  '' '15'  'Live'                   '' '' '' '',
    'VPOSTDATE'      '' ''  '' '15'  'Posting Date'           '' '' '' '',
    'VEXPDATE'       '' ''  '' '15'  'Expired Date'           '' '' '' '',
    'VPOINT'         '' ''  '' '15'  'Point'                  '' '' '' '',
    'VPARTNO'        '' ''  '' '15'  'Part'                   '' '' '' '',
    'VJOINT'         '' ''  '' '5'   'Joint'                  '' '' '' '',
    'REMARKS'        '' ''  '' '100' 'Message'                '' '' '' ''.

  T_FIELDCAT-NO_ZERO = ''.
  MODIFY T_FIELDCAT TRANSPORTING NO_ZERO WHERE FIELDNAME = 'CHARG'.
ENDFORM.                    " f_field_catalog


*&---------------------------------------------------------------------*
*&      Form  f_layout
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
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-CELL_MERGE = 'X'.
ENDFORM.                    " f_layout


*&---------------------------------------------------------------------*
*&      Form  f_list_detail
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
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS'
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
      T_OUTTAB                 = ITAB
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    " f_list_detail


*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  DATA: LT_HUS TYPE HUM_VENUM_T.

  SY-LSIND = 0.
  CASE FU_UCOMM.
    WHEN 'PRINT'.
      IF V_131 = 'X'.
        V_FORMNAME = 'ZLABELROL_A131'.
      ELSEIF V_138 = 'X'.
        V_FORMNAME = 'ZLABELROL_A138'.
      ELSEIF V_139 = 'X'.
        V_FORMNAME = 'ZLABELROL_A139'.
      ELSEIF V_149 = 'X'.
        V_FORMNAME = 'ZLABELROL_A149'.
      ENDIF.
      PERFORM F_PRINT.
      FU_SELFIELD-REFRESH = 'X'.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  f_a131
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM F_PRINT.
  CLEAR: ITAB2, ITAB3.
  REFRESH: ITAB2, ITAB3.

  ITAB2[] = ITAB[].

  LOOP AT ITAB2 INTO ITAB3 WHERE BOX = 'X'.
    DO P_COPIES TIMES.
      APPEND ITAB3.
    ENDDO.
    CLEAR: ITAB3.
  ENDLOOP.

  IF ITAB3[] IS INITIAL.
    MESSAGE 'Pilih data yang akan diprint!' TYPE 'I'.
    EXIT.
  ENDIF.

  IF V_ROLL = 'X'.
    SORT ITAB3 BY VBARCTEXTCUST.
  ELSEIF V_BATCH = 'X'.
    SORT ITAB3 BY VBATCH.
  ENDIF.

  DESCRIBE TABLE ITAB3 LINES V_ROW.

  DATA: GV_DEVTYPE TYPE RSPOPTYPE.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = V_FORMNAME
    IMPORTING
      FM_NAME            = V_FUNCNAME
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.

  V_COPY = P_COPIES.
  IF V_COPY LE 0.
    CONTROL_PARAMETERS-NO_DIALOG = ''.
  ELSE.
    CONTROL_PARAMETERS-NO_DIALOG = 'X'.
*    CONTROL_PARAMETERS-PREVIEW = 'X'.
*    OUTPUT_OPTIONS-TDCOPIES = V_COPY.
  ENDIF.

  CALL FUNCTION V_FUNCNAME
    EXPORTING
      CONTROL_PARAMETERS = CONTROL_PARAMETERS
      OUTPUT_OPTIONS     = OUTPUT_OPTIONS
      V_ROW              = V_ROW
      V_COPY             = V_COPY
    TABLES
      ITAB               = ITAB3.

ENDFORM.                    "f_a131