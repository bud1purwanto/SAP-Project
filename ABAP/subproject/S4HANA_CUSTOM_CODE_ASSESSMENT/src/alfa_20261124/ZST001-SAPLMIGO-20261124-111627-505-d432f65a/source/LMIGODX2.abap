*&---------------------------------------------------------------------*
*&  Include           LMIGODX2
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class (Implementation)  lcl_migo_detail_ewm
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
class lcl_migo_detail_ewm implementation.

  method constructor.
    super->constructor( ).
  endmethod.                    "constructor

*----------------------------------------------------------------------*
* METHOD PBO
*----------------------------------------------------------------------*
  method pbo.
    data: lt_scrap_indicator type /spe/bapi2017_scrap_ind_tab,
          ls_scrap_indicator type /spe/bapi2017_scrap_ind,
          ls_display         type c.

    call method super->pbo.

    if /spe/cl_ctrl=>is_ewm( i_plant = goitem-werks
                             i_stloc = goitem-lgort ) eq abap_true.
      g_sub_ewm = '0100'.
    else.
      clear goitem-spe_scrap_ind.
      clear goitem-spe_keep_qty.
      g_sub_ewm = '0200'.
    endif.
    ls_display = lcl_migo_globals=>kernel->s_action-display.
    call function '/SPE/DISPLAY_SET'
      exporting
        iv_display_mode       = ls_display
              .

  endmethod.                    "pbo

*----------------------------------------------------------------------*
* METHOD PAI
*----------------------------------------------------------------------*
  method pai.
    data: ls_scrap_ind       type /spe/bapi2017_scrap_ind,
          lv_keep_qty_active type flag,
          lv_string_keep_qty type string,
          ls_bapiret2        type bapiret2.
    constants: cv_scrap_retention type /spe/delivery_scrap_ind value 'B'.

    call method super->pai.

* Get current scrap data
    call function '/SPE/SCRAP_IND_GET'
      importing
        es_scrap_indicator = ls_scrap_ind
        ev_keep_qty_active = lv_keep_qty_active.

    ls_scrap_ind-line_id = goitem-zeile.
* Use 'Scrap entire inventory' instead of 'Scrap Inventory with Retention Quantity Constraint'
* if keep quantity is 0, only use message if field for quantity is open.
    if    ls_scrap_ind-scrap_indicator = cv_scrap_retention
      and ls_scrap_ind-keep_quantity   = 0
      and lv_keep_qty_active           = 'X'.
      message i100(migo).
    endif.
* Use 'Scrap Inventory with Retention Quantity Constraint',
* if keep quantity is greater 0.
    if    ls_scrap_ind-scrap_indicator <> cv_scrap_retention
      and ls_scrap_ind-keep_quantity <> 0.
      lv_string_keep_qty = ls_scrap_ind-keep_quantity.
      message i102(migo) with goitem-zeile lv_string_keep_qty.
    endif.
* set current scrap data,even if empty
    call function '/SPE/SCRAP_INDICATORS_SET'
      exporting
        is_scrap_indicator = ls_scrap_ind.
* Save functionality -> check all entries and delete empty ones.
    if okcode = 'OK_POST'.
      if   ls_scrap_ind-scrap_indicator   = cv_scrap_retention
          and ls_scrap_ind-keep_quantity  = 0.
        message i100(migo).
        exit.
      endif.
      call function '/SPE/SCRAP_IND_CHECK'
        importing
          es_return = ls_bapiret2.

      if ls_bapiret2 is not initial.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
    endif.
  endmethod.                    "pai

*----------------------------------------------------------------------*
* Interface
*----------------------------------------------------------------------*

  method lif_migo_frame~okcode_handler.
  endmethod.                    "lif_migo_frame~okcode_handler

  method lif_migo_frame~message_handler.
  endmethod.                    "lif_migo_frame~message_handler


endclass.               "lcl_migo_detail_ewm