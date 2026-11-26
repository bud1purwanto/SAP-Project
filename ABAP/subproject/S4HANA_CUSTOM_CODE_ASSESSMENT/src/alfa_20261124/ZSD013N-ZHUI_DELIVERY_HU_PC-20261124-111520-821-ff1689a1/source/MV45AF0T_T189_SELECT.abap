*---------------------------------------------------------------------*
*       FORM T189_SELECT                                              *
*---------------------------------------------------------------------*
*       Preislistentyp lesen                                          *
*---------------------------------------------------------------------*
FORM T189_SELECT USING US_PLTYP
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_PLTYP NE T189-PLTYP.

  IF US_PLTYP = SPACE.
    CLEAR: T189, T189T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T189 WHERE PLTYP = US_PLTYP.
  IF SY-SUBRC NE 0.
    CLEAR: T189, T189T.
    IF US_ERROR NE SPACE.
      MESSAGE E421 WITH US_PLTYP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.