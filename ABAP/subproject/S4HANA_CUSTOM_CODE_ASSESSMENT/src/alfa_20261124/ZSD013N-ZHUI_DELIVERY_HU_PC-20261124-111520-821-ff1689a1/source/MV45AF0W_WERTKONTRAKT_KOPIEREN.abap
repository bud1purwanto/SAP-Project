*&---------------------------------------------------------------------*
*&      FORM  WERTKONTRAKT_KOPIEREN_PRUEFEN
*&---------------------------------------------------------------------*
*       Es wird geprüft, ob weitere Materialien als das Material       *
*       der Wertkontraktposition abgerufen werden können.              *
*----------------------------------------------------------------------*
FORM WERTKONTRAKT_KOPIEREN_PRUEFEN USING US_WKKOP
                                         US_AUARN
                                         US_AUARV
                                         US_FKARV
                                         US_ETTYV
                                         US_PSTYV
                                         US_PSTYN.

  DATA: BEGIN OF DA_TVCPA.
          INCLUDE STRUCTURE TVCPA.
  DATA: END OF DA_TVCPA.

  CLEAR US_WKKOP.

  SELECT SINGLE WKKOP PSTYN FROM TVCPA INTO (US_WKKOP, US_PSTYN)
                                 WHERE AUARN = US_AUARN AND
                                       AUARV = US_AUARV AND
                                       FKARV = US_FKARV AND
                                       ETTYV = US_ETTYV AND
                                       PSTYV = US_PSTYV.

ENDFORM.