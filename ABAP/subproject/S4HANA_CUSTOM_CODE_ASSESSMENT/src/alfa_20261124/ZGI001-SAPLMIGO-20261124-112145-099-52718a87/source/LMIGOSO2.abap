*----------------------------------------------------------------------*
*   INCLUDE LMIGOSO2                                                   *
*   Screen object implementation
*----------------------------------------------------------------------*

CLASS lcl_migo_screenobject IMPLEMENTATION.

************************************************************************
* SCREENOBJECT executes the calls for the cursor management and
* performs the central field modification.
************************************************************************
METHOD pbo.
* Get the cursor data
  CALL METHOD lcl_migo_cursor=>pbo_cursor_set
       EXPORTING
         i_oref_screenobject = me.
* Execute screenmodification
  CALL METHOD lcl_migo_screenmodification=>main
    EXPORTING i_global_counter = i_global_counter.
ENDMETHOD.

************************************************************************
* Same in PAI
************************************************************************
METHOD pai.
  CALL METHOD lcl_migo_cursor=>pai_cursor_get
       EXPORTING
         i_oref_screenobject = me.
ENDMETHOD.

************************************************************************
* The resolution of the current cursor position is usually
* done in the proper subclass.
************************************************************************
METHOD cursor_position_resolve.
  e_name  = 'UNKNOWN'.                                       "#EC NEEDED
  e_tabix = 0.
ENDMETHOD.

ENDCLASS.