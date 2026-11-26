*---------------------------------------------------------------------*
*       FORM BELEG_PRUEFEN                                            *
*---------------------------------------------------------------------*
*       Beleg auf Konsistenz prüfen                                   *
*       Inkonsistenzen führen zum Abbruch                             *
*       DER MODUL KANN KEINE DIALOGE MEHR BRINGEN                     *
*---------------------------------------------------------------------*
FORM BELEG_PRUEFEN.

  CHECK MODIFICATION_FLAG-NO_PRICING IS INITIAL.
  CHECK: YVBAK_UPDKZ NE UPDKZ_DELETE.

  IF NOT VBAK-NETWR IS INITIAL.
    DESCRIBE TABLE XKOMV LINES SY-TFILL.
    IF SY-TFILL = 0.
      MESSAGE A557.
    ENDIF.
  ENDIF.

ENDFORM.