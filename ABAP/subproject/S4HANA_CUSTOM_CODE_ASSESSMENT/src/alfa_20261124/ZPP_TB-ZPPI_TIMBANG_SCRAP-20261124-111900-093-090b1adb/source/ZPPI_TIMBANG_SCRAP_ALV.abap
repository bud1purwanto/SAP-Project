*&---------------------------------------------------------------------*
*&  Include           ZPPI_REC_MAT_BY_PROD_ALV
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'ITAB_DIST' :
         'ZSTAT'       '' ''  ''  ''  'Status'            ''   ''  ''  '',
         'AUFNR'      ''  ''  ''  ''  'Process Order'     ''   ''  ''  '',
         'MBLNR'      ''  ''  ''  ''  'Material Document' ''   ''  ''  '',
         'MATNR_W'     ''  ''  ''  ''  'Material'          ''   ''  ''  '',
         'MATNR_RR'      ''  ''  ''  ''  'Raw Material'      ''   ''  ''  '',
         'BWART'      ''  ''  ''  ''  'Movement Type'     ''   ''  ''  '',
         'BKTXT'      ''  ''  ''  ''  'No. Roll'          ''   ''  ''  '',
         'LGORT'       ''  ''  ''  ''  'Sloc'              ''   ''  ''  '',
         'MENGE'      ''  ''  ''  ''  'Quantity'          ''   ''  ''  '',
         'MENGE_W'     ''  ''  ''  ''  'Nett Qty'          ''   ''  ''  '',
         'MENGA'  ''  ''  ''  ''  'Qty Alokasi'       ''   ''  ''  '',
         'ETYPE'      ''  ''  ''  ''  'Msg. Type'         ''   ''  ''  '',
         'EID'        ''  ''  ''  ''  'Msg. ID'           ''   ''  ''  '',
         'ENUMBER'    ''  ''  ''  ''  'Msg. No.'          ''   ''  ''  '',
         'EMSG'       ''  ''  ''  ''  'Msg. Text'         ''   ''  ''  ''.

ENDFORM.                    " F_FIELD_CATALOG


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_TIMBANG
*&---------------------------------------------------------------------*

FORM F_LAYOUT_TIMBANG .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
ENDFORM.                    " F_LAYOUT_TIMBANG

*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAILTIMBANG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAILTIMBANG .

  "ADDED BY FATHIR ON 12.11.2020
  PERFORM F_SET_QTY_DISPLAY USING ''. " ubah nilai qty untuk kebutuhan display - TRDK917760

  " Add event exit, hanya jika Execute
  CLEAR T_EVENT_EXIT.
  REFRESH T_EVENT_EXIT.
  IF IS_TEST_RUN IS INITIAL.
    T_EVENT_EXIT-UCOMM = '&F03'.
    T_EVENT_EXIT-AFTER = 'X'.
    APPEND T_EVENT_EXIT.

    T_EVENT_EXIT-UCOMM = '&F15'.
    T_EVENT_EXIT-AFTER = 'X'.
    APPEND T_EVENT_EXIT.

    T_EVENT_EXIT-UCOMM = '&F12'.
    T_EVENT_EXIT-AFTER = 'X'.
    APPEND T_EVENT_EXIT.
  ENDIF.

  D_REPID = SY-REPID.
  WA_VARIANTE-REPORT = D_REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS_TB'
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND_TB'
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
      T_OUTTAB                 = ITAB_DIST
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAILTIMBANG

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_LT
*&---------------------------------------------------------------------*
FORM F_FIELD_CATALOG_LT .
  REFRESH : T_FIELDCAT.

  IF R_SUM IS NOT INITIAL.
    PERFORM F_ALV_FIELDCATG_ICON USING 'ITLOGTIMBANG' :
      'ZBUDAT'   ''  ''  ''  ''  'Posting Date'          ''   ''  ''  '',
      'ZCPUDT'   ''  ''  ''  ''  'Entered On'            ''   ''  ''  '',
      'ZCPUTM'   '' ''   ''  ''  'Entered at'            ''   ' ' ''  '',
      'ZLINE'    '' ''   ''  ''  'Prod. Line'            ''   ' ' ''  '',
      'ZUSNAM'   '' ''   ''  ''  'NIK'                   ''   ' ' ''  '',
      'ZNEWMD'   ''  ''  ''  ''  'Mat Doc. Timbang' ''   ''  ''  '',
      'ZMATNR'   ''  ''  ''  ''  'Material'              ''   ''  ''  '',
      'MAKTX'    ''  ''  ''  ''  'Material Description'  ''   ''  ''  '',
      'ZWERKS'   ''  ''  ''  ''  'Plant'                 ''   ''  ''  '',
      'ZBAGIAN'  ''  ''  ''  ''  'Bagian'                ''   ''  ''  '',
      'ZQTY'     ''  ''  ''  ''  'Qty. Timbang'          ''   ''  ''  ''.
  ELSE.
    PERFORM F_ALV_FIELDCATG_ICON USING 'ITLOGTIMBANG' :

    'ZIDLOG'   ''  ''  ''  ''  'ID Log Timbang'        ''   ''  ''  '',
    'ZITEMLOG' ''  ''  ''  ''  'Item Log Timbang'      ''   ''  ''  '',
    'ZOLDMD'   ''  ''  ''  ''  'Mat Doc. RR'           ''   ''  ''  '',
    'ZNEWMD'   ''  ''  ''  ''  'Mat Doc. Timbang'      ''   ''  ''  '',
    'ZAUFNR'   '' ''   ''  ''  'Order'                 ''   ' ' ''  '',
    'ZBUDAT'   ''  ''  ''  ''  'Posting Date'          ''   ''  ''  '',
    'ZCPUDT'   ''  ''  ''  ''  'Entered On'            ''   ''  ''  '',
    'ZCPUTM'   '' ''   ''  ''  'Entered at'            ''   ' ' ''  '',
    'ZLINE'    '' ''   ''  ''  'Prod. Line'            ''   ' ' ''  '',
    'ZUSNAM'   '' ''   ''  ''  'NIK'                   ''   ' ' ''  '',
    'ZBWART'   ''  ''  ''  ''  'Movement Type'         ''   ''  ''  '',
    'ZMATNR'   ''  ''  ''  ''  'Material'              ''   ''  ''  '',
    'MAKTX'    ''  ''  ''  ''  'Material Description'  ''   ''  ''  '',
    'ZWERKS'   ''  ''  ''  ''  'Plant'                 ''   ''  ''  '',
    'ZLGORT'   ''  ''  ''  ''  'S.Loc'                 ''   ''  ''  '',
    'ZBAGIAN'  ''  ''  ''  ''  'Bagian'                ''   ''  ''  '',
    'ZQTY'     ''  ''  ''  ''  'Qty. Timbang'          ''   ''  ''  ''.
  ENDIF.
