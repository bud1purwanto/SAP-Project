*----------------------------------------------------------------------*
*   INCLUDE MV45AF0S_SHIPMENT_VSART_CHECK                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SHIPMENT_VSART_CHECK
*&---------------------------------------------------------------------*
*       Check Business Data Shipping Type against Route table
*----------------------------------------------------------------------*
*      -->US_VSART  Business Data Shipping Type
*      -->US_ROUTE  Item Data Route
*      -->CH_SUBRC  text
*----------------------------------------------------------------------*
FORM SHIPMENT_VSART_CHECK USING    US_VSART
                                   US_ROUTE
                                   CH_SUBRC.

  CH_SUBRC = 0.
  CHECK US_VSART NE SPACE.

  IF US_ROUTE = SPACE.
    CLEAR: TVRO.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVRO WHERE ROUTE = US_ROUTE.

  IF SY-SUBRC NE 0.
    CLEAR TVRO.
    EXIT.
  ENDIF.

  CHECK TVRO-VSART NE SPACE.

  IF US_VSART NE TVRO-VSART.
    MESSAGE ID 'VW' TYPE 'E' NUMBER '815'
      WITH VBKD-VSART TVRO-VSART TVRO-ROUTE.
  ENDIF.

ENDFORM.                    " SHIPMENT_VSART_CHECK