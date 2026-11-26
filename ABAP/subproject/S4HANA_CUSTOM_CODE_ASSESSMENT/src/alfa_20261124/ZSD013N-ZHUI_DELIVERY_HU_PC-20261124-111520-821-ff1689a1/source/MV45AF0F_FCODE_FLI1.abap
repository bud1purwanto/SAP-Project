*---------------------------------------------------------------------*
*       FORM FCODE_FLI1                                               *
*---------------------------------------------------------------------*
*       Kein Beleg da und Lieferung aufrufen                          *
*---------------------------------------------------------------------*
FORM FCODE_FLI1.

  SET PARAMETER ID 'VKO' FIELD VBAK-VKORG.
  SET PARAMETER ID 'VTW' FIELD VBAK-VTWEG.
  SET PARAMETER ID 'SPA' FIELD VBAK-SPART.
  IF SY-DATAR = SPACE AND
     SVBAK-TABIX = 0.
    LEAVE TO TRANSACTION 'VL01N'.
  ENDIF.
  PERFORM FCODE_EXIT(SAPLV00F).

ENDFORM.