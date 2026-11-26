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
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_ORDERGI' :
         'ZSTAT'       '' ''  ''  ''  'Status'            ''   ''  ''  '',
         'AUFNR'      ''  ''  ''  ''  'Process Order'     ''   ''  ''  '',
         'MBLNR'      ''  ''  ''  ''  'Material Document' ''   ''  ''  '',
         'BMATNR'     ''  ''  ''  ''  'Material'          ''   ''  ''  '',
         'MATNR'      ''  ''  ''  ''  'Raw Material'      ''   ''  ''  '',
         'BWART'      ''  ''  ''  ''  'Movement Type'     ''   ''  ''  '',
         'BKTXT'      ''  ''  ''  ''  'No. Roll'          ''   ''  ''  '',
         'SLOC'       ''  ''  ''  ''  'Sloc'              ''   ''  ''  '',
         'MENGE'      ''  ''  ''  ''  'Quantity'          ''   ''  ''  '',
         'ZNETQY'     ''  ''  ''  ''  'Nett Qty'          ''   ''  ''  '',
         'ZPROPORSI'  ''  ''  ''  ''  'Qty Alokasi'       ''   ''  ''  '',
         'ETYPE'      ''  ''  ''  ''  'Msg. Type'         ''   ''  ''  '',
         'EID'        ''  ''  ''  ''  'Msg. ID'           ''   ''  ''  '',
         'ENUMBER'    ''  ''  ''  ''  'Msg. No.'          ''   ''  ''  '',
         'EMSG'       ''  ''  ''  ''  'Msg. Text'         ''   ''  ''  ''.

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
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
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
      T_OUTTAB                 = IT_LIKP
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'PROD_STAT1500'.
  SET TITLEBAR  'PROD_TITLE1500'.

ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  CASE FU_UCOMM.
    WHEN 'BACK'.
      CALL SCREEN 1000.
    WHEN '&IC1'.
      CLEAR : WA_LIKP.
      READ TABLE IT_LIKP INTO WA_LIKP INDEX FU_SELFIELD-TABINDEX.
      CASE FU_SELFIELD-SEL_TAB_FIELD.
        WHEN 'IT_LIKP-VBELN'.
          SET PARAMETER ID 'VL' FIELD WA_LIKP-VBELN.
          CALL TRANSACTION 'ZVL03NOG' AND SKIP FIRST SCREEN.
      ENDCASE.
  ENDCASE.

ENDFORM.                    "F_USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_PRINT .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_PRINT' :
  'VBELN'   ''  ''  ''  10   'Nomor ODO'       ''   ''  ''  '',
  'KUNNR'   ''  ''  ''  10   'Customer'        ''   ''  ''  '',
  'NAME1'   ''  ''  ''  35   'Customer Name  '   ''   ''  ''  ''.

ENDFORM.                    " F_FIELD_CATALOG_PRINT

*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT_PRINT .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-SUBTOTALS_TEXT = 'Sub Total'.
  WA_LAYOUT-TOTALS_TEXT = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
*  WA_LAYOUT-BOX_TABNAME = 'T_HEADER'.
*  WA_LAYOUT-EXPAND_FIELDNAME = 'EXPAND'.
*  wa_layout-expand_all = 'X'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.


ENDFORM.                    " F_LAYOUT_PRINT


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL_PRINT .
  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  SORT IT_LIKP BY VBELN POSNR.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND_PRINT'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS_PRINT'
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
      T_OUTTAB                 = IT_PRINT
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

ENDFORM.                    " F_LIST_DETAIL_PRINT

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS_PRINT USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'PROD_STAT1600'.
  SET TITLEBAR  'PROD_TITLE1600'.

ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_PRINT USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  CASE FU_UCOMM.
*    BREAK-POINT.
    WHEN 'BACK'.
      CALL SCREEN 1000.
    WHEN 'PRINT' OR 'PREV'.
      CLEAR: PRINT,PREVIEW.
      IF FU_UCOMM EQ 'PRINT'.
        PRINT = 'X'.
      ELSEIF FU_UCOMM EQ 'PREV'.
        PREVIEW = 'X'.
      ENDIF.
      PERFORM PRINT_DATA.
      PERFORM CALL_FORM.
  ENDCASE.


ENDFORM.                    "F_USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ALL .
  IF IT_ALL[] IS INITIAL.
    MESSAGE 'No Data Selected' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM F_FIELD_CATALOG_ALL.
  PERFORM F_LAYOUT_ALL.
  PERFORM F_LIST_DETAIL_ALL.

