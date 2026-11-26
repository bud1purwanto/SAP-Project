*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TVTYT_SELECT                                      *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  TVTYT_SELECT
*&---------------------------------------------------------------------*
*       Shipping Material Types: Designations Check
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TVTYT_SELECT USING US_TRATY
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_TRATY NE TVTYT-TRATY.

  IF US_TRATY = SPACE.
    CLEAR: TVTYT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVTYT WHERE SPRAS = SY-LANGU
                               AND TRATY = US_TRATY.

  IF SY-SUBRC NE 0.
    CLEAR TVTYT.
  ENDIF.

ENDFORM.                    " TVTYT_SELECT



















