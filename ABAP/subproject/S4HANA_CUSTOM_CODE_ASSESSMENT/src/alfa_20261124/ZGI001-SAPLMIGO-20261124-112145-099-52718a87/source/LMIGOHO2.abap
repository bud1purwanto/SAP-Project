*----------------------------------------------------------------------*
*   INCLUDE LMIGOHO2                                                   *
*   Header object implementation
*----------------------------------------------------------------------*

CLASS lcl_migo_headerobject IMPLEMENTATION.

************************************************************************
* If the cursor is in this object, what's the current line
************************************************************************
METHOD cursor_position_resolve.
  e_name = 'HEADER'.
ENDMETHOD.

************************************************************************
* PBO: Cursor position information
*      Dynpro modification
************************************************************************
METHOD pbo.
  CALL METHOD super->pbo.
* CALL METHOD lcl_migo_screenmodification=>screen_modify_header.
ENDMETHOD.

ENDCLASS.