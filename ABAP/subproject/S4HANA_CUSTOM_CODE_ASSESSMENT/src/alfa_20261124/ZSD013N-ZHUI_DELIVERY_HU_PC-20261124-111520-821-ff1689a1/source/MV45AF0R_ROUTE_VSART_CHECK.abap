*----------------------------------------------------------------------*
*   INCLUDE MV45AF0R_ROUTE_VSART_CHECK                                 *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ROUTE_VSART_CHECK
*&---------------------------------------------------------------------*
*       Compare Shipping Type on Route to Shipping Type from
*       Transportation relevant fields in VBKD
*----------------------------------------------------------------------*
FORM ROUTE_VSART_CHECK USING US_ROUTE
                             US_ERROR
                        CHANGING
                             CH_SUBRC.

  DATA: L_XVBKD_WA LIKE VBKDVB.

  CH_SUBRC = 0.

  CHECK US_ROUTE <> SPACE.

* Get VBKD entry for line item
  READ TABLE XVBKD INTO L_XVBKD_WA
                   WITH KEY POSNR = VBAP-POSNR
                   BINARY SEARCH.
  IF SY-SUBRC <> 0.
*   Check header instead.
    READ TABLE XVBKD INTO L_XVBKD_WA
                     WITH KEY POSNR = '000000'
                     BINARY SEARCH.
  ENDIF.

  CH_SUBRC = SY-SUBRC.

  CHECK CH_SUBRC EQ 0.

  CHECK L_XVBKD_WA-VSART NE SPACE.

  CHECK TVRO-VSART NE SPACE.

  IF L_XVBKD_WA-VSART NE TVRO-VSART.
    MESSAGE ID 'VW' TYPE 'E' NUMBER '809'.
  ENDIF.


ENDFORM.                    " ROUTE_VSART_CHECK
