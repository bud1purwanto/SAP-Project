*eject
*---------------------------------------------------------------------*
*       FORM TVSBT_SELECT                                              *
*---------------------------------------------------------------------*
*       Versandbedingung mit Text lesen                               *
*---------------------------------------------------------------------*
FORM TVSBT_SELECT USING US_VSBED
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VSBED NE TVSBT-VSBED.

  IF US_VSBED = SPACE.
    CLEAR: TVSBT.
    EXIT.
  ENDIF.


  SELECT SINGLE * FROM TVSBT WHERE SPRAS = SY-LANGU
                               AND VSBED = US_VSBED.

  IF SY-SUBRC NE 0.
    CLEAR: TVSBT.
    IF US_ERROR = CHARX.
      MESSAGE E015 WITH US_VSBED.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.