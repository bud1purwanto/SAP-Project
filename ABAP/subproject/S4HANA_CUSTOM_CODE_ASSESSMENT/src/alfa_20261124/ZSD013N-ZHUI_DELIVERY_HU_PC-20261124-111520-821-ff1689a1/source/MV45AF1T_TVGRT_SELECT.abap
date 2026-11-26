*eject
*---------------------------------------------------------------------*
*       FORM TVGRT_SELECT                                             *
*---------------------------------------------------------------------*
*       Verkäufergruppe   lesen                                       *
*---------------------------------------------------------------------*
FORM TVGRT_SELECT USING US_VKGRP
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VKGRP NE TVGRT-VKGRP.

  IF US_VKGRP = SPACE.
    CLEAR: TVGRT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVGRT WHERE VKGRP = US_VKGRP
                               AND SPRAS = SY-LANGU.
  IF SY-SUBRC NE 0.
    CLEAR: TVGRT.
    IF US_ERROR NE SPACE.
      MESSAGE E317 WITH US_VKGRP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.