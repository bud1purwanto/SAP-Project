*eject
*---------------------------------------------------------------------*
*       FORM TFACD_SELECT                                             *
*---------------------------------------------------------------------*
*       Fabrikkalenderdefinitionen lesen                              *
*---------------------------------------------------------------------*
FORM TFACD_SELECT USING US_IDENT
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_IDENT NE TFACD-IDENT.

  IF US_IDENT = SPACE.
    CLEAR: TFACD.
    EXIT.
  ENDIF.


  SELECT SINGLE * FROM TFACD WHERE IDENT = US_IDENT.
  IF SY-SUBRC NE 0.
    CLEAR: TFACD.
    IF US_ERROR NE SPACE.
      MESSAGE E826 WITH US_IDENT.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.


ENDFORM.