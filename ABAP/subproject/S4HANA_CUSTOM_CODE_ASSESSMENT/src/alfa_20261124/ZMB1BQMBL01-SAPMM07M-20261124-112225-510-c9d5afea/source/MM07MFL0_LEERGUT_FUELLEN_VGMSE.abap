*&---------------------------------------------------------------------*
*&      Form  LEERGUT_FUELLEN_VGMSEG
*&---------------------------------------------------------------------*
*       text: append a full product to table vgmseg if it's not in the
*             table yet
*----------------------------------------------------------------------*
FORM LEERGUT_FUELLEN_VGMSEG.

  DATA: H_MBEFU LIKE MBEFU.

  READ TABLE VGMSEG WITH KEY MATNR = MSEG-MATNR
                             ZEILE = MSEG-ZEILE
                             EBELN = MSEG-EBELN
                             EBELP = MSEG-EBELP.
  IF NOT SY-SUBRC IS INITIAL.
    VGMSEG-MATNR = MSEG-MATNR.
    VGMSEG-ZEILE = MSEG-ZEILE.
    VGMSEG-EBELN = MSEG-EBELN.
    VGMSEG-EBELP = MSEG-EBELP.
    VGMSEG-MATBF = MBEFU-MATNR.
    VGMSEG-MENGU = MSEG-MENGU.
    VGMSEG-WERTU = MSEG-WERTU.
    VGMSEG-WERKS = MSEG-WERKS.
    VGMSEG-UMWRK = MSEG-UMWRK.
    IF NOT VGMSEG-UMWRK IS INITIAL.
* in case of a stock transfer -> get the material on which the stock is
* managed at the receiver's
      PERFORM LESE_VOLLGUT USING    VGMSEG-UMWRK
                                    MSEG-UMLGO
                                    VGMSEG-MATNR
                           CHANGING H_MBEFU.

      IF SY-SUBRC IS INITIAL.
        MOVE H_MBEFU-MATNR TO VGMSEG-UMMATBF.
      ENDIF.
    ENDIF.
    APPEND VGMSEG.
  ENDIF.
ENDFORM.                               " LEERGUT_FUELLEN_VGMSEG