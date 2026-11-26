*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TCSP_SELECT                                       *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  TCSP_SELECT
*&---------------------------------------------------------------------*
*       Tabelle zum Cross-Selling Profil wird gelesen
*----------------------------------------------------------------------*
FORM TCSP_SELECT USING    US_CRSPL
                          US_ERROR
                 CHANGING CH_SUBRC.

  CH_SUBRC = 0.
  CHECK US_CRSPL NE TCSP-CRSPL.

  SELECT SINGLE * FROM TCSP WHERE CRSPL = US_CRSPL.
  IF SY-SUBRC NE 0.
    CLEAR TCSP.
    IF US_ERROR NE SPACE.
      MESSAGE E101(WVA) WITH US_CRSPL.
    ELSE.
      MESSAGE I101(WVA) WITH US_CRSPL.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.                               " TCSP_SELECT



























