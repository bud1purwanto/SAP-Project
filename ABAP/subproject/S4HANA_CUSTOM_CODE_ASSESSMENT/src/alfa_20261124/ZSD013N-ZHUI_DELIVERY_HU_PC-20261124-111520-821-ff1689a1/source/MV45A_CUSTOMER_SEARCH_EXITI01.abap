*----------------------------------------------------------------------*
***INCLUDE MV45A_CUSTOMER_SEARCH_EXITI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  ACCEPT_CUSTOMER_SEARCH  INPUT
*&---------------------------------------------------------------------*
*       Step 1: Split the system okay code and use the part
*               that contains the needed information.
*       Step 2: Handle okay codes.
*----------------------------------------------------------------------*
MODULE accept_customer_search INPUT.
  DATA:   str1 TYPE string,
          str2 TYPE string,
          str3 TYPE string.

* Split the system okay code and use the part that contains the needed information
  SPLIT fcode AT space INTO str1 str2 str3.
  IF str1 EQ '%_GC'.
    fcode = str3.
  ELSE.
    fcode = str1.
  ENDIF.

* Handle okay codes
  IF fcode = 'OKAY' OR fcode = '19'.
    PERFORM cs_read_from_alv.
  ELSEIF fcode = 'EESC' OR fcode = 'CANC'.
    CLEAR gv_kunnr_from_search.
  ENDIF.

* right klick on line
  if fcode = '9'.
    gv_right_click = abap_true.
    return.
  else.
    gv_right_click = abap_false.
  endif.

*if not doubleclick on line end popup
  IF NOT fcode = '3'.
    fcode = 'ENT1'.
    SET SCREEN 0.
    LEAVE SCREEN.
  ENDIF.

ENDMODULE.                 " ACCEPT_CUSTOMER_SEARCH  INPUT