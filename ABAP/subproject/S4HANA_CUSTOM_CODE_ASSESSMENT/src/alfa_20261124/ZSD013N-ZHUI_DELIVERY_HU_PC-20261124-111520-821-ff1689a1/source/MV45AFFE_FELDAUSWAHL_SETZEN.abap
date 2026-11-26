*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_SETZEN                                       *
*---------------------------------------------------------------------*
*       Feldauswahl setzen                                            *
*---------------------------------------------------------------------*
FORM FELDAUSWAHL_SETZEN USING US_SUBRC.

  CASE US_SUBRC.
    WHEN 1.
      SCREEN-INPUT = 0.
    WHEN 2.
      SCREEN-ACTIVE = 0.
  ENDCASE.

ENDFORM.