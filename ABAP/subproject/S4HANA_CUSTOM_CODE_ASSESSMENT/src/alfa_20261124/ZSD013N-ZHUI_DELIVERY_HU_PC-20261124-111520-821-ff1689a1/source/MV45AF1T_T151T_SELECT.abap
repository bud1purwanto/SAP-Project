*eject
*---------------------------------------------------------------------*
*       FORM T151T_SELECT                                              *
*---------------------------------------------------------------------*
*       Kundengruppe mit Text lesen                                   *
*---------------------------------------------------------------------*
FORM T151T_SELECT USING US_KDGRP
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KDGRP NE T151T-KDGRP.

  IF US_KDGRP = SPACE.
    CLEAR: T151T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T151T WHERE SPRAS = SY-LANGU
                               AND KDGRP = US_KDGRP.
  IF SY-SUBRC NE 0.
    CLEAR: T151T.
    IF US_ERROR NE SPACE.
      MESSAGE E418 WITH US_KDGRP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.