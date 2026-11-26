*---------------------------------------------------------------------*
*       FORM TCURC_SELECT                                             *
*---------------------------------------------------------------------*
*       Währung mit Text lesen                                        *
*---------------------------------------------------------------------*
FORM TCURC_SELECT USING US_WAERS
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_WAERS NE TCURC-WAERS.

  IF US_WAERS = SPACE.
    CLEAR: TCURC.
    EXIT.
  ENDIF.


  SELECT SINGLE * FROM TCURC WHERE WAERS = US_WAERS.
  IF SY-SUBRC NE 0.
    CLEAR: TCURC.
    IF US_ERROR NE SPACE.
      MESSAGE E438 WITH US_WAERS.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.