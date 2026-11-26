*---------------------------------------------------------------------*
*       FORM TVKWZ_SELECT                                             *
*---------------------------------------------------------------------*
*       Verkaufsorganisationen-Werke-Zuordnung prüfen                 *
*---------------------------------------------------------------------*
FORM TVKWZ_SELECT USING US_VKORG
                        US_VTWEG
                        US_WERKS
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  IF US_VKORG IS INITIAL AND
     US_VTWEG IS INITIAL.
    CLEAR TVKWZ.
    EXIT.
  ENDIF.
  CHECK: US_VKORG NE TVKWZ-VKORG OR
         US_VTWEG NE TVKWZ-VTWEG OR
         US_WERKS NE TVKWZ-WERKS.

  SELECT SINGLE * FROM TVKWZ WHERE VKORG = US_VKORG
                               AND VTWEG = US_VTWEG
                               AND WERKS = US_WERKS.

  IF SY-SUBRC NE 0.
    CLEAR TVKWZ.
*   In CSFG case we might deal with an external plant.
    DO 1 TIMES.
      SELECT SINGLE * FROM T001W_EXT WHERE WERKS = US_WERKS
                                       AND VKORG = US_VKORG
                                       AND VTWEG = US_VTWEG.
      CHECK SY-SUBRC NE 0.
      IF US_ERROR = CHARX.
*       Internal Error Handling
        MESSAGE E369 WITH US_VKORG
                          US_VTWEG
                          US_WERKS.
      ELSE.
*       External Error Handling
        CH_SUBRC = SY-SUBRC.
      ENDIF.
    ENDDO.
  ENDIF.

ENDFORM.