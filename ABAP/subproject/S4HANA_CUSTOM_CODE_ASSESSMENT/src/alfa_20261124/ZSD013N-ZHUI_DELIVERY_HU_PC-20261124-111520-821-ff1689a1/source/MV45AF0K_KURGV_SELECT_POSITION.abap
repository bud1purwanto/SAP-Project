*---------------------------------------------------------------------*
*       FORM KURGV_SELECT_POSITION                                     *
*---------------------------------------------------------------------*
*       Der Regulierer wird je Position nachgelesen, da sich die      *
*       Sparte in den Positionen ändern kann.                         *
*---------------------------------------------------------------------*
FORM KURGV_SELECT_POSITION USING US_POSNR
                                 US_SPART
                                 US_WKLND
                                 US_LLAND.

  LOCAL: KURGV-KKBER,
         KURGV-KNKLI,
         KURGV-KLIMK,
         KURGV-SAUFT,
         KURGV-SKFOR,
         KURGV-SSOBL,
         KURGV-WAERS.

  PERFORM XVBPA_LESEN(SAPFV45K) USING 'RG'
                                      US_POSNR
                                      XVBPA_AKTIND.

  IF XVBPA-PARVW EQ 'RG'.
    IF NOT XVBPA-ADRNR IS INITIAL AND
       XVBPA-ADRNR = XVBADR-ADRNR.
      KURGV-NAME1 = XVBADR-NAME1.
      KURGV-ORT01 = XVBADR-ORT01.
      PERFORM KURGV-TXTPA_ERMITTELN.
    ENDIF.
    IF VTCOMRG-KUNNR NE XVBPA-KUNNR OR
       VTCOMRG-VKORG NE VBAK-VKORG OR
       VTCOMRG-VTWEG NE VBAK-VTWEG OR
       VTCOMRG-ALAND NE US_WKLND OR
       VTCOMRG-LLAND NE US_LLAND OR
       VTCOMRG-SPART NE US_SPART OR
       VTCOMRG-ADRNR NE XVBPA-ADRNR OR
       KURGV-KUNNR IS INITIAL.
      CLEAR VTCOMRG.
      VTCOMRG-VKORG = VBAK-VKORG.
      VTCOMRG-VTWEG = VBAK-VTWEG.
      VTCOMRG-SPART = US_SPART.
      VTCOMRG-ALAND = US_WKLND.
      VTCOMRG-LLAND = US_LLAND.
      VTCOMRG-KUNNR = XVBPA-KUNNR.
      IF VBAK-VKORG NE SPACE.
        PERFORM TVKO_SELECT USING VBAK-VKORG
                                  CHARX
                                  SY-SUBRC.
      ENDIF.
*     VTCOMRG-KKBER = T001-KKBER.
      VTCOMRG-ADRNR = XVBPA-ADRNR.

      IF VTCOMRG-KUNNR CN '0 '.        "wg. Fehlerprotokoll
        CALL FUNCTION 'VIEW_KURGV'
             EXPORTING
                  COMWA   = VTCOMRG
             IMPORTING
                  RGWA    = KURGV
             EXCEPTIONS
                  NO_KNVV = 1.
        IF SY-SUBRC = 1.
          CLEAR VTCOMRG.
          MESSAGE E196(VP) WITH SY-MSGV1
                                SY-MSGV2
                                SY-MSGV3
                                SY-MSGV4.
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