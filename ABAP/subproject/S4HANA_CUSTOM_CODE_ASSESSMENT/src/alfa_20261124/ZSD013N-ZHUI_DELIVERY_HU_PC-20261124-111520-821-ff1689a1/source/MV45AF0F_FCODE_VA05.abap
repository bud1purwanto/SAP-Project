*---------------------------------------------------------------------*
*       FORM FCODE_VA05                                               *
*---------------------------------------------------------------------*
*       Umsetzen des FCodes VA05 in den jeweiligen Transaktionscode   *
*---------------------------------------------------------------------*
FORM FCODE_VA05.

  LOCAL: KUAGV-KUNNR.

  IF KUAGV-KUNNR(1) = '?'.
    CLEAR KUAGV-KUNNR.
  ENDIF.
  SET PARAMETER ID 'VAG' FIELD KUAGV-KUNNR.
  SET PARAMETER ID 'AAV' FIELD '  '.
* SET PARAMETER ID 'PAR' FIELD 'AG'.
* Bei VA02-Anforderungsbild ist der Beleg noch nicht eingelesen
  IF VBAK-VKORG NE SPACE.
    SET PARAMETER ID 'VKO' FIELD VBAK-VKORG.
    SET PARAMETER ID 'VTW' FIELD VBAK-VTWEG.
    SET PARAMETER ID 'SPA' FIELD VBAK-SPART.
  ENDIF.

ENDFORM.