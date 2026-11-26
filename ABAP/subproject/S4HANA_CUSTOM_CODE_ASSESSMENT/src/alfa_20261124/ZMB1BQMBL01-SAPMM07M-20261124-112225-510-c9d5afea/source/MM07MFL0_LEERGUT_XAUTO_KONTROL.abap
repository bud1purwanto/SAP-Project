*&---------------------------------------------------------------------*
*&      Form  LEERGUT_XAUTO_KONTROLLIEREN
*&---------------------------------------------------------------------*
*       text: check whether xauto for the empty has to be changed (this
*             depends on how the full product is managed in werks
*             and (if exists) in umwrk
*----------------------------------------------------------------------*
FORM LEERGUT_XAUTO_KONTROLLIEREN.

  CHECK XMBWL IS INITIAL.
* either there is a purchase order -> the field uebpo points to the full
* product
* or the field urzei is populated and shows to the full product
  IF NOT FUSS-UEBPO IS INITIAL.
    READ TABLE VGMSEG WITH KEY EBELN = FUSS-EBELN  EBELP = FUSS-UEBPO.
    IF SY-SUBRC IS INITIAL.
      PERFORM LEERGUT_XAUTO_SETZEN.
    ENDIF.
  ELSEIF NOT MSEG-URZEI IS INITIAL.
    READ TABLE VGMSEG WITH KEY ZEILE = MSEG-URZEI.
    IF SY-SUBRC IS INITIAL.
      PERFORM LEERGUT_XAUTO_SETZEN.
    ENDIF.
  ENDIF.

ENDFORM.                               " LEERGUT_XAUTO_KONTROLLIEREN