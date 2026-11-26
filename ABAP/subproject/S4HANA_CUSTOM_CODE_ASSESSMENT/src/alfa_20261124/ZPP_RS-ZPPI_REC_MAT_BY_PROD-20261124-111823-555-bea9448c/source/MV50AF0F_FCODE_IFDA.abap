***INCLUDE MV50AF0F_FCODE_IFDA .
*----------------------------------------------------------------------*
*       FORM FCODE_IFDA
*----------------------------------------------------------------------*
*       Anzeigen Finanzdokument
*----------------------------------------------------------------------*
FORM FCODE_IFDA.

DATA: loc_back_to_report(1) TYPE c.

  IF LIKP-LCNUM IS INITIAL.
    MESSAGE S257.
*   MESSAGE S544(EI).
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN.
  ELSE.
    SET PARAMETER ID 'AKN' FIELD LIKP-LCNUM.
    loc_back_to_report = 'X'.
    EXPORT loc_back_to_report TO MEMORY ID 'SAP_FT_LOC_MASTER'.
  ENDIF.

ENDFORM.                               " FCODE_IFDA