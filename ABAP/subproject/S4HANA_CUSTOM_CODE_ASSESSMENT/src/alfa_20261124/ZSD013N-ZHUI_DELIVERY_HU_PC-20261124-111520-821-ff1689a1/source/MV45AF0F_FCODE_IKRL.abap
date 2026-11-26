*eject
*---------------------------------------------------------------------*
*       FORM FCODE_IKRL                                               *
*---------------------------------------------------------------------*
*       Anzeige Kreditlimit-Kontrollbereich                           *
*---------------------------------------------------------------------*
FORM FCODE_IKRL.
  IF VBAK-KKBER IS INITIAL OR
     VBAK-KNKLI IS INITIAL.
    MESSAGE S659.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
  ELSE.
    SET PARAMETER ID 'KUN' FIELD VBAK-KNKLI.
    SET PARAMETER ID 'KKB' FIELD VBAK-KKBER.
    SET PARAMETER ID 'CDY' FIELD '/0210'.
  ENDIF.
ENDFORM.