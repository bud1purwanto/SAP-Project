*----------------------------------------------------------------------*
*   INCLUDE MV45AF0T_TCSPF_SELECT                                      *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  TCSPF_SELECT
*&---------------------------------------------------------------------*
*       Tabelle zur Ermittlung des Cross-Selling Profils wird gelesen
*----------------------------------------------------------------------*
FORM TCSPF_SELECT USING    US_VKORG
                           US_VTWEG
                           US_SPART
                           US_CSKSM
                           US_CSBSM
                  CHANGING CH_CRSPL.

  CLEAR CH_CRSPL.
  CHECK: US_VKORG NE TCSPF-VKORG OR
         US_VTWEG NE TCSPF-VTWEG OR
         US_SPART NE TCSPF-SPART OR
         US_CSKSM NE TCSPF-CSKSM OR
         US_CSBSM NE TCSPF-CSBSM.

  CLEAR TCSPF.

  SELECT SINGLE * FROM TCSPF WHERE VKORG = US_VKORG
                               AND VTWEG = US_VTWEG
                               AND SPART = US_SPART
                               AND CSKSM = US_CSKSM
                               AND CSBSM = US_CSBSM.
  IF SY-SUBRC EQ 0.
    CH_CRSPL = TCSPF-CRSPL.
  ELSE.
    CLEAR TCSP.
  ENDIF.

ENDFORM.                               " TCSPF_SELECT