ENDFORM.                    " DISPLAY_ALL

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_ALL .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_ALL' :
       'ICON'   ''  ''  ''  8   'Status'   ''  ''  ''  '',
       'NOREF'   ''  ''  ''  12   'Delivery'  ''   'X'  ''  '' , "'X'  ''  ''
       'WBSTK'   ''  ''  ''  30   'Good Issue Status'  ''   ''  ''  '' ,
       'MBLNR'   ''  ''  ''  15    'Material Doc.'    ''   ''  ''  '',
       'MJAHR'   ''  ''  ''  6   'Year'   ''   ''  ''  '',
       'KUNNR'   ''  ''  ''  15   'Ship-to party'   ''   ''  ''  '',
       'ROUTE'   ''  ''  ''  8   'Route'       ''   ''  ''  '',
       'BUDAT'   ''  ''  ''  17   'Posting Date'  ''   ''  ''  '',
       'WERKS'   ''  ''  ''  6   'Plant'   ''  ''  ''  '',
       'LGORT'   ''  ''  ''  6   'Sloc'   ''  ''  ''  '',
       'VSTEL'   ''  ''  ''  15   'Ship.Point' ''   ''  ''  '',
       'ZPENGEMUDI'   ''  ''  '' 20   'Nama Pengemudi'    ''   ''  ''  '',
       'ZKENDARAAN'   ''  ''  ''  20   'Nomor Kendaraan'  ''   ''  ''  '',
       'ZSKP'   ''  ''  ''  15   'Nomor SKP'  ''   ''  ''  '',
       'ERDAT'   ''  ''  ''  12   'Created on'   ''  ''  ''  '',
       'ERZET'   ''  ''  ''  12   'Time' ''   ''  ''  '',
       'ERNAM'   ''  ''  ''  20   'Created by'    ''   ''  ''  '',
***         'MSGTYP'   ''  ''  ''  8   'Msg.type'  ''   ''  ''  '',
***         'MSGID'   ''  ''  ''  8   'Msg.ID'    ''   ''  ''  '',
***         'MSGNR'   ''  ''  ''  8   'Msg.NO'  ''   ''  ''  '',
       'MESSAGE'   ''  ''  ''  10  'Text'  ''   ''  ''  ''.


ENDFORM.                    " F_FIELD_CATALOG_ALL


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT_ALL .
  CLEAR WA_LAYOUT.
  WA_LAYOUT-ZEBRA = 'X'.
  WA_LAYOUT-CONFIRMATION_PROMPT = 'X'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
  WA_LAYOUT-CELL_MERGE = 'X'.
  WA_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.

ENDFORM.                    " F_LAYOUT_ALL


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_ALL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL_ALL .
  PERFORM BUILD_SORTCAT.

  D_REPID = SY-REPID.
  T_PRINT-NO_PRINT_LISTINFOS = 'X'.
  SORT IT_LIKP BY VBELN POSNR.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM       = D_REPID
      I_CALLBACK_USER_COMMAND  = 'F_USER_COMMAND_ALL'
      I_CALLBACK_PF_STATUS_SET = 'F_GUI_STATUS_ALL'
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
      T_OUTTAB                 = IT_ALL
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.
  CLEAR: T_SORT.
  REFRESH: T_SORT.
