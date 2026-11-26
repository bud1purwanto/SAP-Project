*eject
*&---------------------------------------------------------------------*
*&      Form  T683C_SELECT
*&---------------------------------------------------------------------*
*       Suchschema zur Chargenfindung ermitteln                        *
*----------------------------------------------------------------------*
FORM T683C_SELECT USING US_VKORG
                        US_VTWEG
                        US_SPART
                        US_AUART
                        US_ERROR
                        US_SUBRC.

  DATA: DA_HILFSTEXT(10).

  US_SUBRC = 0.
  CHECK: US_VKORG NE T683C-VKORG OR
         US_VTWEG NE T683C-VTWEG OR
         US_SPART NE T683C-SPART OR
         US_AUART NE T683C-AUART.


  SELECT SINGLE * FROM T683C WHERE VKORG = US_VKORG
                               AND VTWEG = US_VTWEG
                               AND SPART = US_SPART
                               AND AUART = US_AUART.

  IF SY-SUBRC <> 0.
    CLEAR T683C.
    MOVE US_VKORG TO DA_HILFSTEXT.
    MOVE US_VTWEG TO DA_HILFSTEXT+5.
    MOVE US_SPART TO DA_HILFSTEXT+8.
    IF US_ERROR NE SPACE.
      MESSAGE E279 WITH DA_HILFSTEXT US_AUART.
    ELSE.
*     MESSAGE I279 WITH DA_HILFSTEXT US_AUART.
      US_SUBRC = 279.
    ENDIF.
  ENDIF.

ENDFORM.                               " T683C_SELECT