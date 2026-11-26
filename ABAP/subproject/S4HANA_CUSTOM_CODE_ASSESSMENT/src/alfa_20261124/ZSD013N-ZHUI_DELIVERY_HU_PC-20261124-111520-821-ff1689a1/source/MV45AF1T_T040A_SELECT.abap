*eject
*---------------------------------------------------------------------*
*       FORM T040A_SELECT                                             *
*---------------------------------------------------------------------*
*       Mahnschlüssel Text                                            *
*---------------------------------------------------------------------*
FORM T040A_SELECT USING US_MSCHL
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MSCHL NE T040A-MSCHL.

  IF US_MSCHL = SPACE.
    CLEAR: T040A.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T040A WHERE MSCHL = US_MSCHL
                               AND SPRAS = SY-LANGU.
  IF SY-SUBRC NE 0.
    CLEAR: T040A.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.