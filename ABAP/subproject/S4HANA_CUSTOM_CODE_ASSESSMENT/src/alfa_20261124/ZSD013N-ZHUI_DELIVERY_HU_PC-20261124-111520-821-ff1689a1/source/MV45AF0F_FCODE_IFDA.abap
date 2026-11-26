*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_IFDA                                        *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       FORM FCODE_IFDA
*----------------------------------------------------------------------*
*       Anzeigen Finanzdokument
*----------------------------------------------------------------------*
FORM FCODE_IFDA.

  DATA: lf_from_doc TYPE char1.

  IF VBKD-LCNUM IS INITIAL.
    MESSAGE S544(EI).
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
  ELSE.
    SET PARAMETER ID 'AKN' FIELD VBKD-LCNUM.
    lf_from_doc = 'X'.
    EXPORT lf_from_doc FROM lf_from_doc TO MEMORY ID 'FDTWZ007'.
  ENDIF.

ENDFORM.                                 " FCODE_IFDA