*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TVSAKT_SELECT                                     *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  TVSAKT_SELECT
*&---------------------------------------------------------------------*
*       Special Processing Indicator: Texts Check
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TVSAKT_SELECT USING US_SDABW
                         US_ERROR
                         CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_SDABW NE TVSAKT-SDABW.

  IF US_SDABW = SPACE.
    CLEAR: TVSAKT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVSAKT WHERE SPRAS = SY-LANGU
                                AND SDABW = US_SDABW.

  IF SY-SUBRC NE 0.
    CLEAR TVSAKT.
  ENDIF.

ENDFORM.                    " TVSAKT_SELECT



















