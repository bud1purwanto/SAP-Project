*&---------------------------------------------------------------------*
*&      Form  T691M_SELECT
*&---------------------------------------------------------------------*
*       Absicherungsschema ermitteln                                   *
*----------------------------------------------------------------------*
FORM T691M_SELECT USING US_ABSSC
                        US_ERROR
                        US_SUBRC.

  US_SUBRC = 0.

  CHECK: US_ABSSC NE T691M-ABSSC.

  IF US_ABSSC = SPACE.
    CLEAR: T691M, T691N.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T691M WHERE ABSSC = US_ABSSC.

  IF SY-SUBRC <> 0.
    CLEAR: T691M, T691N.
    IF US_ERROR NE SPACE.
      MESSAGE E835 WITH US_ABSSC.
    ELSE.
      US_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.                               " T683C_SELECT