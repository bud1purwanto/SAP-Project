*---------------------------------------------------------------------*
*       FORM TVAKZ_SELECT                                             *
*---------------------------------------------------------------------*
*       Ist die Auftragsart erlaubt ?                                 *
*---------------------------------------------------------------------*
FORM TVAKZ_SELECT USING US_VKORG
                        US_VTWEG
                        US_SPART
                        US_AUART
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.

* Performance
  CHECK: US_VKORG NE TVAKZ-VKORG OR
         US_VTWEG NE TVAKZ-VTWEG OR
         US_SPART NE TVAKZ-SPART OR
         US_AUART NE TVAKZ-AUART.
* Wenn ja: Gibt es den Eintrag zur angegebenen Auftragsart?
  SELECT SINGLE * FROM TVAKZ WHERE VKORG = US_VKORG
                               AND VTWEG = US_VTWEG
                               AND SPART = US_SPART
                               AND AUART = US_AUART.
  IF SY-SUBRC NE 0.
    CLEAR TVAKZ.
    IF US_ERROR = CHARX.
      MESSAGE E022(VT) WITH US_AUART US_VKORG US_VTWEG US_SPART.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.