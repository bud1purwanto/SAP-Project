*eject
*---------------------------------------------------------------------*
*       FORM T151_SELECT                                              *
*---------------------------------------------------------------------*
*       Kundengruppe lesen                                            *
*---------------------------------------------------------------------*
FORM T151_SELECT USING US_KDGRP
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KDGRP NE T151-KDGRP.

  IF US_KDGRP = SPACE.
    CLEAR: T151T, T151.
    EXIT.
  ENDIF.
  SELECT SINGLE * FROM T151 WHERE KDGRP = US_KDGRP.
  IF SY-SUBRC NE 0.
    CLEAR: T151, T151T.
    IF US_ERROR NE SPACE.
      MESSAGE E417 WITH US_KDGRP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.