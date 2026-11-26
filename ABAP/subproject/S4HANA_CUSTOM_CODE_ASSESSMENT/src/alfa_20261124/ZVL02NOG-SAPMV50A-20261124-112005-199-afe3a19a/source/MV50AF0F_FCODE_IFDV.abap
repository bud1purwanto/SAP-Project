***INCLUDE MV50AF0F_FCODE_IFDV .
*----------------------------------------------------------------------*
*       FORM FCODE_IFDV
*----------------------------------------------------------------------*
*       Aendern Finanzdokument
*----------------------------------------------------------------------*
FORM FCODE_IFDV.

  IF LIKP-LCNUM IS INITIAL.
    MESSAGE S257.
*   MESSAGE S544(EI).
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
  ELSE.
    SET PARAMETER ID 'AKN' FIELD LIKP-LCNUM.
  ENDIF.

ENDFORM.                               " FCODE_IFDV