*----------------------------------------------------------------------*
***INCLUDE MV45AF0T_TEXT_CONTROL_XTHEAD_A .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TEXT_CONTROL_XTHEAD_AUFBAUEN
*&---------------------------------------------------------------------*
*       Die Kopfzeile der XTHEAD wird für den Text Control eingestellt *
*       Ist die XTHEAD noch nicht vorhanden, so wird sie aufgebaut     *
*----------------------------------------------------------------------*
*      <-- CH_SUBRC
*----------------------------------------------------------------------*
FORM TEXT_CONTROL_XTHEAD_AUFBAUEN CHANGING CH_SUBRC.

  CLEAR CH_SUBRC.

  DO 2 TIMES.
* Sind passende XTHEAD Einträge vorhanden?
    LOOP AT XTHEAD WHERE TDID = TVAK-TDID
                     AND TDOBJECT = 'VBBK'
                     AND ( TDSPRAS = SY-LANGU OR
                           TDSPRAS = SPACE OR
                           TDSPRAS = CHAR* )
                     AND UPDKZ NE UPDKZ_DELETE.
* Ist der zugehörige ITHEAD-Eintrag da?
      READ TABLE ITHEAD WITH KEY TDOBJECT = XTHEAD-TDOBJECT
                                 TDID     = XTHEAD-TDID
                                 TDSPRAS  = XTHEAD-TDSPRAS.
      CH_SUBRC = SY-SUBRC.
    ENDLOOP.
* Beides vorhanden, dann DO-Schleife verlassen.
    IF SY-SUBRC EQ 0 AND CH_SUBRC = 0.
      EXIT.
    ENDIF.
* Nicht beides vorhanden: Fcode_Ktex baut die XTHEAD auf
    PERFORM FCODE_KTEX.
    SY-SUBRC = 1.
  ENDDO.

  CH_SUBRC = SY-SUBRC.
* Nur weiter, wenn Eintrag noch nicht gefunden
  CHECK CH_SUBRC NE 0.

  LOOP AT XTHEAD WHERE TDID = TVAK-TDID
                   AND TDOBJECT = 'VBBK'
                   AND UPDKZ NE UPDKZ_DELETE.
  ENDLOOP.
  CH_SUBRC = SY-SUBRC.
* Nur weiter, wenn IRGENDEIN Eintrag zur Text-ID vorhanden
  CHECK CH_SUBRC EQ 0.

* Neuen Eintrag aufnehmen
  XTHEAD-TDSPRAS = SY-LANGU.
  CLEAR: XTHEAD-TDREFID,
         XTHEAD-TDREFOBJ,
         XTHEAD-TDREFNAME.
  THEAD = XTHEAD.
  PERFORM XTHEAD_ANLEGEN(SAPFV45T).

ENDFORM.                               " TEXT_CONTROL_XTHEAD_AUFBAUEN