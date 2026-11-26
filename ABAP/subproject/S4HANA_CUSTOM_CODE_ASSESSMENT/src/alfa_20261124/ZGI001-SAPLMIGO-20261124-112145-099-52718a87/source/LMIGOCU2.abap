*----------------------------------------------------------------------*
*   INCLUDE LMIGOCU2                                                   *
*   Cursor control
*----------------------------------------------------------------------*

CLASS lcl_migo_cursor IMPLEMENTATION.

************************************************************************
* Place the cursor into this screen if it's the right one
************************************************************************
  METHOD pbo_cursor_set.
    IF oref_screenobject = i_oref_screenobject OR
       dynnr             = sy-dynnr.
      SET CURSOR FIELD field LINE stepl.
    ENDIF.
  ENDMETHOD.

************************************************************************
* Check whether the cursor is on the current screen and set the
* internal buffer accordingly
************************************************************************
  METHOD pai_cursor_get.
    DATA: l_field TYPE scrfname,
          l_stepl TYPE systepl,
          l_value TYPE char50.
    GET CURSOR FIELD l_field LINE l_stepl VALUE l_value.
    IF sy-subrc = 0.
      oref_screenobject = i_oref_screenobject.
      stepl             = l_stepl.
      field             = l_field.
      value             = l_value.
      dynnr             = sy-dynnr.
    ENDIF.
  ENDMETHOD.
************************************************************************
* Manual setting of the new cursor position
************************************************************************
  METHOD cursor_set.
    oref_screenobject = i_oref_screenobject.
    field             = i_field.
    stepl             = i_stepl.
    dynnr             = i_dynnr.
  ENDMETHOD.
************************************************************************
* Clear the cursor position. If not refilled, there will be no
* SET CURSOR during next PBO
************************************************************************
METHOD clear.
  CLEAR: oref_screenobject, field, value, stepl, dynnr.
ENDMETHOD.

ENDCLASS.