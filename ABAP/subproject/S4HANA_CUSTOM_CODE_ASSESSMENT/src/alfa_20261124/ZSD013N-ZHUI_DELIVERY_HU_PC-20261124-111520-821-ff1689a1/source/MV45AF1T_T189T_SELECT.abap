*eject
*---------------------------------------------------------------------*
*       FORM T189T_SELECT                                             *
*---------------------------------------------------------------------*
*       Preislistentyp mit Text lesen                                 *
*---------------------------------------------------------------------*
FORM T189T_SELECT USING US_PLTYP
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_PLTYP NE T189T-PLTYP.

  IF US_PLTYP = SPACE.
    CLEAR: T189T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T189T WHERE SPRAS = SY-LANGU
                               AND PLTYP = US_PLTYP.
  IF SY-SUBRC NE 0.
    CLEAR: T189T.
    IF US_ERROR NE SPACE.
      MESSAGE E422 WITH US_PLTYP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.