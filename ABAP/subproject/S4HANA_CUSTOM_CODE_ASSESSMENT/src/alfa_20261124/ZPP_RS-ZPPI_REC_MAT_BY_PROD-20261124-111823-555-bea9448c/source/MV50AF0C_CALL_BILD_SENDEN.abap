*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CALL_BILD_SENDEN                                  *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM CALL_BILD_SENDEN                                         *
*---------------------------------------------------------------------*
*       Temporär: zum Aufruf von Call-Bildern mittels der Folge-      *
*                 bildsteuerung (Stand: 6.11.90 v.Helmolt)            *
*---------------------------------------------------------------------*
*       USING-Parameter: Fenster-Koordinaten + CUA-Parameter          *
*---------------------------------------------------------------------*
FORM call_bild_senden USING dynpro      like t185v-dynnr
                            leave       LIKE t185v-leave
                            winx1       LIKE t185v-winx1
                            winy1       LIKE t185v-winy1
                            winx2       LIKE t185v-winx2
                            winy2       LIKE t185v-winy2
                            status      LIKE t185v-status
                            ctitel      LIKE t185v-ctitel
                            para1       LIKE t185v-para1
                            para2       LIKE t185v-para2
                            para3       LIKE t185v-para3
                            para4       LIKE t185v-para4
                            dunkel      LIKE t185-dunkel
                            folgefcode  LIKE fcode.

  MOVE: leave      TO t185v-leave,
        status     TO t185v-status,
        ctitel     TO t185v-ctitel,
        para1      TO t185v-para1,
        para2      TO t185v-para2,
        para3      TO t185v-para3,
        para4      TO t185v-para4,
        dunkel     TO t185-dunkel,
        folgefcode TO fcode.

  CALL SCREEN dynpro STARTING AT winx1 winy1
                       ENDING AT winx2 winy2.

  MOVE: fcode TO folgefcode.

ENDFORM.                    "CALL_BILD_SENDEN