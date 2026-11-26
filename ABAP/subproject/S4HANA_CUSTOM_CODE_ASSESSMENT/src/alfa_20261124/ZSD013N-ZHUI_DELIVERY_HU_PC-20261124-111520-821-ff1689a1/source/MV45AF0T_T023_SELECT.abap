*---------------------------------------------------------------------*
*       FORM T023_SELECT                                              *
*---------------------------------------------------------------------*
*       Warengruppe  lesen                                            *
*---------------------------------------------------------------------*
FORM T023_SELECT USING US_MATKL
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MATKL NE T023-MATKL.

  IF US_MATKL = SPACE.
    CLEAR: T023T, T023.
    EXIT.
  ENDIF.
  SELECT SINGLE * FROM T023 WHERE MATKL = US_MATKL.
  IF SY-SUBRC NE 0.
    CLEAR: T023, T023T.
    IF US_ERROR NE SPACE.
      MESSAGE E582 WITH US_MATKL.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.