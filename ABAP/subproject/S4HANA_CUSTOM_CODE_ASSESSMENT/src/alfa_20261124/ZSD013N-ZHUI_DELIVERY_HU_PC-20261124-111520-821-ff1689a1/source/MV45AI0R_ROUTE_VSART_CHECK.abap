*----------------------------------------------------------------------*
*   INCLUDE MV45AI0R_ROUTE_VSART_CHECK                                 *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  ROUTE_VSART_CHECK  INPUT
*&---------------------------------------------------------------------*
*       Check Route Shipping Type (VSART) against VBKD-VSART
*----------------------------------------------------------------------*
MODULE ROUTE_VSART_CHECK INPUT.

  PERFORM ROUTE_VSART_CHECK USING VBAP-ROUTE
                                  CHARX
                                  SY-SUBRC.

ENDMODULE.                 " ROUTE_VSART_CHECK  INPUT
