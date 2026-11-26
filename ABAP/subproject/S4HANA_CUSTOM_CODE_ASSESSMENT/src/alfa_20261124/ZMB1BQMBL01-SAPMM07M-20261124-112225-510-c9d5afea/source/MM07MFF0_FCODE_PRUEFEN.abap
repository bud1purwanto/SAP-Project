*eject
*---------------------------------------------------------------------*
*        FORM FCODE_PRUEFEN                                           *
*---------------------------------------------------------------------*
*        Der eingegebene FCODE   wird geprueft. Sofern dieser o. k.   *
*        ist (RC = 0) wird die interne Tabelle FUSS gelesen. Sofern   *
*        kein Eintrag gefunden wird, wird der FCODE auf FCODE_NEXT    *
*        umgesetzt.                                                   *
*        In beiden Faellen wird der FCODE gegen die Feldleiste FCOD   *
*        geprueft.                                                    *
*---------------------------------------------------------------------*
FORM fcode_pruefen.

  old_fcausw = fcausw.
  IF fcode NE fcode_next.
    CLEAR a_zeile.
    IF t063o-auswa = p.
      DATA: zeile LIKE m_zeile. CLEAR zeile.
      zeile = m_zeile + s_zeile.
      IF zeile < rm07m-zeile.
        CLEAR rm07m-zeile.
        fcode_next = fcode.
        IF fcode = fcod-nl.
          fcode_next = fcod-kl.
        ENDIF.
      ENDIF.
    ENDIF.
    fcode = fcode_next.
    CHECK t063o-auswa NE u.
    PERFORM fcode_lesen USING fcode.
    IF NOT old_fcausw-xselp IS INITIAL AND fcausw-xselp IS INITIAL
       AND NOT t063o-xback IS INITIAL.
      PERFORM auswahl_pruefen.
    ENDIF.
  ENDIF.
  IF NOT fcausw-xneup IS INITIAL AND fcausw-xlist IS INITIAL.
    IF m_zeile >= max_zeile.
      MESSAGE w008 WITH max_zeile.
      fcode_next = fcod-ab.
      fcode = fcode_next.
      PERFORM fcode_lesen USING fcode.
    ENDIF.
  ENDIF.

ENDFORM.