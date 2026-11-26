*eject
*&---------------------------------------------------------------------*
*&      Form  VTBER_ERFORDERLICH
*&---------------------------------------------------------------------*
*       Prüfung, ob auf dem Einstiegsbild ein Vertriebsbereich
*       angegeben werden muß
*----------------------------------------------------------------------*
FORM VTBER_ERFORDERLICH USING    US_PARGR
                                 US_PARVW
                                 US_ERROR
                        CHANGING CH_SUBRC.

  PERFORM TPAER_SELECT USING US_PARGR
                             US_PARVW
                             SPACE
                             SY-SUBRC.
  IF TPAER-PAPFL IS INITIAL.
    MESSAGE E644.
  ENDIF.

ENDFORM.                               " VTBER_ERFORDERLICH