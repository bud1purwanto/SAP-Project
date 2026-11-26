*eject
*---------------------------------------------------------------------*
*       FORM TVKBZ_SELECT                                             *
*---------------------------------------------------------------------*
*       Verkaufsbürozuordnung lesen                                   *
*---------------------------------------------------------------------*
FORM TVKBZ_SELECT USING US_VKORG
                        US_VTWEG
                        US_SPART
                        US_VKBUR
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VKORG NE TVKBZ-VKORG OR
         US_VTWEG NE TVKBZ-VTWEG OR
         US_SPART NE TVKBZ-SPART OR
         US_VKBUR NE TVKBZ-VKBUR.

  IF US_VKBUR = SPACE.
    CLEAR: TVKBZ.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVKBZ WHERE VKBUR = US_VKBUR AND
                                   VKORG = US_VKORG AND
                                   VTWEG = US_VTWEG AND
                                   SPART = US_SPART.
  IF SY-SUBRC NE 0.
    CLEAR: TVKBZ, TVBUR, TVKBT.
    IF US_ERROR NE SPACE.
      SET CURSOR FIELD 'VBAK-VKBUR' LINE SY-STEPL.
      MESSAGE E051 WITH US_VKBUR US_VKORG US_VTWEG US_SPART.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.