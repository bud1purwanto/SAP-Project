*----------------------------------------------------------------------*
*   INCLUDE MV45AF0M_MAKT_SELECT                                       *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MAKT_SELECT
*&---------------------------------------------------------------------*
*
*       Material Descriptions Check
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAKT_SELECT USING US_TRMTYP
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_TRMTYP NE MAKT-MATNR.

  IF US_TRMTYP = SPACE.
    CLEAR: MAKT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM MAKT WHERE SPRAS = SY-LANGU
                              AND MATNR = US_TRMTYP.

  IF SY-SUBRC NE 0.
    CLEAR MAKT.
  ENDIF.


ENDFORM.                    " MAKT_SELECT



















