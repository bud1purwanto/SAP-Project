*----------------------------------------------------------------------*
*   INCLUDE MV45AI0S_SHIPMENT_VSART_CHECK                              *
*----------------------------------------------------------------------*

* PERFORM SHIPMENT_VSART_CHECK USING VBKD-VSART
*                                    VBAP-ROUTE
*                                    SY-SUBRC.

* IF SY-SUBRC NE 0.
* ENDIF.

*&---------------------------------------------------------------------*
*&      Module  SHIPMENT_VSART_CHECK  INPUT
*&---------------------------------------------------------------------*
*       Check VBKD-VSART against Route table
*----------------------------------------------------------------------*
MODULE SHIPMENT_VSART_CHECK INPUT.

  PERFORM SHIPMENT_VSART_CHECK USING VBKD-VSART
                                     VBAP-ROUTE
                                     SY-SUBRC.

ENDMODULE.                 " SHIPMENT_VSART_CHECK  INPUT



















