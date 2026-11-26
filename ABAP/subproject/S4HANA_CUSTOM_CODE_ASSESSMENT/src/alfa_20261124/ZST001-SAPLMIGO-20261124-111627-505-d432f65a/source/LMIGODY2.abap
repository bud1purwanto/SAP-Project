*----------------------------------------------------------------------*
***INCLUDE LMIGODY2 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_MIGO_DETAIL_EXT_INT
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_ext_int IMPLEMENTATION.
***********************************************************************
* Constructor                                                         *
***********************************************************************
  METHOD constructor.
    CALL METHOD super->constructor.
    IF if_badi_ext_int IS NOT BOUND.
      TRY.
          GET BADI if_badi_ext_int.
          IF if_badi_ext_int IS BOUND.
            CALL BADI if_badi_ext_int->get_no_tab_text
              RECEIVING
                rv_no_tab_text = gv_scrn_badi_no_tab.
          ENDIF.
        CATCH cx_badi.
          CLEAR if_badi_ext_int.
      ENDTRY.
    ENDIF.
  ENDMETHOD.                    "constructor

***********************************************************************
* Message_handling                                                    *
***********************************************************************
  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.                    "lif_migo_frame~message_handler

************************************************************************
* OK-code handler
************************************************************************
  METHOD lif_migo_frame~okcode_handler.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler

***********************************************************************
*          pbo                                                        *
***********************************************************************
  METHOD pbo.
    DATA:
      lv_tab_visible  TYPE abap_bool,
      lv_tab_relevant TYPE abap_bool,
      ls_migo_action  TYPE lcl_migo_kernel=>ty_s_action,
      ls_badi_action  TYPE migo_badi_ext_int_action.

    gv_scrn_badi_dynpro  = '2099'.
    gv_scrn_badi_program = 'SAPLMIGO'.

    IF if_badi_ext_int IS BOUND.
      TRY.
          CALL BADI if_badi_ext_int->get_tab_visibility
            EXPORTING
              is_goitem  = goitem
            RECEIVING
              rv_visible = lv_tab_visible.
        CATCH cx_badi.
          CLEAR if_badi_ext_int.
      ENDTRY.

      IF lv_tab_visible = abap_true.
        TRY.
            CALL BADI if_badi_ext_int->get_tab_relevance
              EXPORTING
                is_goitem   = goitem
              RECEIVING
                rv_relevant = lv_tab_relevant.
          CATCH cx_badi.
            CLEAR if_badi_ext_int.
        ENDTRY.

        IF lv_tab_relevant IS INITIAL.
          gv_scrn_badi_dynpro  = '4201'.
          gv_scrn_badi_program = 'SAPLMIGO'.
          RETURN.
        ENDIF.
      ENDIF.

      TRY.
          CALL METHOD
            cl_enh_badi_runtime_functions=>get_prog_and_dynp_for_subscr
            EXPORTING
              badi_name       = 'MB_MIGO_BADI_EXT_INT'
              calling_dynpro  = '4200'
              calling_program = 'SAPLMIGO'
              subscreen_area  = 'EXT_INT'
            IMPORTING
              called_dynpro   = gv_scrn_badi_dynpro
              called_program  = gv_scrn_badi_program
            EXCEPTIONS
              OTHERS          = 1.
        CATCH cx_enh_badi_inconsistent
              cx_enh_badi_no_such_extension
              cx_enh_badi_not_found
              cx_enh_badi_mulitple_impls
              cx_enh_badi_filter_missing
              cx_badi.
          RETURN.
      ENDTRY.

      MOVE lcl_migo_globals=>kernel->s_action TO ls_migo_action.
      ls_badi_action-migo_cancel       = ls_migo_action-cancel.
      ls_badi_action-migo_create       = ls_migo_action-create.
      ls_badi_action-migo_copy         = ls_migo_action-copy.
      ls_badi_action-migo_display      = ls_migo_action-display.
      ls_badi_action-migo_mode         = ls_migo_action-migo_mode.

      TRY.
          CALL BADI if_badi_ext_int->put_data_to_screen
            EXPORTING
              is_goitem = goitem
              is_action = ls_badi_action.

          CALL BADI if_badi_ext_int->get_tab_name
            RECEIVING
              rv_tab_name = ts_goitem_ext_int.
        CATCH cx_badi.
          CLEAR if_badi_ext_int.
      ENDTRY.
    ENDIF.
  ENDMETHOD.                    "pbo

***********************************************************************
*          pai                                                        *
***********************************************************************
  METHOD pai.
    DATA: ls_goitem TYPE goitem.

    IF if_badi_ext_int IS BOUND.
      ls_goitem = goitem.
      TRY.
          CALL BADI if_badi_ext_int->pai
            CHANGING
              cv_okcode = okcode
              cs_goitem = ls_goitem.
        CATCH cx_badi.
          CLEAR if_badi_ext_int.
      ENDTRY.

      IF ls_goitem <> goitem.
        CALL METHOD lcl_migo_globals=>kernel->line_modify
          EXPORTING
            i_status_delayed = abap_true
            i_force_change   = abap_true
            i_line           = oref_detail->current_line
          CHANGING
            cs_goitem        = ls_goitem.
        goitem = ls_goitem.
      ENDIF.

      TRY.
          CALL BADI if_badi_ext_int->put_data_to_screen
            EXPORTING
              is_goitem = goitem.
        CATCH cx_badi.
          CLEAR if_badi_ext_int.
      ENDTRY.
    ENDIF.
  ENDMETHOD.                    "pai
  "pai
************************************************************************
* get_visibility
************************************************************************
  METHOD get_tab_visibility.
    IF if_badi_ext_int IS BOUND.
      TRY.
          CALL BADI if_badi_ext_int->get_tab_visibility
            EXPORTING
              is_goitem  = is_goitem
            RECEIVING
              rv_visible = rv_visible.
        CATCH cx_badi.
          CLEAR if_badi_ext_int.
      ENDTRY.
    ENDIF.
  ENDMETHOD.                    "cursor_position_resolve
************************************************************************
* cursor_position_resolve
************************************************************************
  METHOD cursor_position_resolve.
  ENDMETHOD.                    "cursor_position_resolve

ENDCLASS.               "LCL_MIGO_DETAIL_EXT_INT