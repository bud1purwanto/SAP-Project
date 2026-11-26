*eject
*---------------------------------------------------------------------*
*       FORM T179_SELECT                                              *
*---------------------------------------------------------------------*
*       Produkthierarchie lesen                                       *
*---------------------------------------------------------------------*
FORM T179_SELECT USING US_PRODH
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_PRODH NE T179-PRODH.

  IF US_PRODH = SPACE.
    CLEAR: T179, T179T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T179 WHERE PRODH = US_PRODH.
  IF SY-SUBRC NE 0.
    CLEAR: T179, T179T.
    IF US_ERROR NE SPACE.
      MESSAGE E411 WITH US_PRODH.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.