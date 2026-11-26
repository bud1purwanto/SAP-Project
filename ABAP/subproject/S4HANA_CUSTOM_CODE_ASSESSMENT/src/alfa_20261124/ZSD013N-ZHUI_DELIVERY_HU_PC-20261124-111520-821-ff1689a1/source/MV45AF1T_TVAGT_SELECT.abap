*eject
*---------------------------------------------------------------------*
*       FORM TVAGT_SELECT                                             *
*---------------------------------------------------------------------*
*       Absagegrund mit Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVAGT_SELECT USING US_ABGRU
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_ABGRU = SPACE.
    CLEAR: TVAGT.
    EXIT.
  ENDIF.
* Im Absagegrund-Steploop-Bild wird im Pai TVAGT-Text wieder gesetzt,
* nicht aber der Key.
  CHECK: US_ABGRU NE TVAGT-ABGRU.

  SELECT SINGLE * FROM TVAGT WHERE SPRAS = SY-LANGU
                               AND ABGRU = US_ABGRU.
  IF SY-SUBRC NE 0.
    CLEAR: TVAGT.
    IF US_ERROR NE SPACE.
      MESSAGE E416 WITH US_ABGRU.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.