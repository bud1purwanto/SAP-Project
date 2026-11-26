*&---------------------------------------------------------------------*
*&      Form  ABHOLFENSTER_PRUEFEN
*&---------------------------------------------------------------------*
*       für MAIS-Aufträge wird das Abholfenster geprüft
*----------------------------------------------------------------------*
FORM ABHOLFENSTER_PRUEFEN USING US_MODE
                                US_ABHOD
                                US_ABHOV
                                US_ABHOB
                                US_VBELN.

  IF US_MODE EQ CHARX.
    IF NOT *VBAK-ABHOD IS INITIAL AND
           US_ABHOD NE *VBAK-ABHOD.
      PERFORM MESSAGE_VARIABEL(SAPFV45L) USING 'V4'
                                         '168'
                                         RV45Z-MSGVS
                                         ' '
                                         *VBAK-ABHOD
                                         US_ABHOD
                                         SPACE
                                         SPACE.
* Das Abholdatum sollte nur in Absprache mit dem Kunden geändert werden
    ENDIF.
    IF NOT US_ABHOD IS INITIAL.
* Prüfen Abholdatum auf Gültigkeit im Fabrikkalender der Versandstelle
      IF ( NOT SY-BINPT IS INITIAL AND CATTAKTIV IS INITIAL ) OR
         NOT SY-BATCH IS INITIAL OR
         KOPIEREN EQ CHARX.
        PERFORM VBAP_ABHOLDATUM_PRUEFEN(SAPFV45P) USING SPACE
                                                        US_ABHOD
                                                        CHARX.
      ELSE.
        PERFORM VBAP_ABHOLDATUM_PRUEFEN(SAPFV45P) USING CHARX
                                                        US_ABHOD
                                                        CHARX.
      ENDIF.
      IF US_ABHOD NE *VBAK-ABHOD.
        MESSAGE W786.
*   Das Preisdatum wird nicht automatisch angepaßt
      ENDIF.
      IF US_ABHOD NE *VBAK-ABHOD OR
         SVBAK-TABIX = 0.
        IF US_ABHOD LT SY-DATLO.
          PERFORM MESSAGE_VARIABEL(SAPFV45L) USING 'V4'
                                             '146'
                                             RV45Z-MSGVS
                                             ' '
                                             SPACE
                                             SPACE
                                             SPACE
                                             SPACE.
        ENDIF.

        VBAK-VDATU = US_ABHOD.
        PERFORM DATUM_PRUEFEN_GUELTIGKEIT(SAPMV45A) USING VBAK-VDATU
                                                          VBAK-ANGDT
                                                          VBAK-GUEBG
                                                          VBAK-GUEEN.
        LOOP AT XVBEP WHERE UPDKZ NE UPDKZ_DELETE.
          EXIT.
        ENDLOOP.
        IF SY-SUBRC EQ 0.
          MESSAGE W637.
        ENDIF.
      ENDIF.
    ENDIF.

    CHECK US_ABHOV NE *VBAK-ABHOV OR
          US_ABHOB NE *VBAK-ABHOB.

    IF US_ABHOV GT US_ABHOB.
      SET CURSOR FIELD 'VBAK-ABHOV'.
      MESSAGE E635.
* Die Von-Uhrzeit ist größer als die Bis-Uhrzeit
    ELSEIF US_ABHOV EQ US_ABHOB.
      SET CURSOR FIELD 'VBAK-ABHOV'.
      IF SY-BINPT EQ CHARX OR
         SY-BATCH EQ CHARX.
        MESSAGE I771.
      ELSE.
        MESSAGE W771.
* Von- und Bis-Uhrzeit sollten nicht gleich sein
      ENDIF.
    ENDIF.

    IF ( US_ABHOV EQ SPACE AND NOT
         US_ABHOB EQ SPACE OR
         US_ABHOB EQ SPACE AND NOT
         US_ABHOV EQ SPACE ).
      SET CURSOR FIELD 'VBAK-ABHOV'.
      MESSAGE E636.
*    Bitte pflegen Sie die Uhrzeiten vollständig
    ENDIF.
  ELSE.
* auf dem Kopierpopup - aber erst, wenn die Belegnummer sitzt und nur
* dann, wenn die Felder eingabebereit sind - ist vbak-abhod gefüllt,
* sind die Felder zu
    CHECK VBAK-ABHOD IS INITIAL.
    IF NOT US_VBELN IS INITIAL.
      IF US_ABHOD IS INITIAL.
        SET CURSOR FIELD 'LV45C-ABHOD'.
        MESSAGE E785.
*   Ohne Abholdatum ist eine Weiterverarbeitung nicht möglich
      ENDIF.

      IF NOT US_ABHOD IS INITIAL AND
             US_ABHOD LT SY-DATLO.
        SET CURSOR FIELD 'LV45C-ABHOD'.
        IF SY-BINPT EQ CHARX OR
           SY-BATCH EQ CHARX.
          PERFORM MESSAGE_VARIABEL(SAPFV45L) USING 'V4'
                                             '146'
                                             RV45Z-MSGVS
                                             'X'
                                             SPACE
                                             SPACE
                                             SPACE
                                             SPACE.
        ELSE.
          PERFORM MESSAGE_VARIABEL(SAPFV45L) USING 'V4'
                                             '146'
                                             RV45Z-MSGVS
                                             ' '
                                             SPACE
                                             SPACE
                                             SPACE
                                             SPACE.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ( US_ABHOV EQ SPACE OR
       US_ABHOB EQ SPACE ).
      SET CURSOR FIELD 'LV45C-ABHOV'.
      MESSAGE E636.
*    Bitte pflegen Sie die Uhrzeiten vollständig
    ENDIF.

    CHECK: ( NOT US_ABHOV EQ SPACE OR
             NOT US_ABHOB EQ SPACE ) AND
             NOT US_VBELN IS INITIAL.

    IF US_ABHOV GT US_ABHOB.
      SET CURSOR FIELD 'LV45C-ABHOV'.
      MESSAGE E635.
* Die Von-Uhrzeit ist größer als die Bis-Uhrzeit
    ELSEIF US_ABHOV EQ US_ABHOB.
      SET CURSOR FIELD 'LV45C-ABHOV'.
      IF SY-BINPT EQ CHARX OR
         SY-BATCH EQ CHARX.
        MESSAGE I771.
      ELSE.
        MESSAGE W771.
* Von- und Bis-Uhrzeit sollten nicht gleich sein
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.                               " ABHOLFENSTER_PRUEFEN