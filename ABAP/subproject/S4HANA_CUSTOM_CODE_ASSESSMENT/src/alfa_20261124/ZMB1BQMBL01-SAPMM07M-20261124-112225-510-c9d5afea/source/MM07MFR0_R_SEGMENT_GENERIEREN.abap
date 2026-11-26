*---------------------------------------------------------------------*
*       FORM R-SEGMENT_GENERIEREN                                     *
*---------------------------------------------------------------------*
*       Die Reservierungen werden zum Buchen aufbereitet.             *
*---------------------------------------------------------------------*
FORM r-segment_generieren.

  CHECK NOT xmseg-rsnum IS INITIAL and xmseg-xauto is initial.
  DATA: BEGIN OF mres,
           rsnum LIKE mseg-rsnum,
           rspos LIKE mseg-rspos,
        END OF mres.
  mres-rsnum = xmseg-rsnum.
  mres-rspos = xmseg-rspos.
  READ TABLE xmres WITH KEY mres BINARY SEARCH.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e001 WITH 'XMRES' mres-rsnum mres-rspos.
  ENDIF.
  IF xmseg-shkzg = s.
    IF zdm07m-rshkz = s.
      xmres-enwrt = xmres-enwrt + xmseg-dmbtr.
    ELSE.
      xmres-enwrt = xmres-enwrt - xmseg-dmbtr.
    ENDIF.
  ELSE.
    IF zdm07m-rshkz = s.
      xmres-enwrt = xmres-enwrt - xmseg-dmbtr.
    ELSE.
      xmres-enwrt = xmres-enwrt + xmseg-dmbtr.
    ENDIF.
  ENDIF.
  MODIFY xmres INDEX sy-tabix.
  MOVE-CORRESPONDING xmres TO xmcmres.
  APPEND xmcmres.

ENDFORM.