*&---------------------------------------------------------------------*
*&  Include           ZHUI_DELIVERY_HU_PC_ALV
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
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_VBAP' :
         'ICON'    ''  ''  '' 6   'Status'               ''   '' ''  '' ,
         'BSTNK'   ''  ''  '' 10   'PO Number'            ''   '' ''  '' ,
         'VBELN'   ''  ''  '' 10   'SO Number'            ''   'X' ''  '' ,
         'POSNR'   ''  ''  ''   6    'SO Item'            ''   ''  ''  '',
         'MATNR'   ''  ''  ''  18   'Material'            ''   ''  ''  '',
         'VEMNG'   ''  ''  ''  18   'Qty HU(KG) '         ''   ''  ''  '',
         'VEMEH'   ''  ''  ''   4   'UoM in HU '          ''   ''  ''  '',
         'VRKME'   ''  ''  ''   4   'UoM in SO '          ''   ''  ''  '',
         'ZEXIDV'  ''  ''  ''  18   'HU Number'           ''   ''  ''  '',
         'KET'     ''  ''  ''  18   'Keterangan'          ''   ''  ''  '',
         'ZSTAT'   ''  ''  ''  18   'Status HU'           ''   ''  ''  '',
         'ZREMARKS' ''  ''  ''  18  'Dlv. Remark(dari SO)' ''   ''  ''  '',
         'BESTQ'   ''  ''  ''  5   'Stock Category'       ''   ''  ''  '',
         'ZVBELN'  ''  ''  ''  10   'ODO Number'          ''   'X' ''  '',
         'VSTEL'   ''  ''  ''  4   'Shipping Point'       ''   ''  ''  '',
         'SLOCA'   ''  ''  ''  4   'SLoc Asal'            ''   ''  ''  '',
         'LGORT'   ''  ''  ''  4   'SLoc Tujuan'          ''   ''  ''  '',
         'PLANTA'  ''  ''  ''  4   'Plant Asal'           ''   ''  ''  '',
         'PLANTT'  ''  ''  ''  4   'Plant Tujuan'         ''   ''  ''  '',
         'MATDOC'  ''  ''  ''  12   'Material Doc.'       ''   ''  ''  '',
         'ZZTYPE'  ''  ''  ''  20   'Film Type'           ''   ''  ''  '',
         'ZZWIDTH' ''  ''  ''  10   'Width'               ''   ''  ''  '',
         'ZZLENGTH' ''  ''  ''  10   'Length'             ''   ''  ''  '',
         'KUNNR'   ''  ''  ''  12   'Sold-to-Party'       ''   ''  ''  '',
         'NAME1'   ''  ''  ''  35   'Sold-to-Party Name'  ''   ''  ''  '',
         'ZKUNNR'  ''  ''  ''  12   'Ship-to-Party'       ''   ''  ''  '',
         'ZNAME1'  ''  ''  ''  35   'Ship-to-Party Name'  ''   ''  ''  ''.

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
  wa_layout-subtotals_text = 'Sub Total'.
  wa_layout-totals_text = 'Total'.
  WA_LAYOUT-BOX_FIELDNAME = 'BOX'.
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
  SORT IT_VBAP BY VBELN POSNR EXIDV.
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
      it_sort                  = t_sort[]
      it_excluding             = t_excluding[]
      i_bypassing_buffer       = 'X'
    tables
      t_outtab                 = IT_VBAP
    exceptions
      program_error            = 1
      others                   = 2.

ENDFORM.                    " F_LIST_DETAIL

*&---------------------------------------------------------------------
*&      Form  F_GUI_STATUS
*&---------------------------------------------------------------------
FORM F_GUI_STATUS USING FT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'ZSTDR_HU'.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.

  DATA : LT_HUS  TYPE HUM_VENUM_T.
  DATA : WA_VBAP LIKE LINE OF IT_VBAP.

  SY-LSIND = 0.
  CASE FU_UCOMM.
    WHEN '&IC1'.
      READ TABLE IT_VBAP INTO WA_VBAP INDEX FU_SELFIELD-TABINDEX.
      CASE FU_SELFIELD-SEL_TAB_FIELD.
        WHEN 'IT_VBAP-ZVBELN'.
          IF WA_VBAP-ZVBELN NE ''.
            SET PARAMETER ID 'VL' FIELD WA_VBAP-ZVBELN.
            CALL TRANSACTION 'VL02N' AND SKIP FIRST SCREEN.
          ENDIF.
        WHEN 'IT_VBAP-VBELN'.
          IF WA_VBAP-VBELN NE ''.
            SET PARAMETER ID 'AUN' FIELD WA_VBAP-VBELN.
            CALL TRANSACTION 'ZVA03A' AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.
    WHEN  'CREATE'.
      PERFORM VALIDASI.
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
  PERFORM F_ALV_FIELDCATG_ICON USING 'IT_ERROR' :
   'ICON'    '' ''  '' '4'   'Icon '          '' ' ' '' '',
   'TYPE'    '' ''  '' '6'   'Status '          '' ' ' '' '',
   'ID'      '' ''  '' '12'  'Message ID'     '' ' ' '' '',
   'VBELN'   '' ''  '' '12'  'Delivery'     '' 'X' '' '',
   'NUMBER'  '' ''  '' '14'  'Message Number'   '' ' ' '' '',
   'MESSAGE' '' ''  '' '100' 'Remaks'           '' ' ' '' ''.

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
      i_callback_user_command  = 'F_USER_COMMAND_ERROR'
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
  APPEND 'CREATE' TO FT_EXTAB.

  SET PF-STATUS 'ZSTDR_HU' EXCLUDING FT_EXTAB.
ENDFORM.                    " F_ALV_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM F_USER_COMMAND_ERROR USING FU_UCOMM LIKE SY-UCOMM
                          FU_SELFIELD TYPE SLIS_SELFIELD.
  CASE FU_UCOMM.
    WHEN '&IC1'.
      CLEAR : WA_ERROR.
      READ TABLE IT_ERROR INTO WA_ERROR INDEX FU_SELFIELD-TABINDEX.
      CASE FU_SELFIELD-SEL_TAB_FIELD.
      WHEN 'IT_ERROR-VBELN'.
        IF WA_ERROR-VBELN NE ''.
          SET PARAMETER ID 'VL' FIELD WA_ERROR-VBELN.
          CALL TRANSACTION 'VL02N' AND SKIP FIRST SCREEN.
        ENDIF.

      ENDCASE.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDFORM.                    "F_USER_COMMAND