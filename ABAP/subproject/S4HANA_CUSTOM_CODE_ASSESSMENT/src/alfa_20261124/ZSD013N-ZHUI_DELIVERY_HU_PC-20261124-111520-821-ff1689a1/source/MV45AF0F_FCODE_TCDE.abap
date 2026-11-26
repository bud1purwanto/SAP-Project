*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_TCDE                                        *
*----------------------------------------------------------------------*

FORM FCODE_TCDE.

  DATA: DA_THEAD LIKE THEADVB,
        DA_RC LIKE SY-SUBRC.
  CONSTANTS: LARGE VALUE '2'.          " Größe des Popups

* Kann das Text-Popup gesendet werden?
  IF NOT SY-BINPT IS INITIAL OR
     NOT SY-BATCH IS INITIAL.
    EXIT.
  ENDIF.

* Text in die Kopfzeile der XTHEAD stellen (falls vorhanden)
  PERFORM TEXT_CONTROL_XTHEAD_AUFBAUEN CHANGING DA_RC.

  IF DA_RC EQ 0.
    MOVE XTHEAD TO DA_THEAD.
    CALL FUNCTION 'SD_TEXT_DISPLAY'
         EXPORTING
              I_TDOBJECT        = 'VBBK'
              I_TDID            = TVAK-TDID
              I_TDNAME          = XTHEAD-TDNAME
              I_TDSPRAS         = SY-LANGU
              I_SHOW_EMPTY_TEXT = CHARX
              I_SIZE            = LARGE
         TABLES
              FXTHEAD           = XTHEAD
         EXCEPTIONS
              TEXT_NOT_FOUND    = 1
              OTHERS            = 2.
    LOOP AT XTHEAD WHERE TDOBJECT = 'VBBK' AND
                         TDID     = TVAK-TDID AND
                         ( TDSPRAS  = SY-LANGU  OR
                           TDSPRAS CO ' *' )  AND
                         UPDKZ   NE UPDKZ_DELETE.
    ENDLOOP.
* Wurde Text entsperrt oder gelöscht?
    IF SY-SUBRC NE 0 OR
       XTHEAD-TDSPRAS CO ' *' OR
       ( XTHEAD-TDREFOBJ    IS INITIAL AND
         XTHEAD-TDREFID     IS INITIAL AND
         XTHEAD-TDREFNAME   IS INITIAL ).
* Eingabebereitschaft des Text Edit Control setzen
      CLEAR TEXT_CONTROL_REFERIERT.
      TEXT_CONTROL_READY_FOR_INPUT = CHARX.
    ENDIF.
  ELSE.
* ... wenn Text nicht in der XTHEAD gefunden
    CLEAR TEXT_CONTROL_AVAILABLE.
    MESSAGE I248(VC) WITH TVAK-TDID TVAK-TXTGR.
  ENDIF.
ENDFORM.