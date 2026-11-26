*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TVSTAT_SELECT                                     *
*----------------------------------------------------------------------*
FORM TVSTAT_SELECT USING US_AUART
                         US_STSMA
                   CHANGING CH_TVSTAT STRUCTURE TVSTAT.

  STATICS: ST_TVSTAT LIKE TVSTAT OCCURS 0 WITH HEADER LINE.

* Stimmt Kopfzeile schon?
  CHECK CH_TVSTAT-AUART NE US_AUART OR
        CH_TVSTAT-STSMA NE US_STSMA.

* Stimmt Kopfzeile der Puffertabelle schon?
  IF ST_TVSTAT-AUART = US_AUART AND
     ST_TVSTAT-STSMA = US_STSMA.
    CH_TVSTAT = ST_TVSTAT.
    EXIT.
  ENDIF.

* Einmal je Auftragsart wird die Tabelle nachgelesen.
  READ TABLE ST_TVSTAT WITH KEY AUART = US_AUART.
  IF SY-SUBRC NE 0.
    SELECT * FROM TVSTAT APPENDING TABLE ST_TVSTAT
                         WHERE AUART = US_AUART
                         ORDER BY PRIMARY KEY.
  ENDIF.

  IF US_AUART NE ST_TVSTAT-AUART OR
     US_STSMA NE ST_TVSTAT-STSMA.
    READ TABLE ST_TVSTAT WITH KEY AUART = US_AUART
                                  STSMA = US_STSMA
                         BINARY SEARCH.
    IF SY-SUBRC NE 0.
      READ TABLE ST_TVSTAT WITH KEY AUART = US_AUART
                                    STSMA = SPACE
                           BINARY SEARCH.
      IF SY-SUBRC NE 0.
        CLEAR CH_TVSTAT.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

  MOVE ST_TVSTAT TO CH_TVSTAT.         " Für externe Aufrufe

ENDFORM.