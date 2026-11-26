*----------------------------------------------------------------------*
*   INCLUDE LMIGODW2                                                   *
*----------------------------------------------------------------------*
*   Detail tabstrip warehouse management
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_wm IMPLEMENTATION.

*----------------------------------------------------------------------*
* METHOD CONSTRUCTOR
*----------------------------------------------------------------------*
  METHOD constructor.
    super->constructor( ).
  ENDMETHOD.
*----------------------------------------------------------------------*
* METHOD PBO
*----------------------------------------------------------------------*
  METHOD pbo.
    DATA: ls_disp_data TYPE wms_migo_disp.
    CALL METHOD super->pbo.
*   creation mode: screen SAPLLPAL 0100
    IF lcl_migo_globals=>kernel->s_action-display = abap_false.
      g_sub_wm = '0100'.
*     Send current line to WM (data has been filled in line_check)
      CALL FUNCTION 'SEND_CURRENT_LINE_TO_WM'
        EXPORTING
          i_global_counter       = goitem-global_counter.
*   display mode: screen SAPLLPAL 0200
    ELSE.
      g_sub_wm = '0200'.
      MOVE-CORRESPONDING goitem TO ls_disp_data.
      CALL FUNCTION 'SEND_DISP_LINE_TO_WM'
        EXPORTING
          i_disp_data   = ls_disp_data
                .
    ENDIF.
  ENDMETHOD.

*----------------------------------------------------------------------*
* METHOD PAI
*----------------------------------------------------------------------*
  METHOD pai.
    CALL METHOD super->pai.
  ENDMETHOD.

*----------------------------------------------------------------------*
* Interface
*----------------------------------------------------------------------*

  METHOD lif_migo_frame~okcode_handler.
* call method...
  ENDMETHOD.

  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.


ENDCLASS.