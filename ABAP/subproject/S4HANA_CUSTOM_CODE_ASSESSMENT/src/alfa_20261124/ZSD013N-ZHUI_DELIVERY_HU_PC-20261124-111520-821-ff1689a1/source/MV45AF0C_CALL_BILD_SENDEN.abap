*---------------------------------------------------------------------*
*       FORM CALL_BILD_SENDEN                                         *
*---------------------------------------------------------------------*
*       Temporär: zum Aufruf von Call-Bildern mittels der Folge-      *
*                 bildsteuerung (Stand: 6.11.90 v.Helmolt)            *
*---------------------------------------------------------------------*
*       USING-Parameter: Fenster-Koordinaten + CUA-Parameter          *
*---------------------------------------------------------------------*
FORM CALL_BILD_SENDEN USING DYNPRO LEAVE
                                   WINX1
                                   WINY1
                                   WINX2
                                   WINY2
                                   STATUS
                                   CTITEL
                                   PARA1
                                   PARA2
                                   PARA3
                                   PARA4
                                   DUNKEL
                                   FOLGEFCODE.

  MOVE: LEAVE      TO T185V-LEAVE,
        STATUS     TO T185V-STATUS,
        CTITEL     TO T185V-CTITEL,
        PARA1      TO T185V-PARA1,
        PARA2      TO T185V-PARA2,
        PARA3      TO T185V-PARA3,
        PARA4      TO T185V-PARA4,
        DUNKEL     TO T185-DUNKEL,
        FOLGEFCODE TO FCODE.


  IF WINX2 NE 0 AND WINY2 NE 0.
    CALL SCREEN DYNPRO STARTING AT WINX1 WINY1
                         ENDING AT WINX2 WINY2.
  ELSE.
    CALL SCREEN DYNPRO.
  ENDIF.

  MOVE: FCODE TO FOLGEFCODE.

ENDFORM.