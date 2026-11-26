*eject
*---------------------------------------------------------------------*
*       FORM TPRIT_SELECT                                             *
*---------------------------------------------------------------------*
*       Lieferpriorität  prüfen                                       *
*---------------------------------------------------------------------*
FORM TPRIT_SELECT USING US_LPRIO
                        US_ERROR
                        CH_SUBRC.

  STATICS: DA_BEZEI LIKE TPRIT-BEZEI.

  CH_SUBRC = 0.

  IF US_LPRIO = SPACE.
    CLEAR: TPRIT.
    EXIT.
  ENDIF.

  IF US_LPRIO EQ TPRIT-LPRIO.
    TPRIT-BEZEI = DA_BEZEI.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TPRIT WHERE SPRAS = SY-LANGU AND
                                   LPRIO = US_LPRIO.

  IF SY-SUBRC NE 0.
    CLEAR TPRIT.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      MESSAGE E074 WITH US_LPRIO.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ELSE.
    DA_BEZEI = TPRIT-BEZEI.
  ENDIF.

ENDFORM.