ENDFORM.                    " F_LIST_DETAIL_ALL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS_ALL USING FT_EXTAB TYPE SLIS_T_EXTAB.

  IF RB2 = 'X'.
    REFRESH FT_EXTAB.
    APPEND 'EXEC'  TO FT_EXTAB.
    APPEND 'RUN'  TO FT_EXTAB.
    SET PF-STATUS 'PROD_STAT1410' EXCLUDING FT_EXTAB.
    SET TITLEBAR  'PROD_TITLE1410'.
  ELSEIF RB3 = 'X'.
    REFRESH FT_EXTAB.
    APPEND 'POST'  TO FT_EXTAB.
    SET PF-STATUS 'PROD_STAT1410' EXCLUDING FT_EXTAB.
    SET TITLEBAR  'PROD_TITLE1410'.
  ELSE.
    SET PF-STATUS 'PROD_STAT1410'.
    SET TITLEBAR  'PROD_TITLE1410'.
  ENDIF.

ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_ALL USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  IT_ALL_BOX[] = IT_ALL[].
  DELETE IT_ALL_BOX  WHERE BOX NE 'X'.

  CASE FU_UCOMM.
    WHEN 'BACK'.
      CALL SCREEN 1000.
    WHEN 'EXEC'.
      IF IT_ALL_BOX[] IS INITIAL.
        MESSAGE 'No data selected. Select at least one line.' TYPE 'I'.
        EXIT.
      ENDIF.
      LOOP AT IT_ALL_BOX.
        IF IT_ALL_BOX-ICON EQ '@09@' OR IT_ALL_BOX-ICON EQ '@08@'.
          MESSAGE 'Can not re-run execution. Cek error.' TYPE 'E'.
        ENDIF.
      ENDLOOP.

      CLEAR : FLAG, SY-UCOMM.
      FLAG = 'X'.
      FLAG2 = 'X'.
      CALL SCREEN 1700.
    WHEN 'RUN'.
      IF IT_ALL_BOX[] IS INITIAL.
        MESSAGE 'No data selected. Select at least one line.' TYPE 'I'.
        EXIT.
      ENDIF.
      LOOP AT IT_ALL_BOX.
        IF IT_ALL_BOX-ICON EQ '@09@'.
          MESSAGE 'ODO already created succesfully, can not be re-run' TYPE 'E'.
        ELSEIF IT_ALL_BOX-ICON EQ '@08@'.
          MESSAGE 'GI already been posted.' TYPE 'E'.
        ENDIF.
      ENDLOOP.
      CLEAR : FLAG, FLAG2, SY-UCOMM.
      FLAG = 'X'.
      CALL SCREEN 1700.
    WHEN 'POST'.
      IF IT_ALL_BOX[] IS INITIAL.
        MESSAGE 'No data selected. Select at least one line.' TYPE 'I'.
        EXIT.
      ENDIF.
      LOOP AT IT_ALL_BOX.
        IF IT_ALL_BOX-ICON EQ '@0A@'.
          MESSAGE 'Can not post GI. Cek error.' TYPE 'E'.
        ELSEIF IT_ALL_BOX-ICON EQ '@08@'.
          MESSAGE 'Document already GI' TYPE 'E'.
        ENDIF.
      ENDLOOP.
      PERFORM POP_UP.
      IF SY-UCOMM EQ 'FURT'.
        PERFORM GI_DATA.
      ENDIF.
    WHEN '&IC1'.
      CLEAR : WA_ALL.
      READ TABLE IT_ALL INTO WA_ALL INDEX FU_SELFIELD-TABINDEX.
      CASE FU_SELFIELD-SEL_TAB_FIELD.
        WHEN 'IT_ALL-NOREF'.
          IF  WA_ALL-NOREF NE ''.
            SET PARAMETER ID 'VL' FIELD WA_ALL-NOREF.
            CALL TRANSACTION 'ZVL02NOG' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    "F_USER_COMMAND


*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_COPY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_COPY .
  REFRESH : T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_LIKP' :
         'VBELN'   ''  ''  ''  10   'ODO Number'  ''   'X'  ''  '' ,
         'POSNR'   ''  ''  ''  6    'ODO Item'    ''   ''  ''  '',
         'MBLNR'   ''  ''  ''  10   'Nomor material document'   ''   ''  ''  '',
         'MJAHR'   ''  ''  ''  4   'Year'   ''   ''  ''  '',
         'KUNNR'   ''  ''  ''  10   'Customer'       ''   ''  ''  '',
         'NAME1'   ''  ''  ''  35   'Customer Name'  ''   ''  ''  '',
         'MATNR'   ''  ''  ''  18   'Material'   ''  ''  ''  '',
         'ARKTX'   ''  ''  ''  40   'Material Description' ''   ''  ''  '',
         'LFIMG'   ''  ''  ''  13   'Quantity'    ''   ''  ''  '',
         'VRKME'   ''  ''  ''  3   'UoM'  ''   ''  ''  '',
         'ROUTE'   ''  ''  ''  6   'Route'  ''   ''  ''  '',
         'WADAT_IST'   ''  ''  ''  10   'Posting Date'   ''  ''  ''  '',
         'WERKS'   ''  ''  ''  4   'Plant' ''   ''  ''  '',
         'VSTEL'   ''  ''  ''  4   'Shipping Point'    ''   ''  ''  '',
         'LGORT'   ''  ''  ''  4   'Storage Location'  ''   ''  ''  '',
         'ZPENGEMUDI'   ''  ''  ''  40   'Nama Pengemudi'    ''   ''  ''  '',
         'ZKENDARAAN'   ''  ''  ''  40   'Nomor Kendaraan'  ''   ''  ''  '',
         'ZSKP'   ''  ''  ''  40  'Nomor SKP'  ''   ''  ''  '',
         'VKORG'   ''  ''  ''  4   'Sales Org.'   ''  ''  ''  '',
         'VTWEG'   ''  ''  ''  2   'Distr. Ch.' ''   ''  ''  '',
         'SPART'   ''  ''  ''  2   'Division'   ''   ''  ''  '',
         'ZINFORMATION'   ''  ''  ''  40   'Information'  ''   ''  ''  ''.


ENDFORM.                    " F_FIELD_CATALOG_COPY


*&---------------------------------------------------------------------*
*&      Form  BUILD_SORTCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_SORTCAT .
  CLEAR: T_SORT.
  REFRESH: T_SORT.

  T_SORT-SPOS      = 1.
  T_SORT-FIELDNAME = 'NOREF'.
  T_SORT-UP        = 'X'.
  APPEND T_SORT.

ENDFORM.                    " BUILD_SORTCAT