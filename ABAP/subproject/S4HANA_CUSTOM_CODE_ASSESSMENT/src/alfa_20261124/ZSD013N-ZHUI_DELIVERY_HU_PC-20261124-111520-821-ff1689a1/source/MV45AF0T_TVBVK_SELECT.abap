*eject
*---------------------------------------------------------------------*
*       FORM TVBVK_SELECT                                             *
*---------------------------------------------------------------------*
*       Verkäufergruppenzuordnung lesen                               *
*---------------------------------------------------------------------*
FORM TVBVK_SELECT USING US_VKBUR
                        US_VKGRP
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VKBUR NE TVBVK-VKBUR OR
         US_VKGRP NE TVBVK-VKGRP.
  IF US_VKGRP = SPACE.
    CLEAR: TVKGR, TVGRT, TVBVK.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVBVK WHERE VKBUR = US_VKBUR
                               AND VKGRP = US_VKGRP.
  IF SY-SUBRC NE 0.
    CLEAR: TVKGR, TVGRT, TVBVK.
    IF US_ERROR NE SPACE.
      SET CURSOR FIELD 'VBAK-VKGRP' LINE SY-STEPL.
      MESSAGE E052 WITH US_VKGRP US_VKBUR.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.