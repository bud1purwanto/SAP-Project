*---------------------------------------------------------------------*
*       FORM TVAK_SELECT                                              *
*---------------------------------------------------------------------*
*       Auftragsartentabelle lesen                                    *
*---------------------------------------------------------------------*
FORM TVAK_SELECT USING US_AUART
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_AUART NE TVAK-AUART.

  SELECT SINGLE * FROM TVAK WHERE AUART = US_AUART.

  IF SY-SUBRC NE 0.
    CLEAR: TVAK, TVAKT.
    IF US_ERROR = CHARX.
      MESSAGE E312 WITH US_AUART.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.
* Dynamisch Schlüsselwörter und Texte setzen
  PERFORM SCHLUESSELWORTE_SETZEN USING TVAK-TRVOG.

ENDFORM.