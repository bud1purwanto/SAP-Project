*&---------------------------------------------------------------------*
*&      Form  leergut_xauto_setzen
*&---------------------------------------------------------------------*
*       text: determine the value for mseg-xauto of the actual empty
*----------------------------------------------------------------------*
FORM LEERGUT_XAUTO_SETZEN.

  IF VGMSEG-MATNR <> VGMSEG-MATBF.
* full product is managed on a value-only basis at sender's
    IF NOT VGMSEG-UMMATBF IS INITIAL.
      IF VGMSEG-MATNR <> VGMSEG-UMMATBF.
* full product is managed on a value-only basis at receiver's
        MSEG-XAUTO = F.
      ELSE.
        MSEG-XAUTO = W.
      ENDIF.
    ELSE.
      MSEG-XAUTO = F.
    ENDIF.
  ELSE.
* full product is managed normally at sender's
    IF NOT VGMSEG-UMMATBF IS INITIAL.
      IF VGMSEG-MATNR <> VGMSEG-UMMATBF.
* full product is managed on a value-only basis at receiver's
        MSEG-XAUTO = M.
      ELSE.
        MSEG-XAUTO = L.
      ENDIF.
    ELSE.
      MSEG-XAUTO = L.
    ENDIF.
  ENDIF.

ENDFORM.                               " leergut_xauto_setzen