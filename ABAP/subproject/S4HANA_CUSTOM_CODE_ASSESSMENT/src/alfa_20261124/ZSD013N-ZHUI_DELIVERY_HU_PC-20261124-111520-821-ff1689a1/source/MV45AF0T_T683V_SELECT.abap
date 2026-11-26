*EJECT
*---------------------------------------------------------------------*
*       FORM T683V_SELECT                                             *
*---------------------------------------------------------------------*
*       Die Tabelle zur Kalkulationsschemaermittlung wird gelesen     *
*---------------------------------------------------------------------*
FORM T683V_SELECT USING US_KALVG
                        US_KALKS
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK MODIFICATION_FLAG-NO_PRICING IS INITIAL.
  CHECK: US_KALVG NE T683V-KALVG OR
         US_KALKS NE T683V-KALKS OR
         VBAK-VKORG NE T683V-VKORG OR
         VBAK-VTWEG NE T683V-VTWEG OR
         VBAK-SPART NE T683V-SPART.

  SELECT SINGLE * FROM T683V WHERE VKORG = VBAK-VKORG
                               AND VTWEG = VBAK-VTWEG
                               AND SPART = VBAK-SPART
                               AND KALVG = TVAK-KALVG
                               AND KALKS = KUAGV-KALKS.
  IF SY-SUBRC NE 0.
    CLEAR T683V.
* WE löschen wenn es zum AG keine Kalkulationsschema gibt. Dieser muss
* neu ermittelt werden sobald der gültige AG eingegeben wurde
    IF SAVE-WE IS INITIAL.
      CLEAR KUWEV.
    ENDIF.
    DATA: DA_HILFSTEXT(10).
    MOVE TVKO-VKORG TO DA_HILFSTEXT.
    MOVE TVTW-VTWEG TO DA_HILFSTEXT+5.
    MOVE VBAK-SPART TO DA_HILFSTEXT+8.
    IF US_ERROR NE SPACE.
      CLEAR XVBAK-AGUPDA.
      MESSAGE E212 WITH DA_HILFSTEXT US_KALVG US_KALKS.
    ELSE.
* Damit bei VA52 keine Meldung kommt
      IF NOT KUAGV-KUNNR IS INITIAL.
        MESSAGE I212 WITH DA_HILFSTEXT US_KALVG US_KALKS.
      ENDIF.
      CH_SUBRC = 212.
    ENDIF.
  ENDIF.

ENDFORM.