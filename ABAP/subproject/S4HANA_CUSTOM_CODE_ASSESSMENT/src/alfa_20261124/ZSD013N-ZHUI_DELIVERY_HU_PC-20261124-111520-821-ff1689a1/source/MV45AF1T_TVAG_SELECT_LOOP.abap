*eject
*---------------------------------------------------------------------*
*       FORM TVAG_SELECT_LOOP                                         *
*---------------------------------------------------------------------*
*       In Loopzeilen muss der Text des Absagegrundes pro Zeile       *
*       gelesen werden (PBO).                                         *
*---------------------------------------------------------------------*
FORM TVAG_SELECT_LOOP USING US_ABGRU.

  CLEAR: TVAG, TVAGT.

  PERFORM TVAGT_SELECT USING US_ABGRU
                             SPACE
                             SY-SUBRC.

ENDFORM.