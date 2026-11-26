*---------------------------------------------------------------------*
*       FORM KURGV_SELECT_XVBPA                                        *
*---------------------------------------------------------------------*
*       Regulierer aus Partnertabelle lesen                           *
*---------------------------------------------------------------------*
FORM KURGV_SELECT_XVBPA.

  LOCAL: KURGV-KKBER,
         KURGV-KNKLI,
         KURGV-KLIMK,
         KURGV-SAUFT,
         KURGV-SKFOR,
         KURGV-SSOBL.

* umgestellt, da im Kopf kein Regulierer sein muß
  PERFORM XVBPA_LESEN(SAPFV45K) USING 'RG'
                                      POSNR_LOW
                                      XVBPA_AKTIND.
  IF XVBPA-PARVW EQ 'RG'.
    IF NOT XVBPA-ADRNR IS INITIAL AND
       XVBPA-ADRNR = XVBADR-ADRNR.
      KURGV-ADRNR = XVBPA-ADRNR.
      KURGV-NAME1 = XVBADR-NAME1.
      KURGV-ORT01 = XVBADR-ORT01.
      PERFORM KURGV-TXTPA_ERMITTELN.
    ENDIF.
    IF VTCOMRG-KUNNR NE XVBPA-KUNNR OR
       VTCOMRG-VKORG NE VBAK-VKORG OR
       VTCOMRG-VTWEG NE VBAK-VTWEG OR
       VTCOMRG-SPART NE VBAK-SPART.
* Regulierer gefunden
      CLEAR VTCOMRG.
      VTCOMRG-KUNNR = XVBPA-KUNNR.
      VTCOMRG-VKORG = VBAK-VKORG.
      VTCOMRG-VTWEG = VBAK-VTWEG.
      VTCOMRG-SPART = VBAK-SPART.
      VTCOMRG-VBOBJ = CHARA.
      VTCOMRG-VBTYP = TVAK-VBTYP.
      IF VBAK-VKORG NE SPACE.
        PERFORM TVKO_SELECT USING VBAK-VKORG
                                  CHARX
                                  SY-SUBRC.
      ENDIF.
*     VTCOMRG-KKBER = T001-KKBER.
      IF VTCOMRG-KUNNR CN '0 '.        "wg. Fehlerprotokoll
        CALL FUNCTION 'VIEW_KURGV'
             EXPORTING
                  COMWA  = VTCOMRG
             IMPORTING
                  RGWA   = KURGV
             EXCEPTIONS
                  OTHERS = 1.
        IF SY-SUBRC <> 0.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
        IF NOT XVBPA-ADRNR IS INITIAL AND
           XVBPA-ADRNR = XVBADR-ADRNR.
          KURGV-NAME1 = XVBADR-NAME1.
          KURGV-ORT01 = XVBADR-ORT01.
        ENDIF.
        PERFORM KURGV-TXTPA_ERMITTELN.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.