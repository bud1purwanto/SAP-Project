*----------------------------------------------------------------------*
*   INCLUDE MV50AI0G                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR_POSITION  INPUT
*&---------------------------------------------------------------------*
MODULE GET_CURSOR_POSITION INPUT.

* Check whether cursor is on current dynpro. If not GS_GET_CURSOR
* remains unchanged
  GET CURSOR FIELD GF_CURSOR_FIELDNAME.
  IF SY-SUBRC EQ 0.
    GET CURSOR FIELD GS_GET_CURSOR-FIELDNAME
               LINE  GS_GET_CURSOR-LINE.
  ENDIF.

ENDMODULE.                             " GET_CURSOR_POSITION  INPUT

*&---------------------------------------------------------------------*
*&      Module  GET_NEW_DOC_NUMBER  INPUT
*&---------------------------------------------------------------------*
MODULE GET_NEW_DOC_NUMBER INPUT.

  IF FCODE(4) EQ FCODE_ABBRECHEN.
    CLEAR RV50A-VBELN.
  ENDIF.
  LEAVE TO SCREEN 0.

ENDMODULE.                             " GET_NEW_DOC_NUMBER  INPUT

*&---------------------------------------------------------------------*
*&      Module  get_fcode  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_FCODE INPUT.

  CALL FUNCTION 'EHS003_GET_FCODE'
    EXPORTING
      I_FCODE = FCODE
    EXCEPTIONS
      OTHERS_ = 1.

ENDMODULE.                 " get_fcode  INPUT