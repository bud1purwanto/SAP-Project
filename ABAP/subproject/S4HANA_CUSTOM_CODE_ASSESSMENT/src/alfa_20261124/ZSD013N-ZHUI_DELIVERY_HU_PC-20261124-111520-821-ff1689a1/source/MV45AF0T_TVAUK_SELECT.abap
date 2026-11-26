*---------------------------------------------------------------------*
*       FORM TVAUK_SELECT                                             *
*---------------------------------------------------------------------*
*       Kostenstelle zum Auftragsgrund lesen                          *
*---------------------------------------------------------------------*
FORM TVAUK_SELECT USING US_VKORG
                        US_VTWEG
                        US_SPART
                        US_AUGRU
                        US_ERROR
                        CH_SUBRC.

  DATA: DA_SUBRC.
  CH_SUBRC = 0.
  CHECK: US_AUGRU NE TVAUK-AUGRU OR
         US_VTWEG NE TVAUK-VTWEG OR
         US_SPART NE TVAUK-SPART OR
         US_VKORG NE TVAUK-VKORG.
  IF US_AUGRU = SPACE.
    CLEAR: TVAUK.
    EXIT.
  ENDIF.

  DA_SUBRC = 4.
  SELECT * FROM TVAUK WHERE VKORG = US_VKORG
                        AND VTWEG = US_VTWEG
                        AND SPART = US_SPART
                        AND AUGRU = US_AUGRU
                        AND DATAB <= SY-DATLO
                        ORDER BY PRIMARY KEY.
    DA_SUBRC = 0.
  ENDSELECT.
  IF DA_SUBRC NE 0.
    CLEAR: TVAUK.
    IF US_ERROR NE SPACE.
      SET CURSOR FIELD 'VBAK-AUGRU' LINE SY-STEPL.
      MESSAGE E050 WITH US_AUGRU US_VKORG.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.