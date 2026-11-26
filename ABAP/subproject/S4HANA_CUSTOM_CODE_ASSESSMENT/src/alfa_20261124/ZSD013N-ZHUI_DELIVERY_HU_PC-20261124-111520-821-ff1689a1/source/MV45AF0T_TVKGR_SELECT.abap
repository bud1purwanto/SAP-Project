*eject
*---------------------------------------------------------------------*
*       FORM TVKGR_SELECT                                             *
*---------------------------------------------------------------------*
*       Verkäufergruppe   lesen                                       *
*---------------------------------------------------------------------*
FORM TVKGR_SELECT USING US_VKGRP
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VKGRP NE TVKGR-VKGRP.

  IF US_VKGRP = SPACE.
    CLEAR: TVKGR, TVGRT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVKGR WHERE VKGRP = US_VKGRP.
  IF SY-SUBRC NE 0.
    CLEAR: TVKGR, TVGRT.
    IF US_ERROR NE SPACE.
      MESSAGE E317 WITH US_VKGRP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.