*---------------------------------------------------------------------*
*       FORM FCODE_KUST                                               *
*---------------------------------------------------------------------*
*       Übergang zum Kundenstammblatt                                 *
*---------------------------------------------------------------------*
FORM FCODE_KUST.

  IF NOT VBAK-KUNNR IS INITIAL.
    SUBMIT RVKUSTA1 AND RETURN
      WITH VKORG = VBAK-VKORG
      WITH VTWEG = VBAK-VTWEG
      WITH SPART = VBAK-SPART
      WITH KUNNR = VBAK-KUNNR.
  ENDIF.

ENDFORM.