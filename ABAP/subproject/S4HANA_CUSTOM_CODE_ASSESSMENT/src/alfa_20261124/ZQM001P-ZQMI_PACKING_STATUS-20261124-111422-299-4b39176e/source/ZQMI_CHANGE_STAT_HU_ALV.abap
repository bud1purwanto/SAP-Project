*&---------------------------------------------------------------------*
*&  Include           ZQMI_CHANGE_STAT_HU_ALV
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_alv_fieldcatg_icon
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
  T_FIELDCAT-SELTEXT_M     = FU_FLTXT.
  T_FIELDCAT-SELTEXT_S     = FU_FLTXT.
  T_FIELDCAT-REPTEXT_DDIC  = FU_FLTXT.
  T_FIELDCAT-DO_SUM        = FU_DOSUM.
  T_FIELDCAT-HOTSPOT       = FU_HOTSP.
  T_FIELDCAT-JUST          = FU_JUST.
  T_FIELDCAT-ICON          = FU_ICON.
  T_FIELDCAT-CHECKBOX      = FU_CHK.
  T_FIELDCAT-EDIT          = FU_EDIT.
  T_FIELDCAT-NO_ZERO       = 'X'.
  APPEND T_FIELDCAT.
  CLEAR T_FIELDCAT.

ENDFORM.                    " f_alv_fieldcatg_icon

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

  PERFORM F_ALV_FIELDCATG_ICON1 USING 'ITRESULT' :
         'BOX'   ''  ''  '' 10   ''  ''   '' '' '' 'X' 'X',
         'EXIDV'     ''  ''  '' 12   'HU Number' ''   ''  '' '' '' '',
         'PSTATD'     ''  ''  '' 10   'HU Status'   ''   ''  '' '' '' '',
         'MATNR'     ''  ''  '' 18   'Material'   ''   ''  '' '' '' '',
         'CHARG'     ''  ''  '' 10   'Batch SR'  ''   ''  '' '' '' '',
         'LGORT'     ''  ''  '' 10   'Sloc'  ''   ''  '' '' '' '',
         'K'     ''  ''  '' 10   'HU Status'   ''  ''  '' '' '' ''.
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
  clear wa_layout.
  wa_layout-zebra = 'X'.
  wa_layout-confirmation_prompt = 'X'.
  wa_layout-cell_merge = 'X'.
  wa_layout-colwidth_optimize = 'X'.
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

  d_repid = sy-repid.
  t_print-no_print_listinfos = 'X'.
  SORT ITRESULT BY NO.
  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_callback_program       = d_repid
      i_callback_user_command  = 'F_USER_COMMAND'
      i_callback_pf_status_set = 'F_GUI_STATUS'
      is_layout                = wa_layout
      it_fieldcat              = t_fieldcat[]
      it_events                = t_events[]
      it_event_exit            = t_event_exit[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = wa_variante
      is_print                 = t_print
*      it_sort                  = t_sort[]
      it_excluding             = t_excluding[]
      i_bypassing_buffer       = 'X'
    tables
      t_outtab                 = ITRESULT
    exceptions
      program_error            = 1
      others                   = 2.


    CASE SY-UCOMM.
      WHEN 'YES' OR 'LEAVE'.
        LEAVE TO TRANSACTION 'ZQM017'.
    ENDCASE.
ENDFORM.                    " F_LIST_DETAIL

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

  DATA : LT_HUS  TYPE HUM_VENUM_T.
  DATA : WA_RESULT LIKE LINE OF ITRESULT.

  SY-LSIND = 0.
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      E_GRID = LS_REF1.

  CALL METHOD LS_REF1->CHECK_CHANGED_DATA .

  CLEAR FU_UCOMM.
  FU_UCOMM = SY-UCOMM.
  CASE FU_UCOMM.
    WHEN 'LEAVE' OR 'YES'.
      LEAVE TO TRANSACTION 'ZQM017'.
      CLEAR FU_UCOMM.
    WHEN 'EXEC'.
      PERFORM EDIT_STATUS.
      CLEAR FU_UCOMM.
    WHEN 'SELALL'.
      PERFORM SELECT_ALL.
      CLEAR FU_UCOMM.
    WHEN 'DESALL'.
      PERFORM DESELECT_ALL.
      CLEAR FU_UCOMM.
    WHEN 'REFDAT'.
      PERFORM DATA_RETRIEVAL.
      CLEAR FU_UCOMM.
  ENDCASE.

**  FU_SELFIELD-REFRESH = 'X'.

ENDFORM.                    "F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  WRITE_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM WRITE_ERROR .
  PERFORM F_FIELD_CATALOG_ERROR.
  PERFORM F_LAYOUT_ERROR.
  PERFORM F_LIST_DETAIL_ERROR.

ENDFORM.                    " WRITE_ERROR

*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CATALOG_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_FIELD_CATALOG_ERROR .
  REFRESH: T_FIELDCAT.
  PERFORM F_ALV_FIELDCATG_ICON1 USING 'IT_ERROR' :
   'TYPE'  '' ''  '' '10'  'Status '         '' ' ' '' '' '' '',
   'ID'  '' ''  '' '20'  'Delivery Number'  '' ' ' '' '' '' '',
   'MESSAGE'  '' ''  '' '100' 'Remaks'     '' ' ' '' '' '' ''.

ENDFORM.                    " F_FIELD_CATALOG_ERROR


*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LAYOUT_ERROR .
  clear wa_layout.
  wa_layout-zebra = 'X'.
  wa_layout-confirmation_prompt = 'X'.
  wa_layout-cell_merge = 'X'.
*  wa_layout-colwidth_optimize = 'X'.

ENDFORM.                    " F_LAYOUT_ERROR


*&---------------------------------------------------------------------*
*&      Form  F_LIST_DETAIL_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM F_LIST_DETAIL_ERROR .
  d_repid = sy-repid.
  t_print-no_print_listinfos = 'X'.
  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_callback_program       = d_repid
      i_callback_user_command  = 'F_USER_COMMAND'
      i_callback_pf_status_set = 'F_GUI_STATUS_ERROR'
      is_layout                = wa_layout
      it_fieldcat              = t_fieldcat[]
      it_events                = t_events[]
      it_event_exit            = t_event_exit[]
      i_default                = 'X'
      i_save                   = 'A'
      is_variant               = wa_variante
      is_print                 = t_print
      it_sort                  = t_sort[]
      it_excluding             = t_excluding[]
      i_bypassing_buffer       = 'X'
    tables
      t_outtab                 = IT_ERROR
    exceptions
      program_error            = 1
      others                   = 2.

  d_repid = sy-repid.
ENDFORM.                    " F_LIST_DETAIL_ERROR

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS_ERROR USING FT_EXTAB TYPE SLIS_T_EXTAB.
  REFRESH FT_EXTAB.
*  APPEND 'CREATE' TO FT_EXTAB.

  SET PF-STATUS 'STANDARD_FULLSCREEN' EXCLUDING FT_EXTAB.
ENDFORM.                    " F_ALV_STATUS