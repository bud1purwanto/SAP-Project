*----------------------------------------------------------------------*
*       FORM NACHRICHTEN_POSITION                                      *
*----------------------------------------------------------------------*
*       Nachrichtenfindung über alle Positionen                        *
*----------------------------------------------------------------------*
FORM NACHRICHTEN_POSITION.

  CHECK XVBAK_UPDKZ NE UPDKZ_DELETE.
  CHECK T185F-TRTYP NE CHARA.
  CHECK NO_MESSAGES EQ SPACE.

* Kommunikationsblock Kopf neu aufbauen
  READ TABLE XVBKD INDEX 1.
  NA_VBKD = XVBKD.
  CALL FUNCTION 'COMMUNICATION_AREA_KOMKBV1'
       EXPORTING MSG_VBAK  = VBAK
                 MSG_VBKD  = NA_VBKD
                 MSG_VBUK  = VBUK
                 MSG_TRTYP = T180-TRTYP
       TABLES    TAB_VBPA  = XVBPA
                 TAB_VBAP  = XVBAP
                 TAB_PART  = PART.
  LOOP AT XVBAP WHERE UPDKZ NE UPDKZ_DELETE
                  AND PVPOS IS INITIAL.
* Tuning
    PERFORM TVAP_SELECT(SAPMV45A) USING XVBAP-PSTYV
                                        SPACE
                                        SY-SUBRC.
    CHECK TVAP-KALSM NE SPACE.

    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
* Objektkey aufbauen
    MOVE  VBAK-VBELN TO XOBJKY_POS.
    WRITE VBAP-POSNR TO XOBJKY_POS+10.
* Kommunikationsblock aufbauen
    VBUP = XVBUP.
    CALL FUNCTION 'COMMUNICATION_AREA_KOMPBV1'
         EXPORTING MSG_VBAP = VBAP
                   MSG_VBKD = VBKD
                   MSG_VBUP = VBUP
* EHS environment
                   msg_VBAK = VBAK
         TABLES    TAB_VBPA = XVBPA
                   TAB_PART = PART.
    IF T185F-TRTYP = CHARV.
      IF XVBAP-UPDKZ = CHARU.
ENHANCEMENT-POINT NACHRICHTEN_POSITION_01 SPOTS ES_SAPMV45A.
* Kommunikationsblock alt aufbauen
        PERFORM YVBAP_LESEN(SAPFV45P) USING XVBAP-POSNR SY-TABIX.
        VBAP = YVBAP.
        PERFORM YVBKD_LESEN(SAPFV45K) USING XVBAP-POSNR SY-TABIX ' '.
        IF SY-SUBRC = 0.
          VBKD = YVBKD.
        ELSE.
          VBKD-POSNR = 0.
          PERFORM YVBKD_LESEN(SAPFV45K) USING VBKD-POSNR SY-TABIX ' '.
          IF SY-SUBRC = 0.
            VBKD = YVBKD.
          ELSE.
            READ TABLE XVBKD INDEX 1.
            VBKD = XVBKD.
          ENDIF.
        ENDIF.
        YVBUP-MANDT = VBAK-MANDT.
        YVBUP-VBELN = VBAK-VBELN.
        YVBUP-POSNR = VBAP-POSNR.
        READ TABLE YVBUP.
        IF SY-SUBRC = 0.
          VBUP = YVBUP.
        ENDIF.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'COMMUNICATION_AREA_KOMPBV1'
         EXPORTING MSG_OLD  = 'X'
                   MSG_VBAP = VBAP
                   MSG_VBKD = VBKD
                   MSG_VBUP = VBUP
         TABLES    TAB_VBPA = XVBPA
                   TAB_PART = PART.
* Nachrichtenfindung durchführen
    CALL FUNCTION 'MESSAGING'
         EXPORTING APPLIKATION = TVAK-KAPPL
                   MSG_OBJKY   = XOBJKY_POS
                   SCHEMA      = TVAP-KALSM
                   PI_OBJTYPE  = BUSINESSOBJEKT_POS
                   PI_ITEM     = CHARX
         TABLES    MSG_PART    = PART.
  ENDLOOP.

ENDFORM.