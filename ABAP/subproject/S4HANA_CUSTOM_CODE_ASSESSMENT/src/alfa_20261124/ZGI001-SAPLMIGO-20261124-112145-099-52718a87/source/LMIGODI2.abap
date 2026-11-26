*----------------------------------------------------------------------*
*   INCLUDE LMIGODI2                                                   *
*----------------------------------------------------------------------*
*   Detail tabstrip foreign trade implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_import IMPLEMENTATION.

*----------------------------------------------------------------------*
* METHOD CONSTRUCTOR
*----------------------------------------------------------------------*
METHOD constructor.
  DATA: lt_okcodes TYPE lif_migo_frame=>ty_t_okcodes.

* screenobject constructor needed to instance variables
  CALL METHOD super->constructor.

  APPEND 'MIGO_OK_IMPORT_ITEM' TO lt_okcodes.
  lif_migo_frame~class_id = 'MIGO_DETAIL_IMPORT'.
  CALL METHOD lcl_migo_frame=>viewer_register
    EXPORTING
      i_iref_viewer = me
      it_okcodes    = lt_okcodes.
ENDMETHOD.
*----------------------------------------------------------------------*
* METHOD PBO
*----------------------------------------------------------------------*
METHOD pbo.
  DATA: l_complete TYPE abap_bool,
        ls_gohead  TYPE gohead.
  CALL METHOD super->pbo.
  CALL METHOD lcl_migo_globals=>kernel->header_get
    IMPORTING e_gohead = ls_gohead.
* Check if import data is complete and set red or green light
  CALL FUNCTION 'EXPIMP_DATA_COMPLETENESS_CHECK'
    EXPORTING
      i_exnum              = ls_gohead-exnum
      i_expos              = goitem-global_counter        "#EC DOM_EQUAL
      i_ft_basis           = '1WE'
    IMPORTING
*     e_header_complete    =
      e_line_item_complete = l_complete
    EXCEPTIONS
*     NO_EXPORT_DATA       = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    rl50e-stat_p = icon_red_light.
  ENDIF.
  CASE l_complete.
    WHEN abap_true.
      rl50e-stat_p = icon_green_light.
    WHEN abap_false.
      rl50e-stat_p = icon_red_light.
  ENDCASE.
ENDMETHOD.
*----------------------------------------------------------------------*
* METHOD PAI
*----------------------------------------------------------------------*
METHOD pai.
  CALL METHOD super->pai.
ENDMETHOD.
*----------------------------------------------------------------------*
* METHOD PBO_POPUP
*----------------------------------------------------------------------*
METHOD pbo_popup.
  DATA: l_trtyp           TYPE t180-trtyp,
        ls_gohead         TYPE gohead.

  CHECK sy-ucomm = 'MIGO_OK_IMPORT_ITEM'.

  SET PF-STATUS 'IMPORT_ITEM'.
  SET TITLEBAR  'IMPORT_ITEM'.
  IF     lcl_migo_globals=>kernel->s_action-create = abap_true AND
     NOT lcl_migo_globals=>kernel->s_action-cancel = abap_true.
    l_trtyp = h.
  ELSE.
    l_trtyp = a.
  ENDIF.

  CALL METHOD lcl_migo_globals=>kernel->header_get
    IMPORTING e_gohead = ls_gohead.
  CALL FUNCTION 'FTRADE_ITEM_DATA_MNT_TS_PBO'
    EXPORTING
*     I_PARTNER_COUNTRY         = '   '
      i_material_text           = goitem-maktx
*     I_BATCH_NUMBER            = ' '
      i_ftrade_number           = ls_gohead-exnum
      i_ftrade_number_line_item = goitem-global_counter "#EC DOM_EQUAL
      i_home_country            = goitem-land1
      i_material_number         = goitem-matnr
*     I_MANUFACTURER_NUMBER     = ' '
      i_ft_basis                = '1WE'
*     I_STAT_COMPLETE_MANDATORY = ' '
      i_transaction_type        = l_trtyp.
*     I_FUNCTION_CODE           = '    '
*     I_FUNCTION_CODE_DEFAULT   = '    '
ENDMETHOD.
*----------------------------------------------------------------------*
* METHOD PAI_EXIT
*----------------------------------------------------------------------*
METHOD pai_exit.
  SET SCREEN 0.
  LEAVE SCREEN.
ENDMETHOD.
*----------------------------------------------------------------------*
* METHOD PAI_POPUP
*----------------------------------------------------------------------*
METHOD pai_popup.
  DATA: l_exnum   TYPE gohead-exnum,
        ls_gohead TYPE gohead.

  IF sy-ucomm = 'OK_WEIT'.
    CALL METHOD lcl_migo_globals=>kernel->header_get
      IMPORTING e_gohead = ls_gohead.
    CALL FUNCTION 'FTRADE_ITEM_DATA_MNT_TS_PAI'
      EXPORTING
        i_ftrade_number           = ls_gohead-exnum
        i_ftrade_number_line_item = goitem-global_counter "#EC DOM_EQUAL
        i_function_code           = sy-ucomm
      IMPORTING
*       E_FTRADE_DATA_COMPLETE    =
        e_ftrade_number_new       = l_exnum
*       E_DATALOSS                =
        e_function_code           = sy-ucomm.
*       E_SYSTEM_UCOMM            =

*   When the user first maintain the item popup, it will generate a new
*   exnum. In that case it is necessary to change
*   the header gohead-exnum
    IF ls_gohead-exnum IS INITIAL AND NOT l_exnum IS INITIAL.
      ls_gohead-exnum = l_exnum.
      CALL METHOD lcl_migo_globals=>kernel->header_modify
        EXPORTING i_gohead = ls_gohead.
    ENDIF.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.
ENDMETHOD.
*----------------------------------------------------------------------*
* Interface
*----------------------------------------------------------------------*
METHOD lif_migo_frame~okcode_handler.
  DATA: ls_goitem TYPE goitem.
  CASE i_okcode.
    WHEN 'MIGO_OK_IMPORT_ITEM'.
      CALL SCREEN 4100 STARTING AT 5 1
                       ENDING   AT 90 18.                      "455734
    WHEN OTHERS.
  ENDCASE.
ENDMETHOD.

METHOD lif_migo_frame~message_handler.
ENDMETHOD.

ENDCLASS.