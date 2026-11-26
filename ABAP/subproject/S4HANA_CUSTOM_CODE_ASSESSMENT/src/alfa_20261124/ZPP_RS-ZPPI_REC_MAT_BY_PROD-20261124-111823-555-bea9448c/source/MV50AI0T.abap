*----------------------------------------------------------------------*
***INCLUDE MV50AI0T .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  TRACKING_PASS_FCODE  INPUT
*&---------------------------------------------------------------------*
MODULE TRACKING_PASS_FCODE INPUT.

  CALL FUNCTION 'XSI_PASS_FCODE'
       EXPORTING
            OKCODE = FCODE.

ENDMODULE.                             " TRACKING_PASS_FCODE  INPUT

*&---------------------------------------------------------------------*
*&      Module  TRACKING_GET_FCODE  INPUT
*&---------------------------------------------------------------------*
MODULE TRACKING_GET_FCODE INPUT.

  CALL FUNCTION 'XSI_FETCH_FCODE'
       IMPORTING
            OKCODE = FCODE.

  IF FCODE IS INITIAL.
    FCODE = FCODE_GLEICHE_SEITE.
  ENDIF.

ENDMODULE.                             " TRACKING_GET_FCODE  INPUT

*&---------------------------------------------------------------------*
*&      Module  TRACKING_SUBSCREEN_GET_DATA  INPUT
*&---------------------------------------------------------------------*
MODULE TRACKING_SUBSCREEN_GET_DATA INPUT.

  PERFORM TRACKING_SUBSCREEN_GET_DATA.

ENDMODULE.                 " TRACKING_SUBSCREEN_GET_DATA  INPUT