ENDFORM.                    " F_FIELD_CATALOG_LT


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_LTIMBANG
*&---------------------------------------------------------------------*
FORM F_LIST_DETAIL_LTIMBANG .
  " Add event refresh
  REFRESH: T_EVENTS, T_EVENT_EXIT.
  CLEAR: T_EVENT_EXIT.
  T_EVENT_EXIT-UCOMM = '&REFRESH'.
  T_EVENT_EXIT-AFTER = 'X'.
  APPEND T_EVENT_EXIT.

  D_REPID = SY-REPID.
  WA_VARIANTE-REPORT = D_REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND_LOG'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS_LOG'
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
      T_OUTTAB                 = ITLOGTIMBANG
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL_LTIMBANG


*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS_TB USING FT_EXTAB TYPE SLIS_T_EXTAB.
  DATA ITAB_EXCLUDE TYPE TABLE OF SY-UCOMM.
  SET PF-STATUS 'PROD_STAT1210' EXCLUDING ITAB_EXCLUDE.
ENDFORM.                    " F_GUI_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_TB USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  DATA: V_ANSWER(1).
  CLEAR: V_ANSWER.

  " Tampilkan popup konfirmasi pada saat tombol back / exit diklik
  IF FU_UCOMM = '&F03' OR FU_UCOMM = '&F15' OR FU_UCOMM = '&F12'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = 'Exit List'
        TEXT_QUESTION         = 'Leave List?'
        TEXT_BUTTON_1         = 'Yes'
        TEXT_BUTTON_2         = 'No'
        DEFAULT_BUTTON        = '2'
        DISPLAY_CANCEL_BUTTON = 'X'
      IMPORTING
        ANSWER                = V_ANSWER
      EXCEPTIONS
        TEXT_NOT_FOUND        = 1
        OTHERS                = 2.

    IF SY-SUBRC <> 0.
      EXIT.
    ENDIF.
  ENDIF.

  CASE FU_UCOMM.
    " Kosongkan variabel setelah proses eksekusi berhasil
    WHEN '&F03' OR '&F15' OR '&F12'.
      IF V_ANSWER = '1'.
        REFRESH: IT_TIMBANG, ITAB_TIPE, ITAB_DIST, S_PLINE.
        CLEAR: ITAB_TIPE, ITAB_DIST, PRSNTOTAL, PRSNORDTOTAL.
        CLEAR:S_PLANT, S_MATNR, S_SLOCA, S_SLOCT, S_NIKP, S_NIKPR, S_PLINE.
        CALL SCREEN 1100.
      ENDIF.

    WHEN OTHERS.

  ENDCASE.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS_LOG
*&---------------------------------------------------------------------
FORM F_GUI_STATUS_LOG USING FT_EXTAB TYPE SLIS_T_EXTAB.
  DATA ITAB_EXCLUDE TYPE TABLE OF SY-UCOMM.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.

ENDFORM.                    "F_GUI_STATUS_LOG

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_LOG USING FU_UCOMM LIKE SY-UCOMM
                 	         FU_SELFIELD TYPE SLIS_SELFIELD.

  CASE FU_UCOMM.
    WHEN '&IC1'.

    " Refresh buttons' event
    WHEN '&REFRESH'.
      PERFORM F_GET_LOG_TIMBANG.
      FU_SELFIELD-REFRESH = 'X'.
  ENDCASE.
  FU_SELFIELD-REFRESH = 'X'.
ENDFORM.                    "F_USER_COMMAND_LOG