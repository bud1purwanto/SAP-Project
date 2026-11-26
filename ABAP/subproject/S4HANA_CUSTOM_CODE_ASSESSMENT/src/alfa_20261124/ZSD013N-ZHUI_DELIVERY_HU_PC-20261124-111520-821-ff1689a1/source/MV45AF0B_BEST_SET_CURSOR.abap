*eject
*----------------------------------------------------------------------*
*-      Form  BEST_SET_CURSOR
*----------------------------------------------------------------------*
*       set cursor ergonomicly
*----------------------------------------------------------------------*
*      -->US_FELDNAME      field which the cursor is set
*----------------------------------------------------------------------*
FORM BEST_SET_CURSOR USING    US_FELDNAME.

* Cursor is set the specific filed at first line
  SET CURSOR FIELD US_FELDNAME LINE 1.

ENDFORM.                               " BEST_SET_CURSOR